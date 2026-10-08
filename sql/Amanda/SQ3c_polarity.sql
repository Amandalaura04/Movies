-- SQ3c | Are controversial movies really polarized? (Schoenmueller et al., 2020)
-- Written by Amanda Luijendijk (Student ID: 500903801)

SELECT 'SQ3c: polarity' AS query,
       category,
       COUNT(*) AS n_movies,
       ROUND(100 * AVG(viewer_polarity)::numeric, 1)  AS avg_pct_extreme_viewers,
       ROUND(100 * AVG(viewer_two_camps)::numeric, 1) AS avg_two_camps_pct,
       ROUND(100.0 * COUNT(*) FILTER (WHERE viewer_two_camps >= 0.25) / COUNT(*), 1) AS pct_movies_two_camps,
       NULL::NUMERIC AS corr_c_polarity   -- correlation only in the 'All movies' row
FROM v_reception
GROUP BY category
UNION ALL
SELECT 'SQ3c: polarity', 'All movies', COUNT(*),
       ROUND(100 * AVG(viewer_polarity)::numeric, 1),
       ROUND(100 * AVG(viewer_two_camps)::numeric, 1),
       ROUND(100.0 * COUNT(*) FILTER (WHERE viewer_two_camps >= 0.25) / COUNT(*), 1),
       ROUND(CORR(c_score, viewer_polarity)::numeric, 3)
FROM v_reception
ORDER BY n_movies DESC;
