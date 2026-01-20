{{ config(MATERIALIZED='table') }}

WITH metrics AS (
    SELECT *
    FROM {{ ref('int_asset_metrics') }}
),

global_stats AS (
    SELECT
        load_timestamp,
        sum(market_cap_usd) AS total_market_cap_usd,
        sum(volume_usd_24h) AS total_volume_24h,
        -- Get BTC specific market cap for dominance calculation
        sum(CASE WHEN asset_id = 'bitcoin' THEN market_cap_usd ELSE 0 END) AS btc_market_cap_usd
    FROM metrics
    GROUP BY 1
    )

SELECT load_timestamp,
       total_market_cap_usd,
       total_volume_24h,
       (btc_market_cap_usd / total_market_cap_usd) * 100 AS btc_dominance_percentage
FROM global_stats