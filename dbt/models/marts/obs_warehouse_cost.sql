SELECT warehouse_name,
       SUM(credits_used) AS total_credits,
       start_time::DATE AS usage_date
FROM snowflake.account_usage.warehouse_metering_history
WHERE warehouse_name = 'COINCAP_WH'
GROUP BY 1, 3