resource "snowflake_schema" "staging" {
  database = snowflake_database.database.name
  name     = "STAGING"
}

# resource "snowflake_grant_privileges_to_account_role" "transformer_staging" {
#   privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW", "SELECT"]
#   account_role_name = snowflake_role.transformer_role.name
#   on_schema {
#     schema_name = "${snowflake_database.database.name}.STAGING"
#   }
# }
