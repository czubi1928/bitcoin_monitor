variable "organization_name" {
  description = "Organization name for Snowflake account"
  type        = string
  sensitive   = true
}

variable "account_name" {
  description = "Account name for Snowflake account"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to the private key for Snowflake JWT authentication"
  type        = string
  default     = "../snowflake_tf_snow_key.p8"
}
