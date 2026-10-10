with order_items as (
    select * from {{ ref('stg_order_items') }}
),

orders as (
    select * from {{ ref('stg_orders') }}
),

customers as (
    select * from {{ ref('stg_customers') }}
)

select
    order_items.order_item_key,
    order_items.order_id,
    order_items.item_number,
    order_items.product_id,
    order_items.seller_id,
    customers.customer_unique_id,
    orders.purchased_at::date as purchase_date,
    orders.order_status,
    order_items.price,
    order_items.freight_value,
    order_items.price + order_items.freight_value as total_value
from order_items
join orders on orders.order_id = order_items.order_id
join customers on customers.customer_id = orders.customer_id