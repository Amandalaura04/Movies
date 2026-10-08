-- SQ3a: reception category per film group (SQ3, E1)
-- Written by Amanda Luijendijk

WITH ranked AS (
  SELECT category, title, c_score,
         ROW_NUMBER() OVER (
           PARTITION BY category
           ORDER BY CASE WHEN category = 'Controversial' THEN -c_score ELSE c_score END,
                    movie_id) AS rn
  FROM v_reception),
profile AS (
  SELECT threshold_set, category,
         COUNT(*) AS n_movies,
         ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_movies,
         ROUND(AVG(critic_mean)::numeric, 1) AS avg_critic,
         ROUND(AVG(viewer_mean)::numeric, 1) AS avg_viewer,
         ROUND(AVG(combined_mean)::numeric, 1) AS avg_combined,
         ROUND(AVG(d_between)::numeric, 3) AS avg_d,
         ROUND(AVG(vdisp)::numeric, 3) AS avg_vdisp,
         ROUND(AVG(edisp)::numeric, 3) AS avg_edisp,
         ROUND(AVG(c_score)::numeric, 3) AS avg_c
  FROM v_reception
  GROUP BY threshold_set, category
  HAVING COUNT(*) >= 5),
examples AS (
  SELECT category,
         STRING_AGG(title || ' (' || ROUND(c_score::numeric, 3) || ')', '; ' ORDER BY rn) AS clearest_examples
  FROM ranked
  WHERE rn <= 3
  GROUP BY category)
SELECT 'SQ3a: classification' AS query, p.*, e.clearest_examples
FROM profile p JOIN examples e USING (category)
ORDER BY p.n_movies DESC;
