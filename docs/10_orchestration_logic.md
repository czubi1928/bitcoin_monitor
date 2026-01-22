# Orchestration Details

## Schedule

- **Frequency:** Every 5 minutes (`*/5 * * * *`).
- **Timeout:** 10 minutes. If dbt takes longer than 10 mins, the task is killed to prevent overlapping runs.

## Container Strategy

- **Image:** `dbt-snowflake:latest`.
- **Environment:** Credentials passed via Airflow Environment Variables (Secrets).
- **Isolation:** Each run is a fresh container instance.

## Error Handling

- If `load_data` fails, `dbt run` is skipped.
- If `dbt run` fails, `dbt test` is skipped.
- Critical failures trigger Airflow retries (3 attempts).