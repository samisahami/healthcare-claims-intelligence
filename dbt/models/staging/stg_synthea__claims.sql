with source as (

    select *
    from {{ source('synthea', 'claims') }}

),

renamed as (

    select
        "Id" as claim_id,
        "PATIENTID" as patient_id,
        "PROVIDERID" as provider_id,
        "PRIMARYPATIENTINSURANCEID" as primary_payer_id,
        "SECONDARYPATIENTINSURANCEID" as secondary_payer_id,
        "DEPARTMENTID" as department_id,
        "PATIENTDEPARTMENTID" as patient_department_id,

        "DIAGNOSIS1" as diagnosis_1,
        "DIAGNOSIS2" as diagnosis_2,
        "DIAGNOSIS3" as diagnosis_3,
        "DIAGNOSIS4" as diagnosis_4,
        "DIAGNOSIS5" as diagnosis_5,
        "DIAGNOSIS6" as diagnosis_6,
        "DIAGNOSIS7" as diagnosis_7,
        "DIAGNOSIS8" as diagnosis_8,

        "REFERRINGPROVIDERID" as referring_provider_id,
        "APPOINTMENTID" as appointment_id,


        nullif("CURRENTILLNESSDATE", '')::date as current_illness_date,
        nullif("SERVICEDATE", '')::date as service_date,

        "SUPERVISINGPROVIDERID" as supervising_provider_id,

        "STATUS1" as status_1,
        "STATUS2" as status_2,
        "STATUSP" as status_p,

        nullif("OUTSTANDING1", '')::numeric as outstanding_1,
        nullif("OUTSTANDING2", '')::numeric as outstanding_2,
        nullif("OUTSTANDINGP", '')::numeric as outstanding_p,

        nullif("LASTBILLEDDATE1", '')::date as last_billed_date_1

        

    from source

)

select *
from renamed