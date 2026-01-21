# Performance Optimization

## Incremental Strategy

To minimize Snowflake credit consumption and reduce run times, we transitioned from `table` materialization to
`incremental`.

### Implementation Details:

- **Model:** `int_asset_metrics` and `fct_asset_history`.
- **Logic:** We use a 2-hour "lookback buffer" during incremental runs to ensure that window functions (`LAG`) have
  access to historical rows required for calculations.
- **Unique Key:** A composite key of `asset_id` and `ingest_timestamp` prevents duplicate records.

## Results

- **Initial Load:** Full table scan.
- **Subsequent Runs:** Only processes data arriving in the last 5-10 minutes.
- **Scalability:** The pipeline can now handle years of historical data without increasing the cost of each 5-minute
  run.