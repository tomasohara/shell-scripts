## Tests for shell-scripts

This is work-in-progress test suite for the shell-scripts repo.

The emphasis is an alias and Bash functions such as via Jupyter notebooks
a la testing by example. See [README.ipynb](README.ipynb)

In addition, there are tests for the supporting python scripts.

## Weekly dashboard

`.github/workflows/weekly-test-dashboard.yml` runs the existing Python and
BatsPP tests every Monday at 13:15 UTC (and can be run manually). It enables
Kcov for the alias tests, uploads the complete HTML and text reports as a
`weekly-test-dashboard` artifact, and adds a concise result to the Actions job
summary. The retained `weekly-summary.json` is the stable input for a future UI.

The report compares the current run with the prior non-expired weekly artifact.
It calls out increased failed-test counts, alias coverage drops of two or more
percentage points, and changes to Python, Bash, BatsPP, Kcov, or Mezcla versions.
The email contains only these aggregate results and alerts; use the artifact for
per-test results so that the message remains readable.

To enable delivery, set the repository variable `WEEKLY_TEST_EMAIL_ENABLED` to
`true` and configure these repository secrets: `WEEKLY_TEST_SMTP_HOST`,
`WEEKLY_TEST_SMTP_PORT`, `WEEKLY_TEST_SMTP_USERNAME`,
`WEEKLY_TEST_SMTP_PASSWORD`, `WEEKLY_TEST_EMAIL_FROM`, and
`WEEKLY_TEST_EMAIL_TO`. The workflow uses SMTP STARTTLS and fails explicitly if
any enabled email setting is absent.
