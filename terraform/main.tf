# -----------------------------------------------------------------------------
# Warehouse, database and schemas setup
# -----------------------------------------------------------------------------

resource "snowflake_warehouse" "this" {
  name           = "${var.project_name}_WH"
  warehouse_size = "X-Large"
  auto_suspend   = 60
  auto_resume    = true
  comment        = "Compute resource for ${var.project_name} pipeline"
}

resource "snowflake_database" "this" {
  name    = "${var.project_name}_DB"
  comment = "Database for ${var.project_name} data pipeline."
}

resource "snowflake_schema" "schemas" {
  for_each = toset(var.environment_schemas)

  database = snowflake_database.this.name
  name     = each.key

  comment = "Schema for ${each.key} layer"
}

resource "snowflake_table" "asset_snapshots" {
  database = snowflake_database.this.name
  schema   = snowflake_schema.schemas["RAW"].name # Explicit dependency on loop

  name    = "ASSETS_SNAPSHOTS"
  comment = "Raw data ingestion table"

  dynamic "column" {
    for_each = var.asset_snapshots_columns
    content {
      name     = column.value["name"]
      type     = column.value["type"]
      nullable = column.value["nullable"]
      comment  = column.value["comment"]

      # REMOVED: "default =" logic caused the error.
      # Since your variables don't strictly need defaults right now,
      # we leave it out for a clean apply.
    }
  }
}
