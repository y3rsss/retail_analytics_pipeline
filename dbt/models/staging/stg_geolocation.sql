with source as (
    select * from {{ source('raw', 'geolocation') }}
),

typed as (
    select
        geolocation_zip_code_prefix as zip_code_prefix,
        cast(geolocation_lat as numeric) as latitude,
        cast(geolocation_lng as numeric) as longitude,
        geolocation_state as state
    from source
),

inside_brazil as (
    select *
    from typed
    where latitude between -35 and 6
        and longitude between -75 and -34
),

one_row_per_zip as (
    select
        zip_code_prefix,
        avg(latitude) as latitude,
        avg(longitude) as longitude,
        max(state) as state
    from inside_brazil
    group by zip_code_prefix
)

select * from one_row_per_zip