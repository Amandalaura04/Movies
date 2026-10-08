# Actual integration results
Executed 8 October 2026 against PostgreSQL 18 on Amanda's Mac.

| Environment | Passed | Total | Scope |
| --- | ---: | ---: | --- |
| Fresh final-CSV rebuild | 61 | 61 | 13 CSV imports, 11 extracts, CSV checks, SQL scripts, threshold mutation/restoration |
| Existing movies_db | 58 | 58 | Read-only extraction, CSV, population, integrity and SQL checks |

Both integration reports have overall passed=true. These are agent-run technical checks; independent student verification remains pending. The setup ran only on the fresh database; no data or views in existing movies_db were replaced.

Confirmed counts: 11,344 movie records; 30,611 sales rows; 316,212 user reviews; 238,737 expert reviews; 5,449 eligible SQ3 films; 4,143 positive-revenue SQ4 films. Categories: Controversial 4,322; Positive 709; Normal 392; Negative 26.

The seven original shared-notebook extraction methods plus four proposal extraction methods all returned nonempty DataFrames. Each full CSV export was read back and checked for row count and column equality; hashes are in the JSON reports. Aggregate SQ3/SQ4 exports are public here. Full record-level extracts and sampled SQL text output are in the private submission package. The notebook has actual execution counts and population output from the fresh build.

Meaningful checks include original-audit population agreement, SQL dummy/uniqueness/range checks, midpoint-rank Spearman comparison in Python, import counts, budget filtering, unknown-threshold rejection, and restoration of the active threshold. Foreign-key and primary-key constraints were enforced during the fresh import.

Limitations: two expert scores are NULL and explicitly retained; COUNT(*) includes those reviews while AVG/STDDEV ignore their scores. The original raw-input cleaning pipeline was not rerun. SQ4a/SQ4b are tested proposals, awaiting the intended owners' final confirmation. These descriptive outputs do not prove causal effects or substitute for student understanding. The dated earlier audit reports document their earlier untested state; this document supersedes that execution status only.

[Fresh rebuild report](evidence/rebuilt/integration_report.json) · [Existing database report](evidence/existing/integration_report.json) · [SQL integrity output](evidence/rebuilt/sql_integrity_tests.csv)
