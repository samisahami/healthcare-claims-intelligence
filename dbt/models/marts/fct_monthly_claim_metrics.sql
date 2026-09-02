with monthly_claims as (

    select
        date_trunc('month', service_date)::date as service_month,
        count(*) as claim_count,
        sum(total_charge_amount) as total_charge_amount,
        sum(total_payment_amount) as total_payment_amount

    from {{ ref('fct_claims') }}

    group by 1

),

monthly_members as (

    select
        coverage_month,
        count(distinct patient_id) as eligible_members

    from {{ ref('fct_member_month') }}

    group by 1

),

final as (

    select
        m.coverage_month,
        m.eligible_members,

        coalesce(c.claim_count, 0) as claim_count,
        coalesce(c.total_charge_amount, 0) as total_charge_amount,
        coalesce(c.total_payment_amount, 0) as total_payment_amount,

        coalesce(c.claim_count, 0) * 1000.0
            / nullif(m.eligible_members, 0) as claims_per_1000,

        coalesce(c.total_charge_amount, 0)
            / nullif(m.eligible_members, 0) as charge_pmpm

    from monthly_members m

    left join monthly_claims c
        on m.coverage_month = c.service_month

)

select *
from final