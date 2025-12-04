# Camvio Data Requirements

## What Information is Needed

To enable cross-instance analysis and reporting between Fybe and Camvio Snowflake instances, we need the following information:

### 1. Available Tables and Views

**Action Required**: List all accessible tables/views in the Camvio instance.

**Information Needed**:
- Schema name (e.g., `ANALYTICS`, `DATA_LAKE`, etc.)
- Table/view name
- Brief description of what the table contains
- Primary key field(s)

**Where to Document**: `snowflake/camvio/SCHEMA_DOCUMENTATION.md`

### 2. Key Fields for Joining

**Action Required**: Identify fields that can be used to join Camvio data with Fybe data.

**Common Join Keys to Look For**:
- `PROJECT_ID` - Project identifier
- `ASSET_ID` - Asset identifier  
- `TASK_ID` - Task identifier
- `CONTRACTOR` - Contractor name
- Any other common identifiers

**Information Needed**:
- Field name
- Data type
- Whether it can reliably join with Fybe data
- Any data quality concerns (nulls, format differences, etc.)

### 3. Date/Time Fields

**Action Required**: Document all date and time fields available in Camvio tables.

**Fields to Look For**:
- Creation dates
- Completion dates
- Approval dates
- Release dates
- Target/due dates
- Any other temporal fields

**Information Needed**:
- Field name
- Data type (TIMESTAMP, DATE, etc.)
- What the date represents
- Whether it's nullable

### 4. Status and Categorical Fields

**Action Required**: Document status fields and their possible values.

**Information Needed**:
- Field name
- Possible values (e.g., "Active", "Completed", "Jeopardy")
- Meaning of each value
- Whether values match Fybe status values (for consistency)

### 5. Sample Data Structure

**Action Required**: Provide sample row(s) or describe the data structure.

**Information Needed**:
- Example of what a typical row looks like
- Field names and sample values
- Any special formatting or encoding

### 6. Data Dictionary

**Action Required**: Document business meanings of important fields.

**Information Needed**:
- Field name
- Business description
- How it relates to business processes
- Any calculations or derivations

## How to Gather This Information

### Option 1: Snowflake Query

Run this query in Camvio Snowflake to list all accessible tables:

```sql
-- List all tables in accessible schemas
SELECT 
    table_schema,
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY table_schema, table_name;
```

### Option 2: Metabase Connection

1. Connect Metabase to Camvio Snowflake instance
2. Browse available tables in Metabase
3. Document table names and structures
4. Sample a few rows to understand data

### Option 3: Schema Documentation

If Camvio provides schema documentation, that would be ideal.

## Recommended Approach

1. **Start with High-Level Overview**:
   - List all schemas you have access to
   - List all tables/views in each schema
   - Identify which ones seem most relevant to your use case

2. **Focus on Key Tables**:
   - Identify tables that likely contain project, task, or asset data
   - These are most likely to join with Fybe data

3. **Document Structure**:
   - For each relevant table, document:
     - All column names
     - Data types
     - Sample values
     - Relationships to other tables

4. **Identify Join Opportunities**:
   - Compare Camvio fields with Fybe fields
   - Document potential join keys
   - Note any data quality concerns

## Template for Documentation

Use the template in `snowflake/camvio/SCHEMA_DOCUMENTATION.md` to document your findings. The template includes:
- Table/view documentation format
- Join strategy section
- Sample queries section
- Data quality notes

## Next Steps After Documentation

Once we have the Camvio schema documented:

1. **Create Metabase Models**:
   - Base models pointing to Camvio tables
   - Enriched models with custom columns (if needed)

2. **Create Combined Models**:
   - Models that join Fybe and Camvio data
   - Document join logic and performance considerations

3. **Build Dashboards**:
   - Create visualizations combining data from both instances
   - Document any limitations or considerations

## Questions to Answer

When documenting Camvio data, try to answer:

1. What is the primary purpose of each table?
2. How does this data relate to Fybe data?
3. What are the key identifiers for joining?
4. Are there any data quality issues to be aware of?
5. What time periods does the data cover?
6. How frequently is the data updated?
7. Are there any filters or exclusions applied (like QA/test projects in Fybe)?

## Support

If you need help documenting the schema or have questions about what information is most important, refer to:
- The Fybe views in `snowflake/fybe/` as examples
- The Metabase custom column definitions in `docs/metabase/` to understand what fields might be useful

