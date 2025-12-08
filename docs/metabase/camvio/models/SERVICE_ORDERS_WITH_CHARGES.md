# Service Orders with Charges - Metabase Model Documentation

## Overview

This model provides a comprehensive view of **completed service orders** with:
- Service lines (including service line start date)
- Service line features (services on the order with rates)
- Account recurring credits (recurring charges)
- Account other charges/credits (one-time charges)

**Model Type**: BASE MODEL  
**Source Query**: `snowflake/camvio/queries/service_orders_with_charges.sql`  
**Database**: Camvio Snowflake (read-only)

## Purpose

This model enables analysis of:
1. **Number of services completed** - Count distinct service orders
2. **Services on each service order** - Features associated with each order
3. **Rate associated with each service feature** - FEATURE_PRICE field
4. **One-time charges** - From ACCOUNT_OTHER_CHARGES_CREDITS
5. **Recurring charges** - From ACCOUNT_RECURRING_CREDITS
6. **Service line start date** - SERVICELINE_STARTDATE from SERVICELINES table
7. **Sales commissions** - SALES_AGENT field for sales commission calculations ⭐ **REQUIRED**

## Model Structure

### Base Model: "Service Orders with Charges (Base)"
- **Query**: `service_orders_with_charges.sql`
- **Filters**: Only `COMPLETED` service orders
- **Joins**: 
  - SERVICELINES (LEFT JOIN) - for service line start date
  - SERVICELINE_FEATURES (LEFT JOIN) - for features and rates
  - ACCOUNT_RECURRING_CREDITS (LEFT JOIN) - for recurring charges
  - ACCOUNT_OTHER_CHARGES_CREDITS (LEFT JOIN) - for one-time charges

### Enhanced Model: "Service Orders with Charges (Enhanced)"
- **Base**: "Service Orders with Charges (Base)"
- **Custom Columns**: TBD (add calculated fields as needed)
- **Metrics**: TBD (add aggregations as needed)

## Important Notes

### Multiple Rows Per Service Order

⚠️ **This model will create multiple rows per service order if:**
- A service order has multiple features (SERVICELINE_FEATURES)
- A service order has multiple recurring credits (ACCOUNT_RECURRING_CREDITS)
- A service order has multiple other charges (ACCOUNT_OTHER_CHARGES_CREDITS)

**Example**: If a service order has 3 features and 2 recurring credits, you'll get 3 × 2 = 6 rows for that service order.

**Solutions**:
1. **Count distinct service orders**: Use `COUNT(DISTINCT SERVICEORDER_ID)` or `COUNT(DISTINCT ORDER_ID)`
2. **One row per service order + feature**: Use `DISTINCT` on `SERVICEORDER_ID + FEATURE`
3. **Aggregate charges**: Sum `RECURRING_CREDIT_AMOUNT` and `OCC_AMOUNT` at the service order level

### Counting Services Completed

To get the **number of services completed**, count distinct service orders:

```sql
COUNT(DISTINCT SERVICEORDER_ID)
-- or
COUNT(DISTINCT ORDER_ID)
```

### Aggregating Charges

**Recurring Charges**:
- Sum `RECURRING_CREDIT_AMOUNT` per service order or account
- Note: This will be duplicated across feature rows if multiple features exist

**One-Time Charges**:
- Sum `OCC_AMOUNT` per service order or account
- Note: This will be duplicated across feature rows if multiple features exist

**Best Practice**: Aggregate charges at the service order level, not at the feature level.

## Key Fields

### Service Order Identifiers
- `ORDER_ID` - Order identifier
- `SERVICEORDER_ID` - Service order identifier (joins to Fybe WORK_PACKAGE)
- `ACCOUNT_ID` - Account identifier
- `ACCOUNT_NUMBER` - Account number

### Service Order Details
- `SERVICEORDER_STATUS` - Should always be 'COMPLETED' (filtered)
- `SERVICEORDER_TYPE` - Type of service order
- `SERVICELINE_NUMBER` - Service line number (join key)
- `SALES_AGENT` - ⭐ **Sales agent for commissions** (required field)
- `SERVICEORDER_CREATED` - When service order was created
- `SERVICEORDER_MODIFIED` - Last modification date

### Service Line Details
- `SERVICELINE_STARTDATE` - ⭐ **Service line start date** (required field)
- `SERVICELINE_ENDDATE` - Service line end date
- `SERVICELINE_STATUS` - Service line status
- `SERVICELINE_SERVICE_MODEL` - Service model type

### Service Line Features (Services on Order)
- `FEATURE` - Feature/service name
- `FEATURE_PRICE` - ⭐ **Rate associated with each service feature**
- `QTY` - Quantity
- `PLAN` - Plan name
- `FEATURE_START_DATETIME` - Feature start date
- `FEATURE_END_DATETIME` - Feature end date

### Account Recurring Credits (Recurring Charges)
- `RECURRING_CREDIT_NAME` - Name of recurring credit/charge
- `RECURRING_CREDIT_DESCRIPTION` - Description
- `RECURRING_CREDIT_AMOUNT` - ⭐ **Recurring charge amount**
- `ACCOUNT_RECURRING_STATUS` - Status
- `RECURRING_CREDIT_START_DATETIME` - Start date
- `RECURRING_CREDIT_END_DATETIME` - End date
- `RECURRING_CREDIT_VALID_FROM` - Valid from date
- `RECURRING_CREDIT_VALID_TO` - Valid to date
- `RECURRING_ITEM_NAME` - Item name
- `RECURRING_ITEM_DESCRIPTION` - Item description

### Account Other Charges/Credits (One-Time Charges)
- `OCC_AMOUNT` - ⭐ **One-time charge amount**
- `OCC_DATETIME` - Charge date/time
- `OCC_STATUS` - Status
- `ITEM_TYPE` - Item type
- `ITEM_NAME` - Item name
- `ITEM_DESCRIPTION` - Item description
- `OCC_USER` - User who created the charge
- `OCC_LOCATION` - Location
- `OCC_NOTES` - Notes

## Usage Patterns

### Pattern 1: Count Services Completed by Date

```sql
SELECT
    DATE(SERVICELINE_STARTDATE) AS start_date,
    COUNT(DISTINCT SERVICEORDER_ID) AS services_completed
FROM service_orders_with_charges
GROUP BY DATE(SERVICELINE_STARTDATE)
ORDER BY start_date DESC;
```

### Pattern 2: Services and Rates by Service Order

```sql
SELECT
    SERVICEORDER_ID,
    ORDER_ID,
    FEATURE,
    FEATURE_PRICE,
    QTY,
    FEATURE_PRICE * QTY AS total_feature_cost
FROM service_orders_with_charges
WHERE FEATURE IS NOT NULL
ORDER BY SERVICEORDER_ID, FEATURE;
```

### Pattern 3: Total Charges per Service Order

```sql
SELECT
    SERVICEORDER_ID,
    ORDER_ID,
    SUM(RECURRING_CREDIT_AMOUNT) AS total_recurring_charges,
    SUM(OCC_AMOUNT) AS total_one_time_charges,
    SUM(RECURRING_CREDIT_AMOUNT) + SUM(OCC_AMOUNT) AS total_charges
FROM service_orders_with_charges
GROUP BY SERVICEORDER_ID, ORDER_ID
ORDER BY total_charges DESC;
```

### Pattern 4: Service Orders with All Details

```sql
SELECT
    so.SERVICEORDER_ID,
    so.ORDER_ID,
    so.SERVICELINE_STARTDATE,
    so.FEATURE,
    so.FEATURE_PRICE,
    so.RECURRING_CREDIT_AMOUNT,
    so.OCC_AMOUNT
FROM service_orders_with_charges so
WHERE so.SERVICELINE_STARTDATE IS NOT NULL
ORDER BY so.SERVICELINE_STARTDATE DESC;
```

## Data Quality Considerations

### NULL Values
- `SERVICELINE_STARTDATE` may be NULL if service line doesn't exist
- `FEATURE` and `FEATURE_PRICE` may be NULL if no features exist
- `RECURRING_CREDIT_AMOUNT` may be NULL if no recurring credits exist
- `OCC_AMOUNT` may be NULL if no other charges exist

### Data Duplication
- Charges (recurring and one-time) will be duplicated across feature rows
- Always aggregate charges at the service order level, not feature level

### Join Strategy
- All joins are LEFT JOINs to preserve all completed service orders
- Even if service line, features, or charges don't exist, the service order will appear

## Related Models

- **Combined Installs and Trouble Tickets** - Technician visit data
- **Installs by Individual** - Installation tracking by technician

## Next Steps

1. ✅ Create base model in Metabase
2. ⏳ Set semantic types (see `SERVICE_ORDERS_WITH_CHARGES_COLUMN_MAPPING.md`)
3. ⏳ Create enhanced model with custom columns
4. ⏳ Add metrics and aggregations
5. ⏳ Create dashboards and reports

