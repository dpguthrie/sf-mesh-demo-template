{% snapshot tpch_part_snapshot %}

{{ config(
    target_schema='snapshots',
    unique_key='p_partkey',
    strategy='timestamp',
    updated_at='_etl_updated_timestamp',
)}}

select * from {{ source('tpch', 'part') }}

{% endsnapshot %}