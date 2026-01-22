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

variable "project_name" {
  type    = string
  default = "COINCAP"
}

variable "environment_schemas" {
  description = "List of schemas to create"
  type        = list(string)
  default     = ["RAW", "STAGING", "INTERMEDIATE", "MART"]
}

variable "asset_snapshots_columns" {
  description = "Column definitions for ASSET_SNAPSHOTS table"

  type = list(object({
    name     = string
    type     = string
    nullable = optional(bool, true) # If you forget to add nullable, it defaults to true
    comment  = optional(string)
  }))

  default = [
    {
      name     = "LOAD_TIMESTAMP"
      type     = "TIMESTAMP_NTZ"
      nullable = false
      comment  = "Timestamp of ingestion"
    },
    {
      name     = "RAW_DATA"
      type     = "VARIANT"
      nullable = true
      comment  = "Snowflake dynamic JSON type"
    },
    {
      name     = "SOURCE_FILE_NAME"
      type     = "VARCHAR"
      nullable = true
      comment  = "Source metadata"
    }
  ]
}
