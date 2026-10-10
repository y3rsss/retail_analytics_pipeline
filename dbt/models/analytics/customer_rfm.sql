with orders as (
    select
        customer_unique_id,
        purchase_date,
        items_value
    from {{ ref('fct_orders') }}
    where order_status not in ('canceled', 'unavailable')
),

reference_date as (
    select max(purchase_date) as as_of_date
    from orders
),

customer_metrics as (
    select
        customer_unique_id,
        max(purchase_date) as last_order_date,
        count(*) as order_count,
        sum(items_value) as total_spent
    from orders
    group by customer_unique_id
),

scored_customers as (
    select
        customer_metrics.*,
        reference_date.as_of_date - customer_metrics.last_order_date as days_since_last_order,
        ntile(5) over (order by customer_metrics.last_order_date) as recency_score,
        ntile(5) over (order by customer_metrics.total_spent) as monetary_score
    from customer_metrics
    cross join reference_date
)

select
    *,
    case
        when order_count >= 2 and recency_score >= 4 then 'Repeat - active'
        when order_count >= 2 then 'Repeat - lapsing'
        when monetary_score = 5 and recency_score >= 4 then 'High value - recent'
        when monetary_score = 5 then 'High value - lapsed'
        when recency_score >= 4 then 'One-time - recent'
        else 'One-time - lapsed'
    end as segment
from scored_customers