--SELECT warehouse_name,
--       SUM(credits_used) AS total_credits,
--       start_time::DATE AS usage_date
--FROM "SNOWFLAKE"."ACCOUNT_USAGE".warehouse_metering_history
--WHERE warehouse_name = 'COINCAP_WH'
--GROUP BY 1, 3

SELECT
    'placeholder_wh'::VARCHAR AS warehouse_name,
    0::INT AS total_credits,
    CURRENT_DATE() AS usage_date
WHERE 1 = 0