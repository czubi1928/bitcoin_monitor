SELECT source_file_name,
       MIN(load_timestamp) AS start_time,
       MAX(load_timestamp) AS end_time,
       COUNT(*) AS record_count,
       DATEDIFF('second', MIN(load_timestamp), MAX(load_timestamp)) AS processing_time_seconds
FROM {{ ref('stg_coincap__assets') }}
GROUP BY 1