{% snapshot snp_coincap_assets %}

{{
    config(
      target_database='COINCAP_DB',
      target_schema='STAGING',
      unique_key='asset_id',
      strategy='timestamp',
      updated_at='load_timestamp',
    )
}}

select * from {{ ref('stg_coincap__assets') }}

{% endsnapshot %}