# Technical audit — 2026-10-08 (partial, evidence-based)

## Scope
Checked the uploaded 13 CSV tables in the local project bundle; inspected the original SQL, Python source and shared Jupyter notebook. This is **not** a successful PostgreSQL execution, because the connected user's local PostgreSQL server is not available in this environment. No SQL queries have been executed on the user's server.

## Checks performed
- All 13 CSVs read successfully.
- All 13 corresponding tables have the expected names in the original SQL schema.
- 11,344 movies, 30,611 sales records, 316,212 user review records, 238,737 critic review records, 8,862 movie_sales links.
- Tested primary-key uniqueness for movie, sales_final, user_rating_detailed, expert_rating_detailed, overall_rating: **0 duplicate IDs and 0 null IDs**.
- Tested movie references in user/expert reviews, overall ratings and movie bridge tables: **0 unmatched references**.
- Tested movie_sales sales_id references: **0 unmatched references**.
- Tested actor, director and genre bridge references: **0 unmatched references**.
- Tested review scores against the 0–100 range: user scores had **0** null/out-of-range entries; critic scores had **2 nulls** and 0 observed out-of-range nonnull entries.
- Recomputed filtering from raw CSVs: **5,449** distinct movies with >=5 user and >=5 critic review rows; **4,143** with a linked, strictly positive worldwide box-office figure. Matches quantities reported in Task 1.
- Python compilation: original cleaning script and original encapsulator Python script **passed syntax compile**.
- Shared Jupyter notebook: 5 cells; the final cell calling SQ3 and SQ4 methods does not contain execution output. This is not evidence of a completed end-to-end run.

## Blockers
1. **No reachable PostgreSQL server in this test environment**: SQL syntax, permissions, view dependencies, pandas exports and query results still require an actual database run.
2. **SQL object mismatch**: Jonas SQ1 uses user_rating/expert_rating while import schema creates user_rating_detailed/expert_rating_detailed.
3. **Setup alternatives conflict**: SQ3_setup_INTEGRATION_DRAFT.sql and SQ3_1_setup_ORIGINAL_SANITIZED.sql are NOT interchangeable. Execute only after confirming dependencies and on a throwaway/test database (DROP ... CASCADE statements).
4. **Review data limitation**: two missing critic review scores; checking HAVING COUNT(*)>=5 counts records rather than valid scores. Decide and document whether to exclude null-score rows when imposing the >=5 minimum.
5. **Notebook security**: original shared notebook includes a literal PostgreSQL password. Remove it from copies and rotate if it has been shared publicly.
6. **Final team Python extractor not validated**: Python compile != PostgreSQL execution.
7. **Not confirmed available**: final SQ4a H1/H2 and SQ4b E2 implementations, exact sample/results, reproducibility and real individual code history.

## Next verification steps
- On the user's Mac, create a private test database and import the group's approved CSVs.
- Execute the SQL files in the documented order and log exact failures.
- Run SQL consistency checks; verify SQ3 counts and SQ4 1-row-per-film uniqueness.
- Run >=5 pandas DataFrame extraction functions and verify actual export CSVs.
- Capture logs and attach actual evidence to the appropriate issues.

**Pass/fail conclusion:** Static checks partly PASS, full integration **NOT YET TESTED**. This repository must not be described as fully tested.
