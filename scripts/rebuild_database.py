"""Rebuild into a NEW database only; Integration."""
import argparse, csv, hashlib, json, os
from pathlib import Path
import psycopg2
from psycopg2 import sql

ROOT = Path(__file__).resolve().parents[1]
SETUPS = ['sql/Nethmi/SQ2_Nethmi.sql', 'sql/Amanda/SQ3_1_setup.sql',
          'sql/Amanda/SQ4_setup_Amanda.sql', 'sql/Nethmi/SQ4a_Nethmi.sql']

def rebuild(data_dir, dbname):
    cfg = {'host':os.getenv('PGHOST','127.0.0.1'), 'port':os.getenv('PGPORT','5432')}
    for key,env in [('user','PGUSER'),('password','PGPASSWORD')]:
        if os.getenv(env): cfg[key]=os.environ[env]
    manifest=json.loads((ROOT/'data/manifest.json').read_text())
    # Check all files before creating a database.
    for item in manifest:
        p=data_dir/item['filename']
        if hashlib.sha256(p.read_bytes()).hexdigest()!=item['sha256']:
            raise ValueError('Data checksum mismatch: '+p.name)
        with p.open(newline='',encoding='utf-8-sig') as f:
            rows=csv.reader(f)
            if next(rows)!=item['columns'] or sum(1 for _ in rows)!=item['rows']:
                raise ValueError('Data layout/count mismatch: '+p.name)
    admin=psycopg2.connect(dbname='postgres',**cfg); admin.autocommit=True
    try:
        with admin.cursor() as cur:
            cur.execute('SELECT 1 FROM pg_database WHERE datname=%s',(dbname,))
            if cur.fetchone(): raise ValueError('Refusing to replace an existing database: '+dbname)
            cur.execute(sql.SQL('CREATE DATABASE {}').format(sql.Identifier(dbname)))
    finally: admin.close()
    conn=psycopg2.connect(dbname=dbname,**cfg)
    try:
        with conn, conn.cursor() as cur:
            cur.execute((ROOT/'sql/database/01_create_tables_PUBLIC.sql').read_text())
            for item in manifest:
                command=sql.SQL('COPY {} FROM STDIN WITH (FORMAT CSV, HEADER TRUE, ENCODING \'UTF8\')').format(sql.Identifier(item['table']))
                with (data_dir/item['filename']).open(encoding='utf-8') as f:
                    cur.copy_expert(command.as_string(conn),f)
                cur.execute(sql.SQL('SELECT COUNT(*) FROM {}').format(sql.Identifier(item['table'])))
                if cur.fetchone()[0]!=item['rows']:raise AssertionError('Import count mismatch')
            for filename in SETUPS:cur.execute((ROOT/filename).read_text())
        print('Imported 13 verified CSV files and created SQ2/SQ3/SQ4 objects:',dbname)
    finally:conn.close()

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--data-dir',type=Path,required=True);p.add_argument('--database',required=True)
    a=p.parse_args();rebuild(a.data_dir,a.database)
