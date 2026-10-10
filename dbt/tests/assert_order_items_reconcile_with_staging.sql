with fact_totals as (
    select
        count(*) as row_count,
        sum(price) as total_price
    from {{ ref('fct_order_items') }}
),

staging_totals as (
    select
        count(*) as row_count,
        sum(price) as total_price
    from {{ ref('stg_order_items') }}
)

select *
from fact_totals
cross join staging_totals
where fact_totals.row_count <> staging_totals.row_count
    or fact_totals.total_price <> staging_totals.total_price