"""Real PostgreSQL/Python checks. Integration.
Read-only except threshold tests on an explicitly named disposable test database.
"""
import argparse, contextlib, hashlib, io, json, os, sys
from datetime import datetime, timezone
from pathlib import Path
import pandas as pd
import sqlparse
from sqlalchemy import text
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'python/shared'))
from movie_db import MovieDB

METHODS=['SQ1_descriptive_stats','SQ2_controversy_score','SQ3_get_reception',
'SQ3_get_classification','SQ3_threshold_sensitivity','SQ3_viewer_polarity',
'SQ4_controversy_revenue_evaluation','SQ4a_sample_counts',
'SQ4a_critic_bands','SQ4a_viewer_quartiles']

def run(output, private, allow_threshold=False):
 output.mkdir(parents=True,exist_ok=True);private.mkdir(parents=True,exist_ok=True)
 checks=[];frames={};exports=[]
 def check(name,condition,observed):
  checks.append({'test':name,'passed':bool(condition),'observed':observed})
 with MovieDB() as db:
  version=db._query('SELECT version() AS version').iloc[0,0]
  for m in METHODS:
   df=getattr(db,m)();frames[m]=df
   check(m+' returns nonempty DataFrame',isinstance(df,pd.DataFrame) and not df.empty,{'rows':len(df),'columns':list(df.columns)})
   path=private/(m+'.csv');df.to_csv(path,index=False);reread=pd.read_csv(path)
   check(m+' CSV round trip',len(reread)==len(df) and list(reread.columns)==list(df.columns),len(reread))
   exports.append({'file':path.name,'rows':len(df),'sha256':hashlib.sha256(path.read_bytes()).hexdigest()})
  manifest=json.loads((ROOT/'data/manifest.json').read_text())
  for i in manifest:
   count=int(db._query('SELECT COUNT(*) AS n FROM '+i['table']).iloc[0,0]);check('Imported '+i['table'],count==i['rows'],count)
  reception=frames['SQ3_get_reception'];sq4=frames['SQ4_controversy_revenue_evaluation']
  check('Expected review-minimum population',len(reception)==5449,len(reception))
  check('Expected positive-revenue population',len(sq4)==4143,len(sq4))
  expected={'Controversial':4322,'Positive':709,'Normal':392,'Negative':26}
  observed={str(k):int(v) for k,v in reception.category.value_counts().items()}
  check('Categories match original CSV audit',observed==expected,observed)
  check('Unique movie per SQ3 and SQ4 row',reception.movie_id.is_unique and sq4.movie_id.is_unique,{'sq3':len(reception),'sq4':len(sq4)})
  check('SQ4 references SQ3 population',set(sq4.movie_id)<=set(reception.movie_id),len(sq4))
  check('SQ3 dummies sum to one',reception[['is_controversial','is_positive','is_negative','is_normal']].sum(axis=1).eq(1).all(),len(reception))
  filtered=db.SQ4_controversy_revenue_evaluation(only_with_budget=True)
  check('Budget filter',filtered.production_budget.gt(0).all(),len(filtered))
  nulls=db._query('SELECT COUNT(*) FILTER (WHERE score IS NULL) AS missing, COUNT(*) FILTER (WHERE score<0 OR score>100) AS invalid FROM expert_rating').iloc[0]
  check('Known missing critic scores explicitly recorded',int(nulls['missing'])==2,{'missing':int(nulls['missing']),'out_of_range':int(nulls['invalid'])})
  sample=db._query('SELECT * FROM sq4a_h1_h2')
  check('SQ4a unique movie rows',sample.movie_id.is_unique,len(sample))
  eligible=db._query("""SELECT COUNT(*) AS n FROM (
    SELECT ms.movie_id FROM movie_sales ms JOIN sales s USING(sales_id)
    GROUP BY ms.movie_id HAVING COUNT(DISTINCT ms.sales_id)=1
    AND MAX(s.worldwide_box_office) IS NOT NULL) q""").iloc[0,0]
  check('SQ4a sample matches its supplied sales restrictions',len(sample)==int(eligible),len(sample))
  counts=frames['SQ4a_sample_counts'].iloc[0]
  check('SQ4a H1 band population',int(frames['SQ4a_critic_bands'].n_films.sum())==int(counts.films_for_h1),int(counts.films_for_h1))
  check('SQ4a H2 quartile population',int(frames['SQ4a_viewer_quartiles'].n_films.sum())==int(counts.films_for_h2),int(counts.films_for_h2))
  sql_tests=db._query((ROOT/'sql/Amanda/SQ3_2_tests.sql').read_text());sql_tests.to_csv(output/'sql_integrity_tests.csv',index=False)
  for row in sql_tests.to_dict('records'):check('SQL: '+row['test'],row['result']=='PASS',row['observed'])
  if allow_threshold:
   if not os.getenv('PGDATABASE','').startswith('movies_codex_test_'):raise ValueError('Threshold checks require a disposable movies_codex_test_ database')
   original=db._query('SELECT threshold_set FROM classification_thresholds WHERE is_active').iloc[0,0]
   try:
    selected=db.SQ3_set_active_threshold('fixed_0.30');check('Threshold mutation',int(selected.is_active.sum())==1 and selected.loc[selected.is_active,'threshold_set'].iloc[0]=='fixed_0.30','fixed_0.30')
    try:db.SQ3_set_active_threshold('invalid-rule')
    except ValueError:check('Unknown threshold rejected',True,'ValueError')
    else:check('Unknown threshold rejected',False,'not rejected')
   finally:db.SQ3_set_active_threshold(original)
   check('Threshold restored',db._query('SELECT threshold_set FROM classification_thresholds WHERE is_active').iloc[0,0]==original,original)
  # Execute every published current SQL script, preserving actual text results.
  sql_files=['sql/Jonas/Query_Jonas_SQ1_V2.sql','sql/Amanda/SQ3a_classification.sql','sql/Amanda/SQ3b_sensitivity.sql','sql/Amanda/SQ3c_polarity.sql']
  with db.engine.connect() as conn:
   for filename in sql_files:
    with (private/(Path(filename).stem+'.txt')).open('w') as f:
     for statement in sqlparse.split((ROOT/filename).read_text()):
      if not sqlparse.format(statement,strip_comments=True).strip():continue
      rows=conn.execute(text(statement)).fetchall()
      f.write('Rows: '+str(len(rows))+'\n'+repr(rows[:20])+'\n')
    check('Executed SQL '+filename,True,'success')
  # Aggregate evidence suitable for public publication, omit example film names.
  for m in METHODS[3:]:
   if m=='SQ4_controversy_revenue_evaluation':continue
   frames[m].drop(columns=['clearest_examples'],errors='ignore').to_csv(output/(m+'.csv'),index=False)
 report={'executed_utc':datetime.now(timezone.utc).isoformat(),'database':os.getenv('PGDATABASE','movies_db'),'server_version':version,'checks':checks,'exports':exports,'passed':all(x['passed'] for x in checks),'limitations':['Two missing critic scores are retained; AVG/STDDEV ignore NULL, COUNT(*) includes reviews.','SQ4a keeps the supplied single-sales-match sample, without a five-review minimum. SQ4b is excluded.','Technical checks are agent-run; independent student verification remains required.']}
 (output/'integration_report.json').write_text(json.dumps(report,indent=2))
 print('Checks:',len(checks),'Passed:',sum(c['passed'] for c in checks),'Overall:',report['passed'])
 for c in checks:
  if not c['passed']:print('FAILED:',c)
 return report
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--output-dir',type=Path,required=True);p.add_argument('--private-export-dir',type=Path,required=True);p.add_argument('--test-threshold-update',action='store_true');a=p.parse_args()
 result=run(a.output_dir,a.private_export_dir,a.test_threshold_update);sys.exit(0 if result['passed'] else 1)
