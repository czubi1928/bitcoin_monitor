# -----------------------------------------------------------------------------
# Bronze Layer: Raw immutable append-only storage
# -----------------------------------------------------------------------------

resource "snowflake_schema" "bronze" {
  name                = "RAW"
  database            = snowflake_database.database.name
  with_managed_access = true
}

resource "snowflake_table" "raw_assets" {
  database = snowflake_database.database.name
  schema   = snowflake_schema.bronze.name
  name     = "ASSETS_SNAPSHOTS"
  column {
    name = "LOAD_TIMESTAMP"
    type = "TIMESTAMP_NTZ"
  }
  column {
    name = "RAW_DATA"
    type = "VARIANT" # Snowflake's dynamic JSON type
  }
  column {
    name = "SOURCE_FILE_NAME"
    type = "VARCHAR"
  }
}
