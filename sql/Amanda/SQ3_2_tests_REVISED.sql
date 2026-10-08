-- SQ3 validation checks (Amanda)
-- Revised from original: invalid 'copied reviews' inference replaced by factual bounds/keys check.
-- This script needs v_reception, v_sq4_analysis and detailed rating tables.
WITH tests AS (
 SELECT 1 AS nr,'Exactly one active rule set' AS test,
  (SELECT COUNT(*) FROM classification_thresholds WHERE is_active)::TEXT AS observed,
  (SELECT COUNT(*)=1 FROM classification_thresholds WHERE is_active) AS ok
 UNION ALL SELECT 2,'One row per movie in v_reception',
  (SELECT COUNT(*)||' rows / '||COUNT(DISTINCT movie_id)||' movies' FROM v_reception),
  (SELECT COUNT(*)=COUNT(DISTINCT movie_id) FROM v_reception)
 UNION ALL SELECT 3,'Category dummy variables sum to 1',
  (SELECT COUNT(*) FROM v_reception
   WHERE is_controversial+is_positive+is_negative+is_normal<>1)::TEXT,
  (SELECT COUNT(*)=0 FROM v_reception
   WHERE is_controversial+is_positive+is_negative+is_normal<>1)
 UNION ALL SELECT 4,'C-score is between 0 and 1',
  (SELECT MIN(c_score)||' to '||MAX(c_score) FROM v_reception),
  (SELECT MIN(c_score)>=0 AND MAX(c_score)<=1 FROM v_reception)
 UNION ALL SELECT 5,'Detailed review scores within expected 0-100 range',
  (SELECT COUNT(*) FROM (
    SELECT score FROM user_rating_detailed UNION ALL SELECT score FROM expert_rating_detailed
   ) scores WHERE score IS NULL OR score<0 OR score>100)::TEXT||' invalid scores',
  (SELECT COUNT(*)=0 FROM (
    SELECT score FROM user_rating_detailed UNION ALL SELECT score FROM expert_rating_detailed
   ) scores WHERE score IS NULL OR score<0 OR score>100)
 UNION ALL SELECT 6,'Critic mean and metascore positively correlate (r > 0.8)',
  (SELECT ROUND(CORR(c.critic_mean,o.metascore)::numeric,3)::TEXT
   FROM v_controversy c JOIN overall_rating o USING(movie_id)),
  (SELECT CORR(c.critic_mean,o.metascore)>0.8
   FROM v_controversy c JOIN overall_rating o USING(movie_id))
 UNION ALL SELECT 7,'One row per movie in v_sq4_analysis',
  (SELECT COUNT(*)||' rows / '||COUNT(DISTINCT movie_id)||' movies' FROM v_sq4_analysis),
  (SELECT COUNT(*)=COUNT(DISTINCT movie_id) FROM v_sq4_analysis)
)
SELECT 'SQ3 tests' AS query,nr,test,observed,
 CASE WHEN ok THEN 'PASS' WHEN NOT ok THEN 'FAIL' ELSE 'NOT EVALUATED' END AS result
FROM tests ORDER BY nr;
