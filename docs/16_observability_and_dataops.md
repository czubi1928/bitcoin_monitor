# Observability & DataOps Strategy

## Monitoring Layers

1. **Infrastructure:** Snowflake `WAREHOUSE_METERING_HISTORY` (Credit Tracking).
2. **Pipeline:** Airflow `on_failure_callback` (Slack Alerts).
3. **Data Quality:** dbt tests (Unique, Not Null, Accepted Range).
4. **Data Freshness:** dbt `source freshness` (SLA < 15 mins).

## Incident Response

- **Alert Level 1 (Warning):** Data is > 10 mins old. Check Airflow Scheduler.
- **Alert Level 2 (Critical):** dbt tests fail on `price_usd`. Stop downstream dashboards.
- **Alert Level 3 (Infrastructure):** Credit usage spike. Check for long-running queries or `LAG` window function
  inefficiency.

## Package Dependencies

The project relies on three core observability packages:

1. **dbt_utils**: For basic data integrity tests.
2. **dbt_expectations**: For advanced statistical testing (row count ranges).
3. **elementary**: For operational metadata and test result tracking.

## Deployment Note

After any change to `packages.yml`, the command `make dbt-deps` must be executed to refresh the local environment. To
initialize the observability schema in Snowflake, run `make elementary-init`.