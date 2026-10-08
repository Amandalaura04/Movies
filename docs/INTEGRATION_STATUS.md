# Integration status — 8 October 2026

This is a **public code and task-evidence repository**, not a verified executable submission.

## Published source and supporting files
- `sql/database/01_create_tables_PUBLIC.sql`: the group's 13-table schema, without local import paths or raw course CSVs.
- `sql/Jonas/Query_Jonas_SQ1_V2.sql`: SQ1 query (table-name reconciliation still needed).
- `sql/Nethmi/SQ2_Nethmi.sql`: SQ2 controversy-view draft.
- `sql/Amanda/SQ3_1_setup_ORIGINAL_SANITIZED.sql`: Amanda's original SQ3 setup with student number removed; caution, it drops views and thresholds.
- `sql/Amanda/SQ3a_classification.sql`, `SQ3b_sensitivity.sql`, `SQ3c_polarity.sql`: SQ3 analytical queries.
- `sql/Amanda/SQ3_2_tests_REVISED.sql`: test queries with corrected data-quality check; revised test not executed here.
- `sql/Amanda/SQ4_setup_Amanda.sql`: Amanda's one-row-per-movie SQ4 view.
- `python/Amanda/movie_db_encapsulator.py`: public-safe Amanda SQ3/SQ4 Python extraction module.
- `python/requirements.txt`, `sql/RUN_ORDER.md`, `tests/TEST_EVIDENCE_TEMPLATE.md` and `scrum/SCRUM_BOARD.md`.
- Twelve GitHub Issues describing remaining work.

## Important: do not execute both SQ3 setup versions
`sql/Amanda/SQ3_setup_INTEGRATION_DRAFT.sql` is an older integration **draft** with different expected schema, kept as an example. Use the clearly marked sanitized original with the documented dependency on `movie_controversy` instead. Verify against actual PostgreSQL outputs.

## Still not published / not verified
1. Authorized source CSVs and local data import commands; source datasets have intentionally **not** been redistributed publicly.
2. Amanda's complete original cleaning script and its input/output validation.
3. Jonas' final E2 / SQ4b and Nethmi's H1/H2 / SQ4a scripts, which were not confirmed in the available uploads. **Do not invent analysis outputs.**
4. Full shared-team Python encapsulator merging all five or more working methods.
5. End-to-end PostgreSQL execution, test screenshots, CSV output checks, and accurate row counts.
6. Real GitHub Projects Kanban board (the Markdown status board and labeled Issues are available).
7. Real individual Git contributions / collaborator invitations, actual testing evidence and private individual AI logs.

## Known issues
- Jonas SQ1 uses `user_rating`/`expert_rating`, whereas physical schema uses `user_rating_detailed`/`expert_rating_detailed`.
- SQL view dependency order is critical: `movie_controversy` → `v_controversy` → `v_reception` → `v_sq4_analysis`.
- Changing threshold sets or recreating views may affect downstream dependencies. Test on a disposable DB copy first.
- Public Git commits made by one connected account don't establish earlier individual authorship by other students.

See [SQL run order](../sql/RUN_ORDER.md), [Scrum overview](../scrum/SCRUM_BOARD.md), [all Issues](../../issues).
