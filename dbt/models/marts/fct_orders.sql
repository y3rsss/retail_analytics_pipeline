with orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
),

order_items as (
    select * from {{ ref('stg_order_items') }}
),

payments as (
    select * from {{ ref('stg_order_payments') }}
),

reviews as (
    select * from {{ ref('stg_order_reviews') }}
),

item_totals as (
    select
        order_id,
        count(*) as item_count,
        sum(price) as items_value,
        sum(freight_value) as freight_value
    from order_items
    group by order_id
),

payment_totals as (
    select
        order_id,
        sum(payment_value) as payment_value,
        max(installments) as max_installments
    from payments
    group by order_id
),

primary_payments as (
    select
        order_id,
        payment_type as primary_payment_type
    from (
        select
            order_id,
            payment_type,
            row_number() over (partition by order_id order by payment_value desc, payment_sequence) as payment_rank
        from payments
    ) as ranked_payments
    where payment_rank = 1
),

latest_reviews as (
    select
        order_id,
        review_score
    from (
        select
            order_id,
            review_score,
            row_number() over (partition by order_id order by created_at desc, answered_at desc, review_id) as review_rank
        from reviews
    ) as ranked_reviews
    where review_rank = 1
)

select
    orders.order_id,
    customers.customer_unique_id,
    orders.purchased_at::date as purchase_date,
    orders.order_status,
    orders.purchased_at,
    orders.delivered_at,
    orders.estimated_delivery_at,
    coalesce(item_totals.item_count, 0) as item_count,
    coalesce(item_totals.items_value, 0) as items_value,
    coalesce(item_totals.freight_value, 0) as freight_value,
    payment_totals.payment_value,
    payment_totals.max_installments,
    primary_payments.primary_payment_type,
    orders.delivered_at::date - orders.purchased_at::date as delivery_days,
    orders.delivered_at::date - orders.estimated_delivery_at::date as days_late,
    orders.delivered_at::date > orders.estimated_delivery_at::date as is_late,
    latest_reviews.review_score
from orders
join customers on customers.customer_id = orders.customer_id
left join item_totals on item_totals.order_id = orders.order_id
left join payment_totals on payment_totals.order_id = orders.order_id
left join primary_payments on primary_payments.order_id = orders.order_id
left join latest_reviews on latest_reviews.order_id = orders.order_id