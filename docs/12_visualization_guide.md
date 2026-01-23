# Visualization Guide

## BI Strategy

- **Primary Tool:** Apache Superset (Dockerized).

## Dashboard Layout

1. **Global Header:** Total Market Cap & BTC Dominance (Last 5 mins).
2. **Asset Leaderboard:** Top 10 coins by Market Cap showing `rank_delta`.
3. **Risk Analysis:** Scatter plot of `Volatility` vs `Turnover Ratio` to identify high-risk pumps.

## Refresh Strategy

- Dashboards should be set to "Auto-Refresh" every 5 minutes to align with the Airflow/dbt pipeline frequency.