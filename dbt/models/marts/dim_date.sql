with date_bounds as (
    select
        date_trunc('year', min(purchased_at))::date as start_date,
        (date_trunc('year', max(estimated_delivery_at)) + interval '1 year' - interval '1 day')::date as end_date
    from {{ ref('stg_orders') }}
),

days as (
    select generate_series(start_date, end_date, interval '1 day')::date as date_day
    from date_bounds
)

select
    date_day,
    extract(year from date_day)::integer as year,
    extract(quarter from date_day)::integer as quarter,
    extract(month from date_day)::integer as month,
    to_char(date_day, 'Mon') as month_name,
    to_char(date_day, 'YYYY-MM') as year_month,
    extract(isodow from date_day)::integer as day_of_week,
    to_char(date_day, 'Dy') as day_name,
    extract(isodow from date_day) in (6, 7) as is_weekend
from days