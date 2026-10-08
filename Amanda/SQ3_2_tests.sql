-- SQ3 data tests: every row should say PASS
-- Written by Amanda Luijendijk (Student ID: 500903801)

WITH t AS (
  SELECT 1 AS nr, 'Exactly one active rule set' AS test,
         (SELECT COUNT(*) FROM classification_thresholds WHERE is_active)::TEXT AS observed,
         (SELECT COUNT(*) FROM classification_thresholds WHERE is_active) = 1 AS ok
  UNION ALL
  SELECT 2, 'One row per movie in v_reception',
         (SELECT COUNT(*) || ' rows / ' || COUNT(DISTINCT movie_id) || ' movies' FROM v_reception),
         (SELECT COUNT(*) = COUNT(DISTINCT movie_id) FROM v_reception)
  UNION ALL
  SELECT 3, 'Every movie has exactly one label (dummies sum to 1)',
         (SELECT COUNT(*) FROM v_reception WHERE is_controversial + is_positive + is_negative + is_normal <> 1)::TEXT || ' violations',
         (SELECT COUNT(*) FROM v_reception WHERE is_controversial + is_positive + is_negative + is_normal <> 1) = 0
  UNION ALL
  SELECT 4, 'C-score lies between 0 and 1',
         (SELECT ROUND(MIN(c_score)::numeric,3) || ' to ' || ROUND(MAX(c_score)::numeric,3) FROM v_reception),
         (SELECT MIN(c_score) >= 0 AND MAX(c_score) <= 1 FROM v_reception)
  UNION ALL
  SELECT 5, 'Expert reviews are not copies of user reviews (same movie, score and date)',
         -- a copied table would repeat the same review rows, so count expert rows that also exist as user rows
         (SELECT ROUND(100.0 * AVG(copied::INT), 1) || '% of expert rows found in user reviews' FROM (
            SELECT EXISTS (SELECT 1 FROM user_rating u
                           WHERE u.movie_id = e.movie_id AND u.score = e.score
                             AND u.datep IS NOT DISTINCT FROM e.datep) AS copied
            FROM expert_rating e) x),
         (SELECT AVG(copied::INT) < 0.05 FROM (
            SELECT EXISTS (SELECT 1 FROM user_rating u
                           WHERE u.movie_id = e.movie_id AND u.score = e.score
                             AND u.datep IS NOT DISTINCT FROM e.datep) AS copied
            FROM expert_rating e) x)
  UNION ALL
  SELECT 6, 'Critic means follow the metascore (strong relation, r > 0.8)',
         -- the metascore is a weighted average of the same critic reviews, so it will not be identical
         -- to our simple mean, but the two should be strongly related
         (SELECT 'r = ' || ROUND(CORR(c.critic_mean, o.metascore)::numeric, 3) || ', mean abs diff = '
                 || ROUND(AVG(ABS(c.critic_mean - o.metascore))::numeric, 1)
            FROM v_controversy c JOIN overall_rating o USING (movie_id)),
         (SELECT CORR(c.critic_mean, o.metascore) > 0.8
            FROM v_controversy c JOIN overall_rating o USING (movie_id))
  UNION ALL
  SELECT 7, 'One row per movie in v_sq4_analysis (no double sales rows)',
         (SELECT COUNT(*) || ' rows / ' || COUNT(DISTINCT movie_id) || ' movies' FROM v_sq4_analysis),
         (SELECT COUNT(*) = COUNT(DISTINCT movie_id) FROM v_sq4_analysis)
)
SELECT 'SQ3 tests' AS query, nr, test, observed,
       CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END AS result
FROM t
ORDER BY nr;
