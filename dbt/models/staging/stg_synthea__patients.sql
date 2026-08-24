with source as (

    select *
    from {{ source('synthea', 'patients') }}

),

renamed as (

    select
        "Id" as patient_id,

        nullif("BIRTHDATE", '')::date as birth_date,
        nullif("DEATHDATE", '')::date as death_date,

        nullif("SSN", '') as ssn,
        nullif("DRIVERS", '') as drivers_license,
        nullif("PASSPORT", '') as passport_number,

        nullif("PREFIX", '') as name_prefix,
        nullif("FIRST", '') as first_name,
        nullif("MIDDLE", '') as middle_name,
        nullif("LAST", '') as last_name,
        nullif("SUFFIX", '') as name_suffix,

        nullif("MAIDEN", '') as maiden_name,
        nullif("MARITAL", '') as marital_status,

        nullif("RACE", '') as race,
        nullif("ETHNICITY", '') as ethnicity,
        nullif("GENDER", '') as gender,
        nullif("BIRTHPLACE", '') as birth_place,

        nullif("ADDRESS", '') as address,
        nullif("CITY", '') as city,
        nullif("STATE", '') as state,
        nullif("COUNTY", '') as county,
        nullif("FIPS", '') as fips_code,
        nullif("ZIP", '') as zip_code,

        nullif("LAT", '')::numeric as latitude,
        nullif("LON", '')::numeric as longitude,

        nullif("HEALTHCARE_EXPENSES", '')::numeric(18, 2) as healthcare_expenses,
        nullif("HEALTHCARE_COVERAGE", '')::numeric(18, 2) as healthcare_coverage,
        nullif("INCOME", '')::numeric(18, 2) as income,

        "_source_file" as source_file,
        "_load_batch_id" as load_batch_id,
        "_ingested_at" as ingested_at

    from source

)

select *
from renamed