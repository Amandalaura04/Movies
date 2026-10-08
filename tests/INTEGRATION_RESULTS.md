# Historical integration results
**Source changed:** Amanda's supplied DB_Assignment_Amanda.zip is now authoritative. This report validates the earlier integrated version, not the original notebook and SQ3 test script newly selected from that ZIP. Their fresh execution is pending.

Executed 8 October 2026 on PostgreSQL 18.6 using a new database built from the thirteen exact final CSVs.

**59 of 59 checks passed.** All ten current extraction methods returned DataFrames and passed CSV row/column round trips. The executed notebook uses the current shared source. The threshold setter was tested only on the disposable database and the original setting was restored.

The chosen table names are expert_rating, user_rating and sales, matching the supplied screenshot. Original CSV filenames and hashes are preserved in data/manifest.json. The existing movies_db was not modified.

Nethmi SQ4a sample: 5,645 films with one sales match and nonmissing revenue; 5,644 have a critic mean (H1), 5,264 have viewer reviews (H2), 5,263 satisfy both. Python critic-band and viewer-quartile totals agree with those counts. SQ4a preserves the supplied sampling rules and is not restricted to five reviews per group.

Amanda's SQ3 sample remains 5,449 films, with categories 4,322 Controversial, 709 Positive, 392 Normal and 26 Negative. Amanda's positive-revenue SQ4 view remains 4,143 films. Its sampling rule differs from Nethmi's SQ4a and was not silently changed.

SQ4b is excluded from the current build and notebook. Earlier 61/61 and 58/58 reports under evidence/rebuilt and evidence/existing describe the previous detailed-table schema and earlier proposal methods; they are historical evidence, not validation of the current SQ4a.

Two missing expert scores are retained. Original-source cleaning has not been rerun; reproduction begins with the supplied final CSVs. The new script's calculations executed successfully, but matching the research method and final student acceptance remain a separate review.

[Current machine-readable report](evidence/final/integration_report.json) · [Current SQL checks](evidence/final/sql_integrity_tests.csv)
