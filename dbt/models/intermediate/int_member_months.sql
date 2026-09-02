with eligibility_spans as (

    select *
    from {{ ref('int_member_eligibility_spans') }}

),

member_months as (

    select
        patient_id,
        member_id,
        payer_id,
        secondary_payer_id,
        start_date,
        end_date,

        generate_series(
            coverage_start_month,
            coverage_end_month,
            interval '1 month'
        )::date as coverage_month

    from eligibility_spans
    where is_valid_span = true

),

deduped as (

    select
        *,
        row_number() over (
            partition by patient_id, coverage_month
            order by start_date desc, end_date desc
        ) as row_num

    from member_months

)

select
    patient_id,
    member_id,
    payer_id,
    secondary_payer_id,
    coverage_month

from deduped

where row_num = 1
