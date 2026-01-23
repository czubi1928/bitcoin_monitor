#!/bin/bash

# Create Admin user, you can read these values from env or anywhere else possible
superset fab create-admin \
  --username "$ADMIN_USERNAME" \
  --firstname Superset \
  --lastname Admin \
  --email "$ADMIN_EMAIL" \
  --password "$ADMIN_PASSWORD"

# Upgrading Superset metastore
superset db upgrade

# Setup roles and permissions
superset superset init

# Add Snowflake Connection
superset set_database_uri \
  --database_name "Snowflake" \
  --uri "snowflake://$SNOWFLAKE_USER@$SNOWFLAKE_ACCOUNT/COINCAP_DB/MART?warehouse=COINCAP_WH&role=SYSADMIN"

# Starting server
/bin/sh -c /usr/bin/run-server.sh
