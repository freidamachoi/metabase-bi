# Metabase Documentation

This directory contains documentation for Metabase models, custom columns, and configurations organized by data source.

## Directory Structure

```
metabase/
├── fybe/              # Fybe-specific models and custom columns
│   └── models/       # Fybe data models
├── camvio/           # Camvio-specific models
│   └── models/       # Camvio data models
└── combined/         # Models that join Fybe and Camvio data
    └── models/       # Combined/integrated models
```

## Organization

### Fybe (`fybe/`)
Contains models, custom columns, and configurations for data sourced from the Fybe Snowflake instance (DATA_LAKE database).

- **Custom Column Definitions**: Metabase custom column definitions for Fybe models
- **Models**: Documentation for models built from Fybe data sources

### Camvio (`camvio/`)
Contains models and configurations for data sourced from the Camvio Snowflake instance (read-only access).

- **Models**: Documentation for models built from Camvio data sources
- All models reference queries in `snowflake/camvio/queries/`

### Combined (`combined/`)
Contains models that integrate data from both Fybe and Camvio sources.

- **Models**: Documentation for unified models that join Fybe and Camvio data
- Currently empty - use this directory for future integrated models

## Notes

- Models may reference join keys between Fybe and Camvio (e.g., `SERVICEORDER_ID` joins to Fybe `WORK_PACKAGE`), but if the model only queries one source, it belongs in that source's directory
- Models that actually query both databases should be placed in `combined/`
