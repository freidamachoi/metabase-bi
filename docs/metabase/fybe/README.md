# Fybe Metabase Documentation

This directory contains Metabase models, custom columns, and configurations for data sourced from the **Fybe Snowflake instance**.

## Database Context

- **Database**: DATA_LAKE
- **Primary Schemas**: ANALYTICS, S3_STAGES
- **Access**: Full access (our own instance)

## Contents

### Custom Column Definitions
- `Custom Column Definitions - Render.md` - Metabase custom column definitions for Fybe models
- `Custom Column Definitions - Vetro Service Locations.md` - Custom column definitions for Vetro service locations (e.g. State default NC, CAPS)
- `drop_bury_custom_columns.txt` - Custom column definitions for drop/bury models

### Models (`models/`)
Documentation for Metabase models built from Fybe data sources.

Models in this directory:
- Reference queries in `snowflake/fybe/queries/` or views in `snowflake/fybe/`
- Use data from the DATA_LAKE database (ANALYTICS or S3_STAGES schemas)

**Current Models**:
- **Render Unit Report (Base)** - Unit-level work tracking with labor code enrichment
  - Documentation: [`models/RENDER_UNIT_REPORT.md`](./models/RENDER_UNIT_REPORT.md)
  - Semantic Types: [`models/RENDER_UNIT_REPORT_SEMANTIC_TYPES.md`](./models/RENDER_UNIT_REPORT_SEMANTIC_TYPES.md)
  - Source: `DATA_LAKE.ANALYTICS.VW_RENDER_UNITS`

- **Render Tickets Report (Base)** - Ticket-level work tracking (excludes Fybe contractor)
  - Documentation: [`models/RENDER_TICKETS_REPORT.md`](./models/RENDER_TICKETS_REPORT.md)
  - Semantic Types: [`models/RENDER_TICKETS_REPORT_SEMANTIC_TYPES.md`](./models/RENDER_TICKETS_REPORT_SEMANTIC_TYPES.md)
  - Source: `DATA_LAKE.ANALYTICS.VW_RENDER_TICKETS`
  - Filter: Excludes records where `CONTRACTOR = 'Fybe'`

- **Render Labor Unit Report (Enriched)** - Labor unit analysis with financial calculations
  - Documentation: [`models/RENDER_LABOR_UNIT_REPORT.md`](./models/RENDER_LABOR_UNIT_REPORT.md)
  - Semantic Types: [`models/RENDER_LABOR_UNIT_REPORT_SEMANTIC_TYPES.md`](./models/RENDER_LABOR_UNIT_REPORT_SEMANTIC_TYPES.md)
  - Base Model: Render Unit Report (Base)
  - Filter: `UNIT_TYPE = 'Labor'`
  - Custom Columns: 12 custom fields including financial calculations (Gross $, Net $, Retainage $)

- **Render Material Unit Report (Enriched)** - Material unit tracking with categorization
  - Documentation: [`models/RENDER_MATERIAL_UNIT_REPORT.md`](./models/RENDER_MATERIAL_UNIT_REPORT.md)
  - Semantic Types: [`models/RENDER_MATERIAL_UNIT_REPORT_SEMANTIC_TYPES.md`](./models/RENDER_MATERIAL_UNIT_REPORT_SEMANTIC_TYPES.md)
  - Base Model: Render Unit Report (Base)
  - Filter: `UNIT_TYPE = 'Material'`
  - Custom Columns: 7 custom fields for status tracking and categorization

- **Render Tickets (Enriched)** - Comprehensive ticket workflow tracking with time analysis
  - Documentation: [`models/RENDER_TICKETS_ENRICHED.md`](./models/RENDER_TICKETS_ENRICHED.md)
  - Semantic Types: [`models/RENDER_TICKETS_ENRICHED_SEMANTIC_TYPES.md`](./models/RENDER_TICKETS_ENRICHED_SEMANTIC_TYPES.md)
  - Base Model: Render Tickets (Base)
  - Filter: Inherits `CONTRACTOR != 'Fybe'` from base
  - Custom Columns: 19 custom fields including workflow tracking, time calculations, and enhanced status

## Related Files

- Snowflake queries: `snowflake/fybe/queries/`
- Snowflake views: `snowflake/fybe/*.sql`
- Discovery queries: `snowflake/fybe/DISCOVERY_QUERIES.sql`
