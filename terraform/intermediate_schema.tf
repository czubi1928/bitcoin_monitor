resource "snowflake_schema" "intermediate" {
  database = snowflake_database.database.name
  name     = "INTERMEDIATE"
}

# resource "snowflake_grant_privileges_to_account_role" "transformer_intermediate" {
#   privileges        = ["USAGE", "CREATE TABLE", "CREATE VIEW", "SELECT"]
#   account_role_name = snowflake_role.transformer_role.name
#   on_schema {
#     schema_name = "${snowflake_database.db.name}.INTERMEDIATE"
#   }
# }