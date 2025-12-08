# Render Tickets (Enriched) - Metabase Model Documentation

## Overview

This model provides an enriched view of **Render tickets** with comprehensive custom calculated fields for workflow tracking, status management, time analysis, and categorization. It builds on the base tickets model with extensive business logic.

**Model Type**: ENHANCED MODEL  
**Base Model**: Render Tickets (Base)  
**Source View**: `DATA_LAKE.ANALYTICS.VW_RENDER_TICKETS`  
**Database**: Fybe Snowflake (DATA_LAKE)
**Schema**: ANALYTICS

## Purpose

This model enables analysis of:
1. **Workflow tracking** - Complete ticket lifecycle from release to approval
2. **Status management** - Enhanced status indicators with jeopardy and overdue tracking
3. **Time analysis** - Age calculations and time-to-completion metrics
4. **Task categorization** - Cleaned and normalized task type and category classifications
5. **Approval workflow** - Approval status and age tracking
6. **Jeopardy and overdue tracking** - Proactive identification of at-risk tickets

## Model Structure

### Enhanced Model: "Render Tickets (Enriched)"
- **Base Model**: Render Tickets (Base)
- **Filter**: Inherits filter from base model (excludes `CONTRACTOR = 'Fybe'`)
- **Custom Columns**: 19 custom calculated fields (see Custom Columns section)
- **Joins**: None (single table view with enrichments)

## Important Notes

### Custom Column Dependencies
Several custom columns depend on others:
- `Labels General (norm)` is used by: `Is Invoiced`, `Is Deferred`, `Is Rejected`, `Primary Category`, `Secondary Category`
- `Task Type Clean` is used by: `Task Type`
- `Status` (normalized) is used by: `Task Status` (with Jeopardy/Overdue)
- `Days to Due` is used by: `Task Status` (with Jeopardy/Overdue)
- Date-based boolean fields (`Is Released`, `Is Completed`, `Is Approved`) are used by age calculations

### Status Field Hierarchy
The model includes multiple status-related fields:
- **Base `STATUS`** - Raw status from database
- **`Status`** (custom) - Normalized/formatted version of base STATUS
- **`Task Status`** (custom) - Enhanced status with jeopardy and overdue indicators
- **`Task Stage`** - Stage in the workflow (if defined)

### Time Calculations
Age calculations are conditional and only show values when relevant:
- `Released Age (Not Completed)` - Only calculated if released but not completed
- `Time to Complete` - Only calculated if both released and completed
- `Completed Age (Not Approved)` - Only calculated if completed but not approved

## Custom Columns

All custom columns are defined in [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md). Below is a summary:

### Status Indicators

| Custom Column | Type | Description | Formula Reference |
|---------------|------|-------------|-------------------|
| `NLR` | Boolean | Task marked as "No Longer Required" | `lower(trim([Work Activity])) = "no longer required"` |
| `In Jeopardy` | Boolean | Status is "jeopardy" | `lower(trim(coalesce([Status], ""))) = "jeopardy"` |
| `Is Rejected` | Boolean | Task has been disapproved | `contains([Labels General (norm)], "disapproved")` |
| `Is Deferred` | Boolean | Task has been deferred | `contains([Labels General (norm)], "defer")` |
| `Is Releasable` | Boolean | Task is ready to be released | (Definition in Custom Column Definitions) |
| `Is Released` | Boolean | Task has been released | `notNull([Date Released])` |
| `Is Completed` | Boolean | Task has been completed | `notNull([Date Completed])` |
| `Is Approved` | Boolean | Task has been approved | `notNull([Date Approved])` |

### Normalization Fields

| Custom Column | Type | Description | Formula Reference |
|---------------|------|-------------|-------------------|
| `Labels General (norm)` | Text | Normalized (lowercase) version of Labels General | `if(isNull([Labels General]), "", lower([Labels General]))` |
| `Task Type Clean` | Text | Cleaned task type (replaces underscores, dashes, dots with spaces) | `replace(replace(replace([Task Type], "_", " "), "-", " "), ".", " ")` |
| `Status` | Text | Normalized/formatted version of base STATUS field | Complex formatting with proper capitalization |

### Enhanced Status Fields

| Custom Column | Type | Description | Formula Reference |
|---------------|------|-------------|-------------------|
| `Task Status` | Text | Enhanced status with jeopardy and overdue indicators | Includes "Placed in Jeopardy", "Overdue", "Jeopardy" (within 3 days), or base Status |
| `Task Stage` | Text | Stage in the workflow | (Definition in Custom Column Definitions) |

### Task Type Fields

| Custom Column | Type | Description | Formula Reference |
|---------------|------|-------------|-------------------|
| `Task Type` | Text | Formatted task type with proper capitalization | Complex formatting based on `Task Type Clean` |

### Category Fields

| Custom Column | Type | Description | Formula Reference |
|---------------|------|-------------|-------------------|
| `Primary Category` | Text | Primary category from labels (Cable Placing, Path, Splicing) | Extracted from first part of `Labels General (norm)` |
| `Secondary Category` | Text | Secondary category from labels | Extracted from second part of `Labels General (norm)` |

### Time Calculation Fields

| Custom Column | Type | Description | Formula Reference |
|---------------|------|-------------|-------------------|
| `Days to Due` | Number | Days until target date (negative = overdue) | `datetimeDiff(now(), [Target Date], "day")` |
| `Released Age (Not Completed)` | Number | Days since release (only if not completed) | Calculated only when released but not completed |
| `Time to Complete` | Number | Days from release to completion | Calculated only when both released and completed |
| `Completed Age (Not Approved)` | Number | Days since completion (only if not approved) | Calculated only when completed but not approved |

## Key Fields (Inherited from Base)

All fields from **Render Tickets (Base)** are available, including:
- `TASK_ID`, `PROJECT_ID`, `WORK_PACKAGE`
- `TASK`, `PHASE`, `STATUS`, `ACTION`, `WORK_ACTIVITY`
- `QTTY`, `CONTRACTOR`, `RESOURCE_USER_NAME`
- `DATE_RELEASED`, `DATE_COMPLETED`, `DATE_APPROVED`
- `BLUEPRINTED_DATE`, `TARGET_DATE`
- `STREET_ADDRESS`, `ROAD_NAME`
- `ASSET_ID`, `RESOURCE_ID`, `GROUP_ID`
- `NOTES`, `FFP`
- Label fields: `LABELS_GENERAL`, `LABELS_GRANT_ID`, `LABELS_WORK_ORDER`

See [`RENDER_TICKETS_REPORT.md`](./RENDER_TICKETS_REPORT.md) for complete field documentation.

## Related Documentation

- **Base Model**: [`RENDER_TICKETS_REPORT.md`](./RENDER_TICKETS_REPORT.md)
- **Custom Column Definitions**: [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md) - Full formulas for all custom columns
- **Semantic Types**: See [`RENDER_TICKETS_ENRICHED_SEMANTIC_TYPES.md`](./RENDER_TICKETS_ENRICHED_SEMANTIC_TYPES.md) (to be created)
- **Metrics**: See Custom Column Definitions for additional metrics (Total Tickets, Completion Rate, etc.)

## Usage Examples

### Example Query 1: Workflow Status Dashboard
Track tickets through the workflow:
- **Dimensions**: `Task Stage`, `Task Status`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`
- **Filter**: `NLR = false` (exclude cancelled)

### Example Query 2: Jeopardy and Overdue Analysis
Identify at-risk tickets:
- **Filter**: `Task Status IN ("Placed in Jeopardy", "Overdue", "Jeopardy")`
- **Dimensions**: `PROJECT_ID`, `CONTRACTOR`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`
- **Use Case**: Proactive management of at-risk tickets

### Example Query 3: Time-to-Completion Analysis
Analyze completion times:
- **Filter**: `Is Completed = true` AND `Time to Complete IS NOT NULL`
- **Dimensions**: `CONTRACTOR`, `Task Type`
- **Metrics**: 
  - `AVG([Time to Complete])` - Average days to complete
  - `COUNT(DISTINCT TASK_ID)` - Number of completed tickets
- **Use Case**: Performance tracking and contractor evaluation

### Example Query 4: Approval Workflow Tracking
Track approval status and delays:
- **Dimensions**: `Is Approved`, `Is Completed`
- **Metrics**: 
  - `COUNT(DISTINCT TASK_ID)` - Total tickets
  - `AVG([Completed Age (Not Approved)])` - Average days waiting for approval
- **Filter**: `Is Completed = true`
- **Use Case**: Identify bottlenecks in approval process

### Example Query 5: Category Analysis
Analyze tickets by category:
- **Dimensions**: `Primary Category`, `Secondary Category`, `Task Type`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(QTTY)`
- **Filter**: `NLR = false` AND `Is Rejected = false`

### Example Query 6: Released but Not Completed
Track tickets that are released but haven't been completed:
- **Filter**: `Is Released = true` AND `Is Completed = false`
- **Dimensions**: `CONTRACTOR`, `PROJECT_ID`
- **Metrics**: 
  - `COUNT(DISTINCT TASK_ID)` - Stuck tickets
  - `AVG([Released Age (Not Completed)])` - Average days stuck
- **Use Case**: Identify tickets that need attention

### Example Query 7: Days to Due Analysis
Track tickets approaching or past due date:
- **Dimensions**: 
  - `CASE WHEN [Days to Due] < 0 THEN "Overdue" WHEN [Days to Due] <= 3 THEN "Due Soon" ELSE "On Track" END`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`
- **Filter**: `TARGET_DATE IS NOT NULL` AND `Is Completed = false`

## Notes

- **Contractor Filter**: Inherits filter from base model (excludes `CONTRACTOR = 'Fybe'`)
- **Status Field Confusion**: There are multiple status-related fields - use `Task Status` for enhanced status with jeopardy/overdue, and base `STATUS` for raw status
- **Time Calculations**: Age calculations are conditional - they only show values when the condition is met (e.g., `Released Age (Not Completed)` only shows if released but not completed)
- **Days to Due**: Negative values indicate overdue tickets, positive values indicate days remaining
- **Work Package Joins**: `WORK_PACKAGE` field may be used to join with Camvio service orders (`SERVICEORDER_ID`)
- **Task Stage**: Verify definition in Custom Column Definitions if not found

## Custom Column Setup

All custom columns should be added to the model according to the definitions in [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md). The custom columns should be added in this order to respect dependencies:

1. `Labels General (norm)` - Base normalization field
2. `Task Type Clean` - Base cleaning field
3. `Status` - Normalized status field
4. `NLR` - Simple boolean
5. `In Jeopardy` - Simple boolean
6. `Is Rejected` - Depends on `Labels General (norm)`
7. `Is Deferred` - Depends on `Labels General (norm)`
8. `Is Released` - Simple boolean
9. `Is Completed` - Simple boolean
10. `Is Approved` - Simple boolean
11. `Is Releasable` - (Verify definition)
12. `Days to Due` - Time calculation
13. `Task Type` - Depends on `Task Type Clean`
14. `Primary Category` - Depends on `Labels General (norm)`
15. `Secondary Category` - Depends on `Labels General (norm)`
16. `Task Status` - Depends on `Status`, `Days to Due`, `In Jeopardy`, `Is Completed`, `NLR`
17. `Task Stage` - (Verify definition)
18. `Released Age (Not Completed)` - Depends on `Is Released`, `Is Completed`
19. `Time to Complete` - Depends on `Is Released`, `Is Completed`
20. `Completed Age (Not Approved)` - Depends on `Is Completed`, `Is Approved`
