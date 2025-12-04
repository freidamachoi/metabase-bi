# Query Results

This directory contains exported CSV files from the Camvio Snowflake discovery queries.

## Naming Convention

Use descriptive names that indicate which query the results came from:

- `query-01-schemas.csv` - All available schemas
- `query-02-tables-views.csv` - All tables and views
- `query-03-all-columns.csv` - All columns (may be large)
- `query-07-join-keys.csv` - Potential join key fields
- `query-08-date-fields.csv` - Date/time fields
- `query-09-status-fields.csv` - Status fields
- `query-15-quick-overview.csv` - Quick overview summary (START HERE)

## Usage

These CSV files serve as:
1. **Reference data** - Quick lookup of table/column names
2. **Documentation source** - Use to populate SCHEMA_DOCUMENTATION.md
3. **Version control** - Track changes in database structure over time

## Notes

- Large CSV files (like query-03-all-columns.csv) may be excluded from git if they exceed reasonable size limits
- Focus on documenting key tables in SCHEMA_DOCUMENTATION.md rather than including every detail
- Use these files to identify which tables are most relevant for joining with Fybe data

