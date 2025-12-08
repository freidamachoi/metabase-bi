# Service Orders with Charges - Column Mapping & Semantic Types

## Overview

This document maps each column in the **Service Orders with Charges** Metabase model to its corresponding database column(s) and recommended semantic types.

**Model Type**: BASE MODEL with multiple LEFT JOINs  
**Source Query**: `snowflake/camvio/queries/service_orders_with_charges.sql`

## Column Mapping Table

| Model Column Name | Database Table.Column | Semantic Type | Priority | Notes |
|------------------|---------------------|---------------|----------|-------|
| `ORDER_ID` | `SERVICEORDERS.ORDER_ID` | **Entity Key** | ⭐ **HIGH** | Order identifier |
| `SERVICEORDER_ID` | `SERVICEORDERS.SERVICEORDER_ID` | **Entity Key** | ⭐ **HIGH** | Service order identifier (joins to Fybe WORK_PACKAGE) |
| `ACCOUNT_ID` | `SERVICEORDERS.ACCOUNT_ID` | **Entity Key** | ⭐ **HIGH** | Account identifier |
| `ACCOUNT_NUMBER` | `SERVICEORDERS.ACCOUNT_NUMBER` | **Entity Key** | Medium | Account number |
| `SERVICEORDER_STATUS` | `SERVICEORDERS.STATUS` | **Category** | ⭐ **HIGH** | Should always be 'COMPLETED' |
| `SERVICEORDER_TYPE` | `SERVICEORDERS.SERVICEORDER_TYPE` | **Category** | Medium | Service order type |
| `SERVICELINE_NUMBER` | `SERVICEORDERS.SERVICELINE_NUMBER` | **Entity Key** | Medium | Service line number (join key) |
| `SALES_AGENT` | `SERVICEORDERS.SALES_AGENT` | **Entity Name** | ⭐ **HIGH** | ⭐ **Required: Sales agent for commissions** |
| `SERVICEORDER_CREATED` | `SERVICEORDERS.CREATED_DATETIME` | **Creation Timestamp** | Medium | Service order creation date |
| `SERVICEORDER_MODIFIED` | `SERVICEORDERS.MODIFIED_DATETIME` | **Modification Timestamp** | Low | Last modification date |
| `APPLY_DATE` | `SERVICEORDERS.APPLY_DATE` | **Date** | Low | Application date |
| `TARGET_DATETIME` | `SERVICEORDERS.TARGET_DATETIME` | **Date** | Low | Target completion date |
| `SERVICELINE_STARTDATE` | `SERVICELINES.SERVICELINE_STARTDATE` | **Creation Timestamp** | ⭐ **HIGH** | ⭐ **Required: Service line start date** |
| `SERVICELINE_ENDDATE` | `SERVICELINES.SERVICELINE_ENDDATE` | **Date** | Medium | Service line end date |
| `SERVICELINE_STATUS` | `SERVICELINES.SERVICELINE_STATUS` | **Category** | Medium | Service line status |
| `SERVICELINE_SERVICE_MODEL` | `SERVICELINES.SERVICE_MODEL` | **Category** | Medium | Service model type |
| `FEATURE` | `SERVICELINE_FEATURES.FEATURE` | **Category** | ⭐ **HIGH** | Service/feature name |
| `FEATURE_PRICE` | `SERVICELINE_FEATURES.FEATURE_PRICE` | **Currency** | ⭐ **HIGH** | ⭐ **Rate associated with each service feature** |
| `QTY` | `SERVICELINE_FEATURES.QTY` | **Quantity** | Medium | Feature quantity |
| `PLAN` | `SERVICELINE_FEATURES.PLAN` | **Category** | Medium | Plan name |
| `FEATURE_START_DATETIME` | `SERVICELINE_FEATURES.START_DATETIME` | **Creation Timestamp** | Low | Feature start date |
| `FEATURE_END_DATETIME` | `SERVICELINE_FEATURES.END_DATETIME` | **Date** | Low | Feature end date |
| `RECURRING_CREDIT_NAME` | `ACCOUNT_RECURRING_CREDITS.RECURRING_CREDIT_NAME` | **Category** | Medium | Recurring credit name |
| `RECURRING_CREDIT_DESCRIPTION` | `ACCOUNT_RECURRING_CREDITS.RECURRING_CREDIT_DESCRIPTION` | **Description** | Low | Recurring credit description |
| `RECURRING_CREDIT_AMOUNT` | `ACCOUNT_RECURRING_CREDITS.RECURRING_CREDIT_AMOUNT` | **Currency** | ⭐ **HIGH** | ⭐ **Recurring charge amount** |
| `ACCOUNT_RECURRING_STATUS` | `ACCOUNT_RECURRING_CREDITS.ACCOUNT_RECURRING_STATUS` | **Category** | Medium | Recurring credit status |
| `RECURRING_CREDIT_START_DATETIME` | `ACCOUNT_RECURRING_CREDITS.RECURRING_CREDIT_START_DATETIME` | **Creation Timestamp** | Medium | Recurring credit start date |
| `RECURRING_CREDIT_END_DATETIME` | `ACCOUNT_RECURRING_CREDITS.RECURRING_CREDIT_END_DATETIME` | **Date** | Medium | Recurring credit end date |
| `RECURRING_CREDIT_VALID_FROM` | `ACCOUNT_RECURRING_CREDITS.ACCOUNT_RECURRING_VALID_FROM` | **Date** | Low | Valid from date |
| `RECURRING_CREDIT_VALID_TO` | `ACCOUNT_RECURRING_CREDITS.ACCOUNT_RECURRING_VALID_TO` | **Date** | Low | Valid to date |
| `RECURRING_ITEM_NAME` | `ACCOUNT_RECURRING_CREDITS.RECURRING_ITEM_NAME` | **Category** | Low | Recurring item name |
| `RECURRING_ITEM_DESCRIPTION` | `ACCOUNT_RECURRING_CREDITS.RECURRING_ITEM_DESCRIPTION` | **Description** | Low | Recurring item description |
| `OCC_AMOUNT` | `ACCOUNT_OTHER_CHARGES_CREDITS.OCC_AMOUNT` | **Currency** | ⭐ **HIGH** | ⭐ **One-time charge amount** |
| `OCC_DATETIME` | `ACCOUNT_OTHER_CHARGES_CREDITS.OCC_DATETIME` | **Creation Timestamp** | Medium | Charge date/time |
| `OCC_STATUS` | `ACCOUNT_OTHER_CHARGES_CREDITS.OCC_STATUS` | **Category** | Medium | Charge status |
| `ITEM_TYPE` | `ACCOUNT_OTHER_CHARGES_CREDITS.ITEM_TYPE` | **Category** | Low | Item type |
| `ITEM_NAME` | `ACCOUNT_OTHER_CHARGES_CREDITS.ITEM_NAME` | **Category** | Low | Item name |
| `ITEM_DESCRIPTION` | `ACCOUNT_OTHER_CHARGES_CREDITS.ITEM_DESCRIPTION` | **Description** | Low | Item description |
| `OCC_USER` | `ACCOUNT_OTHER_CHARGES_CREDITS.OCC_USER` | **Entity Name** | Low | User who created the charge |
| `OCC_LOCATION` | `ACCOUNT_OTHER_CHARGES_CREDITS.OCC_LOCATION` | **Category** | Low | Location |
| `OCC_NOTES` | `ACCOUNT_OTHER_CHARGES_CREDITS.NOTES` | **Description** | Low | Notes |

## Detailed Field Breakdown

### Service Order Identifiers

#### ORDER_ID
- **Source**: `CAMVIO.PUBLIC.SERVICEORDERS.ORDER_ID`
- **Semantic Type**: **Entity Key**
- **Data Type**: NUMBER
- **Purpose**: Order identifier
- **Notes**: Primary identifier for service orders

#### SERVICEORDER_ID
- **Source**: `CAMVIO.PUBLIC.SERVICEORDERS.SERVICEORDER_ID`
- **Semantic Type**: **Entity Key**
- **Data Type**: NUMBER
- **Purpose**: Service order identifier
- **Notes**: ⭐ **Joins to Fybe WORK_PACKAGE** - This is the join key for Fybe data

#### ACCOUNT_ID
- **Source**: `CAMVIO.PUBLIC.SERVICEORDERS.ACCOUNT_ID`
- **Semantic Type**: **Entity Key**
- **Data Type**: NUMBER
- **Purpose**: Account identifier
- **Notes**: Join key for account-related tables

### Service Line Details

#### SERVICELINE_STARTDATE ⭐
- **Source**: `CAMVIO.PUBLIC.SERVICELINES.SERVICELINE_STARTDATE`
- **Semantic Type**: **Creation Timestamp**
- **Data Type**: TIMESTAMP_NTZ
- **Purpose**: ⭐ **Service line start date** (required field)
- **Notes**: May be NULL if service line doesn't exist or SERVICELINE_NUMBER doesn't match
- **Join**: LEFT JOIN on `SERVICEORDERS.SERVICELINE_NUMBER = SERVICELINES.SERVICELINE_NUMBER`

### Service Line Features

#### FEATURE
- **Source**: `CAMVIO.PUBLIC.SERVICELINE_FEATURES.FEATURE`
- **Semantic Type**: **Category**
- **Data Type**: TEXT
- **Purpose**: Service/feature name
- **Notes**: May be NULL if no features exist for the service line

#### FEATURE_PRICE ⭐
- **Source**: `CAMVIO.PUBLIC.SERVICELINE_FEATURES.FEATURE_PRICE`
- **Semantic Type**: **Currency**
- **Data Type**: NUMBER(38,4)
- **Purpose**: ⭐ **Rate associated with each service feature**
- **Notes**: May be NULL if no features exist. This is the rate for each feature.

### Account Recurring Credits

#### RECURRING_CREDIT_AMOUNT ⭐
- **Source**: `CAMVIO.PUBLIC.ACCOUNT_RECURRING_CREDITS.RECURRING_CREDIT_AMOUNT`
- **Semantic Type**: **Currency**
- **Data Type**: NUMBER(38,8)
- **Purpose**: ⭐ **Recurring charge amount**
- **Notes**: May be NULL if no recurring credits exist. Will be duplicated across feature rows if multiple features exist.
- **Join**: LEFT JOIN on `SERVICEORDERS.ACCOUNT_ID = ACCOUNT_RECURRING_CREDITS.ACCOUNT_ID`

### Account Other Charges/Credits

#### OCC_AMOUNT ⭐
- **Source**: `CAMVIO.PUBLIC.ACCOUNT_OTHER_CHARGES_CREDITS.OCC_AMOUNT`
- **Semantic Type**: **Currency**
- **Data Type**: NUMBER(38,2)
- **Purpose**: ⭐ **One-time charge amount**
- **Notes**: May be NULL if no other charges exist. Will be duplicated across feature rows if multiple features exist.
- **Join**: LEFT JOIN on `SERVICEORDERS.ACCOUNT_ID = ACCOUNT_OTHER_CHARGES_CREDITS.ACCOUNT_ID`

## Table Reference

### SERVICEORDERS (alias: `so`)
**Full Table Name**: `CAMVIO.PUBLIC.SERVICEORDERS`

**Join Strategy**: Base table (filtered to `STATUS = 'COMPLETED'`)

**Key Fields**:
- `ORDER_ID` - Order identifier
- `SERVICEORDER_ID` - Service order identifier (joins to Fybe WORK_PACKAGE)
- `ACCOUNT_ID` - Account identifier (join key for charges)
- `SERVICELINE_NUMBER` - Service line number (join key for service lines and features)
- `SALES_AGENT` - ⭐ Sales agent for commissions (required field)
- `STATUS` - Service order status (filtered to 'COMPLETED')

### SERVICELINES (alias: `sl`)
**Full Table Name**: `CAMVIO.PUBLIC.SERVICELINES`

**Join**: `LEFT JOIN` on `so.SERVICELINE_NUMBER = sl.SERVICELINE_NUMBER`

**Key Fields**:
- `SERVICELINE_NUMBER` - Join key
- `SERVICELINE_STARTDATE` - ⭐ Service line start date (required)
- `SERVICELINE_ENDDATE` - Service line end date
- `SERVICELINE_STATUS` - Service line status
- `SERVICE_MODEL` - Service model type

### SERVICELINE_FEATURES (alias: `sf`)
**Full Table Name**: `CAMVIO.PUBLIC.SERVICELINE_FEATURES`

**Join**: `LEFT JOIN` on `so.SERVICELINE_NUMBER = sf.SERVICELINE_NUMBER`

**Key Fields**:
- `SERVICELINE_NUMBER` - Join key
- `FEATURE` - Feature/service name
- `FEATURE_PRICE` - ⭐ Rate associated with each service feature
- `QTY` - Quantity
- `PLAN` - Plan name
- `START_DATETIME` - Feature start date
- `END_DATETIME` - Feature end date

**Note**: Multiple rows per service order if multiple features exist.

### ACCOUNT_RECURRING_CREDITS (alias: `arc`)
**Full Table Name**: `CAMVIO.PUBLIC.ACCOUNT_RECURRING_CREDITS`

**Join**: `LEFT JOIN` on `so.ACCOUNT_ID = arc.ACCOUNT_ID`

**Key Fields**:
- `ACCOUNT_ID` - Join key
- `RECURRING_CREDIT_AMOUNT` - ⭐ Recurring charge amount
- `RECURRING_CREDIT_NAME` - Credit name
- `RECURRING_CREDIT_DESCRIPTION` - Description
- `ACCOUNT_RECURRING_STATUS` - Status
- `RECURRING_CREDIT_START_DATETIME` - Start date
- `RECURRING_CREDIT_END_DATETIME` - End date

**Note**: Multiple rows per service order if multiple recurring credits exist.

### ACCOUNT_OTHER_CHARGES_CREDITS (alias: `aocc`)
**Full Table Name**: `CAMVIO.PUBLIC.ACCOUNT_OTHER_CHARGES_CREDITS`

**Join**: `LEFT JOIN` on `so.ACCOUNT_ID = aocc.ACCOUNT_ID`

**Key Fields**:
- `ACCOUNT_ID` - Join key
- `OCC_AMOUNT` - ⭐ One-time charge amount
- `OCC_DATETIME` - Charge date/time
- `OCC_STATUS` - Status
- `ITEM_TYPE` - Item type
- `ITEM_NAME` - Item name
- `ITEM_DESCRIPTION` - Item description
- `OCC_USER` - User who created the charge
- `OCC_LOCATION` - Location
- `NOTES` - Notes

**Note**: Multiple rows per service order if multiple other charges exist.

## Semantic Types Summary

### Entity Keys (IDs)
- `ORDER_ID`, `SERVICEORDER_ID`, `ACCOUNT_ID`, `ACCOUNT_NUMBER`, `SERVICELINE_NUMBER`

### Entity Name
- `SALES_AGENT` (sales agent for commissions) ⭐ **REQUIRED**
- `OCC_USER` (user who created the charge)

### Creation Timestamps
- `SERVICEORDER_CREATED`, `SERVICELINE_STARTDATE`, `FEATURE_START_DATETIME`, `RECURRING_CREDIT_START_DATETIME`, `OCC_DATETIME`

### Modification Timestamps
- `SERVICEORDER_MODIFIED`

### Dates
- `APPLY_DATE`, `TARGET_DATETIME`, `SERVICELINE_ENDDATE`, `FEATURE_END_DATETIME`, `RECURRING_CREDIT_END_DATETIME`, `RECURRING_CREDIT_VALID_FROM`, `RECURRING_CREDIT_VALID_TO`

### Currency
- `FEATURE_PRICE`, `RECURRING_CREDIT_AMOUNT`, `OCC_AMOUNT`

### Quantity
- `QTY`

### Category
- `SERVICEORDER_STATUS`, `SERVICEORDER_TYPE`, `SERVICELINE_STATUS`, `SERVICELINE_SERVICE_MODEL`, `FEATURE`, `PLAN`, `RECURRING_CREDIT_NAME`, `ACCOUNT_RECURRING_STATUS`, `RECURRING_ITEM_NAME`, `OCC_STATUS`, `ITEM_TYPE`, `ITEM_NAME`, `OCC_LOCATION`

### Description
- `RECURRING_CREDIT_DESCRIPTION`, `RECURRING_ITEM_DESCRIPTION`, `ITEM_DESCRIPTION`, `OCC_NOTES`

## Priority Fields for Analysis

### ⭐ High Priority (Set These First)

1. **SERVICEORDER_ID** (Entity Key) - Primary identifier
2. **ORDER_ID** (Entity Key) - Order identifier
3. **ACCOUNT_ID** (Entity Key) - Account identifier
4. **SALES_AGENT** (Entity Name) - ⭐ **Required: Sales agent for commissions**
5. **SERVICELINE_STARTDATE** (Creation Timestamp) - ⭐ Required: Service line start date
5. **FEATURE** (Category) - Service/feature name
6. **FEATURE_PRICE** (Currency) - ⭐ Rate associated with each service feature
7. **RECURRING_CREDIT_AMOUNT** (Currency) - ⭐ Recurring charge amount
8. **OCC_AMOUNT** (Currency) - ⭐ One-time charge amount
9. **SERVICEORDER_STATUS** (Category) - Should always be 'COMPLETED'

## Setting Semantic Types in Metabase

1. Open the **Service Orders with Charges** model
2. Go to **Model settings** → **Column metadata**
3. Set semantic types according to the table above
4. Pay special attention to:
   - Currency fields (`FEATURE_PRICE`, `RECURRING_CREDIT_AMOUNT`, `OCC_AMOUNT`)
   - Timestamp fields (`SERVICELINE_STARTDATE`, `SERVICEORDER_CREATED`)
   - Entity keys (`SERVICEORDER_ID`, `ORDER_ID`, `ACCOUNT_ID`)

## Important Notes

### NULL Values
- Many fields may be NULL if the related data doesn't exist (service line, features, charges)
- Always check for NULL values when aggregating or calculating

### Data Duplication
- Charges will be duplicated across feature rows if multiple features exist
- Always aggregate charges at the service order level, not feature level

### Join Strategy
- All joins are LEFT JOINs to preserve all completed service orders
- Even if service line, features, or charges don't exist, the service order will appear

