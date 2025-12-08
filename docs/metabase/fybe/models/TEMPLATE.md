# [Model Name] - Metabase Model Documentation

## Overview

[Brief description of what this model provides]

**Model Type**: BASE MODEL | ENHANCED MODEL  
**Source Query**: `snowflake/fybe/queries/[query_name].sql` OR `snowflake/fybe/[view_name].sql`  
**Database**: Fybe Snowflake (DATA_LAKE)
**Schema**: ANALYTICS | S3_STAGES | [other]

## Purpose

This model enables analysis of:
1. [Primary use case 1]
2. [Primary use case 2]
3. [Primary use case 3]

## Model Structure

### Base Model: "[Model Name] (Base)"
- **Query/View**: `[query_or_view_name]`
- **Filters**: [Any filters applied]
- **Joins**: 
  - [Table/View 1] ([JOIN TYPE]) - [purpose]
  - [Table/View 2] ([JOIN TYPE]) - [purpose]

### Enhanced Model: "[Model Name] (Enhanced)" (if applicable)
- **Base**: "[Model Name] (Base)"
- **Custom Columns**: See [`Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md)
- **Metrics**: [Any calculated metrics]

## Important Notes

[Any important caveats, gotchas, or special considerations]

### Data Characteristics
- [Note about row counts, duplicates, etc.]
- [Note about NULL values]
- [Note about date ranges]

## Key Fields

| Field Name | Type | Semantic Type | Description | Notes |
|------------|------|---------------|-------------|-------|
| `FIELD_NAME` | [data type] | [semantic type] | [description] | [any notes] |
| `FIELD_NAME` | [data type] | [semantic type] | [description] | [any notes] |

### Entity Keys
- `[KEY_FIELD]` - [description] - [joins to...]

### Important Dimensions
- `[DIMENSION_FIELD]` - [description]

### Important Metrics
- `[METRIC_FIELD]` - [description] - [calculation if applicable]

## Tables/Views Used

### [Table/View Name]
**Full Name**: `DATA_LAKE.[SCHEMA].[TABLE_NAME]`  
**Purpose**: [What this table provides]

**Key Columns**:
- `COLUMN_NAME` - [description]

## Related Documentation

- **Semantic Types**: See [`[MODEL_NAME]_SEMANTIC_TYPES.md`](./[MODEL_NAME]_SEMANTIC_TYPES.md)
- **Column Mapping**: See [`[MODEL_NAME]_COLUMN_MAPPING.md`](./[MODEL_NAME]_COLUMN_MAPPING.md) (if applicable)
- **Join Columns**: See [`[MODEL_NAME]_JOIN_COLUMNS.md`](./[MODEL_NAME]_JOIN_COLUMNS.md) (if applicable)
- **Custom Columns**: See [`../Custom Column Definitions - Render.md`](../Custom%20Column%20Definitions%20-%20Render.md)

## Usage Examples

### Example Query 1
[Description of common use case]

### Example Query 2
[Description of common use case]
