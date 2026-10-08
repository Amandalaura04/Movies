# Authorized data and reproducibility
The private local submission package contains the 13 final CSV files under `data/private/` and a PostgreSQL custom-format backup. They are deliberately excluded from public Git. `manifest.json` records each exact filename, header, row count and SHA-256 hash. The rebuild rejects altered or missing input files before creating a new database.

The final CSVs are the authoritative integration inputs. The original sales cleaning script is included separately, but this does not imply its Excel-input pipeline was rerun or verified. Missing expert review scores: 2, retained as NULL. PostgreSQL AVG and STDDEV ignore them; review minima use COUNT(*) as in the original method.

The private package is currently local. Amanda must deliver it via the permitted course submission route or restricted storage and grant the lecturer access. No shared URL or lecturer access is claimed. The repository's public status has not been changed.
