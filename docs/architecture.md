# Architecture

## Overview

The Healthcare Claims Intelligence platform is an end-to-end analytics engineering project that simulates a modern healthcare claims data platform.

The architecture separates data generation, ingestion, transformation, orchestration, testing, and analytics into independent layers.

## Architecture Flow

```text
Synthea
   ↓
Python Ingestion
   ↓
PostgreSQL Raw Layer
   ↓
dbt Staging
   ↓
dbt Intermediate
   ↓
dbt Analytics Marts
   ↓
Healthcare Claims Metrics