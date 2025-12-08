# Render Tickets Report (Base) - Semantic Types

## Overview

Semantic types in Metabase help the system understand what kind of data each column contains, enabling better visualizations, filtering, and data exploration. This document specifies the recommended semantic types for each column in the **Render Tickets Report (Base)** model.

**Model**: Render Tickets Report (Base)  
**Source**: `DATA_LAKE.ANALYTICS.VW_RENDER_TICKETS`  
**Filter**: Excludes records where `CONTRACTOR = 'Fybe'`

## Column Semantic Types

### Task Identification Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `TASK_ID` | `TASK_ID` | **Entity Key** | Unique task identifier | Primary key for tasks |
| `WORK_PACKAGE` | `WORK_PACKAGE` | **Entity Key** | Work package identifier | May join to Camvio SERVICEORDER_ID |
| `PROJECT_ID` | `PROJECT_ID` | **Category** | Project identifier | Already filtered in view (excludes specific projects) |

### Status and Classification Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `STATUS` | `STATUS` | **Category** | Ticket status | Categorical field for filtering/grouping |
| `PHASE` | `PHASE` | **Category** | Task phase | Categorical field |
| `TASK` | `TASK` | **Category** | Task name/description | Categorical field |
| `ACTION` | `ACTION` | **Category** | Action type | Categorical field |
| `WORK_ACTIVITY` | `WORK_ACTIVITY` | **Category** | Work activity type | Categorical field for activity classification |
| `FFP` | `FFP` | **Category** | FFP identifier | Categorical field |
| `GROUP_ID` | `GROUP_ID` | **Category** | Group identifier | Categorical field |

### Entity Name Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `CONTRACTOR` | `CONTRACTOR` | **Entity Name** | Contractor name | **Key field** for contractor analysis. **Filtered**: Excludes "Fybe" |
| `RESOURCE_USER_NAME` | `RESOURCE_USER_NAME` | **Entity Name** | Resource user name | Use for resource/user tracking |

### Quantity Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `QTTY` | `QTTY` | **Quantity** | Quantity | Use for quantity calculations |

### Date Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `DATE_RELEASED` | `DATE_RELEASED` | **Creation Timestamp** | Release date | Use for release tracking |
| `DATE_COMPLETED` | `DATE_COMPLETED` | **Creation Timestamp** | Completion date | Use for completion tracking |
| `DATE_APPROVED` | `DATE_APPROVED` | **Creation Timestamp** | Approval date | Use for approval tracking |
| `BLUEPRINTED_DATE` | `BLUEPRINTED_DATE` | **Creation Timestamp** | Blueprinted date | Use for blueprint tracking |
| `TARGET_DATE` | `TARGET_DATE` | **Creation Timestamp** | Target completion date | Use for target vs actual analysis |

### Asset and Location Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `ASSET_ID` | `ASSET_ID` | **Entity Key** | Asset identifier | Primary key for assets |
| `STREET_ADDRESS` | `STREET_ADDRESS` | **Address** | Street address | Use for location-based analysis |
| `ROAD_NAME` | `ROAD_NAME` | **Address** | Road name | Use for location-based analysis |

### Resource Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `RESOURCE_ID` | `RESOURCE_ID` | **Entity Key** | Resource identifier | Primary key for resources |

### Label Fields (All Category Type)

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `LABELS_GENERAL` | `LABELS_GENERAL` | **Category** | General labels | Flexible categorization |
| `LABELS_GRANT_ID` | `LABELS_GRANT_ID` | **Category** | Grant identifier | Use for grant-based filtering |
| `LABELS_WORK_ORDER` | `LABELS_WORK_ORDER` | **Category** | Work order reference | Categorical field |

### Notes Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `NOTES` | `NOTES` | **Description** | Task notes | Text description field |

## Semantic Type Categories Reference

### Primary Types

- **Entity Key**: Unique identifiers (IDs, primary keys, codes used for joins)
- **Entity Name**: Names of entities (people, companies, contractors, resources)
- **Category**: Categorical data (status, type, classification, labels)
- **Description**: Text descriptions and notes
- **Creation Timestamp**: Date/time fields
- **Quantity**: Numeric quantities
- **Address**: Address fields

## Important Notes

### NULL Values
- Date fields may be NULL if the ticket hasn't reached that stage (e.g., `DATE_COMPLETED` is NULL for incomplete tickets)
- `TARGET_DATE` may be NULL if no target date is set
- `NOTES` may be NULL if no notes are recorded

### Key Fields for Analysis
- **Contractor Analysis**: Use `CONTRACTOR` (Entity Name) + `QTTY` (Quantity) - Note: Already filtered to exclude "Fybe"
- **Project Tracking**: Use `PROJECT_ID` (Category) + `STATUS` (Category) + date fields
- **Completion Analysis**: Use `DATE_COMPLETED` (Creation Timestamp) + `TARGET_DATE` (Creation Timestamp) for on-time analysis
- **Work Package Joins**: `WORK_PACKAGE` (Entity Key) can join to Camvio `SERVICEORDER_ID`
- **Phase/Status Tracking**: Use `PHASE` (Category) + `STATUS` (Category) for workflow analysis

### Label Fields
All label fields are set as **Category** type to enable flexible filtering and grouping. Use these fields for:
- Grant-based analysis (`LABELS_GRANT_ID`)
- Work order tracking (`LABELS_WORK_ORDER`)
- General categorization (`LABELS_GENERAL`)

### Model Filter
⚠️ **Important**: This model must have a filter applied in Metabase to exclude records where `CONTRACTOR = 'Fybe'`. This filter is not in the underlying view but should be applied at the model level.

**Filter Definition**:
```sql
WHERE CONTRACTOR != 'Fybe'
```

Or in Metabase filter interface:
- **Field**: `CONTRACTOR`
- **Operator**: `!=` (not equal)
- **Value**: `Fybe`

## Setting Semantic Types in Metabase

1. Navigate to the model in Metabase
2. **Apply the contractor filter first**: Add filter `CONTRACTOR != 'Fybe'`
3. Go to the model settings
4. For each column, set the semantic type according to this document
5. Pay special attention to:
   - Entity Keys (for proper joins)
   - Entity Names (for proper name formatting)
   - Creation Timestamps (for date-based filtering)
   - Category fields (for proper grouping)

## Date Field Relationships

The model includes multiple date fields that track different stages:
- **BLUEPRINTED_DATE** → **DATE_RELEASED** → **DATE_APPROVED** → **DATE_COMPLETED**
- **TARGET_DATE** can be compared with **DATE_COMPLETED** for on-time analysis

Use these relationships for:
- Workflow stage analysis
- Time-to-completion calculations
- On-time performance metrics
