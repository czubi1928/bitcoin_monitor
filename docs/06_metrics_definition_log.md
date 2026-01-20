# Metrics Definition Log

## Asset Intelligence Metrics

| Metric              | Calculation Logic                           | Lookback Period    | Purpose                                                                                       |
|:--------------------|:--------------------------------------------|:-------------------|:----------------------------------------------------------------------------------------------|
| **Turnover Ratio**  | `volume_usd_24h / market_cap_usd`           | N/A (Real-time)    | Identifies liquidity. High values suggest high trading interest relative to size.             |
| **Price Change 1h** | `(price_now - price_1h_ago) / price_1h_ago` | 12 snapshots (60m) | Identifies "Volatility Spikes" or sudden market pumps/dumps.                                  |
| **Rank Delta**      | `current_rank - previous_rank`              | 1 snapshot (5m)    | Measures "Rank Churn" or stability. Negative values indicate an asset is climbing the charts. |

## Assumptions

- **Ingestion Frequency:** These metrics assume a consistent 5-minute ingestion interval.
- **Data Gaps:** If the Airflow DAG fails and skips an hour, the `LAG(12)` will effectively look back 2 hours. (Future
  Improvement: Implement time-based windowing).