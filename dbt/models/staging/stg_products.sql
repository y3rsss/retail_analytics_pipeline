with source as (
    select * from {{ source('raw', 'products') }}
),

renamed as (
    select
        product_id,
        product_category_name as category_name_portuguese,
        cast(cast(product_name_lenght as numeric) as integer) as name_length,
        cast(cast(product_description_lenght as numeric) as integer) as description_length,
        cast(cast(product_photos_qty as numeric) as integer) as photos_count,
        cast(cast(product_weight_g as numeric) as integer) as weight_grams,
        cast(cast(product_length_cm as numeric) as integer) as length_cm,
        cast(cast(product_height_cm as numeric) as integer) as height_cm,
        cast(cast(product_width_cm as numeric) as integer) as width_cm,
        _loaded_at
    from source
)

select * from renamed