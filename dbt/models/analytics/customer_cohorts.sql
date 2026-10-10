with orders as (
    select
        customer_unique_id,
        date_trunc('month', purchase_date)::date as order_month
    from {{ ref('fct_orders') }}
),

customers as (
    select
        customer_unique_id,
        first_order_month as cohort_month
    from {{ ref('dim_customers') }}
),

customer_activity as (
    select distinct
        customers.cohort_month,
        customers.customer_unique_id,
        ((extract(year from orders.order_month) - extract(year from customers.cohort_month)) * 12
            + (extract(month from orders.order_month) - extract(month from customers.cohort_month)))::integer as months_since_first_order
    from orders
    join customers on customers.customer_unique_id = orders.customer_unique_id
),

cohort_sizes as (
    select
        cohort_month,
        count(*) as cohort_size
    from customers
    group by cohort_month
),

monthly_activity as (
    select
        cohort_month,
        months_since_first_order,
        count(*) as active_customers
    from customer_activity
    group by cohort_month, months_since_first_order
)

select
    monthly_activity.cohort_month,
    monthly_activity.months_since_first_order,
    cohort_sizes.cohort_size,
    monthly_activity.active_customers,
    round(monthly_activity.active_customers::numeric / cohort_sizes.cohort_size, 4) as retention_rate
from monthly_activity
join cohort_sizes on cohort_sizes.cohort_month = monthly_activity.cohort_month