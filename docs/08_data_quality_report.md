# Data Quality & Validation

## Testing Strategy

- **Null Checks:** Applied to `asset_id`, `price_usd`, and `rank` across all layers.
- **Range Validations:** Prices must be $\ge 0$. Asset ranks must be positive integers.
- **Freshness:** (To be implemented) We check if the `load_timestamp` is older than 15 minutes to ensure Airflow is
  running correctly.

## Known Issues / Handling

- **Duplicate Records:** Since we ingest every 5 minutes, we expect duplicate `asset_id` values in the history. Unique
  constraints are only applicable when combined with `load_timestamp`.