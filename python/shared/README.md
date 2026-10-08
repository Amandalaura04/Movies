# Shared team encapsulator
The uploaded HeyEncapsulator notebook is the source for the seven original extraction methods and threshold setter. The shared module preserves their attribution while fixing connection handling and physical table names. Four SQ4 methods integrate the locally supplied proposals; these are not claimed as original code by Jonas or Nethmi.

From repository root, install `python/requirements.txt`, set PostgreSQL environment variables, and open `python/shared/HeyEncapsulator.ipynb`. The notebook has been executed on the rebuilt test database. For actual full CSV exports and checks, run `scripts/integration_test.py` as documented in the root README. The public notebook records population counts; record-level exports are included only in the private package.

The threshold setter changes a database table and should be used intentionally. The test runner only exercises it on a named disposable test DB and restores its previous value.
