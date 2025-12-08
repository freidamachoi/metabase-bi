# Render Labor Unit Report (Enriched) - Metabase Model Documentation

## Overview

This model provides an enriched view of **Render labor units** with custom calculated fields for financial analysis, status tracking, and categorization. It focuses specifically on labor-type units with business logic applied.

**Model Type**: ENHANCED MODEL  
**Base Model**: Render Unit Report (Base)  
**Source View**: `DATA_LAKE.ANALYTICS.VW_RENDER_UNITS`  
**Database**: Fybe Snowflake (DATA_LAKE)
**Schema**: ANALYTICS

## Purpose

This model enables analysis of:
1. **Labor cost analysis** - Gross, net, and retainage calculations
2. **Approval tracking** - Approval status and workflow
3. **Invoice status** - Invoiced and deferred tracking
4. **Contractor filtering** - Fybe vs external contractor identification
5. **Task categorization** - Cleaned and normalized task type classifications
6. **Status indicators** - NLR (No Longer Required), rejected, and approval status

## Model Structure

### Enhanced Model: "Render Labor Unit Report (Enriched)"
- **Base Model**: Render Unit Report (Base)
- **Filter**: `UNIT_TYPE = 'Labor'` (applied in Metabase model)
- **Custom Columns**: 12 custom calculated fields (see Custom Columns section)
- **Joins**: Inherits from base model (includes labor code enrichment)

## Important Notes

### Unit Type Filter
⚠️ **Important**: This model filters to include only records where `UNIT_TYPE = 'Labor'`. This filter must be applied in the Metabase model definition.

**Filter Definition**:
```sql
WHERE UNIT_TYPE = 'Labor'
```

Or in Metabase filter interface:
- **Field**: `UNIT_TYPE`
- **Operator**: `=` (equal)
- **Value**: `Labor`

### Financial Calculations
The model includes financial calculations based on labor rates:
- **Gross $**: `ACTUAL_QUANTITY * LABOR_RATE`
- **Net $**: `0.9 * Gross $` (90% of gross, representing payment after 10% retainage)
- **Retainage $**: `Gross $ - Net $` (10% retainage, or `0.1 * Gross $`)

### Custom Column Dependencies
Several custom columns depend on others:
- `Labels General (norm)` is used by: `Is Invoiced`, `Is Deferred`, `Is Rejected`
- `Task Type Clean` is used by: `@ Task Type`
- `Gross $` is used by: `Net $` (and indirectly by `Retainage $`)

## Custom Columns

All custom columns are defined in [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md). Below is a summary:

### Status Indicators

| Custom Column | Type | Description | Formula Reference |
|---------------|------|-------------|-------------------|
| `Is Approved` | Boolean | Whether the unit has been approved | `notNull([Approved Date])` |
| `Task NLR` | Boolean | Task marked as "No Longer Required" | `lower(trim([Work Activity])) = "no longer required"` |
| `Is Rejected` | Boolean | Task has been disapproved | `contains([Labels General (norm)], "disapproved")` |
| `Is Invoiced` | Boolean | Task has been invoiced | `contains([Labels General (norm)], "invoiced")` |
| `Is Deferred` | Boolean | Task has been deferred | `contains([Labels General (norm)], "defer")` |
| `Is Fybe` | Boolean | Contractor is NOT Fybe (external contractor) | `doesNotContain([Contractor], "fybe")` |

### Normalization Fields

| Custom Column | Type | Description | Formula Reference |
|---------------|------|-------------|-------------------|
| `Labels General (norm)` | Text | Normalized (lowercase) version of Labels General | `if(isNull([Labels General]), "", lower([Labels General]))` |
| `Task Type Clean` | Text | Cleaned task type (replaces underscores, dashes, dots with spaces) | `replace(replace(replace([Task Type], "_", " "), "-", " "), ".", " ")` |
| `@ Task Type` | Text | Formatted task type with proper capitalization | Complex formatting based on `Task Type Clean` |

### Financial Fields

| Custom Column | Type | Description | Formula Reference |
|---------------|------|-------------|-------------------|
| `Gross $` | Currency | Gross labor cost | `[Actual Quantity] * [Labor Rate]` |
| `Net $` | Currency | Net labor cost (90% of gross) | `0.9 * [Gross $]` |
| `Retainage $` | Currency | Retainage amount (10% of gross) | `[Gross $] - [Net $]` or `0.1 * [Gross $]` |

## Key Fields (Inherited from Base)

All fields from **Render Unit Report (Base)** are available, including:
- `TASK_ID`, `WORK_PACKAGE`, `PROJECT`, `ASSET_ID`
- `UNIT_CODE`, `UNIT_TYPE` (filtered to "Labor")
- `ACTUAL_QUANTITY`, `PLANNED_QUANTITY`
- `CONTRACTOR`, `CREW_NAME`, `WORK_ACTIVITY`
- `APPROVED_DATE`, `COMPLETED_DATE`
- `LABOR_RATE`, `LABOR_CODE_*` fields
- All label fields

See [`RENDER_UNIT_REPORT.md`](./RENDER_UNIT_REPORT.md) for complete field documentation.

## Related Documentation

- **Base Model**: [`RENDER_UNIT_REPORT.md`](./RENDER_UNIT_REPORT.md)
- **Custom Column Definitions**: [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md) - Full formulas for all custom columns
- **Semantic Types**: See [`RENDER_LABOR_UNIT_REPORT_SEMANTIC_TYPES.md`](./RENDER_LABOR_UNIT_REPORT_SEMANTIC_TYPES.md) (to be created)

## Usage Examples

### Example Query 1: Labor Cost Analysis
Analyze labor costs by contractor:
- **Filter**: `Is Fybe = false` (external contractors only)
- **Dimensions**: `CONTRACTOR`, `PROJECT`
- **Metrics**: 
  - `SUM([Gross $])` - Total gross labor cost
  - `SUM([Net $])` - Total net labor cost
  - `SUM([Retainage $])` - Total retainage held

### Example Query 2: Approval Status Tracking
Track approval status:
- **Dimensions**: `Is Approved`, `PROJECT`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`
- **Filter**: `Is Rejected = false` (exclude rejected tasks)

### Example Query 3: Invoice Status
Analyze invoicing status:
- **Dimensions**: `Is Invoiced`, `Is Deferred`, `CONTRACTOR`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM([Gross $])`
- **Use Case**: Track which labor units have been invoiced and which are deferred

### Example Query 4: Task Type Analysis
Analyze labor by task type:
- **Dimensions**: `@ Task Type`, `WORK_ACTIVITY`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM([Gross $])`
- **Use Case**: Understand labor distribution across task types

### Example Query 5: NLR and Rejected Analysis
Identify tasks that are no longer required or rejected:
- **Filter**: `Task NLR = true` OR `Is Rejected = true`
- **Dimensions**: `CONTRACTOR`, `PROJECT`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM([Gross $])`
- **Use Case**: Track labor costs for cancelled/rejected work

### Example Query 6: Retainage Analysis
Analyze retainage amounts:
- **Dimensions**: `CONTRACTOR`, `PROJECT`
- **Metrics**: 
  - `SUM([Gross $])` - Total gross
  - `SUM([Retainage $])` - Total retainage
  - `SUM([Retainage $]) / SUM([Gross $])` - Retainage percentage (should be ~10%)
- **Use Case**: Verify retainage calculations and track held amounts

## Notes

- **Unit Type Filter**: The model must filter to `UNIT_TYPE = 'Labor'` to focus on labor units only
- **Financial Calculations**: All financial fields depend on `LABOR_RATE` being populated. Filter to `LABOR_RATE IS NOT NULL` for accurate financial analysis
- **Custom Column Dependencies**: Be aware of the dependency chain when creating new custom columns
- **Work Package Joins**: `WORK_PACKAGE` field may be used to join with Camvio service orders (`SERVICEORDER_ID`)
- **Is Fybe Logic**: Note that `Is Fybe = true` means the contractor is NOT Fybe (it's an external contractor). The field name can be confusing - it's checking if contractor name does NOT contain "fybe"

## Model Filter Definition

In Metabase, apply this filter to the model:

```sql
WHERE UNIT_TYPE = 'Labor'
```

Or in Metabase's filter interface:
- **Field**: `UNIT_TYPE`
- **Operator**: `=` (equal)
- **Value**: `Labor`

## Custom Column Setup

All custom columns should be added to the model according to the definitions in [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md). The custom columns should be added in this order to respect dependencies:

1. `Labels General (norm)` - Base normalization field
2. `Task Type Clean` - Base cleaning field
3. `Is Approved` - Simple boolean
4. `Task NLR` - Simple boolean
5. `Is Rejected` - Depends on `Labels General (norm)`
6. `Is Invoiced` - Depends on `Labels General (norm)`
7. `Is Deferred` - Depends on `Labels General (norm)`
8. `Is Fybe` - Simple boolean
9. `@ Task Type` - Depends on `Task Type Clean`
10. `Gross $` - Depends on `ACTUAL_QUANTITY` and `LABOR_RATE`
11. `Net $` - Depends on `Gross $`
12. `Retainage $` - Depends on `Gross $` and `Net $`
