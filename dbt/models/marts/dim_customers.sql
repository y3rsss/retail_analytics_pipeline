with customers as (
    select * from {{ ref('stg_customers') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customer_orders as (
    select
        customers.customer_unique_id,
        customers.zip_code_prefix,
        customers.city,
        customers.state,
        orders.purchased_at
    from orders
    join customers on customers.customer_id = orders.customer_id
),

ranked_customer_orders as (
    select
        *,
        row_number() over (partition by customer_unique_id order by purchased_at desc) as recency_rank,
        min(purchased_at) over (partition by customer_unique_id) as first_order_at
    from customer_orders
)

select
    customer_unique_id,
    zip_code_prefix,
    city,
    state,
    first_order_at,
    date_trunc('month', first_order_at)::date as first_order_month
from ranked_customer_orders
where recency_rank = 1