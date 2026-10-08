# Definitive-file audit — 2026-10-08

**Source:** latest `Amanda_Luijendijk_SQ3-4zip(1)` and `HeyEncapsulator(1).ipynb`, with `all_tables.zip` as source for independent data calculations. The latest Amanda ZIP and its predecessor have identical contents.

## Verified by executing local Python data checks

| Check | Result |
|---|---|
| Read all 13 CSVs | PASS |
| Duplicate/null primary keys in tested tables | 0 |
| Broken foreign-key references in tested relationships | 0 |
| User review count | 316,212 |
| Expert review count | 238,737 |
| Expert missing score values | 2 (data limitation) |
| Films with >=5 reviews each group | 5,449 |
| Films with positive linked worldwide revenue | 4,143 |
| Controversial / positive / normal / negative | 4,322 / 709 / 392 / 26 |
| C>=0.20, controversial share | 93.4% |
| C>=0.30, controversial share | 53.4% |
| Valence 65/45, unchanged labels | 96.6% |
| SQ3 and cleaning Python scripts compile | PASS |
| Notebook 5 code cells Python syntax | PASS |
| Final SQ3 and SQ4 notebook cell executed | NO (no saved output) |
| PostgreSQL scripts executed on course database | NOT TESTED |

## Discovered issues

1. SQ1 notebook uses short rating table names, while import uses `user_rating_detailed` and `expert_rating_detailed`.
2. The original notebook includes a literal database password and should not be uploaded verbatim.
3. The original SQ3 test 5 treats matching movie/date/score as proof of copied reviews. This is an unsupported inference; use score-quality tests instead and document the two expert null scores.
4. Compiling Python code does not prove that the SQL queries run.
5. The group still needs final SQ4a/SQ4b implementations and real PostgreSQL execution evidence.

## Honest status

**CSV-level and syntax checks: PASS with documented issues. Full database and notebook integration: UNVERIFIED.** Do not claim full success until a PostgreSQL server executes the final scripts, Python methods produce DataFrames, and real output has been saved. Avoid disclosing credentials or source datasets in this public repo.

