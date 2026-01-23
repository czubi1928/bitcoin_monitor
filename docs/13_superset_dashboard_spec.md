# Superset Dashboard Specification: "Crypto Market Intelligence"

## Dashboard Tab: Macro Overview

| Chart Name        | Visual Type | SQL Logic                             |
|:------------------|:------------|:--------------------------------------|
| Global Market Cap | Area Chart  | `SUM(total_market_cap_usd)` over time |
| BTC Dominance     | Big Number  | `btc_dominance_percentage` (latest)   |

## Dashboard Tab: Asset Intelligence (Micro)

| Chart Name    | Visual Type | SQL Logic                             |
|:--------------|:------------|:--------------------------------------|
| Rank Churn    | Table       | `asset_id`, `rank`, `rank_delta`      |
| 1h Change %   | Horiz. Bar  | `price_change_1h` (sorted by ABS)     |
| Liquidity Map | Scatter     | `turnover_ratio` vs `price_change_1h` |

## Maintenance

- **Refresh Rate:** 5 Minutes (Matches Pipeline).
- **Owner:** Data Engineering Team.