with products as (
    select * from {{ ref('stg_products') }}
),

translations as (
    select * from {{ ref('stg_product_category_translation') }}
)

select
    products.product_id,
    initcap(replace(coalesce(translations.category_name_english, products.category_name_portuguese, 'unknown'), '_', ' ')) as category_name,
    products.category_name_portuguese,
    products.photos_count,
    products.weight_grams,
    products.length_cm,
    products.height_cm,
    products.width_cm
from products
left join translations
    on translations.category_name_portuguese = products.category_name_portuguese