# Camvio Queries

This directory contains SQL queries for the Camvio Snowflake instance, including queries migrated from Tableau and new queries for Metabase.

## Query Files

### `installs_by_individual.sql`
- **Source**: Tableau (migrating to Metabase)
- **Purpose**: Get installs by individual technician who completed the install (comprehensive version)
- **Filters**: 
  - `TASK_NAME` = 'TECHNICIAN VISIT'
  - `STATUS` = 'COMPLETED'
- **Key Fields**: ASSIGNEE (technician), TASK_ENDED, appointment details, service line features
- **Tables**: 6 tables (includes APPOINTMENTS and SERVICELINE_FEATURES)
- **Note**: Currently Camvio-only (no Fybe join)
- **Use When**: You need appointment or feature-level data

### `revised_installs_by_individual.sql` ⭐ **RECOMMENDED FOR CORE USE CASE**
- **Purpose**: Optimized version focused on core requirements (technician, account type, date, address)
- **Filters**: 
  - `TASK_NAME` = 'TECHNICIAN VISIT'
  - `STATUS` = 'COMPLETED'
  - `TASK_ENDED IS NOT NULL`
- **Key Fields**: ASSIGNEE (technician), ACCOUNT_TYPE, TASK_ENDED (date), address fields
- **Tables**: 4 tables (removed APPOINTMENTS and SERVICELINE_FEATURES)
- **Optimizations**: 40% fewer JOINs, 40% fewer columns, faster performance
- **Use When**: You only need core install tracking metrics (technician, account type, date, address)

### `installs_by_individual_with_fybe.sql`
- **Enhanced version** of `installs_by_individual.sql`
- **Adds**: Fybe Render Tickets data via `WORK_PACKAGE` = `SERVICEORDER_ID` join
- **Purpose**: Same as above, but enriched with Fybe project and work activity data
- **Use Case**: When you need both Camvio service order details and Fybe work details

## Usage in Metabase

### Model Structure

**`installs_by_individual.sql`** is designed to be used as a **base model** in Metabase:

1. **Base Model**: `Installs by Individual (Base)`
   - Use the SQL from `installs_by_individual.sql` as the model query
   - This provides raw data from Camvio
   - No custom columns or calculations

2. **Enhanced Model**: `Installs by Individual (Enhanced)`
   - Create a new model based on the base model
   - Add custom columns, calculated fields, and business logic
   - See `docs/metabase/models/INSTALLS_BY_INDIVIDUAL.md` for custom column examples

### Other Usage Options

These queries can also be used as:
1. **Native Queries**: Direct SQL queries in Metabase (for ad-hoc analysis)
2. **Reference**: Examples of how to join Camvio tables

## Adding New Queries

When adding new queries:
1. Use descriptive file names (snake_case)
2. Include header comments with purpose and key filters
3. Document any special join logic or data type conversions
4. Note if query is Camvio-only or includes Fybe joins
5. Update this README with query description

## Notes

- All queries use `CAMVIO.PUBLIC` schema prefix
- Fybe queries use `DATA_LAKE.ANALYTICS` schema prefix
- Remember: `ORDER_ID` ≠ `SERVICEORDER_ID` - only `SERVICEORDER_ID` relates to Fybe `WORK_PACKAGE`

