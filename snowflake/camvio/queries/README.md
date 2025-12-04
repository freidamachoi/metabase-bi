# Camvio Queries

This directory contains SQL queries for the Camvio Snowflake instance, including queries migrated from Tableau and new queries for Metabase.

## Query Files

### `installs_by_individual.sql`
- **Source**: Tableau (migrating to Metabase)
- **Purpose**: Get installs by individual technician who completed the install
- **Filters**: 
  - `TASK_NAME` = 'TECHNICIAN VISIT'
  - `STATUS` = 'COMPLETED'
- **Key Fields**: ASSIGNEE (technician), TASK_ENDED, appointment details, service line features
- **Note**: Currently Camvio-only (no Fybe join)

### `installs_by_individual_with_fybe.sql`
- **Enhanced version** of `installs_by_individual.sql`
- **Adds**: Fybe Render Tickets data via `WORK_PACKAGE` = `SERVICEORDER_ID` join
- **Purpose**: Same as above, but enriched with Fybe project and work activity data
- **Use Case**: When you need both Camvio service order details and Fybe work details

## Usage in Metabase

These queries can be used as:
1. **Native Queries**: Direct SQL queries in Metabase
2. **Model Base Queries**: Starting point for creating Metabase models
3. **Reference**: Examples of how to join Camvio tables

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

