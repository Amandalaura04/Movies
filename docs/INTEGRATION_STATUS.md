# Integration status and next actions

**Public repository status (2026-10-08):** This is a work-in-progress demonstration of group code and task tracking. A complete runnable PostgreSQL implementation has **not** been verified.

## Published
- SQ1 descriptive query (Jonas).
- SQ2 draft query (Nethmi; review exact physical table names).
- SQ3a, SQ3b, SQ3c (Amanda).
- SQ3 integration setup draft (Amanda's concepts; **not** verified against SQ2 column names).
- Issue-based current work inventory, Scrum guidance, and verification template.

## Still missing from GitHub
- Final schema and data import script with portable paths.
- Original Amanda SQ3 setup, integrity tests, SQ4 setup and original Python script in vetted public-safe form.
- Jonas/Nethmi completed SQ4 queries.
- Tested shared Python encapsulator.
- Actual GitHub Project board with To do / In progress / Done columns.
- Reproducible evidence of local PostgreSQL execution.

## Known schema issues
- Jonas SQ1 queries reference `user_rating` and `expert_rating`. The physical input tables may instead be named `user_rating_detailed` and `expert_rating_detailed`.
- The SQ3 integration draft assumes `v_controversy` provides `c_score` and `combined_mean`. Before execution verify these names against the final SQL and adapt the view definition.
- Do not treat a count of GitHub Issues as evidence of completed tests, historic Scrum meetings, or individual Git commits.

## How to track work
See the [GitHub Issues](../../issues). To create a Project board, select the repository **Projects** tab and add these issues. Only mark issues Done after real execution or review and link evidence.

## Privacy and attribution
No student identifiers, personal AI logbooks, passwords, or redistributed course data should be committed to this public repository. Git commit authorship describes who committed files **now**, not necessarily who originally authored historical offline work.