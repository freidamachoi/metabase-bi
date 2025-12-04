# Camvio Snowflake Instance - Schema Documentation

> **Status**: ✅ **DOCUMENTED**  
> Schema discovery completed. See query results in `query_results/` directory.

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

**Total**: 25 tables in `PUBLIC` schema  
**Database Type**: Telecom/Billing System (Camvio)

### Summary Statistics

| Category | Count |
|----------|-------|
| Total Tables | 25 |
| Total Rows | ~300K+ |
| Tables with Tasks | 2 (SERVICEORDER_TASKS, TROUBLE_TICKET_TASKS) |
| Tables with Status Fields | 9 |
| Tables with Date Fields | 23 |

### Key Tables for Fybe Integration

#### 1. `PUBLIC.SERVICEORDER_TASKS` (4,516 rows)
- **Description**: Tasks associated with service orders - **Most likely to join with Fybe TASK_ID**
- **Primary Key**: Likely `TASK_ID` or composite
- **Key Fields for Joining**:
  - `TASK_ID` (NUMBER): **Potential join with Fybe TASK_ID** ⚠️ Requires validation
  - `SERVICEORDER_ID` (NUMBER): Links to SERVICEORDERS table
  - `ACCOUNT_ID` (NUMBER): Primary account identifier
- **Date/Time Fields**:
  - `TASK_STARTED` (TIMESTAMP_NTZ): Task start time
  - `TASK_ENDED` (TIMESTAMP_NTZ): Task completion time
  - `LAST_UPDATE_TIME` (TIMESTAMP_NTZ): Last update timestamp
- **Status Fields**: None directly, but linked to SERVICEORDERS.STATUS
- **Important Fields**:
  - `TASK_NAME` (TEXT): Task name/description
  - `ACCOUNT_ID` (NUMBER): Account identifier

#### 2. `PUBLIC.TROUBLE_TICKET_TASKS` (7,972 rows)
- **Description**: Tasks associated with trouble tickets - **Potential join with Fybe TASK_ID**
- **Primary Key**: Likely `TASK_ID` or composite
- **Key Fields for Joining**:
  - `TASK_ID` (NUMBER): **Potential join with Fybe TASK_ID** ⚠️ Requires validation
  - `TROUBLE_TICKET_ID` (NUMBER): Links to TROUBLE_TICKETS table
  - `ACCOUNT_ID` (NUMBER): Primary account identifier
- **Date/Time Fields**:
  - `TASK_STARTED` (TIMESTAMP_NTZ): Task start time
  - `TASK_ENDED` (TIMESTAMP_NTZ): Task completion time
  - `LAST_UPDATE_TIME` (TIMESTAMP_NTZ): Last update timestamp
- **Status Fields**: None directly, but linked to TROUBLE_TICKETS.STATUS
- **Important Fields**:
  - `TASK_NAME` (TEXT): Task name/description
  - `ACCOUNT_ID` (NUMBER): Account identifier

#### 3. `PUBLIC.SERVICEORDERS` (1,338 rows)
- **Description**: Service orders/work orders
- **Primary Key**: `SERVICEORDER_ID` or `ORDER_ID`
- **Key Fields for Joining**:
  - `ORDER_ID` (NUMBER): Order identifier
  - `SERVICEORDER_ID` (NUMBER): Service order identifier
  - `ACCOUNT_ID` (NUMBER): Account identifier
  - `CREATED_SERVICELINE_ID` (NUMBER): Links to SERVICELINES
- **Date/Time Fields**:
  - `CREATED_DATETIME` (TIMESTAMP_NTZ): Order creation
  - `MODIFIED_DATETIME` (TIMESTAMP_NTZ): Last modification
  - `APPLY_DATE` (DATE): Application date
  - `TARGET_DATETIME` (DATE): Target completion date
- **Status Fields**:
  - `STATUS` (TEXT): Service order status
- **Important Fields**:
  - `ACCOUNT_ID` (NUMBER): Account identifier

#### 4. `PUBLIC.TROUBLE_TICKETS` (2,758 rows)
- **Description**: Trouble tickets/incidents
- **Primary Key**: `TROUBLE_TICKET_ID`
- **Key Fields for Joining**:
  - `TROUBLE_TICKET_ID` (NUMBER): Ticket identifier
  - `ACCOUNT_ID` (NUMBER): Account identifier
- **Date/Time Fields**:
  - `CREATED_DATETIME` (TIMESTAMP_NTZ): Ticket creation
  - `MODIFIED_DATETIME` (TIMESTAMP_NTZ): Last modification
  - `TROUBLE_DUE_DATE` (DATE): Due date
- **Status Fields**:
  - `STATUS` (TEXT): Ticket status
- **Important Fields**:
  - `ACCOUNT_ID` (NUMBER): Account identifier

#### 5. `PUBLIC.SERVICELINES` (9,516 rows)
- **Description**: Service lines (active services)
- **Primary Key**: Likely composite or `SERVICELINE_ID`
- **Key Fields for Joining**:
  - `ACCOUNT_ID` (NUMBER): Account identifier
- **Date/Time Fields**:
  - `SERVICELINE_STARTDATE` (TIMESTAMP_NTZ): Service start date
  - `SERVICELINE_ENDDATE` (TIMESTAMP_NTZ): Service end date
- **Status Fields**:
  - `SERVICELINE_STATUS` (TEXT): Service line status
- **Important Fields**:
  - `ACCOUNT_ID` (NUMBER): Account identifier

#### 6. `PUBLIC.SERVICELINE_ADDRESSES` (9,517 rows)
- **Description**: Addresses associated with service lines - **Potential join via address matching**
- **Key Fields for Joining**:
  - `ACCOUNT_ID` (NUMBER): Account identifier
  - `MAPPING_ADDRESS_ID` (TEXT): **Potential join with Fybe address/asset data** ⚠️ Requires validation
  - `MAPPING_AREA_ID` (TEXT): **Potential join with Fybe area/project data** ⚠️ Requires validation
- **Date/Time Fields**: None
- **Status Fields**:
  - `SERVICELINE_ADDRESS_STATE` (TEXT): Address state (likely US state code)
- **Important Fields**: Contains full address information

#### 7. `PUBLIC.SERVICEORDER_ADDRESSES` (1,338 rows)
- **Description**: Addresses associated with service orders
- **Key Fields for Joining**:
  - `ACCOUNT_ID` (NUMBER): Account identifier
  - `MAPPING_ADDRESS_ID` (TEXT): **Potential join with Fybe address/asset data** ⚠️ Requires validation
  - `MAPPING_AREA_ID` (TEXT): **Potential join with Fybe area/project data** ⚠️ Requires validation
  - `ORDER_ID` (NUMBER): Links to SERVICEORDERS
  - `SERVICEORDER_ID` (NUMBER): Service order identifier
- **Date/Time Fields**: None
- **Status Fields**:
  - `SERVICEORDER_ADDRESS_STATE` (TEXT): Address state

### Other Tables (Billing/Account Management)

- **CUSTOMER_ACCOUNTS** (10,502 rows): Account master data
- **CUSTOMERS** (10,630 rows): Customer contact information
- **INVOICES** (18,385 rows): Invoice header records
- **INVOICE_ITEMS** (34,739 rows): Invoice line items
- **PAYMENTS** (6,855 rows): Payment records
- **SERVICELINE_DEVICES** (11,488 rows): Devices on service lines
- **SERVICELINE_FEATURES** (12,486 rows): Features on service lines
- **SERIALIZED_INVENTORY** (14,340 rows): Inventory items
- **APPOINTMENTS** (733 rows): Appointment scheduling
- **ACCOUNT_CREDITS**, **ACCOUNT_NOTES**, **ACCOUNT_OTHER_CHARGES_CREDITS**, **ACCOUNT_RECURRING_CREDITS**: Account credit/note tables

---

## Join Strategy with Fybe Data

### ✅ Primary Join Key (CONFIRMED)

**The ONLY join point between Fybe (Render) and Camvio data:**

| Fybe View | Fybe Field | Camvio Table | Camvio Field | Join Type | Data Types |
|-----------|------------|--------------|--------------|-----------|------------|
| `VW_RENDER_TICKETS` | `WORK_PACKAGE` | `SERVICEORDERS` | `SERVICEORDER_ID` | Inner/Left | Fybe: TEXT/VARCHAR, Camvio: NUMBER |
| `VW_RENDER_UNITS` | `WORK_PACKAGE` | `SERVICEORDERS` | `SERVICEORDER_ID` | Inner/Left | Fybe: TEXT/VARCHAR, Camvio: NUMBER |

**Join Logic:**
```sql
-- In Metabase (example)
SELECT 
  f.*,
  c.*
FROM fybe_view f
LEFT JOIN camvio.SERVICEORDERS c
  ON CAST(f.WORK_PACKAGE AS NUMBER) = c.SERVICEORDER_ID
```

**Important Notes:**
- ⚠️ **Data Type Conversion**: Fybe `WORK_PACKAGE` is TEXT/VARCHAR, Camvio `SERVICEORDER_ID` is NUMBER - may need CAST/CONVERT
- ⚠️ **ORDER_ID vs SERVICEORDER_ID**: These are different fields - `ORDER_ID` does NOT equal `SERVICEORDER_ID`. Only `SERVICEORDER_ID` relates to Fybe `WORK_PACKAGE`.
- ⚠️ **TASK_IDs are NOT related**: TASK_ID values are platform-specific and have no relationship between systems
- ✅ **This is the ONLY join point** - all other fields (TASK_ID, ASSET_ID, PROJECT_ID, ORDER_ID, etc.) are independent

### Related Tables for Enrichment

Once joined on `ORDER_ID`, you can enrich with related Camvio tables:

| Camvio Table | Join Key | Purpose |
|-------------|----------|---------|
| `SERVICEORDER_TASKS` | `SERVICEORDER_ID` | Task-level details for the service order |
| `SERVICEORDER_ADDRESSES` | `SERVICEORDER_ID` | Address information for the service order |
| `SERVICEORDER_FEATURES` | `SERVICEORDER_ID` | Features associated with the service order |
| `SERVICEORDER_NOTES` | `SERVICEORDER_ID` | Notes and comments for the service order |

### Common Join Keys Summary

| Camvio Field | Fybe Field | Join Type | Status | Notes |
|-------------|------------|-----------|--------|-------|
| `SERVICEORDERS.SERVICEORDER_ID` | `VW_RENDER_TICKETS.WORK_PACKAGE` | Inner/Left | ✅ **CONFIRMED** | Primary join - may need type conversion |
| `SERVICEORDERS.SERVICEORDER_ID` | `VW_RENDER_UNITS.WORK_PACKAGE` | Inner/Left | ✅ **CONFIRMED** | Primary join - may need type conversion |
| `SERVICEORDERS.ORDER_ID` | `VW_RENDER_TICKETS.WORK_PACKAGE` | ❌ **NO RELATIONSHIP** | ❌ **INVALID** | ORDER_ID ≠ SERVICEORDER_ID, ORDER_ID does not relate to WORK_PACKAGE |
| `SERVICEORDER_TASKS.TASK_ID` | `VW_RENDER_TICKETS.TASK_ID` | ❌ **NO RELATIONSHIP** | ❌ **INVALID** | TASK_IDs are platform-specific, not related |
| `TROUBLE_TICKET_TASKS.TASK_ID` | `VW_RENDER_TICKETS.TASK_ID` | ❌ **NO RELATIONSHIP** | ❌ **INVALID** | TASK_IDs are platform-specific, not related |

### Recommended Metabase Models

1. **Fybe Render Tickets + Camvio Service Orders** (PRIMARY MODEL):
   - **Base**: `VW_RENDER_TICKETS` (Fybe)
   - **Join**: `SERVICEORDERS` (Camvio) on `WORK_PACKAGE` = `SERVICEORDER_ID`
   - **Enrichment**: 
     - `SERVICEORDER_TASKS` on `SERVICEORDER_ID`
     - `SERVICEORDER_ADDRESSES` on `SERVICEORDER_ID`
     - `SERVICEORDER_NOTES` on `SERVICEORDER_ID`
   - **Purpose**: Link Fybe render tickets to Camvio service order details
   - **Status**: ✅ **READY TO CREATE** - Join key confirmed

2. **Fybe Render Units + Camvio Service Orders**:
   - **Base**: `VW_RENDER_UNITS` (Fybe)
   - **Join**: `SERVICEORDERS` (Camvio) on `WORK_PACKAGE` = `SERVICEORDER_ID`
   - **Enrichment**: 
     - `SERVICEORDER_TASKS` on `SERVICEORDER_ID`
     - `SERVICEORDER_ADDRESSES` on `SERVICEORDER_ID`
   - **Purpose**: Link Fybe render units to Camvio service order details
   - **Status**: ✅ **READY TO CREATE** - Join key confirmed

3. **Unified Service Order View**:
   - **Base**: `SERVICEORDERS` (Camvio)
   - **Join**: `VW_RENDER_TICKETS` and `VW_RENDER_UNITS` (Fybe) on `SERVICEORDER_ID` = `WORK_PACKAGE`
   - **Purpose**: Camvio-centric view with Fybe work details
   - **Status**: ✅ **READY TO CREATE** - Join key confirmed

## Sample Queries

### Example 1: Validate WORK_PACKAGE to SERVICEORDER_ID Join

Check overlap between Fybe WORK_PACKAGE and Camvio SERVICEORDER_ID:

```sql
-- In Fybe Snowflake - Sample WORK_PACKAGE values
SELECT 
  'VW_RENDER_TICKETS' as source,
  WORK_PACKAGE,
  COUNT(*) as ticket_count,
  COUNT(DISTINCT TASK_ID) as distinct_tasks
FROM DATA_LAKE.ANALYTICS.VW_RENDER_TICKETS
WHERE WORK_PACKAGE IS NOT NULL
GROUP BY WORK_PACKAGE
ORDER BY ticket_count DESC
LIMIT 100;

-- In Camvio Snowflake - Sample SERVICEORDER_ID values
SELECT 
  'SERVICEORDERS' as source,
  SERVICEORDER_ID,
  ORDER_ID,  -- Note: ORDER_ID is different from SERVICEORDER_ID
  COUNT(*) as order_count
FROM PUBLIC.SERVICEORDERS
WHERE SERVICEORDER_ID IS NOT NULL
GROUP BY SERVICEORDER_ID, ORDER_ID
ORDER BY order_count DESC
LIMIT 100;
```

### Example 2: Fybe Render Tickets + Camvio Service Orders (Metabase Model)

```sql
-- This would be the base query for a Metabase model
SELECT 
  -- Fybe fields
  f.TASK_ID as fybe_task_id,
  f.PROJECT_ID,
  f.TASK,
  f.STATUS as fybe_status,
  f.WORK_PACKAGE,
  f.STREET_ADDRESS as fybe_address,
  f.DATE_RELEASED,
  f.DATE_COMPLETED,
  f.CONTRACTOR as fybe_contractor,
  
  -- Camvio fields
  c.SERVICEORDER_ID,  -- This is the join key (not ORDER_ID)
  c.ORDER_ID,  -- Note: ORDER_ID is different and not used for joining
  c.STATUS as camvio_order_status,
  c.ACCOUNT_ID,
  c.ACCOUNT_NUMBER,
  c.CREATED_DATETIME as camvio_created,
  c.MODIFIED_DATETIME as camvio_modified,
  c.SERVICEORDER_TYPE,
  c.SOURCE
  
FROM DATA_LAKE.ANALYTICS.VW_RENDER_TICKETS f
LEFT JOIN PUBLIC.SERVICEORDERS c
  ON CAST(f.WORK_PACKAGE AS NUMBER) = c.SERVICEORDER_ID
WHERE f.WORK_PACKAGE IS NOT NULL;
```

### Example 3: Enriched View with Service Order Tasks

```sql
-- Fybe tickets with Camvio service order and task details
SELECT 
  f.WORK_PACKAGE,
  f.TASK_ID as fybe_task_id,
  f.PROJECT_ID,
  f.STATUS as fybe_status,
  
  c.SERVICEORDER_ID,  -- Join key
  c.ORDER_ID,  -- Different field, not used for joining
  c.STATUS as camvio_order_status,
  
  sot.TASK_ID as camvio_task_id,
  sot.TASK_NAME,
  sot.TASK_STARTED,
  sot.TASK_ENDED,
  sot.ASSIGNEE
  
FROM DATA_LAKE.ANALYTICS.VW_RENDER_TICKETS f
LEFT JOIN PUBLIC.SERVICEORDERS c
  ON CAST(f.WORK_PACKAGE AS NUMBER) = c.SERVICEORDER_ID
LEFT JOIN PUBLIC.SERVICEORDER_TASKS sot
  ON c.SERVICEORDER_ID = sot.SERVICEORDER_ID
WHERE f.WORK_PACKAGE IS NOT NULL;
```

### Example 4: Check Data Type Compatibility

```sql
-- In Fybe - Check WORK_PACKAGE data types and formats
SELECT 
  WORK_PACKAGE,
  TYPEOF(WORK_PACKAGE) as data_type,
  COUNT(*) as count
FROM DATA_LAKE.ANALYTICS.VW_RENDER_TICKETS
WHERE WORK_PACKAGE IS NOT NULL
GROUP BY WORK_PACKAGE, TYPEOF(WORK_PACKAGE)
ORDER BY count DESC
LIMIT 50;

-- In Camvio - Check SERVICEORDER_ID format (the join key)
SELECT 
  SERVICEORDER_ID,
  TYPEOF(SERVICEORDER_ID) as data_type,
  ORDER_ID,  -- For comparison - note these are different
  COUNT(*) as count
FROM PUBLIC.SERVICEORDERS
WHERE SERVICEORDER_ID IS NOT NULL
GROUP BY SERVICEORDER_ID, TYPEOF(SERVICEORDER_ID), ORDER_ID
ORDER BY count DESC
LIMIT 50;
```

## Data Quality Notes

### Known Issues
- **All fields are nullable** - Most fields in Camvio tables allow NULL values
- **ACCOUNT_ID is the primary identifier** - Present in almost all tables but may be NULL
- **TASK_ID data type**: NUMBER in Camvio - need to verify Fybe TASK_ID type for joins
- **Address fields**: TEXT type - may require normalization for matching

### Null Handling Requirements
- Always check for NULL values when joining on ACCOUNT_ID, TASK_ID, or address fields
- Use COALESCE or ISNULL for critical fields in reports
- Consider LEFT JOINs to preserve Camvio data even if Fybe matches don't exist

### Data Freshness
- Tables appear to be updated regularly (LAST_ALTERED dates show recent updates)
- Most recent updates: December 2025
- Consider data latency when joining with Fybe data

### Filtering Requirements
- No obvious QA/test project filters needed (unlike Fybe which excludes QA projects)
- May want to filter by date ranges for performance
- Consider filtering by STATUS fields for active records only

## Next Steps

1. ✅ **Document all accessible tables/views** - COMPLETE
2. ✅ **Identify join keys with Fybe data** - COMPLETE
   - **Primary Join**: `WORK_PACKAGE` (Fybe) = `ORDER_ID` (Camvio) ✅ **CONFIRMED**
   - **TASK_ID**: Confirmed NO relationship between systems ✅
3. ⚠️ **Validate WORK_PACKAGE to SERVICEORDER_ID join** - **ACTION REQUIRED**
   - Sample WORK_PACKAGE values from Fybe
   - Sample SERVICEORDER_ID values from Camvio (NOT ORDER_ID - they are different)
   - Check data type compatibility (Fybe: TEXT/VARCHAR, Camvio: NUMBER)
   - Verify join logic works (may need CAST/CONVERT)
   - Check match rate (how many Fybe records have matching Camvio service orders)
4. ⏳ **Create Metabase models combining both instances** - **READY TO START**
   - Model 1: Fybe Render Tickets + Camvio Service Orders
   - Model 2: Fybe Render Units + Camvio Service Orders
   - Model 3: Unified Service Order View
5. ⏳ **Test query performance** - PENDING model creation
6. ⏳ **Document any custom columns needed for Camvio data** - PENDING model creation

## Validation Queries to Run

Before creating Metabase models, run these validation queries:

1. **WORK_PACKAGE to SERVICEORDER_ID Match Rate**: 
   - Count how many Fybe records have matching Camvio service orders
   - Identify any data quality issues (nulls, format mismatches)
   - **Important**: Use SERVICEORDER_ID, NOT ORDER_ID (they are different fields)

2. **Data Type Check**: 
   - Verify WORK_PACKAGE format in Fybe (text vs number)
   - Check if SERVICEORDER_ID in Camvio matches the format
   - Test CAST/CONVERT logic
   - **Note**: ORDER_ID and SERVICEORDER_ID are different - only SERVICEORDER_ID relates to WORK_PACKAGE

3. **Sample Join Test**: 
   - Run a sample join query to verify the logic works
   - Check for any edge cases or data quality issues

