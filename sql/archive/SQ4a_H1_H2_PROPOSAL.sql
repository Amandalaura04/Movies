-- Local proposal, not confirmed as the named student's final contribution.
-- SQ4a | H1 (critic score) and H2 (viewer review volume) vs worldwide revenue
-- Draft for Nethmi: adapt and add your own name and student ID

-- 1. Correlations: Pearson on log revenue and rank-based (Spearman via RANK)
WITH r AS (
  SELECT critic_mean, viewer_n, ln_revenue,
         (RANK() OVER (ORDER BY critic_mean) + (COUNT(*) OVER (PARTITION BY critic_mean) - 1) / 2.0) AS rk_critic,
         (RANK() OVER (ORDER BY viewer_n) + (COUNT(*) OVER (PARTITION BY viewer_n) - 1) / 2.0) AS rk_viewer,
         (RANK() OVER (ORDER BY ln_revenue) + (COUNT(*) OVER (PARTITION BY ln_revenue) - 1) / 2.0) AS rk_rev
  FROM v_sq4_analysis)
SELECT 'H1: critic score' AS hypothesis, COUNT(*) AS n_movies,
       ROUND(CORR(critic_mean, ln_revenue)::numeric, 3) AS pearson_log_revenue,
       ROUND(CORR(rk_critic, rk_rev)::numeric, 3)       AS spearman
FROM r
UNION ALL
SELECT 'H2: viewer review count', COUNT(*),
       ROUND(CORR(viewer_n, ln_revenue)::numeric, 3),
       ROUND(CORR(rk_viewer, rk_rev)::numeric, 3)
FROM r;

-- 2. Median revenue per quartile of critic score and of review volume
WITH q AS (
  SELECT worldwide_box_office,
         NTILE(4) OVER (ORDER BY critic_mean, movie_id) AS critic_q,
         NTILE(4) OVER (ORDER BY viewer_n, movie_id)    AS viewer_q
  FROM v_sq4_analysis)
SELECT 'H1: critic score quartile' AS grouping, critic_q AS quartile, COUNT(*) AS n_movies,
       ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY worldwide_box_office) / 1e6)::numeric, 1) AS median_revenue_mln
FROM q GROUP BY critic_q
UNION ALL
SELECT 'H2: review volume quartile', viewer_q, COUNT(*),
       ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY worldwide_box_office) / 1e6)::numeric, 1)
FROM q GROUP BY viewer_q
ORDER BY 1, 2;
