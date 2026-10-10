with source as (
    select * from {{ source('raw', 'order_payments') }}
),

renamed as (
    select
        order_id || '-' || payment_sequential as payment_key,
        order_id,
        cast(payment_sequential as integer) as payment_sequence,
        payment_type,
        cast(payment_installments as integer) as installments,
        cast(payment_value as numeric(10, 2)) as payment_value,
        _loaded_at
    from source
)

select * from renamed