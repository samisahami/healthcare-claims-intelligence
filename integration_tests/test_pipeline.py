import os

import psycopg2


def get_connection():
    return psycopg2.connect(
        host=os.getenv("POSTGRES_HOST", "127.0.0.1"),
        port=os.getenv("POSTGRES_PORT", "55432"),
        dbname=os.getenv("POSTGRES_DB", "healthcare_analytics"),
        user=os.getenv("POSTGRES_USER", "healthcare"),
        password=os.getenv("POSTGRES_PASSWORD", "healthcare"),
    )


def test_fct_claims_has_unique_claims():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                select
                    count(*) as row_count,
                    count(distinct claim_id) as distinct_claims
                from analytics.fct_claims
            """)
            row_count, distinct_claims = cur.fetchone()

    assert row_count > 0
    assert row_count == distinct_claims


def test_fct_member_month_has_no_duplicates():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                select count(*)
                from (
                    select
                        patient_id,
                        coverage_month
                    from analytics.fct_member_month
                    group by
                        patient_id,
                        coverage_month
                    having count(*) > 1
                ) duplicates
            """)
            duplicate_count = cur.fetchone()[0]

    assert duplicate_count == 0


def test_monthly_claim_metrics_has_rows():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                select count(*)
                from analytics.fct_monthly_claim_metrics
            """)
            row_count = cur.fetchone()[0]

    assert row_count > 0


def test_snapshot_has_rows():
    with get_connection() as conn:
        with conn.cursor() as cur:
            cur.execute("""
                select count(*)
                from snapshots.snap_payer_transitions
            """)
            row_count = cur.fetchone()[0]

    assert row_count > 0