# Current tested SQL run order
1. Run scripts/rebuild_database.py with a NEW database and the final CSV directory. It refuses to replace an existing database and verifies the source hashes.
2. The schema creates the thirteen tables using expert_rating, user_rating and sales. Manifest entries map those tables to the original detailed/final CSV filenames.
3. SQ2_Nethmi.sql creates movie_controversy. Amanda's original SQ3 setup creates thresholds and reception views. SQ4_setup_Amanda.sql creates the review-eligible SQ4 analysis view.
4. SQ4a_Nethmi.sql creates or replaces sq4a_h1_h2 and executes Nethmi's supplied diagnostics and summaries. It preserves the original one-sales-match sample with no minimum review count.
5. Run the shared Python notebook and scripts/integration_test.py. Current evidence is tests/evidence/final.

SQ4b and the earlier SQ4a proposal are excluded. Historical source is under sql/archive. The new script is re-runnable with CREATE OR REPLACE VIEW. Existing movies_db was not renamed or replaced; the final build was tested on movies_codex_test_final_20261008.
