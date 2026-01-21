WITH raw_source AS (
    SELECT *
      FROM {{ source('coincap', 'assets_snapshots') }}
),

flattened AS (
SELECT
    -- Ingestion Metadata
    load_timestamp,
    source_file_name,
    -- Flattening the JSON array inside API_RESPONSE
    -- We use 'f.value' to access fields inside each object in the array
    f.value:id::STRING AS asset_id,
    f.value:rank::INT AS asset_rank,
    f.value:symbol::STRING AS asset_symbol,
    f.value:name::STRING AS asset_name,
    f.value:supply::FLOAT AS supply,
    f.value:maxSupply::FLOAT AS max_supply,
    f.value:marketCapUsd::FLOAT AS market_cap_usd,
    f.value:volumeUsd24Hr::FLOAT AS volume_usd_24h,
    f.value:priceUsd::FLOAT AS price_usd,
    f.value:changePercent24Hr::FLOAT AS change_percent_24h,
    f.value:vwap24Hr::FLOAT AS vwap_24h
FROM raw_source, LATERAL flatten(INPUT => raw_data) f
    )

SELECT *
FROM flattened