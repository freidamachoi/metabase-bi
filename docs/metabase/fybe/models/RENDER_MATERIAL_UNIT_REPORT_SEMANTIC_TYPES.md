# Render Material Unit Report (Enriched) - Semantic Types

## Overview

Semantic types in Metabase help the system understand what kind of data each column contains, enabling better visualizations, filtering, and data exploration. This document specifies the recommended semantic types for each column in the **Render Material Unit Report (Enriched)** model.

**Model**: Render Material Unit Report (Enriched)  
**Base Model**: Render Unit Report (Base)  
**Source**: `DATA_LAKE.ANALYTICS.VW_RENDER_UNITS`  
**Filter**: `UNIT_TYPE = 'Material'`

## Column Semantic Types

### Base Model Fields

All fields from **Render Unit Report (Base)** are inherited. See [`RENDER_UNIT_REPORT_SEMANTIC_TYPES.md`](./RENDER_UNIT_REPORT_SEMANTIC_TYPES.md) for complete documentation of base fields.

**Key Base Fields**:
- `TASK_ID` - **Entity Key**
- `WORK_PACKAGE` - **Entity Key** (may join to Camvio SERVICEORDER_ID)
- `UNIT_TYPE` - **Category** (filtered to "Material")
- `ACTUAL_QUANTITY` - **Quantity**
- `CONTRACTOR` - **Entity Name**
- `APPROVED_DATE` - **Creation Timestamp**
- `LABOR_RATE` - **Currency** (may be NULL for materials)

### Custom Columns - Status Indicators

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `Is Approved` | **Boolean** | Whether the unit has been approved | Use for approval status filtering |
| `Task NLR` | **Boolean** | Task marked as "No Longer Required" | Use to filter out cancelled tasks |
| `Is Invoiced` | **Boolean** | Task has been invoiced | Use for invoice status tracking |
| `Is Deferred` | **Boolean** | Task has been deferred | Use for deferral tracking |

### Custom Columns - Normalization Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `Labels General (norm)` | **Category** | Normalized (lowercase) version of Labels General | Used by other custom columns, not typically displayed |
| `Task Type Clean` | **Category** | Cleaned task type | Intermediate field, used by `@ Task Type` |
| `@ Task Type` | **Category** | Formatted task type with proper capitalization | **Primary field** for task type analysis |

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
1. `Labels General (norm)` → Used by: `Is Invoiced`, `Is Deferred`
2. `Task Type Clean` → Used by: `@ Task Type`

### Key Fields for Analysis

- **Approval Tracking**: Use `Is Approved` (Boolean) + `APPROVED_DATE` (Creation Timestamp)
- **Invoice Status**: Use `Is Invoiced` (Boolean) + `Is Deferred` (Boolean)
- **Contractor Analysis**: Use `CONTRACTOR` (Entity Name) + `ACTUAL_QUANTITY` (Quantity)
- **Task Type Analysis**: Use `@ Task Type` (Category) - this is the cleaned/formatted version
- **Status Filtering**: Use `Task NLR` (Boolean) to filter out cancelled tasks

### No Financial Fields

Unlike the Labor Unit Report, this model does not include financial calculations. Material units are tracked by quantity, not by financial amounts.

### Labor Code Fields

The base model includes labor code fields (`LABOR_CODE_*`, `LABOR_RATE`), but these may be NULL or less relevant for material units. Focus on quantity-based metrics rather than financial metrics.

## Setting Semantic Types in Metabase

1. Navigate to the model in Metabase
2. **Apply the unit type filter first**: Add filter `UNIT_TYPE = 'Material'`
3. **Add all custom columns** according to [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md)
4. Go to the model settings
5. For each column, set the semantic type according to this document
6. Pay special attention to:
   - **Boolean fields** - for proper true/false filtering
   - **Entity Keys** - for proper joins
   - **Entity Names** - for proper name formatting
   - **Creation Timestamps** - for date-based filtering
   - **Quantity fields** - for quantity-based calculations

## Custom Column Display Recommendations

### Fields to Display in Default View
- `TASK_ID`
- `WORK_PACKAGE`
- `CONTRACTOR`
- `@ Task Type` (use this instead of base `TASK_TYPE`)
- `ACTUAL_QUANTITY`
- `Is Approved`
- `Is Invoiced`

### Fields to Hide (Intermediate/Supporting)
- `Labels General (norm)` - Supporting field, use base `LABELS_GENERAL` for display
- `Task Type Clean` - Supporting field, use `@ Task Type` for display

### Fields for Filtering
- `Is Approved` - Filter to approved units
- `Is Invoiced` - Filter to invoiced units
- `Task NLR` - Filter out cancelled tasks (`Task NLR = false`)
- `Is Deferred` - Filter to deferred units

## Usage Patterns

### Pattern 1: Material Unit Approval Status
- **Filter**: `Task NLR = false` (exclude cancelled)
- **Dimensions**: `Is Approved`, `PROJECT`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`

### Pattern 2: Invoice Status Tracking
- **Dimensions**: `Is Invoiced`, `Is Deferred`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`
- **Use Case**: Track which materials have been invoiced vs deferred

### Pattern 3: Task Type Material Analysis
- **Dimensions**: `@ Task Type`, `WORK_ACTIVITY`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`
- **Use Case**: Understand material distribution across task types

### Pattern 4: Contractor Material Analysis
- **Dimensions**: `CONTRACTOR`, `PROJECT`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`
- **Filter**: `Is Approved = true` (approved materials only)

### Pattern 5: Deferred Materials Tracking
- **Filter**: `Is Deferred = true`
- **Dimensions**: `CONTRACTOR`, `PROJECT`, `@ Task Type`
- **Metrics**: `COUNT(DISTINCT TASK_ID)`, `SUM(ACTUAL_QUANTITY)`
- **Use Case**: Identify materials that have been deferred

## Comparison with Labor Unit Report

| Aspect | Material Unit Report | Labor Unit Report |
|--------|---------------------|-------------------|
| **Custom Columns** | 7 fields | 12 fields |
| **Financial Fields** | None | Gross $, Net $, Retainage $ |
| **Status Fields** | Is Approved, Task NLR, Is Invoiced, Is Deferred | Same + Is Rejected, Is Fybe |
| **Primary Metrics** | Quantity-based | Financial and quantity-based |
| **Use Case Focus** | Material tracking and categorization | Labor cost analysis |
