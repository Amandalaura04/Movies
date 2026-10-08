# SQL execution order — verification required

These files were prepared by different students and must be reconciled against the same physical schema.

1. Create/load the 13 tables locally. Source CSV files must be obtained through the course; do not redistribute them without authorization.
2. Validate Jonas' SQ1 query; it refers to `user_rating` / `expert_rating` while the physical import is likely `user_rating_detailed` / `expert_rating_detailed`.
3. Run Nethmi's SQL to create `movie_controversy`.
4. Run Amanda's `SQ3_1_setup_ORIGINAL_SANITIZED.sql`, which creates `v_controversy`, `classification_thresholds`, `v_polarity` and `v_reception`. **It drops and recreates existing objects**; run on a test database first.
5. Run Amanda's `SQ4_setup_Amanda.sql` to create `v_sq4_analysis`.
6. Run `SQ3a_classification.sql`, `SQ3b_sensitivity.sql`, `SQ3c_polarity.sql` and `SQ3_2_tests_REVISED.sql`.
7. Add the group's completed H1, H2 and E2 queries (currently not yet available in GitHub).
8. Run the Python encapsulator and save actual test outputs.

Do **not** run `SQ3_setup_INTEGRATION_DRAFT.sql` instead of the original setup. It uses a different expected schema.
