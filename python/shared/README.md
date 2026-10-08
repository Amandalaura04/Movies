# Shared team encapsulator
The shared module contains seven original extraction methods and three SQ4a extraction methods for sample counts, critic-score bands and viewer-review-count quartiles. SQ4b methods are excluded. PostgreSQL connection settings use environment variables.

Use the table names expert_rating, user_rating and sales. The tested setup is scripts/rebuild_database.py with data/manifest.json and sql/RUN_ORDER.md. The original CSV filenames remain unchanged.

Nethmi's supplied SQ4a view is separate from Amanda's review-eligible SQ4 setup. SQ4a retains its single-sales-match restriction, no five-review minimum, and nonmissing revenue rule. Do not compare the two samples as if they were identical. The executed notebook and tests/evidence/final report record the actual outputs.
