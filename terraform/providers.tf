# -----------------------------------------------------------------------------
# Terraform Provider Configuration
# -----------------------------------------------------------------------------

terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake" # Specifies the Snowflake provider source
      version = "~> 2.12.0"             # Specifies the version of the Snowflake provider
    }
  }
}

provider "snowflake" {
  organization_name        = var.organization_name        # Organization name, passed as a variable
  account_name             = var.account_name             # Account name, passed as a variable
  user                     = "TERRAFORM_SVC"              # Service user for Terraform
  role                     = "SYSADMIN"                   # Role with required permissions
  authenticator            = "SNOWFLAKE_JWT"              # Authentication method
  private_key              = file(var.private_key_path)   # Path to the private key file
  preview_features_enabled = ["snowflake_table_resource"] # Enable preview features
}
