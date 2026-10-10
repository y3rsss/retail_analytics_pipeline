with order_items as (
    select *
    from {{ ref('fct_order_items') }}
    where order_status not in ('canceled', 'unavailable')
),

products as (
    select * from {{ ref('dim_products') }}
),

orders as (
    select
        order_id,
        review_score
    from {{ ref('fct_orders') }}
),

category_items as (
    select
        products.category_name,
        order_items.order_id,
        order_items.price
    from order_items
    join products on products.product_id = order_items.product_id
),

category_totals as (
    select
        category_name,
        count(*) as items_sold,
        count(distinct order_id) as orders,
        sum(price) as revenue,
        avg(price) as average_item_price
    from category_items
    group by category_name
),

category_reviews as (
    select
        category_orders.category_name,
        avg(orders.review_score) as average_review_score
    from (
        select distinct
            category_name,
            order_id
        from category_items
    ) as category_orders
    join orders on orders.order_id = category_orders.order_id
    group by category_orders.category_name
),

ranked_categories as (
    select
        category_totals.*,
        category_reviews.average_review_score,
        category_totals.revenue / sum(category_totals.revenue) over () as revenue_share,
        sum(category_totals.revenue) over (order by category_totals.revenue desc rows between unbounded preceding and current row)
            / sum(category_totals.revenue) over () as cumulative_revenue_share,
        rank() over (order by category_totals.revenue desc) as revenue_rank
    from category_totals
    left join category_reviews on category_reviews.category_name = category_totals.category_name
)

select
    category_name,
    revenue_rank,
    revenue,
    items_sold,
    orders,
    round(average_item_price, 2) as average_item_price,
    round(average_review_score, 2) as average_review_score,
    round(revenue_share, 4) as revenue_share,
    round(cumulative_revenue_share, 4) as cumulative_revenue_share,
    cumulative_revenue_share - revenue_share < 0.8 as is_top_80_percent
from ranked_categories