# Render Unit Report - Metabase Model Documentation

## Overview

This model provides a comprehensive view of **Render units** (work units/tasks) with labor code enrichment. It includes task details, unit information, contractor data, and associated labor codes with rates.

**Model Type**: BASE MODEL  
**Source View**: `DATA_LAKE.ANALYTICS.VW_RENDER_UNITS`  
**Source SQL**: `snowflake/fybe/VW_RENDER_UNITS.sql`  
**Database**: Fybe Snowflake (DATA_LAKE)
**Schema**: ANALYTICS

## Purpose

This model enables analysis of:
1. **Unit-level work tracking** - Individual work units/tasks with quantities
2. **Labor code information** - Labor codes, RUS codes, descriptions, and rates
3. **Task status and completion** - Status, approval, and completion dates
4. **Contractor and crew information** - Who performed the work
5. **Project and work package tracking** - Project organization and work packages
6. **Label-based categorization** - Multiple label fields for filtering and grouping

## Model Structure

### Base Model: "Render Unit Report (Base)"
- **View**: `DATA_LAKE.ANALYTICS.VW_RENDER_UNITS`
- **Base Table**: `DATA_LAKE.ANALYTICS.RENDER_UNITS`
- **Enrichment**: LEFT JOIN with `DATA_LAKE.ANALYTICS.LABOR_CODES` on `UNIT_CODE`
- **Filters**: None (includes all units from base table)

## Important Notes

### Labor Code Enrichment
- Labor code information is joined via `UNIT_CODE` (case-insensitive match)
- If no matching labor code exists, labor code fields will be NULL
- Labor code fields include: `LABOR_CODE_CODE`, `LABOR_CODE_RUS_CODE`, `LABOR_CODE_DESCRIPTION`, `LABOR_CODE_UOM`, `LABOR_RATE`

### Label Fields
The model includes multiple label fields for flexible categorization:
- `LABELS_GENERAL` - General labels
- `LABELS_GRANT_ID` - Grant identifier
- `LABELS_JOB_TYPE` - Job type classification
- `LABELS_SUPERVISOR` - Supervisor assignment
- `LABELS_GRANT_AREAS` - Grant area information
- `LABELS_DROP_ADMIN` - Drop administration labels
- `LABELS_WORK_ORDER` - Work order reference
- `LABELS_DROP_API` - Drop API labels
- `LABELS_WORK_CATEGORY` - Work category classification
- `LABELS_ERP_PROJECT_ID` - ERP project identifier
- `LABELS_FUNDING_POLYGONS` - Funding polygon information
- `LABELS_BLUEPRINT_ID` - Blueprint identifier

### Date Fields
- `APPROVED_DATE` - When the unit was approved
- `COMPLETED_DATE` - When the unit was completed
- `ORIGINAL_COMPLETED_DATE` - Original completion date (if changed)

## Key Fields

| Field Name | Type | Semantic Type | Description | Notes |
|------------|------|---------------|-------------|-------|
| `PROJECT` | TEXT | Category | Project identifier | |
| `TASK_ID` | NUMBER | Entity Key | Unique task identifier | Primary key for tasks |
| `STATUS` | TEXT | Category | Task status | |
| `TASK_TYPE` | TEXT | Category | Type of task | |
| `WORK_PACKAGE` | TEXT | Entity Key | Work package identifier | May join to Camvio SERVICEORDER_ID |
| `SUBSECTOR` | TEXT | Category | Subsector classification | |
| `ASSET_ID` | NUMBER | Entity Key | Asset identifier | |
| `UNIT_TYPE` | TEXT | Category | Type of unit | |
| `RUS_CODE` | TEXT | Category | RUS code | |
| `UNIT_CODE` | TEXT | Entity Key | Unit code | Used to join to LABOR_CODES |
| `UNIT_DESCRIPTION` | TEXT | Description | Description of the unit | |
| `UOM` | TEXT | Category | Unit of measure | |
| `CONTRACTOR` | TEXT | Entity Name | Contractor name | |
| `CREW_NAME` | TEXT | Entity Name | Crew name | |
| `WORK_ACTIVITY` | TEXT | Category | Work activity type | |
| `ACTUAL_QUANTITY` | NUMBER | Quantity | Actual quantity completed | |
| `PLANNED_QUANTITY` | NUMBER | Quantity | Planned quantity | |
| `APPROVING_USER` | TEXT | Entity Name | User who approved | |
| `APPROVED_DATE` | DATE | Creation Timestamp | Approval date | |
| `COMPLETED_DATE` | DATE | Creation Timestamp | Completion date | |
| `ORIGINAL_COMPLETED_DATE` | DATE | Creation Timestamp | Original completion date | |
| `STREET_ADDRESS` | TEXT | Address | Street address | |
| `LABOR_CODE_CODE` | TEXT | Category | Labor code | From LABOR_CODES join |
| `LABOR_CODE_RUS_CODE` | TEXT | Category | Labor code RUS code | From LABOR_CODES join |
| `LABOR_CODE_DESCRIPTION` | TEXT | Description | Labor code description | From LABOR_CODES join |
| `LABOR_CODE_UOM` | TEXT | Category | Labor code unit of measure | From LABOR_CODES join |
| `LABOR_RATE` | NUMBER | Currency | Labor rate | From LABOR_CODES join |
| `CHANGE_REQUEST_APPROVAL_NUMBER` | TEXT | Entity Key | Change request approval number | Joins to TASK_ID in related tasks |

### Entity Keys
- `TASK_ID` - Unique task identifier (primary key)
- `WORK_PACKAGE` - Work package identifier (may join to Camvio `SERVICEORDER_ID`)
- `ASSET_ID` - Asset identifier
- `UNIT_CODE` - Unit code (used for labor code join)
- `CHANGE_REQUEST_APPROVAL_NUMBER` - Change request approval number (joins to TASK_ID in related tasks)

### Important Dimensions
- `PROJECT` - Project organization
- `CONTRACTOR` - Contractor performing work
- `STATUS` - Task status
- `TASK_TYPE` - Type of task
- `WORK_ACTIVITY` - Work activity classification
- `UNIT_TYPE` - Type of unit

### Important Metrics
- `ACTUAL_QUANTITY` - Actual quantity completed
- `PLANNED_QUANTITY` - Planned quantity
- `LABOR_RATE` - Labor rate (from labor codes)

## Tables/Views Used

### RENDER_UNITS (alias: `u`)
**Full Name**: `DATA_LAKE.ANALYTICS.RENDER_UNITS`  
**Purpose**: Base table containing all unit/task information

**Key Columns**:
- `TASK_ID` - Unique task identifier
- `WORK_PACKAGE` - Work package identifier
- `UNIT_CODE` - Unit code (used for labor code join)
- `ACTUAL_QUANTITY` - Actual quantity completed
- `STATUS` - Task status

### LABOR_CODES (alias: `c`)
**Full Name**: `DATA_LAKE.ANALYTICS.LABOR_CODES`  
**Purpose**: Labor code reference data with rates and descriptions

**Join**: `LEFT JOIN` on `UPPER(u.unit_code) = UPPER(c.unit_code)`

**Key Columns**:
- `CODE` → `LABOR_CODE_CODE`
- `RUS_CODE` → `LABOR_CODE_RUS_CODE`
- `DESCRIPTION` → `LABOR_CODE_DESCRIPTION`
- `UOM` → `LABOR_CODE_UOM`
- `RATE` → `LABOR_RATE`

## Related Documentation

- **Custom Columns**: See [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md) for any custom columns defined for Render models
- **Semantic Types**: See [`RENDER_UNIT_REPORT_SEMANTIC_TYPES.md`](./RENDER_UNIT_REPORT_SEMANTIC_TYPES.md) (to be created)
- **Column Mapping**: See [`RENDER_UNIT_REPORT_COLUMN_MAPPING.md`](./RENDER_UNIT_REPORT_COLUMN_MAPPING.md) (to be created if needed)

## Usage Examples

### Example Query 1: Units by Contractor
Group units by contractor to see work distribution:
- **Dimension**: `CONTRACTOR`
- **Metric**: `COUNT(DISTINCT TASK_ID)` or `SUM(ACTUAL_QUANTITY)`

### Example Query 2: Units with Labor Rates
Filter to units that have labor code information:
- **Filter**: `LABOR_CODE_CODE IS NOT NULL`
- **Dimensions**: `UNIT_CODE`, `LABOR_CODE_DESCRIPTION`
- **Metrics**: `SUM(ACTUAL_QUANTITY)`, `AVG(LABOR_RATE)`

### Example Query 3: Completed Units by Project
Track completion by project:
- **Filter**: `STATUS = 'COMPLETED'` or `COMPLETED_DATE IS NOT NULL`
- **Dimension**: `PROJECT`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`

### Example Query 4: Units by Work Package
Analyze units associated with specific work packages:
- **Dimension**: `WORK_PACKAGE`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`
- **Note**: `WORK_PACKAGE` may join to Camvio `SERVICEORDER_ID` for cross-system analysis

### Example Query 5: Change Request Tracking
Join to related tasks using change request approval number:
- **Join**: `CHANGE_REQUEST_APPROVAL_NUMBER` = `TASK_ID` (in related task table/model)
- **Use Case**: Track change requests and their associated original tasks
- **Note**: `CHANGE_REQUEST_APPROVAL_NUMBER` contains the TASK_ID of the related task

## Notes

- The view performs a case-insensitive join on `UNIT_CODE` to match labor codes
- Labor code fields may be NULL if no matching labor code exists
- Multiple label fields provide flexible categorization options
- `WORK_PACKAGE` field may be used to join with Camvio service orders (`SERVICEORDER_ID`)
- `CHANGE_REQUEST_APPROVAL_NUMBER` can be used to join to related tasks where this value appears in the `TASK_ID` field
