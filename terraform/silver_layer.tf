# -----------------------------------------------------------------------------
# Silver Layer Schema
# -----------------------------------------------------------------------------

resource "snowflake_schema" "silver" {
  name                = "SILVER_SCHEMA"
  database            = snowflake_database.coincap_database.name
  with_managed_access = true
}

resource "snowflake_table" "assets_history" {
  database = snowflake_database.coincap_database.name
  schema   = snowflake_schema.silver.name
  name     = "ASSETS_HISTORY"
  comment  = "Flattened history of CoinCap assets with full ingest metadata."

  cluster_by = ["TO_DATE(ASSET_TIMESTAMP)"]

  column {
    name     = "ASSET_ID"
    type     = "VARCHAR(255)"
    nullable = false
    comment  = "Natural key from the /assets payload."
  }
  column {
    name     = "SYMBOL"
    type     = "VARCHAR(64)"
    nullable = true
    comment  = "Ticker symbol that may fluctuate as assets rebrand."
  }
  column {
    name     = "NAME"
    type     = "VARCHAR(256)"
    nullable = true
    comment  = "Human-readable asset name."
  }
  column {
    name     = "ASSET_TIMESTAMP"
    type     = "TIMESTAMP_NTZ"
    nullable = false
    comment  = "CoinCap timestamp for the asset snapshot."
  }
  column {
    name     = "RANK"
    type     = "INTEGER"
    nullable = true
    comment  = "Rank payload cast to integer for rank churn analysis."
  }
  column {
    name     = "PRICE_USD"
    type     = "NUMBER(18,8)"
    nullable = true
    comment  = "Price in USD, cast from the string payload."
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
    name     = "SUPPLY"
    type     = "NUMBER(38,6)"
    nullable = true
  }
  column {
    name     = "MAX_SUPPLY"
    type     = "NUMBER(38,6)"
    nullable = true
  }
  column {
    name     = "CHANGE_PERCENT_24H"
    type     = "NUMBER(12,6)"
    nullable = true
  }
  column {
    name     = "VWAP_24H"
    type     = "NUMBER(12,6)"
    nullable = true
  }
  column {
    name     = "EXPLORER"
    type     = "VARCHAR(512)"
    nullable = true
  }
  column {
    name     = "TOKENS"
    type     = "VARIANT"
    nullable = true
    comment  = "Preserves nested token metadata for future enrichment."
  }
  column {
    name     = "RAW_RESPONSE"
    type     = "VARIANT"
    nullable = true
    comment  = "Complete JSON payload for traceability / replays."
  }
  column {
    name     = "INGEST_TIMESTAMP"
    type     = "TIMESTAMP_NTZ"
    nullable = false
    comment  = "Bronze INGEST_TIMESTAMP used as the dedupe key for the incremental Silver model."
  }
}
