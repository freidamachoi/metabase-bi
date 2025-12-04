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

### ⚠️ Important Note: Different Data Models

**Camvio** uses an **account-centric** model (ACCOUNT_ID as primary identifier)  
**Fybe** uses a **project/asset/task-centric** model (PROJECT_ID, ASSET_ID, TASK_ID)

**Direct joins are NOT straightforward** - we'll need to identify mapping strategies.

### Potential Join Strategies

#### Strategy 1: Task ID Matching (Most Promising)
| Camvio Table | Camvio Field | Fybe View | Fybe Field | Join Type | Validation Needed |
|-------------|--------------|-----------|------------|-----------|-------------------|
| `SERVICEORDER_TASKS` | `TASK_ID` (NUMBER) | `VW_RENDER_TICKETS` | `TASK_ID` | Inner/Left | ✅ **REQUIRES VALIDATION** - Check if TASK_ID values overlap |
| `TROUBLE_TICKET_TASKS` | `TASK_ID` (NUMBER) | `VW_RENDER_TICKETS` | `TASK_ID` | Inner/Left | ✅ **REQUIRES VALIDATION** - Check if TASK_ID values overlap |

**Action Required**: 
- Sample both TASK_ID fields to see if there's overlap
- Check data types match (Camvio: NUMBER, Fybe: likely TEXT or NUMBER)
- Validate if these represent the same task system

#### Strategy 2: Address/Asset Matching
| Camvio Table | Camvio Field | Fybe View | Fybe Field | Join Type | Validation Needed |
|-------------|--------------|-----------|------------|-----------|-------------------|
| `SERVICELINE_ADDRESSES` | `MAPPING_ADDRESS_ID` (TEXT) | `VW_RENDER_UNITS` | `STREET_ADDRESS` or `ASSET_ID` | Fuzzy/Text Match | ⚠️ **COMPLEX** - May require address normalization |
| `SERVICELINE_ADDRESSES` | `MAPPING_AREA_ID` (TEXT) | `VW_RENDER_TICKETS` | `PROJECT_ID` | Text Match | ⚠️ **REQUIRES VALIDATION** |
| `SERVICEORDER_ADDRESSES` | `MAPPING_ADDRESS_ID` (TEXT) | `VW_RENDER_UNITS` | `STREET_ADDRESS` or `ASSET_ID` | Fuzzy/Text Match | ⚠️ **COMPLEX** |

**Action Required**:
- Compare MAPPING_ADDRESS_ID with Fybe STREET_ADDRESS or ASSET_ID
- Check if MAPPING_AREA_ID relates to Fybe PROJECT_ID
- May need address standardization/normalization

#### Strategy 3: Account to Project Mapping (If Available)
If there's a mapping table or field that links ACCOUNT_ID to PROJECT_ID, this would be ideal. **Currently not identified** - may need to request from Camvio team.

### Common Join Keys Summary

| Camvio Field | Fybe Field | Join Type | Confidence | Notes |
|-------------|------------|-----------|------------|-------|
| `SERVICEORDER_TASKS.TASK_ID` | `VW_RENDER_TICKETS.TASK_ID` | Inner/Left | ⚠️ **LOW** | Requires validation - different systems may use different ID schemes |
| `TROUBLE_TICKET_TASKS.TASK_ID` | `VW_RENDER_TICKETS.TASK_ID` | Inner/Left | ⚠️ **LOW** | Requires validation |
| `SERVICELINE_ADDRESSES.MAPPING_ADDRESS_ID` | `VW_RENDER_UNITS.STREET_ADDRESS` | Fuzzy Match | ⚠️ **MEDIUM** | May require address normalization |
| `SERVICELINE_ADDRESSES.MAPPING_AREA_ID` | `VW_RENDER_TICKETS.PROJECT_ID` | Text Match | ⚠️ **LOW** | Requires validation |
| `SERVICEORDER_ADDRESSES.MAPPING_ADDRESS_ID` | `VW_RENDER_UNITS.STREET_ADDRESS` | Fuzzy Match | ⚠️ **MEDIUM** | May require address normalization |

### Recommended Metabase Models

1. **Camvio Tasks + Fybe Tasks** (if TASK_ID matches):
   - Combines: `SERVICEORDER_TASKS` + `TROUBLE_TICKET_TASKS` + `VW_RENDER_TICKETS`
   - Join on: `TASK_ID`
   - Purpose: Unified view of all tasks across both systems
   - **Status**: ⚠️ Requires TASK_ID validation first

2. **Camvio Service Orders + Fybe Render Tickets** (if address/area matches):
   - Combines: `SERVICEORDERS` + `VW_RENDER_TICKETS`
   - Join on: `MAPPING_AREA_ID` = `PROJECT_ID` (or address matching)
   - Purpose: Link service orders to Fybe project work
   - **Status**: ⚠️ Requires address/area validation first

3. **Camvio Service Lines + Fybe Render Units** (address-based):
   - Combines: `SERVICELINES` + `SERVICELINE_ADDRESSES` + `VW_RENDER_UNITS`
   - Join on: Address matching (fuzzy or normalized)
   - Purpose: Link active services to Fybe asset/work data
   - **Status**: ⚠️ Requires address normalization strategy

## Sample Queries

### Example 1: Validate TASK_ID Overlap

Check if Camvio TASK_ID values overlap with Fybe TASK_ID:

```sql
-- In Camvio Snowflake
SELECT 
  'SERVICEORDER_TASKS' as source,
  TASK_ID,
  COUNT(*) as count
FROM PUBLIC.SERVICEORDER_TASKS
WHERE TASK_ID IS NOT NULL
GROUP BY TASK_ID
ORDER BY count DESC
LIMIT 100;

-- In Fybe Snowflake (compare with)
SELECT 
  'VW_RENDER_TICKETS' as source,
  TASK_ID,
  COUNT(*) as count
FROM DATA_LAKE.ANALYTICS.VW_RENDER_TICKETS
WHERE TASK_ID IS NOT NULL
GROUP BY TASK_ID
ORDER BY count DESC
LIMIT 100;
```

### Example 2: Sample Address Data for Matching

```sql
-- Camvio addresses
SELECT 
  MAPPING_ADDRESS_ID,
  MAPPING_AREA_ID,
  ACCOUNT_ID,
  COUNT(*) as service_count
FROM PUBLIC.SERVICELINE_ADDRESSES
WHERE MAPPING_ADDRESS_ID IS NOT NULL
GROUP BY MAPPING_ADDRESS_ID, MAPPING_AREA_ID, ACCOUNT_ID
LIMIT 100;
```

### Example 3: Service Order Tasks with Dates

```sql
SELECT 
  sot.TASK_ID,
  sot.TASK_NAME,
  sot.TASK_STARTED,
  sot.TASK_ENDED,
  so.STATUS as order_status,
  so.ACCOUNT_ID
FROM PUBLIC.SERVICEORDER_TASKS sot
LEFT JOIN PUBLIC.SERVICEORDERS so
  ON sot.SERVICEORDER_ID = so.SERVICEORDER_ID
WHERE sot.TASK_STARTED >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY sot.TASK_STARTED DESC;
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
2. ✅ **Identify join keys with Fybe data** - COMPLETE (identified potential keys)
3. ⚠️ **Validate TASK_ID overlap** - **ACTION REQUIRED**
   - Sample TASK_ID values from both systems
   - Check if they represent the same task system
   - Validate data types match
4. ⚠️ **Validate address/area matching** - **ACTION REQUIRED**
   - Compare MAPPING_ADDRESS_ID with Fybe STREET_ADDRESS
   - Check if MAPPING_AREA_ID relates to PROJECT_ID
   - Develop address normalization strategy if needed
5. ⚠️ **Request mapping table** - **RECOMMENDED**
   - Ask Camvio team if there's an ACCOUNT_ID to PROJECT_ID mapping
   - This would be the cleanest join strategy
6. ⏳ **Create Metabase models combining both instances** - PENDING validation
7. ⏳ **Test query performance** - PENDING model creation
8. ⏳ **Document any custom columns needed for Camvio data** - PENDING model creation

## Validation Queries to Run

Before creating Metabase models, run these validation queries:

1. **TASK_ID Overlap Check**: Compare TASK_ID values between Camvio and Fybe
2. **Address Sample**: Get sample addresses from both systems to assess matching strategy
3. **Data Type Check**: Verify TASK_ID data types match (NUMBER vs TEXT)
4. **Record Count**: Check how many records would match under each join strategy

