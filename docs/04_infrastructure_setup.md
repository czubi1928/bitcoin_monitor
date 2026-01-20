# Infrastructure Setup (Terraform)

## Environment Overview

- **Provider:** Snowflake
- **Database:** `COINCAP_DB`
- **Warehouse:** `COINCAP_WH` (X-Small, 60s auto-suspend)

---

## Schema Architecture

1. **RAW:** Entry point for Python ingestion. Contains `VARIANT` data.
2. **STAGING:** dbt cleaned views.
3. **INTERMEDIATE:** Heavy transformation and window functions.
4. **MART:** Final BI-ready tables.

---

## Security

- `LOADER_ROLE`: Used by Airflow. Permissions: `INSERT` on `RAW`.
- `TRANSFORMER_ROLE`: Used by dbt. Permissions: `SELECT` on `RAW`, `ALL` on `STAGING/INT/MART`.
-

---

## Modular IaC Structure

To improve maintainability, Terraform files are split by Snowflake Schema:

- `raw_schema.tf`: Manages landing tables and LOADER_ROLE permissions.
- `staging_schema.tf`: Entry point for dbt cleaning.
- `intermediate_schema.tf`: Workspace for complex metric generation.
- `mart_schema.tf`: Final consumption layer for BI tools.