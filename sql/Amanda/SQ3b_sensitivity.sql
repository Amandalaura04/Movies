-- SQ3b: does the classification change with other cut-offs? (E1)
-- Written by Amanda Luijendijk

WITH classified AS (
  SELECT t.threshold_set, t.c_cut, t.is_active,
         t.positive_min::INT || '/' || t.negative_max::INT AS pos_neg,
         c.movie_id,
         classify_reception(c.c_score, c.combined_mean, t.c_cut, t.positive_min, t.negative_max) AS category
  FROM v_controversy c
  CROSS JOIN classification_thresholds t),
compared AS (
  SELECT cl.*, r.category AS active_category
  FROM classified cl
  LEFT JOIN v_reception r ON r.movie_id = cl.movie_id)
SELECT 'SQ3b: sensitivity' AS query,
       threshold_set, c_cut, pos_neg, is_active,
       COUNT(*) AS n_movies,
       ROUND(100.0 * COUNT(*) FILTER (WHERE category = 'Controversial') / COUNT(*), 1) AS pct_controversial,
       ROUND(100.0 * COUNT(*) FILTER (WHERE category = 'Positive') / COUNT(*), 1) AS pct_positive,
       ROUND(100.0 * COUNT(*) FILTER (WHERE category = 'Normal') / COUNT(*), 1) AS pct_normal,
       ROUND(100.0 * COUNT(*) FILTER (WHERE category = 'Negative') / COUNT(*), 1) AS pct_negative,
       ROUND(100.0 * COUNT(*) FILTER (WHERE category = active_category) / COUNT(*), 1) AS pct_same_label_as_active
FROM compared
GROUP BY threshold_set, c_cut, pos_neg, is_active
ORDER BY c_cut, pos_neg;
