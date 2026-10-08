-- SQ1: mean critic score, mean viewer score and number of reviews
-- Original SQ1 work: Jonas Breve
-- NOTE: Original SQL uses user_rating and expert_rating. Confirm actual PostgreSQL table names before execution.

-- Query 1: How many films are in the database?
SELECT COUNT(*) AS total_films FROM movie;

-- Query 2: How many films have viewer reviews, and how many have critic reviews?
SELECT COUNT(*) AS total_films,
       COUNT(u.user_count) AS with_viewer_reviews,
       COUNT(e.expert_count) AS with_critic_reviews
FROM movie AS m
LEFT JOIN (SELECT movie_id, COUNT(*) AS user_count FROM user_rating GROUP BY movie_id) AS u ON u.movie_id = m.movie_id
LEFT JOIN (SELECT movie_id, COUNT(*) AS expert_count FROM expert_rating GROUP BY movie_id) AS e ON e.movie_id = m.movie_id;

-- Query 3: films with at least 5 reviews in BOTH groups
SELECT COUNT(*) AS films_with_5_each
FROM (SELECT movie_id FROM user_rating GROUP BY movie_id HAVING COUNT(*) >= 5) AS u
JOIN (SELECT movie_id FROM expert_rating GROUP BY movie_id HAVING COUNT(*) >= 5) AS e ON e.movie_id = u.movie_id;

-- Query 4: films with review minima and box office revenue
SELECT COUNT(DISTINCT u.movie_id) AS films_with_reviews_and_sales
FROM (SELECT movie_id FROM user_rating GROUP BY movie_id HAVING COUNT(*) >= 5) AS u
JOIN (SELECT movie_id FROM expert_rating GROUP BY movie_id HAVING COUNT(*) >= 5) AS e ON e.movie_id = u.movie_id
JOIN movie_sales AS ms ON ms.movie_id = u.movie_id
JOIN sales AS s ON s.sales_id = ms.sales_id
WHERE s.worldwide_box_office IS NOT NULL;

-- Query 5: complete SQ1 result per film
SELECT m.movie_id, m.title, u.user_count, u.user_mean, u.user_sd,
       e.expert_count, e.expert_mean, e.expert_sd
FROM movie AS m
LEFT JOIN (
 SELECT movie_id, COUNT(*) AS user_count,
 ROUND(AVG(score)::numeric, 2) AS user_mean,
 ROUND(STDDEV_POP(score)::numeric, 2) AS user_sd
 FROM user_rating GROUP BY movie_id
) AS u ON u.movie_id = m.movie_id
LEFT JOIN (
 SELECT movie_id, COUNT(*) AS expert_count,
 ROUND(AVG(score)::numeric, 2) AS expert_mean,
 ROUND(STDDEV_POP(score)::numeric, 2) AS expert_sd
 FROM expert_rating GROUP BY movie_id
) AS e ON e.movie_id = m.movie_id
ORDER BY m.title;
