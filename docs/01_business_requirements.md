# Business Requirements

## Executive Summary

A near-real-time analytics platform focusing on **derived market intelligence** (volatility, liquidity, rank stability)
rather than just price tracking.

---

## Key Metrics & Logic

### Market Health (Macro)

- **BTC Dominance:** `(BTC Market Cap / Total Global Market Cap) * 100`
- **Total Volume:** Sum of `volumeUsd24Hr` for all assets at a specific timestamp.

### Asset Signals (Micro)

- **Turnover Ratio (Liquidity):** `volumeUsd24Hr / marketCapUsd`
    - *Interpretation:* High ratio = High liquidity/trading interest.
- **Volatility Spike:**
    - *Logic:* (Current Price - Price 1h ago) / Price 1h ago.
- **Rank Churn:**
    - *Logic:* Change in `rank` value compared to the previous timestamp.

---

## Data Scope

- **Entities:** Top N Assets by Market Cap.
- **History:** Continuous 5-minute intervals.