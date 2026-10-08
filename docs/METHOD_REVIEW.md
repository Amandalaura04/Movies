# Review minimum and reproduction boundary
Checked 8 October 2026 against the supplied final expert_rating_detailed.csv using CSV records, independently of the SQL views.

The current method uses COUNT(*) >= 5 to require five review records. AVG(score) and STDDEV_POP(score) ignore NULL scores. There are two missing expert scores in the supplied final data.

Films satisfying five expert records but fewer than five nonmissing expert scores: **0**. Therefore replacing this review-minimum predicate with COUNT(score) >= 5 would not change eligibility on these final data. It still changes the formal definition and should be confirmed against the report by the students. The original SQL method has been preserved; this check does not assert a new approved research decision.

Reproduction starts from the thirteen final CSV files identified by data/manifest.json. The original Excel-to-final-CSV cleaning pipeline has not been rerun and must not be presented as verified. The cleaning script is retained as attributed source, not proof of complete original-source reproduction.

The current successful execution report is tests/INTEGRATION_RESULTS.md. DEFINITIVE_FILES_AUDIT_2026-10-08.md and TECHNICAL_AUDIT_2026-10-08.md are historical reports from before PostgreSQL integration. The single executable setup route is scripts/rebuild_database.py and sql/RUN_ORDER.md. The archived alternative SQ3 draft is excluded.

Student sign-offs and individual logbooks must come from the actual students. No independent authorship, approval, lecturer access or final grade is inferred from these technical checks.
