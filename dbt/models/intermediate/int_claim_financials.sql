with transactions as (

    select *
    from {{ ref('int_claim_transactions_classified') }}

),

claim_financials as (

    select
        claim_id,

        sum(charge_amount) as total_charge_amount,
        sum(payment_amount) as total_payment_amount,
        sum(transfer_in_amount) as total_transfer_in_amount,
        sum(transfer_out_amount) as total_transfer_out_amount,

        count(*) as transaction_count

    from transactions

    group by claim_id

)

select *
from claim_financials