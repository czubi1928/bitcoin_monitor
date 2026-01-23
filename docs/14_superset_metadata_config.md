# Superset Dataset Configuration

## Dataset: fct_asset_history

- **Schema:** `MART`
- **Primary Time Column:** `load_timestamp` (Temporal)
- **Calculated Metrics:**
    - `avg_volatility`: `AVG(price_change_1h)`
    - `avg_liquidity`: `AVG(turnover_ratio)`
- **Dimensions:** `asset_id`, `asset_symbol`, `asset_rank`.

## Dataset: fct_market_overview

- **Schema:** `MART`
- **Primary Time Column:** `load_timestamp` (Temporal)
- **Calculated Metrics:**
    - `btc_dominance`: `AVG(btc_dominance_percentage)`
    - `total_mkt_cap`: `SUM(total_market_cap_usd)`

## Usage Notes

- Use the `minute` time grain for real-time tracking (Last 6 hours).
- Use the `hour` time grain for trend analysis (Last 7 days).