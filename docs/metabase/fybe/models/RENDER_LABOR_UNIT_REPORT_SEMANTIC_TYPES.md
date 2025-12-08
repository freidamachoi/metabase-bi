# Render Labor Unit Report (Enriched) - Semantic Types

## Overview

Semantic types in Metabase help the system understand what kind of data each column contains, enabling better visualizations, filtering, and data exploration. This document specifies the recommended semantic types for each column in the **Render Labor Unit Report (Enriched)** model.

**Model**: Render Labor Unit Report (Enriched)  
**Base Model**: Render Unit Report (Base)  
**Source**: `DATA_LAKE.ANALYTICS.VW_RENDER_UNITS`  
**Filter**: `UNIT_TYPE = 'Labor'`

## Column Semantic Types

### Base Model Fields

All fields from **Render Unit Report (Base)** are inherited. See [`RENDER_UNIT_REPORT_SEMANTIC_TYPES.md`](./RENDER_UNIT_REPORT_SEMANTIC_TYPES.md) for complete documentation of base fields.

**Key Base Fields**:
- `TASK_ID` - **Entity Key**
- `WORK_PACKAGE` - **Entity Key** (may join to Camvio SERVICEORDER_ID)
- `UNIT_TYPE` - **Category** (filtered to "Labor")
- `ACTUAL_QUANTITY` - **Quantity**
- `LABOR_RATE` - **Currency**
- `CONTRACTOR` - **Entity Name**
- `APPROVED_DATE` - **Creation Timestamp**

### Custom Columns - Status Indicators

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `Is Approved` | **Boolean** | Whether the unit has been approved | Use for approval status filtering |
| `Task NLR` | **Boolean** | Task marked as "No Longer Required" | Use to filter out cancelled tasks |
| `Is Rejected` | **Boolean** | Task has been disapproved | Use to filter out rejected tasks |
| `Is Invoiced` | **Boolean** | Task has been invoiced | Use for invoice status tracking |
| `Is Deferred` | **Boolean** | Task has been deferred | Use for deferral tracking |
| `Is Fybe` | **Boolean** | Contractor is NOT Fybe (external contractor) | **Note**: `true` = external contractor, `false` = Fybe internal |

### Custom Columns - Normalization Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `Labels General (norm)` | **Category** | Normalized (lowercase) version of Labels General | Used by other custom columns, not typically displayed |
| `Task Type Clean` | **Category** | Cleaned task type | Intermediate field, used by `@ Task Type` |
| `@ Task Type` | **Category** | Formatted task type with proper capitalization | **Primary field** for task type analysis |

### Custom Columns - Financial Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `Gross $` | **Currency** | Gross labor cost (Actual Quantity × Labor Rate) | **Primary financial metric** |
| `Net $` | **Currency** | Net labor cost (90% of gross) | Represents payment after 10% retainage |
| `Retainage $` | **Currency** | Retainage amount (10% of gross) | Amount held back |

## Semantic Type Categories Reference

### Primary Types

- **Entity Key**: Unique identifiers (IDs, primary keys, codes used for joins)
- **Entity Name**: Names of entities (people, companies, contractors, crews)
- **Category**: Categorical data (status, type, classification, labels)
- **Description**: Text descriptions and notes
- **Creation Timestamp**: Date/time fields
- **Currency**: Monetary values (rates, costs, amounts)
- **Quantity**: Numeric quantities
- **Boolean**: True/false values
- **Address**: Address fields

## Important Notes

### Custom Column Dependencies

When setting up the model, be aware of these dependencies:
1. `Labels General (norm)` → Used by: `Is Invoiced`, `Is Deferred`, `Is Rejected`
2. `Task Type Clean` → Used by: `@ Task Type`
3. `Gross $` → Used by: `Net $` and `Retainage $`

### Financial Field Requirements

⚠️ **Important**: Financial fields (`Gross $`, `Net $`, `Retainage $`) require:
- `LABOR_RATE` to be populated (not NULL)
- `ACTUAL_QUANTITY` to be populated (not NULL)

For accurate financial analysis, filter to:
```sql
WHERE LABOR_RATE IS NOT NULL AND ACTUAL_QUANTITY IS NOT NULL
```

### Boolean Field Logic

**Is Fybe Field**:
- `Is Fybe = true` → Contractor is **NOT** Fybe (external contractor)
- `Is Fybe = false` → Contractor **IS** Fybe (internal)

This can be confusing! The field checks if contractor name does NOT contain "fybe", so `true` means external contractor.

### Key Fields for Analysis

- **Labor Cost Analysis**: Use `Gross $` (Currency) + `Net $` (Currency) + `Retainage $` (Currency)
- **Approval Tracking**: Use `Is Approved` (Boolean) + `APPROVED_DATE` (Creation Timestamp)
- **Invoice Status**: Use `Is Invoiced` (Boolean) + `Is Deferred` (Boolean)
- **Contractor Analysis**: Use `CONTRACTOR` (Entity Name) + `Is Fybe` (Boolean) + `Gross $` (Currency)
- **Task Type Analysis**: Use `@ Task Type` (Category) - this is the cleaned/formatted version
- **Status Filtering**: Use `Task NLR` (Boolean) + `Is Rejected` (Boolean) to filter out problematic tasks

## Setting Semantic Types in Metabase

1. Navigate to the model in Metabase
2. **Apply the unit type filter first**: Add filter `UNIT_TYPE = 'Labor'`
3. **Add all custom columns** according to [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md)
4. Go to the model settings
5. For each column, set the semantic type according to this document
6. Pay special attention to:
   - **Currency fields** (`Gross $`, `Net $`, `Retainage $`, `LABOR_RATE`) - for proper formatting
   - **Boolean fields** - for proper true/false filtering
   - **Entity Keys** - for proper joins
   - **Entity Names** - for proper name formatting
   - **Creation Timestamps** - for date-based filtering

## Financial Field Relationships

The financial fields have these relationships:
- **Gross $** = `ACTUAL_QUANTITY × LABOR_RATE`
- **Net $** = `0.9 × Gross $` (90% of gross)
- **Retainage $** = `Gross $ - Net $` = `0.1 × Gross $` (10% of gross)

**Verification**: `Gross $` should always equal `Net $ + Retainage $`

## Custom Column Display Recommendations

### Fields to Display in Default View
- `TASK_ID`
- `WORK_PACKAGE`
- `CONTRACTOR`
- `@ Task Type` (use this instead of base `TASK_TYPE`)
- `ACTUAL_QUANTITY`
- `Gross $`
- `Net $`
- `Is Approved`
- `Is Invoiced`

### Fields to Hide (Intermediate/Supporting)
- `Labels General (norm)` - Supporting field, use base `LABELS_GENERAL` for display
- `Task Type Clean` - Supporting field, use `@ Task Type` for display

### Fields for Filtering
- `Is Fybe` - Filter to external contractors (`Is Fybe = true`)
- `Is Approved` - Filter to approved units
- `Is Invoiced` - Filter to invoiced units
- `Task NLR` - Filter out cancelled tasks (`Task NLR = false`)
- `Is Rejected` - Filter out rejected tasks (`Is Rejected = false`)

## Usage Patterns

### Pattern 1: External Contractor Labor Costs
- **Filter**: `Is Fybe = true` AND `LABOR_RATE IS NOT NULL`
- **Dimensions**: `CONTRACTOR`, `PROJECT`
- **Metrics**: `SUM([Gross $])`, `SUM([Net $])`, `SUM([Retainage $])`

### Pattern 2: Approval Status Analysis
- **Dimensions**: `Is Approved`, `PROJECT`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM([Gross $])`
- **Filter**: `Is Rejected = false` AND `Task NLR = false`

### Pattern 3: Invoice Status Tracking
- **Dimensions**: `Is Invoiced`, `Is Deferred`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM([Gross $])`
- **Use Case**: Track which labor has been invoiced vs deferred

### Pattern 4: Task Type Financial Analysis
- **Dimensions**: `@ Task Type`, `WORK_ACTIVITY`
- **Metrics**: `SUM([Gross $])`, `AVG([LABOR_RATE])`
- **Filter**: `LABOR_RATE IS NOT NULL`
