SELECT source_file_name,
       MIN(ingest_timestamp) AS start_time,
       MAX(ingest_timestamp) AS end_time,
       COUNT(*) AS record_count,
       DATEDIFF('second', MIN(ingest_timestamp), MAX(ingest_timestamp)) AS processing_time_seconds
FROM {{ ref('stg_coincap__assets') }}
GROUP BY 1