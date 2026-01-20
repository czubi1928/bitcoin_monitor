# dbt Development Standards

## Layering Strategy

1. **Staging (stg_):**
    - One-to-one with source tables.
    - Purpose: Renaming, type casting, and flattening JSON.
    - No complex joins or business logic allowed.
2. **Intermediate (int_):**
    - Purpose: Calculations (Volatility, Rank Churn), Joins, and Window functions.
    - Not exposed to the final BI tool.
3. **Marts (fct_ / dim_):**
    - Purpose: Final tables optimized for analysis (e.g., BTC Dominance).

## Naming Conventions

- Column names: `snake_case`.
- Prices/Money: Always suffix with `_usd` or `_amount`.
- Timestamps: Always suffix with `_at` (though `ingest_timestamp` is kept for system audit).

## Connection Strategy

- **Authentication:** RSA Key-Pair (JWT) for secure, passwordless access.

[//]: # (- **Role:** `TRANSFORMER_ROLE`.)

## Materialization Strategy

- **Staging:** `view`. Fast to rebuild, no storage cost.
- **Intermediate:** `table`. Since we use time-series window functions (`LAG`), we materialize as tables to "freeze" the
  calculation and improve performance for downstream joins.
- **Marts:** `table`. Optimized for final consumption.

## Custom Schema Logic

- A macro overrides the default dbt behavior to ensure models land in the exact schemas created by Terraform (`STAGING`,
  `INTERMEDIATE`, `MART`).