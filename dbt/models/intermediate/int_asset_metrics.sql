{{
    config(
        materialized='incremental',
        unique_key=['asset_id', 'load_timestamp'],
        on_schema_change='fail'
    )
}}

WITH stg_assets AS (
    SELECT *
    FROM {{ ref('stg_coincap__assets') }}
    {% if is_incremental() %}
        -- Only grab new data PLUS a buffer for the LAG function
        -- We grab the last 2 hours to ensure our 1h LAG has enough data to look back at
        WHERE load_timestamp >= (SELECT dateadd('hour', -2, max(load_timestamp)) FROM {{ this }})
    {% endif %}
),

-- Step 1: Get the previous values using LAG
time_series_lagged AS (
    SELECT *,
    -- Get the price from 1 hour ago.
    -- If snapshots are every 5 mins, 1 hour ago is 12 rows back (60/5 = 12).
    LAG (price_usd, 12) OVER (
        PARTITION BY asset_id
        ORDER BY load_timestamp
    ) AS price_usd_1h_ago,
    -- Get the rank from the previous snapshot (5 mins ago)
    LAG (asset_rank, 1) OVER (
        PARTITION BY asset_id
        ORDER BY load_timestamp
    ) AS asset_rank_prev
    FROM stg_assets
    ),
    -- Step 2: Calculate the derived metrics
    calculated_metrics AS (
    SELECT *,
    -- 1. Turnover Ratio: volume / market_cap
    CASE
        WHEN market_cap_usd > 0 THEN volume_usd_24h / market_cap_usd
        ELSE 0
    END AS turnover_ratio,
    -- 2. Volatility Spike: % change between now and 1h ago
    CASE
    WHEN price_usd_1h_ago > 0
        THEN (price_usd - price_usd_1h_ago) / price_usd_1h_ago
        ELSE 0
    END AS price_change_1h,
    -- 3. Rank Churn: Absolute difference in rank
    (asset_rank - asset_rank_prev) AS rank_delta
    FROM time_series_lagged
    )

SELECT *
FROM calculated_metrics
{% if is_incremental() %}
    -- Final filter to ensure we only insert truly new records into the final table
    WHERE load_timestamp > (SELECT max(load_timestamp) FROM {{ this }})
{% endif %}