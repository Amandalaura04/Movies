-- Amanda: SQ3 classification infrastructure.
-- Requires v_controversy with movie_id, critic_mean, viewer_mean,
-- d_between, vdisp, edisp, c_score, and combined_mean.
-- Integration draft: verify column names with actual SQ2 view.

CREATE TABLE IF NOT EXISTS classification_thresholds (
 threshold_set TEXT PRIMARY KEY,
 c_cut NUMERIC NOT NULL CHECK (c_cut BETWEEN 0 AND 1),
 positive_min NUMERIC NOT NULL CHECK (positive_min BETWEEN 0 AND 100),
 negative_max NUMERIC NOT NULL CHECK (negative_max BETWEEN 0 AND 100),
 is_active BOOLEAN NOT NULL DEFAULT FALSE,
 CHECK (positive_min > negative_max)
);
INSERT INTO classification_thresholds(threshold_set,c_cut,positive_min,negative_max,is_active)
VALUES ('base',0.25,70,40,TRUE),('c020',0.20,70,40,FALSE),('c030',0.30,70,40,FALSE),('valence_65_45',0.25,65,45,FALSE)
ON CONFLICT(threshold_set) DO NOTHING;

CREATE UNIQUE INDEX IF NOT EXISTS one_active_threshold
ON classification_thresholds(is_active) WHERE is_active;

CREATE OR REPLACE FUNCTION classify_reception(
 p_c NUMERIC, p_mean NUMERIC, p_cut NUMERIC,
 p_positive NUMERIC, p_negative NUMERIC)
RETURNS TEXT LANGUAGE SQL IMMUTABLE AS $$
 SELECT CASE WHEN p_c IS NULL OR p_mean IS NULL THEN NULL
 WHEN p_c >= p_cut THEN 'Controversial'
 WHEN p_mean >= p_positive THEN 'Positive'
 WHEN p_mean <= p_negative THEN 'Negative'
 ELSE 'Normal' END
$$;

-- Expected SQ2 source view name and fields must be checked.
CREATE OR REPLACE VIEW v_reception AS
SELECT c.*, t.threshold_set,
 classify_reception(c.c_score::numeric,c.combined_mean::numeric,
                    t.c_cut,t.positive_min,t.negative_max) AS category
FROM v_controversy c
CROSS JOIN classification_thresholds t
WHERE t.is_active;
