# Current tested SQL run order
1. Run scripts/rebuild_database.py with a NEW database and the final CSV directory. It refuses to replace an existing database and verifies the source hashes.
2. The schema creates the thirteen tables using expert_rating, user_rating and sales. Manifest entries map those tables to the original detailed/final CSV filenames.
3. SQ2_Nethmi.sql creates movie_controversy. Amanda's exact ZIP SQ3_1_setup.sql creates thresholds and reception views. SQ4_setup_Amanda.sql creates the review-eligible SQ4 analysis view.
4. SQ4a_Nethmi.sql creates or replaces sq4a_h1_h2 and executes Nethmi's supplied diagnostics and summaries. It preserves the original one-sales-match sample with no minimum review count.
5. Run the shared Python notebook and scripts/integration_test.py. The evidence under tests/evidence/final concerns the previous integration. Re-execute the original notebook and original SQ3_2_tests.sql before asserting a new pass result.

SQ4b and the earlier SQ4a proposal are excluded. Historical source is under sql/archive. The new script is re-runnable with CREATE OR REPLACE VIEW. Existing movies_db was not renamed or replaced; the final build was tested on movies_codex_test_final_20261008.

Authoritative Amanda source: Amanda/DB_Encapsulator.ipynb and sql/Amanda/SQ3_1_setup.sql, SQ3_2_tests.sql, SQ3a_classification.sql, SQ3b_sensitivity.sql, SQ3c_polarity.sql and SQ4_setup_Amanda.sql.
