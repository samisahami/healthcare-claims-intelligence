with source as (
    select *
    from {{ source('synthea', 'payer_transitions') }}
),

renamed as (
    select 
        "PATIENT" as patient_id,
        "MEMBERID" as member_id,

        nullif("START_DATE", '')::date as start_date,
        nullif("END_DATE", '')::date as end_date,

        "PAYER" as payer_id,
        "SECONDARY_PAYER" as secondary_payer_id,

        "PLAN_OWNERSHIP" AS  plan_ownership,
        "OWNER_NAME" as owner_name,
        
        _source_file as source_file,
        _load_batch_id as load_batch_id,
        _ingested_at as ingested_at
    from source
)

select *
from renamed