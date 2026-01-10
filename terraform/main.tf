# -----------------------------------------------------------------------------
# Warehouse and Database
# -----------------------------------------------------------------------------

resource "snowflake_warehouse" "coincap_warehouse" {
  name           = "COINCAP_WAREHOUSE"
  warehouse_size = "XSMALL"
  auto_suspend   = 60
  auto_resume    = true
}

resource "snowflake_database" "coincap_database" {
  name    = "COINCAP_DATABASE"
  comment = "Database for CoinCap data pipeline."
}

# -----------------------------------------------------------------------------
# Database Schemas (Medallion Architecture)
# -----------------------------------------------------------------------------

resource "snowflake_schema" "bronze" {
  name     = "BRONZE_SCHEMA"
  database = snowflake_database.coincap_database.name
}

resource "snowflake_schema" "silver" {
  name     = "SILVER_SCHEMA"
  database = snowflake_database.coincap_database.name
}

resource "snowflake_schema" "gold" {
  name     = "GOLD_SCHEMA"
  database = snowflake_database.coincap_database.name
}

# -----------------------------------------------------------------------------
# Bronze Layer Tables (Dynamic Creation)
# -----------------------------------------------------------------------------

resource "snowflake_table" "bronze_tables" {
  # Loops through the list of table names
  for_each = toset(var.bronze_table_names)

  database = snowflake_database.coincap_database.name
  schema   = snowflake_schema.bronze.name
  name     = each.key
  comment  = "Raw landing table for ${each.key}"

  # Loops through the map of columns for each table
  dynamic "column" {
    for_each = var.shared_bronze_columns
    content {
      name = column.key
      type = column.value
    }
  }
}
