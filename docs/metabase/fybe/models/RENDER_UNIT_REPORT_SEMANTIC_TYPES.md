# Render Unit Report (Base) - Semantic Types

## Overview

Semantic types in Metabase help the system understand what kind of data each column contains, enabling better visualizations, filtering, and data exploration. This document specifies the recommended semantic types for each column in the **Render Unit Report (Base)** model.

**Model**: Render Unit Report (Base)  
**Source**: `DATA_LAKE.ANALYTICS.VW_RENDER_UNITS`

## Column Semantic Types

### Task Identification Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `TASK_ID` | `u.TASK_ID` | **Entity Key** | Unique task identifier | Primary key for tasks |
| `WORK_PACKAGE` | `u.WORK_PACKAGE` | **Entity Key** | Work package identifier | May join to Camvio SERVICEORDER_ID |
| `PROJECT` | `u.PROJECT` | **Category** | Project identifier | Use for project-level grouping |

### Status and Type Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `STATUS` | `u.STATUS` | **Category** | Task status | Categorical field for filtering/grouping |
| `TASK_TYPE` | `u.TASK_TYPE` | **Category** | Type of task | Categorical field |
| `WORK_ACTIVITY` | `u.WORK_ACTIVITY` | **Category** | Work activity type | Categorical field for activity classification |

### Unit Information Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `UNIT_CODE` | `u.UNIT_CODE` | **Entity Key** | Unit code | Used to join to LABOR_CODES |
| `UNIT_TYPE` | `u.UNIT_TYPE` | **Category** | Type of unit | Categorical field |
| `UNIT_DESCRIPTION` | `u.UNIT_DESCRIPTION` | **Description** | Description of the unit | Text description field |
| `RUS_CODE` | `u.RUS_CODE` | **Category** | RUS code | Categorical field |
| `UOM` | `u.UOM` | **Category** | Unit of measure | Categorical field (e.g., "FT", "EA", "HR") |

### Quantity Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `ACTUAL_QUANTITY` | `u.ACTUAL_QUANTITY` | **Quantity** | Actual quantity completed | Use for quantity calculations |
| `PLANNED_QUANTITY` | `u.PLANNED_QUANTITY` | **Quantity** | Planned quantity | Use for variance analysis |

### Date Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `APPROVED_DATE` | `u.APPROVED_DATE` | **Creation Timestamp** | Approval date | Use for approval tracking |
| `COMPLETED_DATE` | `u.COMPLETED_DATE` | **Creation Timestamp** | Completion date | Use for completion tracking |
| `ORIGINAL_COMPLETED_DATE` | `u.ORIGINAL_COMPLETED_DATE` | **Creation Timestamp** | Original completion date | Use for change tracking |

### Entity Name Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `CONTRACTOR` | `u.CONTRACTOR` | **Entity Name** | Contractor name | **Key field** for contractor analysis |
| `CREW_NAME` | `u.CREW_NAME` | **Entity Name** | Crew name | Use for crew-level analysis |
| `APPROVING_USER` | `u.APPROVING_USER` | **Entity Name** | User who approved | Use for approval workflow tracking |

### Asset and Location Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `ASSET_ID` | `u.ASSET_ID` | **Entity Key** | Asset identifier | Primary key for assets |
| `STREET_ADDRESS` | `u.STREET_ADDRESS` | **Address** | Street address | Use for location-based analysis |
| `SUBSECTOR` | `u.SUBSECTOR` | **Category** | Subsector classification | Categorical field for geographic grouping |

### Label Fields (All Category Type)

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `LABELS_GENERAL` | `u.LABELS_GENERAL` | **Category** | General labels | Flexible categorization |
| `LABELS_GRANT_ID` | `u.LABELS_GRANT_ID` | **Category** | Grant identifier | Use for grant-based filtering |
| `LABELS_JOB_TYPE` | `u.LABELS_JOB_TYPE` | **Category** | Job type classification | Categorical field |
| `LABELS_SUPERVISOR` | `u.LABELS_SUPERVISOR` | **Category** | Supervisor assignment | Use for supervisor tracking |
| `LABELS_GRANT_AREAS` | `u.LABELS_GRANT_AREAS` | **Category** | Grant area information | Categorical field |
| `LABELS_DROP_ADMIN` | `u.LABELS_DROP_ADMIN` | **Category** | Drop administration labels | Categorical field |
| `LABELS_WORK_ORDER` | `u.LABELS_WORK_ORDER` | **Category** | Work order reference | Categorical field |
| `LABELS_DROP_API` | `u.LABELS_DROP_API` | **Category** | Drop API labels | Categorical field |
| `LABELS_WORK_CATEGORY` | `u.LABELS_WORK_CATEGORY` | **Category** | Work category classification | Categorical field |
| `LABELS_ERP_PROJECT_ID` | `u.LABELS_ERP_PROJECT_ID` | **Category** | ERP project identifier | Categorical field |
| `LABELS_FUNDING_POLYGONS` | `u.LABELS_FUNDING_POLYGONS` | **Category** | Funding polygon information | Categorical field |
| `LABELS_BLUEPRINT_ID` | `u.LABELS_BLUEPRINT_ID` | **Category** | Blueprint identifier | Categorical field |

### Notes Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `INSTALLED_PER_TASK_NOTES` | `u.INSTALLED_PER_TASK_NOTES` | **Description** | Installation notes per task | Text description field |
| `CONSTRUCTION_NOTES` | `u.CONSTRUCTION_NOTES` | **Description** | Construction notes | Text description field |
| `TASK_NOTES` | `u.TASK_NOTES` | **Description** | Task notes | Text description field |

### Labor Code Fields (from LABOR_CODES join)

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `LABOR_CODE_CODE` | `c.CODE` | **Category** | Labor code | From LABOR_CODES join (may be NULL) |
| `LABOR_CODE_RUS_CODE` | `c.RUS_CODE` | **Category** | Labor code RUS code | From LABOR_CODES join (may be NULL) |
| `LABOR_CODE_DESCRIPTION` | `c.DESCRIPTION` | **Description** | Labor code description | From LABOR_CODES join (may be NULL) |
| `LABOR_CODE_UOM` | `c.UOM` | **Category** | Labor code unit of measure | From LABOR_CODES join (may be NULL) |
| `LABOR_RATE` | `c.RATE` | **Currency** | Labor rate | From LABOR_CODES join (may be NULL) |

### Other Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `CHANGE_REQUEST_APPROVAL_NUMBER` | `u.CHANGE_REQUEST_APPROVAL_NUMBER` | **Entity Key** | Change request approval number | Joins to TASK_ID in related tasks |

## Semantic Type Categories Reference

### Primary Types

- **Entity Key**: Unique identifiers (IDs, primary keys, codes used for joins)
- **Entity Name**: Names of entities (people, companies, contractors, crews)
- **Category**: Categorical data (status, type, classification, labels)
- **Description**: Text descriptions and notes
- **Creation Timestamp**: Date/time fields
- **Currency**: Monetary values (rates, costs)
- **Quantity**: Numeric quantities
- **Address**: Address fields

## Important Notes

### NULL Values
- Labor code fields (`LABOR_CODE_*`, `LABOR_RATE`) may be NULL if no matching labor code exists for the `UNIT_CODE`
- Date fields may be NULL if the task hasn't reached that stage (e.g., `COMPLETED_DATE` is NULL for incomplete tasks)

### Key Fields for Analysis
- **Contractor Analysis**: Use `CONTRACTOR` (Entity Name) + `ACTUAL_QUANTITY` (Quantity)
- **Project Tracking**: Use `PROJECT` (Category) + `STATUS` (Category) + date fields
- **Labor Cost Analysis**: Use `LABOR_RATE` (Currency) + `ACTUAL_QUANTITY` (Quantity) - filter to rows where `LABOR_RATE IS NOT NULL`
- **Work Package Joins**: `WORK_PACKAGE` (Entity Key) can join to Camvio `SERVICEORDER_ID`
- **Change Request Tracking**: `CHANGE_REQUEST_APPROVAL_NUMBER` (Entity Key) can join to related tasks where this value appears in `TASK_ID`

### Label Fields
All label fields are set as **Category** type to enable flexible filtering and grouping. Use these fields for:
- Grant-based analysis (`LABELS_GRANT_ID`, `LABELS_GRANT_AREAS`)
- Supervisor tracking (`LABELS_SUPERVISOR`)
- Work categorization (`LABELS_WORK_CATEGORY`, `LABELS_JOB_TYPE`)
- Cross-system references (`LABELS_ERP_PROJECT_ID`, `LABELS_WORK_ORDER`)

## Setting Semantic Types in Metabase

1. Navigate to the model in Metabase
2. Go to the model settings
3. For each column, set the semantic type according to this document
4. Pay special attention to:
   - Entity Keys (for proper joins)
   - Entity Names (for proper name formatting)
   - Creation Timestamps (for date-based filtering)
   - Currency fields (for proper formatting)
