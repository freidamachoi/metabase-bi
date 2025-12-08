# Render Tickets Report - Metabase Model Documentation

## Overview

This model provides a view of **Render tickets** (tasks) with contractor filtering. It includes task details, project information, dates, and status tracking, excluding internal Fybe contractor records.

**Model Type**: BASE MODEL  
**Source View**: `DATA_LAKE.ANALYTICS.VW_RENDER_TICKETS`  
**Source SQL**: `snowflake/fybe/VW_RENDER_TICKETS.sql`  
**Database**: Fybe Snowflake (DATA_LAKE)
**Schema**: ANALYTICS

## Purpose

This model enables analysis of:
1. **Ticket-level work tracking** - Individual tickets/tasks with quantities
2. **Project tracking** - Tickets organized by project
3. **Contractor work analysis** - External contractor work (excludes internal Fybe work)
4. **Status and phase tracking** - Ticket status and phase information
5. **Date tracking** - Release, completion, approval, and target dates
6. **Work package tracking** - Work package identifiers for cross-system joins

## Model Structure

### Base Model: "Render Tickets (Base)"
- **View**: `DATA_LAKE.ANALYTICS.VW_RENDER_TICKETS`
- **Base Table**: `DATA_LAKE.ANALYTICS.RENDER_TICKETS`
- **Filters**: 
  - Excludes records where `CONTRACTOR = 'Fybe'` (applied in Metabase model, not in view)
  - View already excludes specific PROJECT_IDs (see view definition)
- **Joins**: None (single table view)

## Important Notes

### Contractor Filtering
⚠️ **Important**: This model excludes records where `CONTRACTOR = 'Fybe'` to focus on external contractor work. This filter is applied in the Metabase model definition, not in the underlying view.

### Project Filtering
The underlying view (`VW_RENDER_TICKETS`) already excludes specific PROJECT_IDs:
- ECTYQA, ROAECTY, ROAEDTN, ROAEDTNQA, ROAESNS, ROAESNSQA
- ROAHTFD, ROAHTFDQA, ROANA01, ROANA01QA, ROARDCU, ROARDCUQA
- ROARRP, ROARRPQA, ROAWDSR, ROAWDSRQA, ROAWDVL, ROAWDVLQA

### Label Fields
The model includes label fields for flexible categorization:
- `LABELS_GENERAL` - General labels
- `LABELS_GRANT_ID` - Grant identifier
- `LABELS_WORK_ORDER` - Work order reference

### Date Fields
Multiple date fields track different stages:
- `DATE_RELEASED` - When the ticket was released
- `DATE_COMPLETED` - When the ticket was completed
- `DATE_APPROVED` - When the ticket was approved
- `BLUEPRINTED_DATE` - When the ticket was blueprinted
- `TARGET_DATE` - Target completion date

## Key Fields

| Field Name | Type | Semantic Type | Description | Notes |
|------------|------|---------------|-------------|-------|
| `TASK_ID` | NUMBER | Entity Key | Unique task identifier | Primary key for tasks |
| `PROJECT_ID` | TEXT | Category | Project identifier | Already filtered in view |
| `TASK` | TEXT | Category | Task name/description | |
| `PHASE` | TEXT | Category | Task phase | |
| `QTTY` | NUMBER | Quantity | Quantity | |
| `STREET_ADDRESS` | TEXT | Address | Street address | |
| `ROAD_NAME` | TEXT | Address | Road name | |
| `STATUS` | TEXT | Category | Ticket status | |
| `CONTRACTOR` | TEXT | Entity Name | Contractor name | **Filtered**: Excludes "Fybe" |
| `WORK_PACKAGE` | TEXT | Entity Key | Work package identifier | May join to Camvio SERVICEORDER_ID |
| `FFP` | TEXT | Category | FFP identifier | |
| `ASSET_ID` | NUMBER | Entity Key | Asset identifier | |
| `RESOURCE_ID` | NUMBER | Entity Key | Resource identifier | |
| `RESOURCE_USER_NAME` | TEXT | Entity Name | Resource user name | |
| `DATE_RELEASED` | DATE | Creation Timestamp | Release date | |
| `DATE_COMPLETED` | DATE | Creation Timestamp | Completion date | |
| `DATE_APPROVED` | DATE | Creation Timestamp | Approval date | |
| `ACTION` | TEXT | Category | Action type | |
| `WORK_ACTIVITY` | TEXT | Category | Work activity type | |
| `GROUP_ID` | TEXT | Category | Group identifier | |
| `NOTES` | TEXT | Description | Task notes | |
| `BLUEPRINTED_DATE` | DATE | Creation Timestamp | Blueprinted date | |
| `TARGET_DATE` | DATE | Creation Timestamp | Target completion date | |
| `LABELS_GENERAL` | TEXT | Category | General labels | |
| `LABELS_GRANT_ID` | TEXT | Category | Grant identifier | |
| `LABELS_WORK_ORDER` | TEXT | Category | Work order reference | |

### Entity Keys
- `TASK_ID` - Unique task identifier (primary key)
- `WORK_PACKAGE` - Work package identifier (may join to Camvio `SERVICEORDER_ID`)
- `ASSET_ID` - Asset identifier
- `RESOURCE_ID` - Resource identifier

### Important Dimensions
- `PROJECT_ID` - Project organization (already filtered in view)
- `CONTRACTOR` - Contractor performing work (excludes "Fybe" in model)
- `STATUS` - Ticket status
- `PHASE` - Task phase
- `WORK_ACTIVITY` - Work activity classification
- `ACTION` - Action type

### Important Metrics
- `QTTY` - Quantity

## Tables/Views Used

### RENDER_TICKETS
**Full Name**: `DATA_LAKE.ANALYTICS.RENDER_TICKETS`  
**Purpose**: Base table containing all ticket/task information

**View Filtering**: The view `VW_RENDER_TICKETS` excludes specific PROJECT_IDs (see Important Notes above)

**Model Filtering**: The Metabase model applies an additional filter: `CONTRACTOR != 'Fybe'`

**Key Columns**:
- `TASK_ID` - Unique task identifier
- `WORK_PACKAGE` - Work package identifier
- `CONTRACTOR` - Contractor name (filtered to exclude "Fybe")
- `QTTY` - Quantity
- `STATUS` - Ticket status

## Related Documentation

- **Custom Columns**: See [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md) for any custom columns defined for Render models
- **Semantic Types**: See [`RENDER_TICKETS_REPORT_SEMANTIC_TYPES.md`](./RENDER_TICKETS_REPORT_SEMANTIC_TYPES.md) (to be created)
- **Column Mapping**: See [`RENDER_TICKETS_REPORT_COLUMN_MAPPING.md`](./RENDER_TICKETS_REPORT_COLUMN_MAPPING.md) (to be created if needed)

## Usage Examples

### Example Query 1: Tickets by Contractor
Group tickets by contractor to see work distribution:
- **Filter**: `CONTRACTOR IS NOT NULL` (already filtered to exclude "Fybe")
- **Dimension**: `CONTRACTOR`
- **Metric**: `COUNT(DISTINCT TASK_ID)` or `SUM(QTTY)`

### Example Query 2: Completed Tickets by Project
Track completion by project:
- **Filter**: `STATUS = 'COMPLETED'` or `DATE_COMPLETED IS NOT NULL`
- **Dimension**: `PROJECT_ID`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(QTTY)`

### Example Query 3: Tickets by Work Package
Analyze tickets associated with specific work packages:
- **Dimension**: `WORK_PACKAGE`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(QTTY)`
- **Note**: `WORK_PACKAGE` may join to Camvio `SERVICEORDER_ID` for cross-system analysis

### Example Query 4: Date Tracking Analysis
Compare target dates with actual completion:
- **Dimensions**: `PROJECT_ID`, `STATUS`
- **Metrics**: 
  - `COUNT(DISTINCT TASK_ID)` - Total tickets
  - `COUNT(DISTINCT CASE WHEN DATE_COMPLETED <= TARGET_DATE THEN TASK_ID END)` - On-time completions
- **Filter**: `TARGET_DATE IS NOT NULL AND DATE_COMPLETED IS NOT NULL`

### Example Query 5: Phase and Status Analysis
Analyze tickets by phase and status:
- **Dimensions**: `PHASE`, `STATUS`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(QTTY)`

## Notes

- **Contractor Filter**: The model excludes `CONTRACTOR = 'Fybe'` to focus on external contractor work. This filter must be applied in the Metabase model definition.
- **Project Filtering**: The underlying view already excludes specific PROJECT_IDs (see view definition)
- **Work Package Joins**: `WORK_PACKAGE` field may be used to join with Camvio service orders (`SERVICEORDER_ID`)
- **Date Fields**: Multiple date fields allow tracking of different stages in the ticket lifecycle
- **Label Fields**: Use label fields for flexible categorization and filtering

## Model Filter Definition

In Metabase, apply this filter to the model:

```sql
WHERE CONTRACTOR != 'Fybe'
```

Or in Metabase's filter interface:
- **Field**: `CONTRACTOR`
- **Operator**: `!=` (not equal)
- **Value**: `Fybe`
