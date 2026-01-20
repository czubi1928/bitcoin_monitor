resource "snowflake_schema" "mart" {
  database = snowflake_database.database.name
  name     = "MART"
}

# resource "snowflake_grant_privileges_to_account_role" "transformer_mart" {
#   privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW", "SELECT"]
#   account_role_name = snowflake_role.transformer_role.name
#   on_schema {
#     schema_name = "${snowflake_database.db.name}.MART"
#   }
# }

# Optional: Grant read-only access to a BI_ROLE here later