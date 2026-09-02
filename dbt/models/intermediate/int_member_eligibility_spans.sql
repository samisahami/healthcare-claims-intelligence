with payer_transitions as (

    select *
    from {{ ref('stg_synthea__payer_transitions') }}

),

eligibility_spans as (

    select
        patient_id,
        member_id,
        payer_id,
        secondary_payer_id,
        start_date,
        end_date,
        plan_ownership,
        owner_name,

        (end_date - start_date) + 1 as coverage_days,

        case
            when start_date <= end_date then true
            else false
        end as is_valid_span,

        date_trunc('month', start_date)::date as coverage_start_month,
        date_trunc('month', end_date)::date as coverage_end_month

    from payer_transitions

)

select *
from eligibility_spans