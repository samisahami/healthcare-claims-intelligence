{{ config(
    materialized='incremental',
    unique_key='claim_id'
) }}

with claims as (

    select *
    from {{ ref('stg_synthea__claims') }}

    {% if is_incremental() %}

    where service_date >= (
        select max(service_date) - interval '30 days'
        from {{ this }}
    )

    {% endif %}

),

financials as (

    select *
    from {{ ref('int_claim_financials') }}

),

final as (

    select
        c.claim_id,
        c.patient_id,
        c.provider_id,
        c.primary_payer_id,
        c.secondary_payer_id,
        c.service_date,
        c.current_illness_date,
        c.status_1,
        c.status_2,
        c.status_p,
        f.total_charge_amount,
        f.total_payment_amount,
        f.total_transfer_in_amount,
        f.total_transfer_out_amount,
        f.transaction_count

    from claims c

    left join financials f
        on c.claim_id = f.claim_id
)

select *
from final