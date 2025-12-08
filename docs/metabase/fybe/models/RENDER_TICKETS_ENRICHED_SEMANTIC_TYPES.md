# Render Tickets (Enriched) - Semantic Types

## Overview

Semantic types in Metabase help the system understand what kind of data each column contains, enabling better visualizations, filtering, and data exploration. This document specifies the recommended semantic types for each column in the **Render Tickets (Enriched)** model.

**Model**: Render Tickets (Enriched)  
**Base Model**: Render Tickets (Base)  
**Source**: `DATA_LAKE.ANALYTICS.VW_RENDER_TICKETS`  
**Filter**: Excludes records where `CONTRACTOR = 'Fybe'` (inherited from base)

## Column Semantic Types

### Base Model Fields

All fields from **Render Tickets (Base)** are inherited. See [`RENDER_TICKETS_REPORT_SEMANTIC_TYPES.md`](./RENDER_TICKETS_REPORT_SEMANTIC_TYPES.md) for complete documentation of base fields.

**Key Base Fields**:
- `TASK_ID` - **Entity Key**
- `WORK_PACKAGE` - **Entity Key** (may join to Camvio SERVICEORDER_ID)
- `PROJECT_ID` - **Category**
- `STATUS` - **Category** (raw status)
- `QTTY` - **Quantity**
- `CONTRACTOR` - **Entity Name**
- `DATE_RELEASED`, `DATE_COMPLETED`, `DATE_APPROVED` - **Creation Timestamp**

### Custom Columns - Status Indicators

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `NLR` | **Boolean** | Task marked as "No Longer Required" | Use to filter out cancelled tasks |
| `In Jeopardy` | **Boolean** | Status is "jeopardy" | Use for jeopardy identification |
| `Is Rejected` | **Boolean** | Task has been disapproved | Use to filter out rejected tasks |
| `Is Deferred` | **Boolean** | Task has been deferred | Use for deferral tracking |
| `Is Releasable` | **Boolean** | Task is ready to be released | Use for release workflow |
| `Is Released` | **Boolean** | Task has been released | Use for release status filtering |
| `Is Completed` | **Boolean** | Task has been completed | Use for completion status filtering |
| `Is Approved` | **Boolean** | Task has been approved | Use for approval status filtering |

### Custom Columns - Normalization Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `Labels General (norm)` | **Category** | Normalized (lowercase) version of Labels General | Used by other custom columns, not typically displayed |
| `Task Type Clean` | **Category** | Cleaned task type | Intermediate field, used by `Task Type` |
| `Status` | **Category** | Normalized/formatted version of base STATUS | Use instead of raw `STATUS` for display |

### Custom Columns - Enhanced Status Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `Task Status` | **Category** | Enhanced status with jeopardy and overdue indicators | **Primary status field** - includes "Placed in Jeopardy", "Overdue", "Jeopardy", or base status |
| `Task Stage` | **Category** | Stage in the workflow | Use for workflow stage analysis |

### Custom Columns - Task Type Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `Task Type` | **Category** | Formatted task type with proper capitalization | **Primary field** for task type analysis (use instead of base `TASK_TYPE`) |

### Custom Columns - Category Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `Primary Category` | **Category** | Primary category (Cable Placing, Path, Splicing) | Extracted from labels |
| `Secondary Category` | **Category** | Secondary category | Extracted from labels |

### Custom Columns - Time Calculation Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `Days to Due` | **Number** | Days until target date (negative = overdue) | **Key metric** - negative values = overdue, positive = days remaining |
| `Released Age (Not Completed)` | **Number** | Days since release (only if not completed) | Conditional - only shows if released but not completed |
| `Time to Complete` | **Number** | Days from release to completion | Conditional - only shows if both released and completed |
| `Completed Age (Not Approved)` | **Number** | Days since completion (only if not approved) | Conditional - only shows if completed but not approved |

## Semantic Type Categories Reference

### Primary Types

- **Entity Key**: Unique identifiers (IDs, primary keys, codes used for joins)
- **Entity Name**: Names of entities (people, companies, contractors, resources)
- **Category**: Categorical data (status, type, classification, labels)
- **Description**: Text descriptions and notes
- **Creation Timestamp**: Date/time fields
- **Quantity**: Numeric quantities
- **Boolean**: True/false values
- **Number**: Numeric values (ages, durations, days)
- **Address**: Address fields

## Important Notes

### Custom Column Dependencies

When setting up the model, be aware of these dependencies:
1. `Labels General (norm)` → Used by: `Is Invoiced`, `Is Deferred`, `Is Rejected`, `Primary Category`, `Secondary Category`
2. `Task Type Clean` → Used by: `Task Type`
3. `Status` (normalized) → Used by: `Task Status`
4. `Days to Due` → Used by: `Task Status`
5. Boolean date fields → Used by age calculations

### Time Calculation Fields

⚠️ **Important**: Time calculation fields are **conditional**:
- They only show values when the condition is met
- NULL values are expected and normal (e.g., `Released Age (Not Completed)` is NULL if task is not released or already completed)
- Use filters like `Time to Complete IS NOT NULL` when analyzing these fields

### Days to Due Field

- **Negative values** = Overdue (past target date)
- **Positive values** = Days remaining until target date
- **Zero** = Due today
- **NULL** = No target date set

### Status Field Hierarchy

There are multiple status-related fields:
- **Base `STATUS`** (Category) - Raw status from database
- **`Status`** (Category) - Normalized/formatted version
- **`Task Status`** (Category) - Enhanced with jeopardy/overdue indicators ⭐ **Use this for analysis**
- **`Task Stage`** (Category) - Workflow stage

**Recommendation**: Use `Task Status` as the primary status field for dashboards and analysis.

### Key Fields for Analysis

- **Workflow Tracking**: Use `Task Stage` (Category) + `Is Released` (Boolean) + `Is Completed` (Boolean) + `Is Approved` (Boolean)
- **Jeopardy/Overdue Tracking**: Use `Task Status` (Category) - filter for "Placed in Jeopardy", "Overdue", or "Jeopardy"
- **Time Analysis**: Use `Days to Due` (Number) + `Time to Complete` (Number) + age fields
- **Approval Workflow**: Use `Is Approved` (Boolean) + `Completed Age (Not Approved)` (Number)
- **Category Analysis**: Use `Primary Category` (Category) + `Secondary Category` (Category) + `Task Type` (Category)
- **Status Filtering**: Use `NLR` (Boolean) + `Is Rejected` (Boolean) to filter out problematic tickets

## Setting Semantic Types in Metabase

1. Navigate to the model in Metabase
2. **Ensure base model filter is applied**: `CONTRACTOR != 'Fybe'`
3. **Add all custom columns** according to [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md)
4. Go to the model settings
5. For each column, set the semantic type according to this document
6. Pay special attention to:
   - **Boolean fields** - for proper true/false filtering
   - **Number fields** (time calculations) - for proper numeric formatting
   - **Category fields** - for proper grouping
   - **Entity Keys** - for proper joins
   - **Entity Names** - for proper name formatting
   - **Creation Timestamps** - for date-based filtering

## Custom Column Display Recommendations

### Fields to Display in Default View
- `TASK_ID`
- `WORK_PACKAGE`
- `CONTRACTOR`
- `Task Status` (use this instead of base `STATUS`)
- `Task Type` (use this instead of base `TASK_TYPE`)
- `Task Stage`
- `Days to Due`
- `Is Completed`
- `Is Approved`

### Fields to Hide (Intermediate/Supporting)
- `Labels General (norm)` - Supporting field, use base `LABELS_GENERAL` for display
- `Task Type Clean` - Supporting field, use `Task Type` for display
- `Status` (normalized) - Supporting field, use `Task Status` for display

### Fields for Filtering
- `NLR` - Filter out cancelled tasks (`NLR = false`)
- `Is Rejected` - Filter out rejected tasks (`Is Rejected = false`)
- `Is Released` - Filter to released tickets
- `Is Completed` - Filter to completed tickets
- `Is Approved` - Filter to approved tickets
- `Task Status` - Filter for specific statuses including jeopardy/overdue
- `Days to Due` - Filter for overdue (`Days to Due < 0`) or due soon (`Days to Due <= 3`)

## Usage Patterns

### Pattern 1: Workflow Status Dashboard
- **Dimensions**: `Task Stage`, `Task Status`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`
- **Filter**: `NLR = false` AND `Is Rejected = false`

### Pattern 2: Jeopardy and Overdue Tracking
- **Filter**: `Task Status IN ("Placed in Jeopardy", "Overdue", "Jeopardy")`
- **Dimensions**: `PROJECT_ID`, `CONTRACTOR`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`

### Pattern 3: Time-to-Completion Analysis
- **Filter**: `Is Completed = true` AND `Time to Complete IS NOT NULL`
- **Dimensions**: `CONTRACTOR`, `Task Type`
- **Metrics**: `AVG([Time to Complete])`, `COUNT(DISTINCT TASK_ID)`

### Pattern 4: Approval Bottleneck Analysis
- **Filter**: `Is Completed = true` AND `Is Approved = false`
- **Dimensions**: `PROJECT_ID`, `CONTRACTOR`
- **Metrics**: 
  - `COUNT(DISTINCT TASK_ID)` - Waiting for approval
  - `AVG([Completed Age (Not Approved)])` - Average wait time

### Pattern 5: Category and Type Analysis
- **Dimensions**: `Primary Category`, `Secondary Category`, `Task Type`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(QTTY)`
- **Filter**: `NLR = false` AND `Is Rejected = false`

### Pattern 6: Released but Not Completed
- **Filter**: `Is Released = true` AND `Is Completed = false`
- **Dimensions**: `CONTRACTOR`, `PROJECT_ID`
- **Metrics**: 
  - `COUNT(DISTINCT TASK_ID)`
  - `AVG([Released Age (Not Completed)])`

### Pattern 7: Days to Due Analysis
- **Dimensions**: 
  - `CASE WHEN [Days to Due] < 0 THEN "Overdue" WHEN [Days to Due] <= 3 THEN "Due Soon" ELSE "On Track" END`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`
- **Filter**: `TARGET_DATE IS NOT NULL` AND `Is Completed = false`
