# Architecture Decision Records

## Single Endpoint Scope

- **Decision:** We will exclusively use the `/v2/assets` endpoint.
- **Reasoning:** We previously considered `/rates` and `/exchanges`. These were discarded to reduce scope and "Data
  Swamp" risk. `/assets` provides 90% of the required business value (Price, Volume, Cap, Rank).

---

## Top N Filtering Strategy

- **Decision:** Ingestion and Silver layers must accept ALL data returned by the API.
- **Reasoning:** Filtering to "Top 10" should only happen in the BI/Dashboard layer. Filtering earlier causes data gaps
  if an asset's rank fluctuates (e.g., drops to rank 11 then returns to 9).

---

## Handling Cost vs. Real-Time

- **Decision:** While the architecture supports 5-minute ingestion, we may throttle Airflow to hourly runs during
  development to save Snowflake credits. The code will remain agnostic to this frequency.