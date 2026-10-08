-- Local proposal, not confirmed as the named student's final contribution.
-- Integration and tie corrections: Codex at Amanda request (AI-T2-01).
-- SQ4b | E2: does worldwide revenue differ by reception category and controversy level?
-- Draft for Jonas: adapt and add your own name and student ID

-- 1. Revenue distribution per reception category
SELECT category,
       COUNT(*) AS n_movies,
       ROUND((PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY worldwide_box_office) / 1e6)::numeric, 1) AS p25_mln,
       ROUND((PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY worldwide_box_office) / 1e6)::numeric, 1) AS median_mln,
       ROUND((PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY worldwide_box_office) / 1e6)::numeric, 1) AS p75_mln,
       ROUND(AVG(ln_revenue)::numeric, 2) AS mean_ln_revenue
FROM v_sq4_analysis
GROUP BY category
HAVING COUNT(*) >= 5
ORDER BY median_mln DESC;

-- 2. Median revenue per controversy quartile, with and without budget
WITH q AS (
  SELECT *, NTILE(4) OVER (ORDER BY c_score, movie_id) AS c_quartile FROM v_sq4_analysis)
SELECT c_quartile,
       ROUND(MIN(c_score)::numeric, 3) AS c_from, ROUND(MAX(c_score)::numeric, 3) AS c_to,
       COUNT(*) AS n_movies,
       ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY worldwide_box_office) / 1e6)::numeric, 1) AS median_revenue_mln,
       COUNT(*) FILTER (WHERE production_budget > 0) AS n_with_budget,
       ROUND(AVG(ln_revenue - ln_budget) FILTER (WHERE production_budget > 0)::numeric, 2) AS mean_log1p_revenue_minus_log1p_budget
FROM q
GROUP BY c_quartile
ORDER BY c_quartile;
