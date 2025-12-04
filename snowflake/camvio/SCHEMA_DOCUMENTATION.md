# Camvio Snowflake Instance - Schema Documentation

> **Status**: ⚠️ **TO BE COMPLETED**  
> This document needs to be populated with information about available tables/views in the Camvio Snowflake instance.

## Overview

The Camvio Snowflake instance is **read-only** - we cannot create views, materialized views, or dynamic tables. All joins and transformations must be performed in Metabase.

## Quick Start

To discover the structure of the Camvio database, run the queries in [`DISCOVERY_QUERIES.sql`](./DISCOVERY_QUERIES.sql). 

**Recommended order:**
1. Start with **Query #15** (Quick Overview) to get a high-level view
2. Run **Query #1** to see all available schemas
3. Run **Query #2** to list all tables and views
4. Run **Query #3** to see all columns
5. Use **Queries #7-9** to find join keys, dates, and status fields
6. Run **Query #10** (sample queries) for specific tables of interest

### Saving Query Results

**Option 1: Save CSV files (Recommended for reference)**
- Download query results as CSV files
- Save them in the `query_results/` directory
- Naming convention: `query-15-quick-overview.csv`, `query-02-tables-views.csv`, etc.
- These CSV files serve as reference data and can be committed to the repository

**Option 2: Document directly in this file**
- Copy key findings from query results
- Update the "Available Tables/Views" section below with structured information
- Focus on tables that are most relevant for joining with Fybe data

**Best Practice**: Do both! Save the CSV files for reference, then document the key findings in this markdown file.

## Access Information

- **Instance**: CAMVIO-GOFYBE
- **User**: TABLEAU_GOFYBE
- **Schema**: PUBLIC
- **Warehouse**: ANALYTICS_WH
- **Access Level**: Read-only
- **Connection**: Currently uses username/password

## Available Tables/Views

### Required Information for Each Table/View

For each accessible table or view, please document:

#### Table/View Name: `[SCHEMA].[TABLE_NAME]`

- **Description**: [What this table/view contains]
- **Primary Key**: [Field name(s)]
- **Key Fields for Joining**:
  - `[FIELD_NAME]` (type): [Description and potential join to Fybe data]
  - `[FIELD_NAME]` (type): [Description]
- **Date/Time Fields**:
  - `[FIELD_NAME]` (type): [Description - creation date, completion date, etc.]
- **Status Fields**:
  - `[FIELD_NAME]` (type): [Possible values and meanings]
- **Important Fields**:
  - `[FIELD_NAME]` (type): [Description]

---

## Example Template

### Table/View Name: `ANALYTICS.PROJECTS`

- **Description**: Contains project information
- **Primary Key**: `PROJECT_ID`
- **Key Fields for Joining**:
  - `PROJECT_ID` (VARCHAR): Can join with Fybe `PROJECT_ID` fields
  - `ASSET_ID` (VARCHAR): Can join with Fybe `ASSET_ID` fields
- **Date/Time Fields**:
  - `CREATED_DATE` (TIMESTAMP_NTZ): Project creation date
  - `COMPLETED_DATE` (TIMESTAMP_NTZ): Project completion date
- **Status Fields**:
  - `STATUS` (VARCHAR): Possible values: 'Active', 'Completed', 'Cancelled'
- **Important Fields**:
  - `PROJECT_NAME` (VARCHAR): Project name
  - `CONTRACTOR` (VARCHAR): Contractor name

---

## Join Strategy with Fybe Data

### Common Join Keys

Document fields that can be used to join Camvio data with Fybe data:

| Camvio Field | Fybe Field | Join Type | Notes |
|-------------|------------|-----------|-------|
| `PROJECT_ID` | `PROJECT_ID` | Inner/Left | [Any notes about data quality, nulls, etc.] |
| `ASSET_ID` | `ASSET_ID` | Inner/Left | [Any notes] |
| `TASK_ID` | `TASK_ID` | Inner/Left | [Any notes] |

### Recommended Metabase Models

1. **[Model Name]**: 
   - Combines: [Camvio table] + [Fybe view]
   - Join on: `[FIELD_NAME]`
   - Purpose: [What this model enables]

## Sample Queries

### Example 1: [Query Purpose]

```sql
SELECT 
  c.field1,
  c.field2,
  f.field1
FROM camvio_schema.table_name c
LEFT JOIN fybe_schema.view_name f
  ON c.join_key = f.join_key
WHERE c.filter_field = 'value';
```

## Data Quality Notes

- [Any known data quality issues]
- [Null handling requirements]
- [Data freshness/update frequency]
- [Any filtering requirements]

## Next Steps

1. ✅ Document all accessible tables/views
2. ✅ Identify join keys with Fybe data
3. ✅ Create Metabase models combining both instances
4. ✅ Test query performance
5. ✅ Document any custom columns needed for Camvio data

