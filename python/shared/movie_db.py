"""Shared MovieDB based on the uploaded team notebook.
Original attributed blocks: Jonas SQ1, Nethmi SQ2, Amanda SQ3/SQ4.
Connection, schema and integration changes: Codex at Amanda request, AI-T2-01.
SQ4 proposal methods are AI-assisted integrations, awaiting student confirmation.
"""
import os
from pathlib import Path
import pandas as pd
import sqlparse
from sqlalchemy import create_engine, text
from sqlalchemy.engine import URL

ROOT = Path(__file__).resolve().parents[2]

class MovieDB:
    def __init__(self, user=None, password=None, host=None, port=None, dbname=None):
        url = URL.create("postgresql+psycopg2", username=user or os.getenv("PGUSER"),
            password=password if password is not None else os.getenv("PGPASSWORD"),
            host=host or os.getenv("PGHOST", "127.0.0.1"),
            port=int(port or os.getenv("PGPORT", "5432")),
            database=dbname or os.getenv("PGDATABASE", "movies_db"))
        self.engine = create_engine(url)

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.engine.dispose()

    def _query(self, sql):
        with self.engine.connect() as conn:
            return pd.read_sql_query(text(sql), conn)

    def _file_query(self, filename, statement):
        # Analytical files contain SELECT statements only.
        statements = [s for s in sqlparse.split((ROOT / filename).read_text()) if sqlparse.format(s, strip_comments=True).strip()]
        return self._query(statements[statement])
    def SQ1_descriptive_stats(self): #to get the mean critic score, mean viewer score and number of reviews - Jonas
      sql = """
            SELECT
                m.movie_id,
                m.title,
                u.user_count,
                u.user_mean,
                e.expert_count,
                e.expert_mean
            FROM movie AS m
            LEFT JOIN (
                SELECT
                    movie_id,
                    COUNT(*) AS user_count,
                    ROUND(AVG(score)::numeric, 2) AS user_mean
                FROM user_rating_detailed
                GROUP BY movie_id
            ) AS u ON u.movie_id = m.movie_id
            LEFT JOIN (
                SELECT
                    movie_id,
                    COUNT(*) AS expert_count,
                    ROUND(AVG(score)::numeric, 2) AS expert_mean
                FROM expert_rating_detailed
                GROUP BY movie_id
            ) AS e ON e.movie_id = m.movie_id
            ORDER BY m.title;
        """
      return self._query(sql)
    def SQ2_controversy_score(self): #within/between-group disagreement and controversy score per movie - Nethmi
      sql = "SELECT * FROM movie_controversy"
      return self._query(sql)

    # ---------------------------------------------------------------
    # SQ3 and SQ4 setup | Written by Amanda Luijendijk
    # ---------------------------------------------------------------

    def SQ3_get_reception(self):  # one row per film with category, dummies and C - Amanda
        sql = "SELECT * FROM v_reception ORDER BY movie_id"
        return self._query(sql)

    def SQ3_get_classification(self):  # SQ3a: films and averages per category - Amanda
        sql = """
            WITH ranked AS (
              SELECT category, title, c_score,
                     ROW_NUMBER() OVER (
                       PARTITION BY category
                       ORDER BY CASE WHEN category = 'Controversial' THEN -c_score ELSE c_score END,
                                movie_id) AS rn
              FROM v_reception),
            profile AS (
              SELECT threshold_set, category,
                     COUNT(*)                                           AS n_movies,
                     ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_movies,
                     ROUND(AVG(critic_mean)::numeric, 1)                AS avg_critic,
                     ROUND(AVG(viewer_mean)::numeric, 1)                AS avg_viewer,
                     ROUND(AVG(combined_mean)::numeric, 1)              AS avg_combined,
                     ROUND(AVG(d_between)::numeric, 3)                  AS avg_d,
                     ROUND(AVG(vdisp)::numeric, 3)                      AS avg_vdisp,
                     ROUND(AVG(edisp)::numeric, 3)                      AS avg_edisp,
                     ROUND(AVG(c_score)::numeric, 3)                    AS avg_c
              FROM v_reception
              GROUP BY threshold_set, category
              HAVING COUNT(*) >= 5),
            examples AS (
              SELECT category,
                     STRING_AGG(title || ' (' || ROUND(c_score::numeric, 3) || ')', '; ' ORDER BY rn) AS clearest_examples
              FROM ranked
              WHERE rn <= 3
              GROUP BY category)
            SELECT p.*, e.clearest_examples
            FROM profile p
            JOIN examples e USING (category)
            ORDER BY p.n_movies DESC
        """
        return self._query(sql)

    def SQ3_threshold_sensitivity(self):  # SQ3b: share per category under every rule set - Amanda
        sql = """
            WITH classified AS (
              SELECT t.threshold_set, t.c_cut, t.is_active,
                     t.positive_min::INT || '/' || t.negative_max::INT AS pos_neg,
                     c.movie_id,
                     classify_reception(c.c_score, c.combined_mean, t.c_cut, t.positive_min, t.negative_max) AS category
              FROM v_controversy c
              CROSS JOIN classification_thresholds t),
            compared AS (
              SELECT cl.*, r.category AS active_category
              FROM classified cl
              LEFT JOIN v_reception r ON r.movie_id = cl.movie_id)
            SELECT threshold_set, c_cut, pos_neg, is_active,
                   COUNT(*) AS n_movies,
                   ROUND(100.0 * COUNT(*) FILTER (WHERE category = 'Controversial') / COUNT(*), 1) AS pct_controversial,
                   ROUND(100.0 * COUNT(*) FILTER (WHERE category = 'Positive')      / COUNT(*), 1) AS pct_positive,
                   ROUND(100.0 * COUNT(*) FILTER (WHERE category = 'Normal')        / COUNT(*), 1) AS pct_normal,
                   ROUND(100.0 * COUNT(*) FILTER (WHERE category = 'Negative')      / COUNT(*), 1) AS pct_negative,
                   ROUND(100.0 * COUNT(*) FILTER (WHERE category = active_category) / COUNT(*), 1) AS pct_same_label_as_active
            FROM compared
            GROUP BY threshold_set, c_cut, pos_neg, is_active
            ORDER BY c_cut, pos_neg
        """
        return self._query(sql)

    def SQ3_viewer_polarity(self):  # SQ3c: are controversial films really polarized? - Amanda
        sql = """
            SELECT category,
                   COUNT(*) AS n_movies,
                   ROUND(100 * AVG(viewer_polarity)::numeric, 1)  AS avg_pct_extreme_viewers,
                   ROUND(100 * AVG(viewer_two_camps)::numeric, 1) AS avg_two_camps_pct,
                   ROUND(100.0 * COUNT(*) FILTER (WHERE viewer_two_camps >= 0.25) / COUNT(*), 1) AS pct_movies_two_camps,
                   NULL::NUMERIC AS corr_c_polarity
            FROM v_reception
            GROUP BY category
            UNION ALL
            SELECT 'All movies', COUNT(*),
                   ROUND(100 * AVG(viewer_polarity)::numeric, 1),
                   ROUND(100 * AVG(viewer_two_camps)::numeric, 1),
                   ROUND(100.0 * COUNT(*) FILTER (WHERE viewer_two_camps >= 0.25) / COUNT(*), 1),
                   ROUND(CORR(c_score, viewer_polarity)::numeric, 3)
            FROM v_reception
            ORDER BY n_movies DESC
        """
        return self._query(sql)

    def SQ3_set_active_threshold(self, threshold_set):  # UPDATE: switch the active rule set - Amanda
        with self.engine.begin() as conn:
            found = conn.execute(
                text("SELECT 1 FROM classification_thresholds WHERE threshold_set = :t"),
                {"t": threshold_set}).first()
            if found is None:
                raise ValueError(f"unknown rule set: {threshold_set}")
            conn.execute(
                text("UPDATE classification_thresholds SET is_active = (threshold_set = :t)"),
                {"t": threshold_set})
        return self._query("SELECT threshold_set, c_cut, is_active FROM classification_thresholds ORDER BY c_cut")

    def SQ4_controversy_revenue_evaluation(self, only_with_budget=False):  # SQ4 setup: analysis view - Amanda
        df = self._query("SELECT * FROM v_sq4_analysis ORDER BY movie_id")
        if only_with_budget:
            df = df[df["production_budget"] > 0].reset_index(drop=True)
        df["category"] = pd.Categorical(
            df["category"], categories=["Controversial", "Positive", "Normal", "Negative"])
        return df

    # AI-assisted integration of local SQ4 proposals, AI-T2-01; not attributed as original student code.
    def SQ4a_hypothesis_correlations(self):
        return self._file_query("sql/Nethmi/SQ4a_H1_H2_PROPOSAL.sql", 0)

    def SQ4a_revenue_quartiles(self):
        return self._file_query("sql/Nethmi/SQ4a_H1_H2_PROPOSAL.sql", 1)

    def SQ4b_category_revenue(self):
        return self._file_query("sql/Jonas/SQ4b_E2_PROPOSAL.sql", 0)

    def SQ4b_controversy_quartiles(self):
        return self._file_query("sql/Jonas/SQ4b_E2_PROPOSAL.sql", 1)
