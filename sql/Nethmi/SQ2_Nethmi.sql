-- SQ2 controversy score
-- Original author: Nethmi Atapattu
-- Database naming / re-runnable-view adjustments: Amanda Luijendijk
-- Executed against supplied final CSVs; independent student review required.

CREATE OR REPLACE VIEW movie_controversy AS
WITH expert_stats AS (
    SELECT movie_id, COUNT(*) AS expert_count,
           AVG(score) AS expert_mean, STDDEV_POP(score) AS expert_sd
    FROM expert_rating_detailed
    GROUP BY movie_id HAVING COUNT(*) >= 5
), user_stats AS (
    SELECT movie_id, COUNT(*) AS user_count,
           AVG(score) AS user_mean, STDDEV_POP(score) AS user_sd
    FROM user_rating_detailed
    GROUP BY movie_id HAVING COUNT(*) >= 5
)
SELECT m.movie_id, m.title,
       e.expert_mean, e.expert_sd, e.expert_count,
       u.user_mean, u.user_sd, u.user_count,
       ABS(e.expert_mean-u.user_mean)/100.0 AS d_i,
       u.user_sd/50.0 AS udisp_i,
       e.expert_sd/50.0 AS edisp_i,
       (
        ABS(e.expert_mean-u.user_mean)/100.0
        +u.user_sd/50.0
        +e.expert_sd/50.0
       )/3.0 AS controversy_score
FROM movie m
JOIN expert_stats e ON m.movie_id=e.movie_id
JOIN user_stats u ON m.movie_id=u.movie_id;

SELECT * FROM movie_controversy;
SELECT AVG(d_i) AS avg_d_i, AVG(udisp_i) AS avg_udisp_i,
       AVG(edisp_i) AS avg_edisp_i,
       AVG(controversy_score) AS avg_controversy
FROM movie_controversy;
