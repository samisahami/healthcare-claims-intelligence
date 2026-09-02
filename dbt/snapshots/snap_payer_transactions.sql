{% snapshot snap_payer_transitions %}

{{
    config(
        target_schema='snapshots',
        unique_key="patient_id || '|' || start_date::text",
        strategy='check',
        check_cols=[
            'member_id',
            'payer_id',
            'secondary_payer_id',
            'end_date',
            'plan_ownership',
            'owner_name'
        ]
    )
}}

select
    patient_id,
    member_id,
    payer_id,
    secondary_payer_id,
    start_date,
    end_date,
    plan_ownership,
    owner_name
from {{ ref('stg_synthea__payer_transitions') }}

{% endsnapshot %}