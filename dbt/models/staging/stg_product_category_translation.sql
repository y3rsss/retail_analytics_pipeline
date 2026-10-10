with source as (
    select * from {{ source('raw', 'product_category_name_translation') }}
),

renamed as (
    select
        product_category_name as category_name_portuguese,
        product_category_name_english as category_name_english,
        _loaded_at
    from source
)

select * from renamed