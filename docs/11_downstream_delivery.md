# Downstream Data Delivery

[//]: # (## Direct Access &#40;SQL&#41;)

[//]: # (- **Target:** Data Analysts / Data Scientists.)

[//]: # (- **Access Point:** `COINCAP_DB.MART`.)

[//]: # (- **Role:** `BI_READER_ROLE`.)

## Business Intelligence
- **Tool:** Apache Superset.
- **Key Tables:** 
    - `fct_asset_history`: Used for time-series asset tracking.
    - `fct_market_overview`: Used for macro market health dashboards.

## Data Catalog
- **Tool:** dbt Docs.
- **Refresh Frequency:** On every production deployment.
- **Content:** Column definitions, data lineage, and test results.

[//]: # (## Alerting Thresholds)

[//]: # (- **Volatility Spike:** Triggered when `price_change_1h` > 10% or < -10%.)

[//]: # (- **Liquidity Warning:** Triggered when `turnover_ratio` drops below 0.01 for Top 10 assets.)