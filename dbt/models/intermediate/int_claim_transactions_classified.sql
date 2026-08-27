with transactions as (

    select *
    from {{ ref('stg_synthea__claims_transactions') }}

),

classified as (

    select
        claim_transaction_id,
        claim_id,
        patient_id,
        transaction_type,
        transaction_amount,

        case
            when transaction_type = 'CHARGE'
                then transaction_amount
            else 0
        end as charge_amount,

        case
            when transaction_type = 'PAYMENT'
                then transaction_amount
            else 0
        end as payment_amount,

        case
            when transaction_type = 'TRANSFERIN'
                then transaction_amount
            else 0
        end as transfer_in_amount,

        case
            when transaction_type = 'TRANSFEROUT'
                then transaction_amount
            else 0
        end as transfer_out_amount,

        from_at,
        to_at,
        provider_id,
        procedure_code,

        source_file,
        load_batch_id,
        ingested_at

    from transactions

)

select *
from classified