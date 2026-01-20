# -----------------------------------------------------------------------------
# Warehouse, database and schemas setup
# -----------------------------------------------------------------------------

resource "snowflake_warehouse" "warehouse" {
  name           = "COINCAP_WH"
  warehouse_size = "X-Large"
  auto_suspend   = 60
  auto_resume    = true
}

resource "snowflake_database" "database" {
  name    = "COINCAP_DB"
  comment = "Database for CoinCap data pipeline."
}

# -----------------------------------------------------------------------------
# Service Role for dbt
# -----------------------------------------------------------------------------
#
# resource "snowflake_database_role" "dbt_role" {
#   name    = "DBT_TRANSFORM_ROLE"
#   comment = "Role used by dbt to read Bronze and write to Silver/Gold"
# }
#
# # Grant usage on warehouse
# resource "snowflake_grant_privileges_to_account_role" "wh_usage" {
#   privileges        = ["USAGE"]
#   account_role_name = snowflake_role.dbt_role.name
#   on_account_object {
#     object_type = "WAREHOUSE"
#     object_name = snowflake_warehouse.warehouse.name
#   }
# }
#
# # Grant database usage
# resource "snowflake_grant_privileges_to_account_role" "db_usage" {
#   privileges        = ["USAGE"]
#   account_role_name = snowflake_role.dbt_role.name
#   on_account_object {
#     object_type = "DATABASE"
#     object_name = snowflake_database.database.name
#   }
# }

# -----------------------------------------------------------------------------
# Permissions Model
# -----------------------------------------------------------------------------
#
# # A. Allow dbt to READ from Bronze (Select only)
# resource "snowflake_grant_privileges_to_account_role" "bronze_read" {
#   privileges        = ["USAGE", "SELECT"]
#   account_role_name = snowflake_role.dbt_role.name
#   on_schema {
#     schema_name   = snowflake_schema.bronze.name
#     database_name = snowflake_database.database.name
#   }
# }
#
# # Grant SELECT on all current and future tables in Bronze
# resource "snowflake_grant_privileges_to_account_role" "bronze_tables_read" {
#   privileges        = ["SELECT"]
#   account_role_name = snowflake_role.dbt_role.name
#   on_schema_object {
#     all {
#       object_type_plural = "TABLES"
#       in_schema          = "\"${snowflake_database.database.name}\".\"${snowflake_schema.bronze.name}\""
#     }
#   }
# }
#
# # Allow dbt to FULL CONTROL Silver & Gold (Create, Modify, Drop)
# resource "snowflake_grant_privileges_to_account_role" "silver_gold_ownership" {
#   for_each = toset([snowflake_schema.silver.name, snowflake_schema.gold.name])
#
#   privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW", "MODIFY", "MONITOR"]
#   account_role_name = snowflake_role.dbt_role.name
#   on_schema {
#     schema_name   = each.key
#     database_name = snowflake_database.database.name
#   }
# }
