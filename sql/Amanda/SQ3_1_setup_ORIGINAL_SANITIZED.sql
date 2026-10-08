-- SQ3 setup: rule sets, classification function and views used by SQ3a-c
-- Original work: Amanda Luijendijk. Student number removed for public publishing.
-- Requires SQ2_Nethmi.sql (view movie_controversy).
-- IMPORTANT: drops/recreates SQ3 objects. Run on a test copy; executed on the fresh test database on 2026-10-08.

DROP VIEW IF EXISTS v_controversy CASCADE;
CREATE VIEW v_controversy AS
SELECT movie_id, title,
       expert_count AS critic_n, user_count AS viewer_n,
       expert_mean AS critic_mean, user_mean AS viewer_mean,
       d_i AS d_between, udisp_i AS vdisp, edisp_i AS edisp,
       controversy_score AS c_score,
       (expert_mean + user_mean) / 2.0 AS combined_mean
FROM movie_controversy;

DROP TABLE IF EXISTS classification_thresholds CASCADE;
CREATE TABLE classification_thresholds (
 threshold_set VARCHAR(20) PRIMARY KEY,
 c_cut NUMERIC(7,5) NOT NULL CHECK(c_cut BETWEEN 0 AND 1),
 positive_min NUMERIC(5,1) NOT NULL CHECK(positive_min BETWEEN 0 AND 100),
 negative_max NUMERIC(5,1) NOT NULL CHECK(negative_max BETWEEN 0 AND 100),
 is_active BOOLEAN NOT NULL DEFAULT FALSE,
 source VARCHAR(120) NOT NULL,
 CHECK(negative_max < positive_min)
);
INSERT INTO classification_thresholds
(threshold_set,c_cut,positive_min,negative_max,is_active,source) VALUES
('fixed_0.20',0.20,70,40,FALSE,'Lower cut-off'),
('fixed_0.25',0.25,70,40,TRUE,'Provisional rule (Task 1, 2.7)'),
('fixed_0.30',0.30,70,40,FALSE,'Higher cut-off'),
('val_65_45',0.25,65,45,FALSE,'Other valence boundaries');

INSERT INTO classification_thresholds
(threshold_set,c_cut,positive_min,negative_max,is_active,source)
SELECT 'p75',ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY c_score)::numeric,5),
70,40,FALSE,'Data-driven: 75th percentile of C'
FROM v_controversy;

CREATE OR REPLACE FUNCTION classify_reception(p_c NUMERIC,p_mean NUMERIC,p_cut NUMERIC,p_pos NUMERIC,p_neg NUMERIC)
RETURNS TEXT LANGUAGE sql IMMUTABLE AS $$
 SELECT CASE WHEN p_c >= p_cut THEN 'Controversial'
 WHEN p_mean >= p_pos THEN 'Positive'
 WHEN p_mean <= p_neg THEN 'Negative'
 ELSE 'Normal' END;
$$;

DROP VIEW IF EXISTS v_polarity CASCADE;
CREATE VIEW v_polarity AS
SELECT movie_id,
 AVG((score <= 20)::INT) AS viewer_share_low,
 AVG((score >= 80)::INT) AS viewer_share_high,
 AVG((score <= 20 OR score >= 80)::INT) AS viewer_polarity,
 LEAST(AVG((score <= 20)::INT),AVG((score >= 80)::INT)) AS viewer_two_camps
FROM user_rating_detailed GROUP BY movie_id;

DROP VIEW IF EXISTS v_reception CASCADE;
CREATE VIEW v_reception AS
WITH active AS (SELECT * FROM classification_thresholds WHERE is_active),
classified AS (
 SELECT c.*,a.threshold_set,
 classify_reception(c.c_score,c.combined_mean,a.c_cut,a.positive_min,a.negative_max) AS category
 FROM v_controversy c CROSS JOIN active a
)
SELECT cl.movie_id,cl.title,cl.threshold_set,
 cl.critic_n,cl.viewer_n,cl.critic_mean,cl.viewer_mean,
 cl.d_between,cl.vdisp,cl.edisp,cl.c_score,cl.combined_mean,cl.category,
 (cl.category='Controversial')::INT AS is_controversial,
 (cl.category='Positive')::INT AS is_positive,
 (cl.category='Negative')::INT AS is_negative,
 (cl.category='Normal')::INT AS is_normal,
 NTILE(10) OVER (ORDER BY cl.c_score) AS c_decile,
 p.viewer_polarity,p.viewer_two_camps
FROM classified cl LEFT JOIN v_polarity p ON p.movie_id=cl.movie_id;

DROP INDEX IF EXISTS idx_user_rating_movie_score;
ANALYZE user_rating_detailed;
EXPLAIN ANALYZE SELECT COUNT(*),AVG(score),STDDEV_POP(score) FROM user_rating_detailed
WHERE movie_id=(SELECT movie_id FROM movie WHERE title='Knock Down the House');
CREATE INDEX idx_user_rating_movie_score ON user_rating_detailed(movie_id) INCLUDE(score);
ANALYZE user_rating_detailed;
EXPLAIN ANALYZE SELECT COUNT(*),AVG(score),STDDEV_POP(score) FROM user_rating_detailed
WHERE movie_id=(SELECT movie_id FROM movie WHERE title='Knock Down the House');
DROP INDEX IF EXISTS idx_expert_rating_movie_score;
ANALYZE expert_rating_detailed;
EXPLAIN ANALYZE SELECT COUNT(*),AVG(score),STDDEV_POP(score) FROM expert_rating_detailed
WHERE movie_id=(SELECT movie_id FROM movie WHERE title='Freddy Got Fingered');
CREATE INDEX idx_expert_rating_movie_score ON expert_rating_detailed(movie_id) INCLUDE(score);
ANALYZE expert_rating_detailed;
EXPLAIN ANALYZE SELECT COUNT(*),AVG(score),STDDEV_POP(score) FROM expert_rating_detailed
WHERE movie_id=(SELECT movie_id FROM movie WHERE title='Freddy Got Fingered');
SELECT * FROM classification_thresholds ORDER BY c_cut,positive_min;
