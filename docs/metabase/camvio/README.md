# Camvio Metabase Documentation

This directory contains Metabase models and configurations for data sourced from the **Camvio Snowflake instance**.

## Database Context

- **Database**: Camvio Snowflake
- **Schema**: PUBLIC
- **Access**: Read-only

## Contents

### Models (`models/`)
Documentation for Metabase models built from Camvio data sources.

All models in this directory:
- Reference queries in `snowflake/camvio/queries/`
- Use data from the Camvio Snowflake instance (read-only)
- Source from `CAMVIO.PUBLIC.*` tables

## Model Files

Current models include:
- **Installs by Individual** - Technician visit data from completed service orders
- **Service Orders with Charges** - Service orders with associated charges and credits
- **Service Orders Charges by Type** - Charges aggregated by type
- **Service Orders Commission Detail** - Detailed commission information
- **Combined Installs and Trouble Tickets** - Unified view of installations and trouble tickets
- **Appointments with Orders and Tickets (Base)** - All appointments with related service orders or trouble tickets
  - Documentation: [`models/APPOINTMENTS_WITH_ORDERS_AND_TICKETS.md`](./models/APPOINTMENTS_WITH_ORDERS_AND_TICKETS.md)
  - Semantic Types: [`models/APPOINTMENTS_WITH_ORDERS_AND_TICKETS_SEMANTIC_TYPES.md`](./models/APPOINTMENTS_WITH_ORDERS_AND_TICKETS_SEMANTIC_TYPES.md)
  - Source: `snowflake/camvio/queries/appointments_with_orders_and_tickets.sql`
  - Includes feature pricing aggregates for service order appointments

Each model may have multiple documentation files:
- `*_SEMANTIC_TYPES.md` - Recommended semantic type settings
- `*_COLUMN_MAPPING.md` - Detailed column mapping documentation
- `*_JOIN_COLUMNS.md` - Join column reference (if applicable)

## Related Files

- Snowflake queries: `snowflake/camvio/queries/`
- Discovery queries: `snowflake/camvio/DISCOVERY_QUERIES.sql`
- Schema documentation: `snowflake/camvio/SCHEMA_DOCUMENTATION.md`

## Notes

- Some models mention potential joins to Fybe data (e.g., `SERVICEORDER_ID` joins to Fybe `WORK_PACKAGE`), but the models themselves only query Camvio data
- For models that actually query both Fybe and Camvio, see `../combined/`
