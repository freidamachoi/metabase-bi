# Combined Fybe + Camvio Metabase Documentation

This directory contains Metabase models that integrate data from **both Fybe and Camvio** sources.

## Purpose

Models in this directory:
- Query data from both Fybe (DATA_LAKE) and Camvio Snowflake instances
- Join data across both systems
- Provide unified views of integrated data

## Contents

### Models (`models/`)
Documentation for Metabase models that combine Fybe and Camvio data.

## When to Use This Directory

Place models here when:
- The model queries both Fybe and Camvio databases
- The model performs joins between Fybe and Camvio data sources
- The model requires data from both systems to function

## When NOT to Use This Directory

Do NOT place models here if:
- The model only queries one source (even if it mentions join keys to the other)
- The model is purely Fybe-sourced → use `../fybe/`
- The model is purely Camvio-sourced → use `../camvio/`

## Example Use Cases

- Models that join Camvio service orders with Fybe work packages
- Unified reporting across both systems
- Cross-system analytics and dashboards

## Current Status

This directory is currently empty. As integrated models are developed, they will be documented here.
