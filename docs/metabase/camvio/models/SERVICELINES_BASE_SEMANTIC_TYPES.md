# Servicelines Base - Semantic Types

## Overview

Semantic types in Metabase help the system understand what kind of data each column contains, enabling better visualizations, filtering, and data exploration. This document specifies the recommended semantic types for each column in the **Camvio – Servicelines (Base)** model.

**Model Documentation**: See [`SERVICELINES_BASE.md`](./SERVICELINES_BASE.md) for full model documentation.

## Column Semantic Types

### Serviceline Key Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `ACCOUNT_ID` | `s.ACCOUNT_ID` | **Entity Key** | Customer account identifier | Primary key for customer accounts, joins to CUSTOMER_ACCOUNTS |
| `ACCOUNT_NUMBER` | `s.ACCOUNT_NUMBER` | **Entity Key** | Account number | Alternative account identifier |
| `SERVICELINE_NUMBER` | `s.SERVICELINE_NUMBER` | **Entity Key** | Service line identifier | Primary key for service lines |
| `SERVICE_MODEL` | `s.SERVICE_MODEL` | **Category** | Service model type | Categorical field (e.g., Internet, Voice) |

### Account Context Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `ACCOUNT_STATUS` | `ca.ACCOUNT_STATUS` | **Category** | Account status | Categorical field (e.g., Active, Inactive) - use for filtering active accounts |
| `ACCOUNT_TYPE` | `ca.ACCOUNT_TYPE` | **Category** | Type of customer account | **Key field** for grouping (e.g., Residential, Business) |
| `ACCOUNT_CREATED` | `ca.ACCOUNT_CREATED` | **Creation Timestamp** | When the account was created | Use for account age calculations |
| `BILLCYCLE` | `ca.BILLCYCLE` | **Number** | Billing cycle number | Numeric field for billing cycle grouping |
| `AUTOPAY_FLAG` | `ca.AUTOPAY_FLAG` | **Category** | Autopay enabled flag | Boolean-like categorical field |

### Serviceline Status and Dates

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `SERVICELINE_STATUS` | `s.SERVICELINE_STATUS` | **Category** | Service line status | Categorical field (e.g., Active, Inactive) - use for filtering |
| `SERVICELINE_STARTDATE` | `s.SERVICELINE_STARTDATE` | **Creation Timestamp** | When the serviceline started | Use for tenure calculations |
| `SERVICELINE_ENDDATE` | `s.SERVICELINE_ENDDATE` | **Creation Timestamp** | When the serviceline ended | NULL for active servicelines, use for churn analysis |

### Address / Location Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `SERVICELINE_ADDRESS1` | `a.SERVICELINE_ADDRESS1` | **Address** | Primary address line | Part of full address |
| `SERVICELINE_ADDRESS2` | `a.SERVICELINE_ADDRESS2` | **Address** | Secondary address line | Part of full address |
| `SERVICELINE_ADDRESS3` | `a.SERVICELINE_ADDRESS3` | **Address** | Tertiary address line | Part of full address |
| `SERVICELINE_ADDRESS_CITY` | `a.SERVICELINE_ADDRESS_CITY` | **City** | City name | **Key field** for geographic grouping |
| `SERVICELINE_ADDRESS_STATE` | `a.SERVICELINE_ADDRESS_STATE` | **State** | State abbreviation or name | **Key field** for geographic filtering and grouping |
| `SERVICELINE_ADDRESS_ZIPCODE` | `a.SERVICELINE_ADDRESS_ZIPCODE` | **ZIP Code** | ZIP/postal code | Use for geographic grouping |
| `SERVICELINE_ADDRESS_VERIFIED` | `a.SERVICELINE_ADDRESS_VERIFIED` | **Category** | Address verification flag | Boolean-like categorical field |
| `MAPPING_ADDRESS_ID` | `a.MAPPING_ADDRESS_ID` | **Entity Key** | Mapping address identifier | Potential join key for external address/asset data |
| `MAPPING_AREA_ID` | `a.MAPPING_AREA_ID` | **Entity Key** | Mapping area identifier | Potential join key for area/project data |
| `MAPPING_REF_AREA1` | `a.MAPPING_REF_AREA1` | **Category** | Mapping reference area 1 | Categorical field for area/project grouping |
| `SERVICELINE_LATITUDE` | `a.SERVICELINE_LATITUDE` | **Latitude** | Geographic latitude | Use for map visualizations |
| `SERVICELINE_LONGITUDE` | `a.SERVICELINE_LONGITUDE` | **Longitude** | Geographic longitude | Use for map visualizations |

### Feature Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `PLANS` | `f.PLANS` | **Description** | Comma-separated list of plans | Aggregated from SERVICELINE_FEATURES, use for filtering/searching |
| `FEATURES` | `f.FEATURES` | **Description** | Comma-separated list of features | Aggregated from SERVICELINE_FEATURES, use for filtering/searching |

### Derived Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `IS_ACTIVE_SERVICELINE` | Derived | **Category** | Active serviceline flag | 1 = active, 0 = inactive. **Key field** for subscriber counts |
| `SERVICE_TYPE` | Derived | **Category** | Normalized service type | 'Internet', 'Voice', or 'Other'. **Key field** for service type analysis |
| `SERVICE_LOCATION_KEY` | Derived | **Entity Key** | Stable service location identifier | Hybrid key (MAPPING_ADDRESS_ID or address hash). Use for location-level analysis |

## Semantic Type Categories Reference

### Primary Types

- **Entity Key**: Unique identifiers (IDs, primary keys)
- **Entity Name**: Names of entities (people, companies, etc.)
- **Category**: Categorical data (status, type, classification)
- **Description**: Text descriptions
- **Creation Timestamp**: Date/time fields
- **Number**: Numeric values
- **Address**: Street addresses
- **City**: City names
- **State**: State/province names
- **ZIP Code**: Postal codes
- **Latitude**: Geographic latitude coordinates
- **Longitude**: Geographic longitude coordinates

### Additional Semantic Types Available

- **Currency**: Monetary values
- **Quantity**: Numeric quantities
- **Email**: Email addresses
- **URL**: Web URLs
- **Image URL**: Image URLs
- **JSON**: JSON data
- **Serialized JSON**: Serialized JSON strings
- **Foreign Key**: Foreign key relationships
- **Coordinate**: Geographic coordinates

## Key Fields for Analysis

### Primary Analysis Dimensions

1. **ACCOUNT_TYPE** (Category) - Group by customer type (Residential, Business, etc.)
2. **SERVICE_TYPE** (Category) - Group by service type (Internet, Voice, Other)
3. **IS_ACTIVE_SERVICELINE** (Category) - Filter for active subscribers
4. **SERVICELINE_ADDRESS_STATE** (State) - Geographic analysis
5. **SERVICELINE_ADDRESS_CITY** (City) - Geographic analysis
6. **MAPPING_AREA_ID** (Entity Key) - Area/project-based analysis
7. **SERVICELINE_STARTDATE** (Creation Timestamp) - Time-based analysis

### Primary Metrics

1. **IS_ACTIVE_SERVICELINE** (Category) - Count active servicelines (subscribers)
2. **SERVICELINE_STARTDATE** (Creation Timestamp) - Calculate tenure, growth over time
3. **SERVICELINE_ENDDATE** (Creation Timestamp) - Calculate churn, retention

### Key Filters

1. **IS_ACTIVE_SERVICELINE = 1** - Active servicelines only
2. **SERVICE_TYPE = 'Internet'** - Internet subscribers only
3. **ACCOUNT_STATUS** contains 'ACTIVE' - Active accounts only
4. **SERVICELINE_ENDDATE IS NULL** - No end date (active)

## Setting Semantic Types in Metabase

### Method 1: Model Settings (Recommended)

1. Open the **Camvio – Servicelines (Base)** model
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

1. **Set Entity Keys First**: Identify all primary keys (`ACCOUNT_ID`, `SERVICELINE_NUMBER`, `MAPPING_ADDRESS_ID`, etc.)
2. **Set Timestamps**: Mark all date/time fields (`SERVICELINE_STARTDATE`, `SERVICELINE_ENDDATE`, `ACCOUNT_CREATED`) as Creation Timestamp
3. **Set Geographic Fields**: Mark address, city, state, ZIP code, latitude, longitude fields appropriately
4. **Set Categories**: Mark all categorical fields (status, type, etc.) as Category
5. **Set Derived Flags**: Mark `IS_ACTIVE_SERVICELINE` and `SERVICE_TYPE` as Category for easy filtering

## Impact of Semantic Types

Setting correct semantic types enables:

- **Better Visualizations**: Metabase suggests appropriate chart types (maps for geographic fields, time series for timestamps)
- **Smart Filtering**: Date pickers for timestamps, dropdowns for categories, boolean filters for flags
- **Geographic Features**: Map visualizations for address/state/latitude/longitude fields
- **Relationship Detection**: Automatic foreign key relationship detection (e.g., ACCOUNT_ID relationships)
- **Better Search**: Improved search and filtering capabilities
- **Subscriber Analysis**: Easy filtering on `IS_ACTIVE_SERVICELINE` and `SERVICE_TYPE` for subscriber counts

## Common Use Cases

### Subscriber Count by Account Type

- **Filter**: `IS_ACTIVE_SERVICELINE = 1` AND `SERVICE_TYPE = 'Internet'`
- **Group By**: `ACCOUNT_TYPE`
- **Metric**: Count

### Subscriber Count by Feature

- **Filter**: `IS_ACTIVE_SERVICELINE = 1` AND `SERVICE_TYPE = 'Internet'` AND `FEATURES` contains 'GIG'
- **Group By**: `FEATURES` (or parse individual features)
- **Metric**: Count

### Geographic Analysis

- **Filter**: `IS_ACTIVE_SERVICELINE = 1`
- **Group By**: `SERVICELINE_ADDRESS_STATE` or `SERVICELINE_ADDRESS_CITY`
- **Visualization**: Map or bar chart

### Churn Analysis

- **Filter**: `SERVICELINE_ENDDATE IS NOT NULL`
- **Group By**: `SERVICELINE_ENDDATE` (by month/year)
- **Metric**: Count

## Notes

- Semantic types can be changed later if needed
- Geographic semantic types (`Latitude`, `Longitude`, `State`, `City`) enable map visualizations
- Entity Name types enable better person/company name handling
- Timestamp types enable date range filtering and time-based aggregations
- The `IS_ACTIVE_SERVICELINE` flag matches your existing subscriber counting logic
- `SERVICE_LOCATION_KEY` can be used for future location-level analysis when `MAPPING_ADDRESS_ID` is more populated

