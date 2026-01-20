# -----------------------------------------------------------------------------
# Gold Layer Tables for dbt
# -----------------------------------------------------------------------------

resource "snowflake_schema" "gold" {
  name                = "GOLD_SCHEMA"
  database            = snowflake_database.coincap_database.name
  with_managed_access = true
}


# Dimension: dim_assets
resource "snowflake_table" "dim_assets" {
  database = snowflake_database.coincap_database.name
  schema   = snowflake_schema.gold.name
  name     = "DIM_ASSETS"
  comment  = "Dimension table of distinct assets"

  column {
    name     = "ASSET_ID"
    type     = "VARCHAR(255)"
    nullable = false
    comment  = "Natural key from source"
  }
  column {
    name     = "SYMBOL"
    type     = "VARCHAR(64)"
    nullable = true
  }
  column {
    name     = "NAME"
    type     = "VARCHAR(256)"
    nullable = true
  }
  column {
    name     = "FIRST_SEEN"
    type     = "TIMESTAMP_NTZ"
    nullable = true
  }
  column {
    name     = "LAST_SEEN"
    type     = "TIMESTAMP_NTZ"
    nullable = true
  }
}

# Fact: fact_asset_history
resource "snowflake_table" "fact_asset_history" {
  database = snowflake_database.coincap_database.name
  schema   = snowflake_schema.gold.name
  name     = "FACT_ASSET_HISTORY"
  comment  = "Denormalized fact table for asset history (one row per asset per timestamp)"

  cluster_by = ["TO_DATE(ASSET_TIMESTAMP)"]

  column {
    name     = "ASSET_ID"
    type     = "VARCHAR(255)"
    nullable = false
  }
  column {
    name     = "ASSET_TIMESTAMP"
    type     = "TIMESTAMP_NTZ"
    nullable = false
    comment  = "Snapshot time aligned with Silver ASSETS_HISTORY."
  }
  column {
    name     = "PRICE_USD"
    type     = "NUMBER(18,8)"
    nullable = true
  }
  column {
    name     = "MARKET_CAP_USD"
    type     = "NUMBER(24,2)"
    nullable = true
  }
  column {
    name     = "VOLUME_USD_24H"
    type     = "NUMBER(24,2)"
    nullable = true
  }
  column {
    name     = "RANK"
    type     = "INTEGER"
    nullable = true
  }
  column {
    name     = "TURNOVER_RATIO"
    type     = "NUMBER(24,8)"
    nullable = true
  }
  column {
    name     = "VOLATILITY_1H_PCT"
    type     = "NUMBER(12,8)"
    nullable = true
  }
  column {
    name     = "RANK_CHURN"
    type     = "INTEGER"
    nullable = true
  }
  column {
    name     = "INGEST_TIMESTAMP"
    type     = "TIMESTAMP_NTZ"
    nullable = false
    comment  = "Bronze ingestion timestamp used for deduplication lineage."
  }
}

# Mart: mart_market_pulse
resource "snowflake_table" "mart_market_pulse" {
  database = snowflake_database.coincap_database.name
  schema   = snowflake_schema.gold.name
  name     = "MART_MARKET_PULSE"
  comment  = "Aggregated market-level metrics per timestamp"

  column {
    name     = "TIMESTAMP"
    type     = "TIMESTAMP_NTZ"
    nullable = false
  }
  column {
    name     = "TOTAL_MARKET_CAP"
    type     = "NUMBER(30,2)"
    nullable = true
  }
  column {
    name     = "BTC_DOMINANCE_PCT"
    type     = "NUMBER(12,6)"
    nullable = true
  }
  column {
    name     = "TOTAL_VOLUME_USD"
    type     = "NUMBER(30,2)"
    nullable = true
  }
}

# Mart: mart_volatility_alerts
resource "snowflake_table" "mart_volatility_alerts" {
  database = snowflake_database.coincap_database.name
  schema   = snowflake_schema.gold.name
  name     = "MART_VOLATILITY_ALERTS"
  comment  = "Alert table for assets exceeding volatility thresholds"

  column {
    name     = "ASSET_ID"
    type     = "VARCHAR(255)"
    nullable = false
  }
  column {
    name     = "TIMESTAMP"
    type     = "TIMESTAMP_NTZ"
    nullable = false
  }
  column {
    name     = "PRICE_USD"
    type     = "NUMBER(18,8)"
    nullable = true
  }
  column {
    name     = "VOLATILITY_1H_PCT"
    type     = "NUMBER(12,8)"
    nullable = true
  }
  column {
    name     = "THRESHOLD"
    type     = "NUMBER(12,8)"
    nullable = true
  }
}
