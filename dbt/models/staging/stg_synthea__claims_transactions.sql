with source as (

    select *
    from {{ source('synthea', 'claims_transactions') }}

),

renamed as (

    select
        "ID" as claim_transaction_id,
        "CLAIMID" as claim_id,
        "CHARGEID" as charge_id,
        "PATIENTID" as patient_id,

        nullif("TYPE", '') as transaction_type,
        nullif("AMOUNT", '')::numeric(18, 2) as transaction_amount,
        nullif("METHOD", '') as payment_method,

        nullif("FROMDATE", '')::timestamptz as from_at,
        nullif("TODATE", '')::timestamptz as to_at,

        nullif("PLACEOFSERVICE", '') as place_of_service,
        nullif("PROCEDURECODE", '') as procedure_code,
        nullif("MODIFIER1", '') as modifier_1,
        nullif("MODIFIER2", '') as modifier_2,

        nullif("DIAGNOSISREF1", '') as diagnosis_reference_1,
        nullif("DIAGNOSISREF2", '') as diagnosis_reference_2,
        nullif("DIAGNOSISREF3", '') as diagnosis_reference_3,
        nullif("DIAGNOSISREF4", '') as diagnosis_reference_4,

        nullif("UNITS", '')::numeric as units,
        nullif("DEPARTMENTID", '') as department_id,
        nullif("NOTES", '') as notes,

        nullif("UNITAMOUNT", '')::numeric(18, 2) as unit_amount,

        nullif("TRANSFEROUTID", '') as transfer_out_id,
        nullif("TRANSFERTYPE", '') as transfer_type,

        nullif("PAYMENTS", '')::numeric(18, 2) as payments,
        nullif("ADJUSTMENTS", '')::numeric(18, 2) as adjustments,
        nullif("TRANSFERS", '')::numeric(18, 2) as transfers,
        nullif("OUTSTANDING", '')::numeric(18, 2) as outstanding_amount,

        nullif("APPOINTMENTID", '') as appointment_id,
        nullif("LINENOTE", '') as line_note,
        nullif("PATIENTINSURANCEID", '') as patient_insurance_id,
        nullif("FEESCHEDULEID", '') as fee_schedule_id,
        nullif("PROVIDERID", '') as provider_id,
        nullif("SUPERVISINGPROVIDERID", '') as supervising_provider_id,

        "_source_file" as source_file,
        "_load_batch_id" as load_batch_id,
        "_ingested_at" as ingested_at

    from source

)

select *
from renamed