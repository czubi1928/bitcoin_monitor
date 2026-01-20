# Marts Layer Design

## Models

1. **fct_asset_history**:
    - **Granularity**: 1 row per asset per 5-minute snapshot.
    - **Filtering**: Limited to Top 50 assets by rank to optimize storage and dashboard performance.
2. **fct_market_overview**:
    - **Granularity**: 1 row per 5-minute snapshot.
    - **Key Insights**: Provides a "Macro" view of the crypto market (Total Volume and BTC Dominance).

## BI Consumption

- These tables are materialized as `TABLES` to ensure high-speed querying for end-user dashboards.