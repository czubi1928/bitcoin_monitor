# Architecture Decision Records

## Single Endpoint Scope

- **Decision:** We will exclusively use the `assets` endpoint.
- **Reasoning:** We previously considered `rates` and `exchanges`. These were discarded to reduce scope and "Data
  Swamp" risk. `assets` provides 90% of the required business value (Price, Volume, Cap, Rank).

---

## Top N Filtering Strategy

- **Decision:** Ingestion and Silver layers must accept ALL data returned by the API.
- **Reasoning:** Filtering to "Top 10" should only happen in the BI/Dashboard layer. Filtering earlier causes data gaps
  if an asset's rank fluctuates (e.g., drops to rank 11 then returns to 9).

---

## Handling Cost vs. Real-Time

- **Decision:** While the architecture supports 5-minute ingestion, we may throttle Airflow to hourly runs during
  development to save Snowflake credits. The code will remain agnostic to this frequency.

---

## Advanced Modeling: SCD Type 2

- **Decision:** Implemented dbt Snapshots for Asset Metadata.
- **Reasoning:** In crypto, metadata (ranks, symbols) changes frequently. By using SCD Type 2, we preserve historical
  state, allowing for "Point-in-Time" analysis which is critical for backtesting trading strategies.

---

## Engineering Standards: DRY Macros

- **Decision:** All currency and numeric cleaning is handled via centralized Macros.
- **Reasoning:** Ensures uniform data types across the entire warehouse and reduces technical debt during schema
  evolution.
