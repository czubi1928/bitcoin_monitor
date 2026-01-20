# Technical Architecture

## Tech Stack

- **Source:** CoinCap API (REST).
- **Language:** Python (Ingestion).
- **Orchestration:** Apache Airflow.
- **Warehouse:** Snowflake (Compute XS).
- **Transformation:** dbt Core (SQL).

[//]: # (- **Visualization:** Apache Superset)

---

## API documentation

- **Base URL:** `https://rest.coincap.io/v3/{ENDPOINT}`
- Endpoints of interest:
    - `assets`

### Assets Endpoint

- **Name:** `assets`.
- **Description:** A list of assets.
- **Response format:** JSON.
- **Response schema:**

```json
{
  "timestamp": 0,
  "data": [
    {
      "id": "string",
      "rank": "string",
      "symbol": "string",
      "name": "string",
      "supply": "string",
      "maxSupply": "string",
      "marketCapUsd": "string",
      "volumeUsd24Hr": "string",
      "priceUsd": "string",
      "changePercent24Hr": "string",
      "vwap24Hr": "string",
      "explorer": "string",
      "tokens": {
        "additionalProp1": [
          "string"
        ],
        "additionalProp2": [
          "string"
        ],
        "additionalProp3": [
          "string"
        ]
      }
    }
  ]
}
```

---

## Data Flow (The Medallion Architecture)

### Bronze Layer (Raw Ingestion)

- **Table Name:** `ASSETS`.
- **Source Endpoint:** `assets`.
- **Format:** JSON (stored in a VARIANT column named `API_RESPONSE`).
- **Ingest Strategy:** Append-only (Insert new rows every run).

### Silver Layer (Cleaned History)

- **Table Name:** `ASSETS_HISTORY`
- **Transformation Logic:**
    1. **Flatten:** Extract fields from the `API_RESPONSE` array in the JSON.
    2. **Cast Types:**
        - `priceUsd` -> DECIMAL(18,8)
        - `volumeUsd24Hr` -> DECIMAL(24,2)
        - `rank` -> INTEGER
    3. **Timestamp Standardization:** Convert API timestamp to UTC `TIMESTAMP_NTZ`.
    4. **Deduplication:** Use dbt `incremental` strategy.
        - **Unique Key:** Composite of (`INGEST_TIMESTAMP`).
        - **Rule:** Do NOT filter data here. Keep full history of all ingested assets.

### Gold Layer (Business Intelligence)

- **Schema:** Star Schema
- **Dimension Table:** `DIM_ASSETS`
    - Logic: distinct `symbol`, `name`.
- **Fact Table:** `FACT_ASSETS_HISTORY`.
    - Logic: Join Silver data with Dimensions. Grain = 1 row per asset per timestamp.
- **Data Marts:**
    - `mart_market_pulse`: Aggregation by timestamp (Total Market Cap, BTC Dominance).
    - `mart_volatility_alerts`: Filtered view where volatility > threshold.

---

## Orchestration Strategy

- **DAG:** `exchange_data_dag`
- **Schedule:** `*/5 * * * *`
- **Tasks:**
    1. `extract_data_from_api_task` (Python to JSON): Extract data from CoinCap API.
    2. `load_data_to_warehouse_task` (PUT/COPY): Load extracted data into Snowflake.
    3. `run_dbt_models` (BashOperator): Run dbt transformations.