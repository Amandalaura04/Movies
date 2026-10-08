"""Amanda's SQ3/SQ4 Python encapsulator, adapted for public collaboration.

Original contribution: Amanda Luijendijk.
Set PostgreSQL environment variables locally and run using your own course data.
Dependent SQL files and views must exist first. Not end-to-end verified.
"""
import os
from pathlib import Path
import pandas as pd
import psycopg2

PROJECT_ROOT = Path(__file__).resolve().parents[2]
SQL_DIR = PROJECT_ROOT / "sql" / "Amanda"
OUTPUT_DIR = PROJECT_ROOT / "output"

class MovieDB:
    def __init__(self, config=None):
        self.config = config or {
            "dbname": os.getenv("PGDATABASE", "movies_db"),
            "user": os.getenv("PGUSER"),
            "password": os.getenv("PGPASSWORD"),
            "host": os.getenv("PGHOST", "localhost"),
            "port": os.getenv("PGPORT", "5432"),
        }
        self.conn = None

    def __enter__(self):
        self.conn = psycopg2.connect(
            **{key: val for key, val in self.config.items() if val is not None}
        )
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        if exc_type is not None:
            self.conn.rollback()
        self.conn.close()

    def query(self, sql, params=None):
        with self.conn.cursor() as cur:
            cur.execute(sql, params)
            cols = [column[0] for column in cur.description]
            return pd.DataFrame(cur.fetchall(), columns=cols)

    def run_file(self, filename):
        sql = (SQL_DIR / filename).read_text(encoding="utf-8")
        return self.query(sql).drop(columns="query", errors="ignore")

    def get_reception_classification(self):
        return self.run_file("SQ3a_classification.sql")

    def get_threshold_sensitivity(self):
        return self.run_file("SQ3b_sensitivity.sql")

    def get_viewer_polarity(self):
        return self.run_file("SQ3c_polarity.sql")

    def get_sq4_analysis_data(self, min_year=None, only_with_budget=False):
        sql = ("SELECT * FROM v_sq4_analysis "
               "WHERE (%s IS NULL OR release_year >= %s)")
        df = self.query(sql, (min_year, min_year))
        if only_with_budget:
            df = df[df["production_budget"].notna() &
                    (df["production_budget"] > 0)].copy()
        return df.reset_index(drop=True)

    def export_csv(self, frame, name):
        OUTPUT_DIR.mkdir(exist_ok=True)
        path = OUTPUT_DIR / (name + ".csv")
        frame.to_csv(path, index=False)
        return path

if __name__ == "__main__":
    with MovieDB() as db:
        for name, df in [
            ("sq3a", db.get_reception_classification()),
            ("sq3b", db.get_threshold_sensitivity()),
            ("sq3c", db.get_viewer_polarity()),
            ("sq4_analysis", db.get_sq4_analysis_data()),
        ]:
            print(name, len(df), "rows", db.export_csv(df, name))
