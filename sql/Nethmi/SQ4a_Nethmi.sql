-- SQ4a (H1 and H2)
-- H1: higher mean critic score  -> higher worldwide box-office revenue
-- H2: higher viewer review count -> higher worldwide box-office revenue
-- One row per film. Mean critic score and viewer review count are the SQ1 measures.
-- Revenue comes from movie -> movie_sales -> sales_final.
--
-- ASSUMED NAMES (adjust if your schema differs):
--   expert_rating(movie_id, review_id, score)
--   user_rating(movie_id, review_id, score)
--   movie_sales(movie_id, sales_id)
--   sales_final(sales_id, worldwide_box_office)


-- 1. Diagnostic: films with more than one sales match
--    (the introduction document says a small number have two).
--    Look at these before deciding the rule below.
SELECT ms.movie_id, m.title, COUNT(DISTINCT ms.sales_id) AS sales_match_count
FROM movie_sales ms
JOIN movie m ON m.movie_id = ms.movie_id
GROUP BY ms.movie_id, m.title
HAVING COUNT(DISTINCT ms.sales_id) > 1;


-- 2. Analysis view for H1 and H2
CREATE VIEW sq4a_h1_h2 AS
WITH expert_agg AS (
    SELECT movie_id,
           COUNT(*)   AS critic_review_count,
           AVG(score) AS mean_critic_score          -- H1 predictor (0-100)
    FROM expert_rating
    GROUP BY movie_id
),
user_agg AS (
    SELECT movie_id,
           COUNT(DISTINCT review_id) AS viewer_review_count   -- H2 predictor
    FROM user_rating
    GROUP BY movie_id
),
sales_agg AS (
    SELECT ms.movie_id,
           COUNT(DISTINCT ms.sales_id)      AS sales_match_count,
           MAX(s.worldwide_box_office)     AS worldwide_box_office
    FROM movie_sales ms
    JOIN sales s ON s.sales_id = ms.sales_id
    GROUP BY ms.movie_id
    HAVING COUNT(DISTINCT ms.sales_id) = 1
)
SELECT m.movie_id,
       m.title,
       s.worldwide_box_office,
       LN(1 + s.worldwide_box_office)       AS log_revenue,         
       e.mean_critic_score,
       e.critic_review_count,
       COALESCE(u.viewer_review_count, 0)   AS viewer_review_count
FROM movie m
JOIN sales_agg s        ON s.movie_id = m.movie_id
LEFT JOIN expert_agg e  ON e.movie_id = m.movie_id
LEFT JOIN user_agg u    ON u.movie_id = m.movie_id
WHERE s.worldwide_box_office IS NOT NULL;


-- how many films survive each restriction
SELECT COUNT(*)                                                         AS films_with_sales,
       COUNT(*) FILTER (WHERE mean_critic_score IS NOT NULL)            AS films_for_h1,
       COUNT(*) FILTER (WHERE viewer_review_count > 0)                  AS films_for_h2,
       COUNT(*) FILTER (WHERE mean_critic_score IS NOT NULL
                          AND viewer_review_count > 0)                  AS films_for_both
FROM sq4a_h1_h2;


-- 4. H1 descriptive: revenue by critic-score band (currency units kept)
SELECT FLOOR(mean_critic_score / 20) * 20  AS critic_band_start,
       COUNT(*)                            AS n_films,
       AVG(worldwide_box_office)           AS avg_revenue,
       MIN(worldwide_box_office)           AS min_revenue,
       MAX(worldwide_box_office)           AS max_revenue
FROM sq4a_h1_h2
WHERE mean_critic_score IS NOT NULL
GROUP BY FLOOR(mean_critic_score / 20) * 20
ORDER BY critic_band_start;


-- 5. H2 descriptive: revenue by viewer-review-count quartile
SELECT review_quartile,
       COUNT(*)                     AS n_films,
       MIN(viewer_review_count)     AS min_reviews,
       MAX(viewer_review_count)     AS max_reviews,
       AVG(worldwide_box_office)    AS avg_revenue,
       MIN(worldwide_box_office)    AS min_revenue,
       MAX(worldwide_box_office)    AS max_revenue
FROM (
    SELECT viewer_review_count, worldwide_box_office,
           NTILE(4) OVER (ORDER BY viewer_review_count) AS review_quartile
    FROM sq4a_h1_h2
    WHERE viewer_review_count > 0
) q
GROUP BY review_quartile
ORDER BY review_quartile;
