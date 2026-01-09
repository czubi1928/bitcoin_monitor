# Configure the Terraform provider for Snowflake
terraform {
  required_providers {
    snowflake = {
      source  = "snowflakedb/snowflake" # Specifies the Snowflake provider source
      version = "2.12.0"                # Specifies the version of the Snowflake provider
    }
  }
}

# --- Provider Configuration ---
# Define the Snowflake provider configuration
provider "snowflake" {
  organization_name        = var.organization_name      # Organization name, passed as a variable
  account_name             = var.account_name           # Account name, passed as a variable
  user                     = "TERRAFORM_SVC"            # Service user for Terraform
  role                     = "SYSADMIN"                 # Role with required permissions
  authenticator            = "SNOWFLAKE_JWT"            # Authentication method
  private_key              = file(var.private_key_path) # Path to the private key file
  preview_features_enabled = ["snowflake_table_resource"]
}

# --- Warehouse and Database ---
# Create a Snowflake warehouse
resource "snowflake_warehouse" "coincap_warehouse" {
  name           = "COINCAP_WAREHOUSE" # Name of the warehouse
  warehouse_size = "XSMALL"            # Size of the warehouse
  auto_suspend   = 60                  # Auto-suspend after 60 seconds of inactivity
  auto_resume    = true                # Automatically resume when queried
}

# Create a Snowflake database
resource "snowflake_database" "coincap_database" {
  name = "COINCAP_DATABASE" # Name of the database
}

# --- Database Schemas ---
# Create a schema for the Bronze layer in the database
resource "snowflake_schema" "coincap_bronze_schema" {
  name     = "COINCAP_BRONZE_SCHEMA"                  # Name of the schema
  database = snowflake_database.coincap_database.name # Associated database
}

# Create a schema for the Silver layer in the database
resource "snowflake_schema" "coincap_silver_schema" {
  name     = "COINCAP_SILVER_SCHEMA"                  # Name of the schema
  database = snowflake_database.coincap_database.name # Associated database
}

# Create a schema for the Gold layer in the database
resource "snowflake_schema" "coincap_gold_schema" {
  name     = "COINCAP_GOLD_SCHEMA"                    # Name of the schema
  database = snowflake_database.coincap_database.name # Associated database
}

# --- Bronze Layer Resources ---
resource "snowflake_table" "assets_table" {
  name     = "ASSETS"
  database = snowflake_database.coincap_database.name
  schema   = snowflake_schema.coincap_bronze_schema.name

  column {
    name = "ingest_time"
    type = "TIMESTAMP_NTZ(9)"
  }

  column {
    name = "api_response"
    type = "VARIANT"
  }
}

resource "snowflake_table" "exchanges_table" {
  name     = "EXCHANGES"
  database = snowflake_database.coincap_database.name
  schema   = snowflake_schema.coincap_bronze_schema.name

  column {
    name = "ingest_time"
    type = "TIMESTAMP_NTZ(9)"
  }

  column {
    name = "api_response"
    type = "VARIANT"
  }
}

resource "snowflake_table" "markets_table" {
  name     = "MARKETS"
  database = snowflake_database.coincap_database.name
  schema   = snowflake_schema.coincap_bronze_schema.name

  column {
    name = "ingest_time"
    type = "TIMESTAMP_NTZ(9)"
  }

  column {
    name = "api_response"
    type = "VARIANT"
  }
}

resource "snowflake_table" "rates_table" {
  name     = "RATES"
  database = snowflake_database.coincap_database.name
  schema   = snowflake_schema.coincap_bronze_schema.name

  column {
    name = "ingest_time"
    type = "TIMESTAMP_NTZ(9)"
  }

  column {
    name = "api_response"
    type = "VARIANT"
  }
}
