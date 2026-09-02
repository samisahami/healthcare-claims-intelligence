with member_months as (

    select *
    from {{ ref('int_member_months') }}

),

final as (

    select
        patient_id,
        member_id,
        payer_id,
        secondary_payer_id,
        coverage_month

    from member_months

)

select *
from final