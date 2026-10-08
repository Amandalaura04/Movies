-- SQ4 setup | One analysis view with one row per film (input for SQ4a, SQ4b and Python)
-- Written by Amanda Luijendijk (Student ID: 500903801)
-- Requires SQ2_Nethmi.sql and SQ3_1_setup.sql

DROP VIEW IF EXISTS v_sq4_analysis;
CREATE VIEW v_sq4_analysis AS
WITH sales_ranked AS (
  SELECT ms.movie_id, s.*,
         COUNT(*) OVER (PARTITION BY ms.movie_id) AS n_sales_matches,
         -- some films match more than one sales row: prefer a row with revenue,
         -- then the year closest to the release year, then the highest revenue
         ROW_NUMBER() OVER (
           PARTITION BY ms.movie_id
           ORDER BY (s.worldwide_box_office IS NULL),
                    ABS(COALESCE(s.year, 0) - EXTRACT(YEAR FROM m.reldate)),
                    s.worldwide_box_office DESC NULLS LAST) AS rn
  FROM movie_sales ms
  JOIN sales s ON s.sales_id = ms.sales_id
  JOIN movie m       ON m.movie_id = ms.movie_id)
SELECT r.movie_id, r.title,
       EXTRACT(YEAR FROM m.reldate)::INT          AS release_year,
       r.category, r.is_controversial, r.is_positive, r.is_negative, r.is_normal,
       r.c_score, r.c_decile, r.d_between, r.vdisp, r.edisp,
       r.critic_mean, r.critic_n, r.viewer_mean, r.viewer_n, r.combined_mean,
       r.viewer_polarity,
       s.worldwide_box_office,
       LN(1 + s.worldwide_box_office)             AS ln_revenue,
       s.production_budget,
       LN(1 + s.production_budget)                AS ln_budget,
       s.theatre_count,
       s.n_sales_matches
FROM v_reception r
JOIN movie m          ON m.movie_id = r.movie_id
JOIN sales_ranked s   ON s.movie_id = r.movie_id AND s.rn = 1
WHERE s.worldwide_box_office > 0;

-- check: one row per film
SELECT COUNT(*) AS n_rows, COUNT(DISTINCT movie_id) AS n_movies,
       COUNT(production_budget) AS with_budget, COUNT(theatre_count) AS with_theatres,
       SUM((n_sales_matches > 1)::INT) AS films_with_multiple_sales_rows
FROM v_sq4_analysis;
