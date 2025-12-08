# Render Material Unit Report (Enriched) - Metabase Model Documentation

## Overview

This model provides an enriched view of **Render material units** with custom calculated fields for status tracking and categorization. It focuses specifically on material-type units with business logic applied.

**Model Type**: ENHANCED MODEL  
**Base Model**: Render Unit Report (Base)  
**Source View**: `DATA_LAKE.ANALYTICS.VW_RENDER_UNITS`  
**Database**: Fybe Snowflake (DATA_LAKE)
**Schema**: ANALYTICS

## Purpose

This model enables analysis of:
1. **Material unit tracking** - Material-type units with enhanced categorization
2. **Approval tracking** - Approval status and workflow
3. **Invoice status** - Invoiced and deferred tracking
4. **Task categorization** - Cleaned and normalized task type classifications
5. **Status indicators** - NLR (No Longer Required) and approval status

## Model Structure

### Enhanced Model: "Render Material Unit Report (Enriched)"
- **Base Model**: Render Unit Report (Base)
- **Filter**: `UNIT_TYPE = 'Material'` (applied in Metabase model)
- **Custom Columns**: 7 custom calculated fields (see Custom Columns section)
- **Joins**: Inherits from base model (includes labor code enrichment, though less relevant for materials)

## Important Notes

### Unit Type Filter
⚠️ **Important**: This model filters to include only records where `UNIT_TYPE = 'Material'`. This filter must be applied in the Metabase model definition.

**Filter Definition**:
```sql
WHERE UNIT_TYPE = 'Material'
```

Or in Metabase filter interface:
- **Field**: `UNIT_TYPE`
- **Operator**: `=` (equal)
- **Value**: `Material`

### Custom Column Dependencies
Several custom columns depend on others:
- `Labels General (norm)` is used by: `Is Invoiced`, `Is Deferred`
- `Task Type Clean` is used by: `@ Task Type`

### No Financial Fields
Unlike the Labor Unit Report, this model does not include financial calculations (Gross $, Net $, Retainage $) as material units typically don't have labor rates.

## Custom Columns

All custom columns are defined in [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md). Below is a summary:

### Status Indicators

| Custom Column | Type | Description | Formula Reference |
|---------------|------|-------------|-------------------|
| `Is Approved` | Boolean | Whether the unit has been approved | `notNull([Approved Date])` |
| `Task NLR` | Boolean | Task marked as "No Longer Required" | `lower(trim([Work Activity])) = "no longer required"` |
| `Is Invoiced` | Boolean | Task has been invoiced | `contains([Labels General (norm)], "invoiced")` |
| `Is Deferred` | Boolean | Task has been deferred | `contains([Labels General (norm)], "defer")` |

### Normalization Fields

| Custom Column | Type | Description | Formula Reference |
|---------------|------|-------------|-------------------|
| `Labels General (norm)` | Text | Normalized (lowercase) version of Labels General | `if(isNull([Labels General]), "", lower([Labels General]))` |
| `Task Type Clean` | Text | Cleaned task type (replaces underscores, dashes, dots with spaces) | `replace(replace(replace([Task Type], "_", " "), "-", " "), ".", " ")` |
| `@ Task Type` | Text | Formatted task type with proper capitalization | Complex formatting based on `Task Type Clean` |

## Key Fields (Inherited from Base)

All fields from **Render Unit Report (Base)** are available, including:
- `TASK_ID`, `WORK_PACKAGE`, `PROJECT`, `ASSET_ID`
- `UNIT_CODE`, `UNIT_TYPE` (filtered to "Material")
- `ACTUAL_QUANTITY`, `PLANNED_QUANTITY`
- `CONTRACTOR`, `CREW_NAME`, `WORK_ACTIVITY`
- `APPROVED_DATE`, `COMPLETED_DATE`
- `LABOR_RATE`, `LABOR_CODE_*` fields (may be NULL for materials)
- All label fields

See [`RENDER_UNIT_REPORT.md`](./RENDER_UNIT_REPORT.md) for complete field documentation.

## Related Documentation

- **Base Model**: [`RENDER_UNIT_REPORT.md`](./RENDER_UNIT_REPORT.md)
- **Custom Column Definitions**: [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md) - Full formulas for all custom columns
- **Semantic Types**: See [`RENDER_MATERIAL_UNIT_REPORT_SEMANTIC_TYPES.md`](./RENDER_MATERIAL_UNIT_REPORT_SEMANTIC_TYPES.md) (to be created)

## Usage Examples

### Example Query 1: Material Unit Approval Status
Track approval status for material units:
- **Dimensions**: `Is Approved`, `PROJECT`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`
- **Filter**: `Task NLR = false` (exclude cancelled tasks)

### Example Query 2: Invoice Status
Analyze invoicing status for materials:
- **Dimensions**: `Is Invoiced`, `Is Deferred`, `CONTRACTOR`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`
- **Use Case**: Track which material units have been invoiced and which are deferred

### Example Query 3: Task Type Analysis
Analyze materials by task type:
- **Dimensions**: `@ Task Type`, `WORK_ACTIVITY`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`
- **Use Case**: Understand material distribution across task types

### Example Query 4: NLR Analysis
Identify material tasks that are no longer required:
- **Filter**: `Task NLR = true`
- **Dimensions**: `CONTRACTOR`, `PROJECT`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`
- **Use Case**: Track material quantities for cancelled work

### Example Query 5: Material Units by Contractor
Analyze material units by contractor:
- **Dimensions**: `CONTRACTOR`, `PROJECT`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`
- **Filter**: `Is Approved = true` (approved materials only)

### Example Query 6: Deferred Materials
Track deferred material units:
- **Filter**: `Is Deferred = true`
- **Dimensions**: `CONTRACTOR`, `PROJECT`, `@ Task Type`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`
- **Use Case**: Identify materials that have been deferred

## Notes

- **Unit Type Filter**: The model must filter to `UNIT_TYPE = 'Material'` to focus on material units only
- **No Financial Fields**: Unlike labor units, material units don't typically have financial calculations in this model
- **Custom Column Dependencies**: Be aware of the dependency chain when creating new custom columns
- **Work Package Joins**: `WORK_PACKAGE` field may be used to join with Camvio service orders (`SERVICEORDER_ID`)
- **Labor Code Fields**: Labor code fields may be NULL for material units, as they're primarily relevant for labor units

## Model Filter Definition

In Metabase, apply this filter to the model:

```sql
WHERE UNIT_TYPE = 'Material'
```

Or in Metabase's filter interface:
- **Field**: `UNIT_TYPE`
- **Operator**: `=` (equal)
- **Value**: `Material`

## Custom Column Setup

All custom columns should be added to the model according to the definitions in [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md). The custom columns should be added in this order to respect dependencies:

1. `Labels General (norm)` - Base normalization field
2. `Task Type Clean` - Base cleaning field
3. `Is Approved` - Simple boolean
4. `Task NLR` - Simple boolean
5. `Is Invoiced` - Depends on `Labels General (norm)`
6. `Is Deferred` - Depends on `Labels General (norm)`
7. `@ Task Type` - Depends on `Task Type Clean`

## Comparison with Labor Unit Report

| Feature | Material Unit Report | Labor Unit Report |
|---------|---------------------|-------------------|
| **Filter** | `UNIT_TYPE = 'Material'` | `UNIT_TYPE = 'Labor'` |
| **Custom Columns** | 7 fields | 12 fields |
| **Financial Fields** | None | Gross $, Net $, Retainage $ |
| **Status Fields** | Is Approved, Task NLR, Is Invoiced, Is Deferred | Same + Is Rejected, Is Fybe |
| **Use Case** | Material tracking and categorization | Labor cost analysis and financial tracking |
