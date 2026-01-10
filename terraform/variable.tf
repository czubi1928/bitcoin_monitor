# --- Connection Variables ---

variable "organization_name" {
  description = "Organization name for Snowflake account."
  type        = string
  sensitive   = true
}

variable "account_name" {
  description = "Account name for Snowflake account."
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to the private key for Snowflake JWT authentication."
  type        = string
}

# --- Infrastructure Variables ---

variable "bronze_table_names" {
  description = "List of all bronze tables to be created."
  type        = list(string)
  default     = ["ASSETS", "EXCHANGES", "MARKETS", "RATES"]
}

variable "shared_bronze_columns" {
  description = "Map of column names and data types applied to every bronze table."
  type        = map(string)
  default = {
    "INGEST_TIMESTAMP" = "TIMESTAMP_NTZ(9)"
    "API_RESPONSE"     = "VARIANT"
  }
}