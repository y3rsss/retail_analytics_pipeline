with orders as (
    select
        *,
        date_trunc('month', purchase_date)::date as order_month
    from {{ ref('fct_orders') }}
    where order_status not in ('canceled', 'unavailable')
),

monthly_totals as (
    select
        order_month,
        count(*) as orders,
        count(distinct customer_unique_id) as customers,
        sum(items_value) as revenue,
        sum(freight_value) as freight,
        avg(is_late::integer) as late_delivery_rate,
        avg(review_score) as average_review_score
    from orders
    group by order_month
)

select
    order_month,
    orders,
    customers,
    revenue,
    round(revenue / orders, 2) as average_order_value,
    freight,
    round(late_delivery_rate, 4) as late_delivery_rate,
    round(average_review_score, 2) as average_review_score,
    round((revenue - lag(revenue) over (order by order_month)) / nullif(lag(revenue) over (order by order_month), 0), 4) as revenue_growth_rate
from monthly_totals