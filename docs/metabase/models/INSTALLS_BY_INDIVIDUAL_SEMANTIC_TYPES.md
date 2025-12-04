# Installs by Individual (Base) - Semantic Types

## Overview

Semantic types in Metabase help the system understand what kind of data each column contains, enabling better visualizations, filtering, and data exploration. This document specifies the recommended semantic types for each column in the **Installs by Individual (Base)** model.

## Column Semantic Types

### Service Order Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `ORDER_ID` | **Entity Key** | Order identifier | Primary key for orders (different from SERVICEORDER_ID) |
| `SERVICEORDER_ID` | **Entity Key** | Service order identifier | Primary key for service orders, joins to Fybe WORK_PACKAGE |
| `SERVICEORDER_TYPE` | **Category** | Type of service order | Categorical field for grouping/filtering |
| `STATUS` | **Category** | Service order status | Should be filtered to 'COMPLETED' in base query |

### Account Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `ACCOUNT_ID` | **Entity Key** | Customer account identifier | Primary key for customer accounts |
| `ACCOUNT_TYPE` | **Category** | Type of customer account | Categorical field (e.g., Residential, Business) |

### Service Line Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `SERVICELINE_NUMBER` | **Entity Key** | Service line identifier | Primary key for service lines |

### Task Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `TASK_NAME` | **Category** | Name of the task | Should be 'TECHNICIAN VISIT' in base query |
| `TASK_STARTED` | **Creation Timestamp** | When the task started | Use for duration calculations |
| `TASK_ENDED` | **Creation Timestamp** | When the task ended | Use for duration calculations and completion tracking |
| `ASSIGNEE` | **Entity Name** | Technician/individual who completed the install | **Key field** for grouping by individual |

### Appointment Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `APPOINTMENT_ID` | **Entity Key** | Appointment identifier | Primary key for appointments |
| `APPOINTMENT_TYPE` | **Category** | Type of appointment | Categorical field |
| `APPOINTMENT_TYPE_DESCRIPTION` | **Description** | Description of appointment type | Text description field |
| `APPOINTMENT_DATE` | **Creation Timestamp** | Scheduled appointment date | Use for comparing with TASK_ENDED |

### Service Line Feature Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `FEATURE` | **Category** | Feature name | Categorical field for grouping features |
| `FEATURE_PRICE` | **Currency** | Price of the feature | Use for financial calculations |
| `QTY` | **Quantity** | Quantity of features | Use for quantity calculations |
| `PLAN` | **Category** | Service plan name | Categorical field |

### Address Fields

| Column Name | Semantic Type | Description | Notes |
|------------|---------------|-------------|-------|
| `SERVICE_MODEL` | **Category** | Service model type | Categorical field |
| `SERVICELINE_ADDRESS1` | **Address** | Primary address line | Part of full address |
| `SERVICELINE_ADDRESS2` | **Address** | Secondary address line | Part of full address |
| `SERVICELINE_ADDRESS_CITY` | **City** | City name | Use for geographic grouping |
| `SERVICELINE_ADDRESS_STATE` | **State** | State abbreviation or name | **Key field** for geographic filtering |
| `SERVICELINE_ADDRESS_ZIPCODE` | **ZIP Code** | ZIP/postal code | Use for geographic grouping |

## Semantic Type Categories Reference

### Primary Types

- **Entity Key**: Unique identifiers (IDs, primary keys)
- **Entity Name**: Names of entities (people, companies, etc.)
- **Category**: Categorical data (status, type, classification)
- **Description**: Text descriptions
- **Creation Timestamp**: Date/time fields
- **Currency**: Monetary values
- **Quantity**: Numeric quantities
- **Address**: Street addresses
- **City**: City names
- **State**: State/province names
- **ZIP Code**: Postal codes

### Additional Semantic Types Available

- **Number**: General numeric values
- **Email**: Email addresses
- **URL**: Web URLs
- **Image URL**: Image URLs
- **JSON**: JSON data
- **Serialized JSON**: Serialized JSON strings
- **Foreign Key**: Foreign key relationships
- **Latitude**: Geographic latitude
- **Longitude**: Geographic longitude
- **Coordinate**: Geographic coordinates

## Key Fields for Analysis

### Primary Analysis Dimensions

1. **ASSIGNEE** (Entity Name) - Group by technician/individual
2. **TASK_ENDED** (Creation Timestamp) - Time-based analysis
3. **SERVICELINE_ADDRESS_STATE** (State) - Geographic analysis
4. **SERVICEORDER_TYPE** (Category) - Service type analysis
5. **ACCOUNT_TYPE** (Category) - Customer type analysis

### Primary Metrics

1. **FEATURE_PRICE** (Currency) - Financial metrics
2. **QTY** (Quantity) - Quantity metrics
3. **TASK_STARTED/TASK_ENDED** (Creation Timestamp) - Duration metrics (calculated)

## Setting Semantic Types in Metabase

### Method 1: Model Settings (Recommended)

1. Open the **Installs by Individual (Base)** model
2. Click on **Model settings** (gear icon)
3. Go to **Column metadata** tab
4. For each column, set the **Semantic type** from the dropdown
5. Save changes

### Method 2: Individual Column Settings

1. Open the model
2. Click on a column header
3. Select **Column settings**
4. Set **Semantic type**
5. Save

### Method 3: Bulk Update (Admin)

1. Go to **Admin** → **Data Model**
2. Select the database
3. Navigate to the model
4. Update semantic types in bulk

## Best Practices

1. **Set Entity Keys First**: Identify all primary keys and foreign keys
2. **Set Timestamps**: Mark all date/time fields as Creation Timestamp
3. **Set Geographic Fields**: Mark address, city, state, ZIP code fields appropriately
4. **Set Currency Fields**: Mark all monetary values as Currency
5. **Set Categories**: Mark all categorical fields (status, type, etc.) as Category
6. **Set Entity Names**: Mark person/company name fields as Entity Name

## Impact of Semantic Types

Setting correct semantic types enables:

- **Better Visualizations**: Metabase suggests appropriate chart types
- **Smart Filtering**: Date pickers for timestamps, dropdowns for categories
- **Geographic Features**: Map visualizations for address/state fields
- **Currency Formatting**: Automatic currency formatting
- **Relationship Detection**: Automatic foreign key relationship detection
- **Better Search**: Improved search and filtering capabilities

## Notes

- Semantic types can be changed later if needed
- Some semantic types may require additional configuration (e.g., currency symbol)
- Geographic semantic types enable map visualizations
- Entity Name types enable better person/company name handling
- Timestamp types enable date range filtering and time-based aggregations

