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
  default     = "/keys/snowflake_key.p8"
}

# --- Infrastructure Variables ---

variable "bronze_table_names" {
  type    = list(string)
  default = ["ASSET_SNAPSHOTS"] #"EXCHANGES", "MARKETS", "RATES"]
}

variable "shared_bronze_columns" {
  description = "Standard schema for all Bronze tables"
  type = list(object({
    name     = string
    type     = string
    nullable = bool
    default  = optional(string) # Optional: Not all columns need a default
    comment  = optional(string)
  }))

  default = [
    {
      name     = "INGEST_TIMESTAMP"
      type     = "TIMESTAMP_NTZ(9)"
      nullable = false
      default  = null
      comment  = "API response timestamp"
    },
    {
      name     = "API_RESPONSE"
      type     = "VARIANT"
      nullable = true # Allow nulls initially if API fails totally, though usually we want data
      default  = null
      comment  = "Full JSON response"
    }
  ]
}
