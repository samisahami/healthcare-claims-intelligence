"""
Load Synthea CSV exports into the PostgreSQL raw schema.

Design:
- Source-faithful raw ingestion
- All source columns loaded as TEXT
- One raw table per CSV
- Full reload / idempotent behavior
- No healthcare business transformations
"""

from __future__ import annotations

import csv
import os
import uuid
from datetime import datetime, timezone
from pathlib import Path

import psycopg
from psycopg import sql


# ============================================================
# Configuration
# ============================================================

DATA_DIR = Path("data/raw/synthea/csv")

FILES = [
    "patients.csv",
    "encounters.csv",
    "claims.csv",
    "claims_transactions.csv",
    "conditions.csv",
    "procedures.csv",
    "providers.csv",
    "organizations.csv",
    "payers.csv",
    "payer_transitions.csv",
]

DB_CONFIG = {
    "host": os.getenv("POSTGRES_HOST", "postgres"),
    "port": os.getenv("POSTGRES_PORT", "5432"),
    "dbname": os.getenv("POSTGRES_DB", "healthcare_analytics"),
    "user": os.getenv("POSTGRES_USER", "healthcare"),
    "password": os.getenv("POSTGRES_PASSWORD", "healthcare"),
}


# ============================================================
# Database Connection
# ============================================================

def get_connection():
    """Return a PostgreSQL connection."""
    return psycopg.connect(**DB_CONFIG)


# ============================================================
# Raw Schema
# ============================================================

def create_raw_schema(conn) -> None:
    """Create the raw schema if it does not already exist."""
    with conn.cursor() as cur:
        cur.execute("create schema if not exists raw;")

    conn.commit()


# ============================================================
# Source Inspection
# ============================================================

def get_csv_columns(file_path: Path) -> list[str]:
    """Return the header columns from a CSV file."""
    with file_path.open("r", newline="", encoding="utf-8") as file:
        reader = csv.reader(file)

        try:
            return next(reader)
        except StopIteration as exc:
            raise ValueError(f"CSV file is empty: {file_path}") from exc


def validate_source_file(file_path: Path) -> None:
    """Validate that a required source file exists and is non-empty."""
    if not file_path.exists():
        raise FileNotFoundError(f"Required source file not found: {file_path}")

    if file_path.stat().st_size == 0:
        raise ValueError(f"Source file is empty: {file_path}")


# ============================================================
# Raw Table Creation
# ============================================================

def recreate_raw_table(
    conn,
    table_name: str,
    columns: list[str],
) -> None:
    """
    Drop and recreate a raw table.

    Source columns remain TEXT intentionally.
    Type enforcement belongs in the dbt staging layer.
    """

    source_columns = [
        sql.SQL("{} text").format(sql.Identifier(column))
        for column in columns
    ]

    metadata_columns = [
        sql.SQL("_source_file text not null"),
        sql.SQL("_load_batch_id text not null"),
        sql.SQL("_ingested_at timestamptz not null"),
    ]

    all_columns = source_columns + metadata_columns

    with conn.cursor() as cur:
        cur.execute(
            sql.SQL("drop table if exists raw.{}").format(
                sql.Identifier(table_name)
            )
        )

        cur.execute(
            sql.SQL(
                """
                create table raw.{} (
                    {}
                )
                """
            ).format(
                sql.Identifier(table_name),
                sql.SQL(", ").join(all_columns),
            )
        )

    conn.commit()


# ============================================================
# CSV Loading
# ============================================================

def load_csv(
    conn,
    file_path: Path,
    table_name: str,
    columns: list[str],
    batch_id: str,
    ingested_at: datetime,
) -> int:
    """
    Load one CSV into its corresponding raw table using PostgreSQL COPY.

    Returns the number of data rows loaded.
    """

    copy_columns = [
        sql.Identifier(column)
        for column in columns
    ] + [
        sql.Identifier("_source_file"),
        sql.Identifier("_load_batch_id"),
        sql.Identifier("_ingested_at"),
    ]

    copy_statement = sql.SQL(
        "copy raw.{} ({}) from stdin"
    ).format(
        sql.Identifier(table_name),
        sql.SQL(", ").join(copy_columns),
    )

    row_count = 0

    with file_path.open("r", newline="", encoding="utf-8") as file:
        reader = csv.reader(file)

        # Skip source header.
        next(reader)

        with conn.cursor() as cur:
            with cur.copy(copy_statement) as copy:
                for row in reader:
                    copy.write_row(
                        row
                        + [
                            file_path.name,
                            batch_id,
                            ingested_at,
                        ]
                    )

                    row_count += 1

    conn.commit()

    return row_count


# ============================================================
# Single-File Processing
# ============================================================

def process_file(
    conn,
    filename: str,
    batch_id: str,
    ingested_at: datetime,
) -> int:
    """Validate, recreate, and load a single Synthea CSV."""

    file_path = DATA_DIR / filename
    table_name = file_path.stem

    validate_source_file(file_path)

    columns = get_csv_columns(file_path)

    recreate_raw_table(
        conn=conn,
        table_name=table_name,
        columns=columns,
    )

    row_count = load_csv(
        conn=conn,
        file_path=file_path,
        table_name=table_name,
        columns=columns,
        batch_id=batch_id,
        ingested_at=ingested_at,
    )

    print(
        f"Loaded raw.{table_name}: "
        f"{row_count:,} rows"
    )

    return row_count


# ============================================================
# Pipeline
# ============================================================

def main() -> None:
    """Run the complete Synthea raw ingestion process."""

    batch_id = str(uuid.uuid4())
    ingested_at = datetime.now(timezone.utc)

    print("Starting Synthea ingestion")
    print(f"Batch ID: {batch_id}")
    print(f"Source directory: {DATA_DIR}")
    print()

    total_rows = 0

    with get_connection() as conn:
        create_raw_schema(conn)

        for filename in FILES:
            total_rows += process_file(
                conn=conn,
                filename=filename,
                batch_id=batch_id,
                ingested_at=ingested_at,
            )

    print()
    print("Synthea ingestion complete")
    print(f"Files loaded: {len(FILES)}")
    print(f"Total rows loaded: {total_rows:,}")


if __name__ == "__main__":
    main()