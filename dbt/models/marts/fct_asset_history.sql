{{ config(MATERIALIZED='table') }}

WITH metrics AS (
    SELECT *
    FROM {{ ref('int_asset_metrics') }}
)

SELECT load_timestamp,
       asset_id,
       asset_symbol,
       asset_rank,
       price_usd,
       market_cap_usd,
       turnover_ratio,
       price_change_1h,
       rank_delta
FROM metrics
-- We keep a slightly larger set (Top 50) to allow dashboard users to filter down to Top 10
WHERE asset_rank <= 50