output "database_name" {
  value = snowflake_database.coincap_database.name
}

output "bronze_tables_created" {
  description = "List of tables created in the bronze schema."
  value       = [for t in snowflake_table.bronze_tables : t.name]
}

output "warehouse_name" {
  value = snowflake_warehouse.coincap_warehouse.name
}
