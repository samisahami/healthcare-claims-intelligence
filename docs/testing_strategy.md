# Testing Strategy

## Overview

The Healthcare Claims Intelligence platform uses multiple layers of automated testing to validate data quality and pipeline reliability.

Testing occurs at three levels:

1. dbt model tests

2. Python integration tests

3. End-to-end CI validation

This approach validates both individual data models and the complete analytics pipeline.

## dbt Tests

dbt tests validate assumptions directly within the transformation layer.

Tests include:

- `not_null`

- `unique`

- Relationship and model-level data quality checks

- Custom SQL tests where appropriate

Primary identifiers are tested to ensure critical analytical models maintain their expected grain.

For example, `claim_id` is expected to uniquely identify records in the claim-level fact model.

Running:

```bash

docker compose run --rm dbt build