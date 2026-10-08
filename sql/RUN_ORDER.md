# Tested SQL run order
1. Use `scripts/rebuild_database.py` to create a NEW database and load the 13 final CSVs. It refuses an existing database. The schema's DROP statements execute only in that new empty database.
2. `sql/Nethmi/SQ2_Nethmi.sql` creates `movie_controversy`.
3. `sql/Amanda/SQ3_1_setup_ORIGINAL_SANITIZED.sql` creates thresholds, classification function, SQ3 views and indexes. It replaces objects, so run it only through the fresh database build.
4. `sql/Amanda/SQ4_setup_Amanda.sql` creates the SQ4 analysis view.
5. Execute Jonas SQ1, Amanda SQ3a/b/c and revised integrity checks.
6. Execute Nethmi SQ4a and Jonas SQ4b files marked PROPOSAL, awaiting their confirmation. These are descriptive summaries, not causal/inferential hypothesis proof.
7. Run the shared encapsulator and integration tests; evidence is in `tests/evidence/`.

The obsolete incompatible setup is archived under `sql/archive/` and excluded from the build. The two missing expert scores are explicitly reported separately from out-of-range scores. SQL aggregates retain the original NULL handling. See `docs/ai/AI_T2_01.md` for integration changes.
