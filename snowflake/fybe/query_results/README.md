# Query Results

This directory contains exported CSV files from the Fybe Snowflake discovery queries.

## Database Context

- **Database**: DATA_LAKE
- **Primary Schemas**: ANALYTICS, S3_STAGES
- **Note**: S3_STAGES reads from AWS S3

## Naming Convention

Use descriptive names that indicate which query the results came from:

- `query-01-all-schemas.csv` - All available schemas in DATA_LAKE
- `query-02-tables-views.csv` - All tables and views
- `query-03-analytics-schema.csv` - Tables/views in ANALYTICS schema
- `query-03-s3-stages-schema.csv` - Tables/views in S3_STAGES schema
- `query-03-primary-schemas-combined.csv` - Combined view of ANALYTICS and S3_STAGES
- `query-04-all-columns.csv` - All columns for all tables/views (may be large)
- `query-04-analytics-columns.csv` - Columns in ANALYTICS schema tables
- `query-04-s3-stages-columns.csv` - Columns in S3_STAGES schema tables
- `query-05-primary-keys.csv` - Primary keys and constraints
- `query-05-all-constraints.csv` - All constraints (Primary Keys, Foreign Keys, Unique)
- `query-05-primary-schemas-constraints.csv` - Constraints in ANALYTICS and S3_STAGES
- `query-06-foreign-keys.csv` - Foreign key relationships
- `query-07-join-keys.csv` - Potential join key fields (all schemas)
- `query-07-primary-schemas-join-keys.csv` - Join keys in ANALYTICS and S3_STAGES
- `query-08-date-fields.csv` - All date and timestamp columns
- `query-08-date-fields-patterns.csv` - Date fields with common naming patterns
- `query-08-primary-schemas-date-fields.csv` - Date fields in ANALYTICS and S3_STAGES
- `query-09-status-fields.csv` - Status fields (all schemas)
- `query-09-primary-schemas-status-fields.csv` - Status fields in ANALYTICS and S3_STAGES
- `query-10-s3-external-tables.csv` - External tables in S3_STAGES
- `query-10-s3-stages-all-objects.csv` - All objects in S3_STAGES (tables, views, external tables)
- `query-13-view-definitions.csv` - View SQL definitions (all schemas)
- `query-13-primary-schemas-view-definitions.csv` - View definitions in ANALYTICS and S3_STAGES
- `query-14-table-comments.csv` - Table/view comments (all schemas)
- `query-14-primary-schemas-table-comments.csv` - Table comments in ANALYTICS and S3_STAGES
- `query-15-column-comments.csv` - Column comments (all schemas)
- `query-15-primary-schemas-column-comments.csv` - Column comments in ANALYTICS and S3_STAGES
- `query-16-quick-overview.csv` - Quick overview summary (START HERE - all schemas)
- `query-16-quick-overview-primary-schemas.csv` - Quick overview for ANALYTICS and S3_STAGES only
- `query-17-schema-comparison.csv` - Comparison between ANALYTICS and S3_STAGES
- `query-18-cross-schema-relationships.csv` - Potential relationships between ANALYTICS and S3_STAGES

## Usage

These CSV files serve as:
1. **Reference data** - Quick lookup of table/column names in DATA_LAKE
2. **Documentation source** - Use to populate SCHEMA_DOCUMENTATION.md
3. **Version control** - Track changes in database structure over time
4. **Integration planning** - Identify join keys and relationships for combining with Camvio data

## Notes

- Large CSV files (like query-03-all-columns.csv) may be excluded from git if they exceed reasonable size limits
- Focus on documenting key tables in SCHEMA_DOCUMENTATION.md rather than including every detail
- Pay special attention to S3_STAGES schema as it contains external tables reading from AWS
- Use query-17 and query-18 to understand relationships between ANALYTICS and S3_STAGES schemas
- The ANALYTICS schema likely contains processed/transformed data, while S3_STAGES contains raw data from S3

## Recommended Query Execution Order

1. **Start with query 16** (Quick Overview) to get a high-level understanding
2. **Query 1** - See all available schemas
3. **Query 2** - List all tables and views
4. **Query 3** - Focus on primary schemas (ANALYTICS and S3_STAGES)
5. **Query 4** - Get column information (start with primary schemas)
6. **Query 7** - Identify join keys
7. **Query 8** - Find date fields for time-based analysis
8. **Query 9** - Find status fields
9. **Query 10** - Check S3_STAGES external tables
10. **Query 13** - Review view definitions
11. **Query 14** - Check table comments for documentation
12. **Query 15** - Check column comments for documentation
13. **Query 17** - Compare ANALYTICS vs S3_STAGES schemas
14. **Query 18** - Find cross-schema relationships
