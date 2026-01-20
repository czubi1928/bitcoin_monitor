# -----------------------------------------------------------------------------
# Bronze Layer: Raw immutable append-only storage
# -----------------------------------------------------------------------------

resource "snowflake_schema" "bronze" {
  name                = "BRONZE_SCHEMA"
  database            = snowflake_database.coincap_database.name
  with_managed_access = true
}

resource "snowflake_table" "bronze_tables" {
  # Loops through the list of table names
  for_each = toset(var.bronze_table_names)

  database = snowflake_database.coincap_database.name
  schema   = snowflake_schema.bronze.name
  name     = upper(each.key)
  comment  = "Raw immutable append-only storage for ${each.key}"

  cluster_by      = ["TO_DATE(INGESTED_AT)"]
  change_tracking = true

  # Loops through the map of columns for each table
  dynamic "column" {
    for_each = var.shared_bronze_columns
    content {
      name     = column.value["name"]
      type     = column.value["type"]
      nullable = column.value["nullable"]

      # Only apply default/comment if they exist in the variable
      default = lookup(column.value, "default", null)
      comment = lookup(column.value, "comment", null)
    }
  }
}
