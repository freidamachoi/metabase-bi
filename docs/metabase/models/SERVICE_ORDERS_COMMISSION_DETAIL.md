# Service Orders Commission Detail - Metabase Model Documentation

## Overview

This model provides a **unified line-item view** of completed service orders for commission calculations. It combines:
- **Features** (service line features with rate and quantity)
- **Recurring Credits** (recurring charges with quantity and amount)
- **One-Time Charges** (one-time charges with quantity and amount)

**Model Type**: BASE MODEL  
**Source Query**: `snowflake/camvio/queries/service_orders_commission_detail.sql`  
**Database**: Camvio Snowflake (read-only)

## Purpose

This model enables:
1. **Commission Calculation** - Calculate commissions per order using the formula:
   - Commission = (Feature Rate × Quantity) - Recurring Credits + One-Time Charges
2. **Detail Reporting** - View each line item (feature, recurring credit, or one-time charge) separately
3. **Grouping by ORDER_ID** - Aggregate all line items per order for total commission calculation
4. **Sales Commission Reporting** - SALES_AGENT field for sales commission calculations ⭐ **REQUIRED**

## Model Structure

### Base Model: "Service Orders Commission Detail (Base)"
- **Query**: `service_orders_commission_detail.sql`
- **Structure**: UNION ALL query combining three result sets:
  - **First SELECT**: Features (from SERVICELINE_FEATURES)
  - **Second SELECT**: Recurring Credits (from ACCOUNT_RECURRING_CREDITS)
  - **Third SELECT**: One-Time Charges (from ACCOUNT_OTHER_CHARGES_CREDITS)
- **Filters**: Only `COMPLETED` service orders with features/charges (INNER JOIN)
- **Joins**: 
  - SERVICELINES (LEFT JOIN) - for service line start date
  - SERVICELINE_FEATURES (INNER JOIN) - for features
  - ACCOUNT_RECURRING_CREDITS (INNER JOIN) - for recurring credits
  - ACCOUNT_OTHER_CHARGES_CREDITS (INNER JOIN) - for one-time charges

### Enhanced Model: "Service Orders Commission Detail (Enhanced)"
- **Base**: "Service Orders Commission Detail (Base)"
- **Custom Columns**: TBD (add calculated fields as needed)
- **Metrics**: TBD (add aggregations as needed)

## Key Fields

### Line Item Type
- `LINE_ITEM_TYPE` - Either 'Feature', 'Recurring Credit', or 'One-Time Charge'
  - **'Feature'**: Service line features (positive for commission)
  - **'Recurring Credit'**: Recurring charges (negative for commission, subtracts)
  - **'One-Time Charge'**: One-time charges (positive for commission, adds)

### Unified Fields (All Line Item Types)
- `ORDER_ID` - Order identifier (group by this for commission calculation)
- `SERVICEORDER_ID` - Service order identifier (joins to Fybe WORK_PACKAGE)
- `ACCOUNT_ID` - Account identifier
- `ACCOUNT_NUMBER` - Account number
- `SALES_AGENT` - ⭐ **Sales agent for commissions** (required field)
- `RATE` - Rate per unit:
  - Features: `FEATURE_PRICE`
  - Recurring Credits: `RECURRING_CREDIT_AMOUNT`
  - One-Time Charges: `OCC_AMOUNT`
- `QUANTITY` - Quantity:
  - Features: `QTY` from SERVICELINE_FEATURES
  - Recurring Credits: `1` (each record = one recurring credit)
  - One-Time Charges: `1` (each record = one one-time charge)
- `AMOUNT` - Total amount (RATE × QUANTITY):
  - Features: `FEATURE_PRICE × QTY`
  - Recurring Credits: `RECURRING_CREDIT_AMOUNT`
  - One-Time Charges: `OCC_AMOUNT`

### Item Details
- `ITEM_NAME` - Item name:
  - Features: `FEATURE` (feature/service name)
  - Recurring Credits: `RECURRING_CREDIT_NAME`
  - One-Time Charges: `ITEM_NAME`
- `ITEM_PLAN` - Plan name (only for features, NULL for charges)
- `ITEM_TYPE` - Item type (only for one-time charges, NULL for others)
- `RECURRING_CREDIT_NAME` - Recurring credit name (only for recurring credits, NULL for others)

### Service Order Details
- `SERVICEORDER_STATUS` - Should always be 'COMPLETED' (filtered)
- `SERVICEORDER_TYPE` - Type of service order
- `SERVICELINE_NUMBER` - Service line number (join key)
- `SERVICEORDER_CREATED` - When service order was created
- `SERVICEORDER_MODIFIED` - Last modification date

### Service Line Details
- `SERVICELINE_STARTDATE` - ⭐ **Service line start date** (required field)
- `SERVICELINE_ENDDATE` - Service line end date
- `SERVICELINE_STATUS` - Service line status
- `SERVICELINE_SERVICE_MODEL` - Service model type

### Date Fields
- `ITEM_START_DATETIME` - Item start date:
  - Features: `START_DATETIME` from SERVICELINE_FEATURES
  - Recurring Credits: `RECURRING_CREDIT_START_DATETIME`
  - One-Time Charges: `NULL`
- `ITEM_END_DATETIME` - Item end date:
  - Features: `END_DATETIME` from SERVICELINE_FEATURES
  - Recurring Credits: `RECURRING_CREDIT_END_DATETIME`
  - One-Time Charges: `NULL`
- `CHARGE_DATETIME` - Charge date/time (only for one-time charges, NULL for others)

## Commission Calculation

### Formula
```
Commission per ORDER_ID = 
    SUM(Features: AMOUNT) 
    - SUM(Recurring Credits: AMOUNT) 
    + SUM(One-Time Charges: AMOUNT)
```

### In SQL
```sql
SELECT
    ORDER_ID,
    SERVICEORDER_ID,
    SALES_AGENT,
    SUM(CASE WHEN LINE_ITEM_TYPE = 'Feature' THEN AMOUNT ELSE 0 END) AS total_feature_amount,
    SUM(CASE WHEN LINE_ITEM_TYPE = 'Recurring Credit' THEN AMOUNT ELSE 0 END) AS total_recurring_credits,
    SUM(CASE WHEN LINE_ITEM_TYPE = 'One-Time Charge' THEN AMOUNT ELSE 0 END) AS total_one_time_charges,
    SUM(CASE WHEN LINE_ITEM_TYPE = 'Feature' THEN AMOUNT ELSE 0 END)
        - SUM(CASE WHEN LINE_ITEM_TYPE = 'Recurring Credit' THEN AMOUNT ELSE 0 END)
        + SUM(CASE WHEN LINE_ITEM_TYPE = 'One-Time Charge' THEN AMOUNT ELSE 0 END) AS commission_amount
FROM service_orders_commission_detail
GROUP BY ORDER_ID, SERVICEORDER_ID, SALES_AGENT
ORDER BY commission_amount DESC;
```

## Important Notes

### Multiple Rows Per Service Order

⚠️ **This model will create multiple rows per service order if:**
- A service order has multiple features (different FEATURE values)
- A service order has multiple recurring credits (different RECURRING_CREDIT_NAME values)
- A service order has multiple one-time charges (different ITEM_NAME or ITEM_TYPE values)

**Example**: If a service order has 2 features, 1 recurring credit, and 3 one-time charges, you'll get 2 + 1 + 3 = 6 rows for that service order.

### Only Service Orders with Features/Charges

⚠️ **This query only shows service orders that have features or charges** (INNER JOIN).

If you want to see all service orders (even without features/charges), you would need to modify the query to use LEFT JOIN instead of INNER JOIN.

### Quantity Field

- **Features**: Uses actual `QTY` from `SERVICELINE_FEATURES` table
- **Recurring Credits**: Set to `1` (each record represents one recurring credit)
- **One-Time Charges**: Set to `1` (each record represents one one-time charge)

### Amount Field

- **Features**: `AMOUNT = RATE × QUANTITY` (FEATURE_PRICE × QTY)
- **Recurring Credits**: `AMOUNT = RATE` (RECURRING_CREDIT_AMOUNT, quantity is always 1)
- **One-Time Charges**: `AMOUNT = RATE` (OCC_AMOUNT, quantity is always 1)

## Usage Patterns

### Pattern 1: Commission per Order

```sql
SELECT
    ORDER_ID,
    SERVICEORDER_ID,
    SALES_AGENT,
    SERVICELINE_STARTDATE,
    SUM(CASE WHEN LINE_ITEM_TYPE = 'Feature' THEN AMOUNT ELSE 0 END) AS total_feature_amount,
    SUM(CASE WHEN LINE_ITEM_TYPE = 'Recurring Credit' THEN AMOUNT ELSE 0 END) AS total_recurring_credits,
    SUM(CASE WHEN LINE_ITEM_TYPE = 'One-Time Charge' THEN AMOUNT ELSE 0 END) AS total_one_time_charges,
    SUM(CASE WHEN LINE_ITEM_TYPE = 'Feature' THEN AMOUNT ELSE 0 END)
        - SUM(CASE WHEN LINE_ITEM_TYPE = 'Recurring Credit' THEN AMOUNT ELSE 0 END)
        + SUM(CASE WHEN LINE_ITEM_TYPE = 'One-Time Charge' THEN AMOUNT ELSE 0 END) AS commission_amount
FROM service_orders_commission_detail
GROUP BY ORDER_ID, SERVICEORDER_ID, SALES_AGENT, SERVICELINE_STARTDATE
ORDER BY commission_amount DESC;
```

### Pattern 2: Commission by Sales Agent

```sql
SELECT
    SALES_AGENT,
    COUNT(DISTINCT ORDER_ID) AS total_orders,
    SUM(CASE WHEN LINE_ITEM_TYPE = 'Feature' THEN AMOUNT ELSE 0 END) AS total_feature_amount,
    SUM(CASE WHEN LINE_ITEM_TYPE = 'Recurring Credit' THEN AMOUNT ELSE 0 END) AS total_recurring_credits,
    SUM(CASE WHEN LINE_ITEM_TYPE = 'One-Time Charge' THEN AMOUNT ELSE 0 END) AS total_one_time_charges,
    SUM(CASE WHEN LINE_ITEM_TYPE = 'Feature' THEN AMOUNT ELSE 0 END)
        - SUM(CASE WHEN LINE_ITEM_TYPE = 'Recurring Credit' THEN AMOUNT ELSE 0 END)
        + SUM(CASE WHEN LINE_ITEM_TYPE = 'One-Time Charge' THEN AMOUNT ELSE 0 END) AS total_commission
FROM service_orders_commission_detail
GROUP BY SALES_AGENT
ORDER BY total_commission DESC;
```

### Pattern 3: Detail View (All Line Items)

```sql
SELECT
    ORDER_ID,
    SERVICEORDER_ID,
    SALES_AGENT,
    LINE_ITEM_TYPE,
    ITEM_NAME,
    RATE,
    QUANTITY,
    AMOUNT,
    SERVICELINE_STARTDATE
FROM service_orders_commission_detail
ORDER BY ORDER_ID, LINE_ITEM_TYPE, ITEM_NAME;
```

### Pattern 4: Features Only

```sql
SELECT
    ORDER_ID,
    SERVICEORDER_ID,
    SALES_AGENT,
    ITEM_NAME AS feature_name,
    ITEM_PLAN AS plan,
    RATE AS feature_price,
    QUANTITY AS qty,
    AMOUNT AS total_feature_amount
FROM service_orders_commission_detail
WHERE LINE_ITEM_TYPE = 'Feature'
ORDER BY ORDER_ID, ITEM_NAME;
```

### Pattern 5: Recurring Credits Only

```sql
SELECT
    ORDER_ID,
    SERVICEORDER_ID,
    SALES_AGENT,
    ITEM_NAME AS recurring_credit_name,
    RATE AS recurring_credit_amount,
    QUANTITY,
    AMOUNT AS total_recurring_credit
FROM service_orders_commission_detail
WHERE LINE_ITEM_TYPE = 'Recurring Credit'
ORDER BY ORDER_ID, ITEM_NAME;
```

### Pattern 6: One-Time Charges Only

```sql
SELECT
    ORDER_ID,
    SERVICEORDER_ID,
    SALES_AGENT,
    ITEM_NAME AS charge_name,
    ITEM_TYPE AS charge_type,
    RATE AS charge_amount,
    QUANTITY,
    AMOUNT AS total_charge,
    CHARGE_DATETIME
FROM service_orders_commission_detail
WHERE LINE_ITEM_TYPE = 'One-Time Charge'
ORDER BY ORDER_ID, CHARGE_DATETIME DESC;
```

## Data Quality Considerations

### NULL Values
- `SERVICELINE_STARTDATE` may be NULL if service line doesn't exist
- `ITEM_PLAN` is NULL for recurring credits and one-time charges
- `ITEM_TYPE` is NULL for features and recurring credits
- `RECURRING_CREDIT_NAME` is NULL for features and one-time charges
- `CHARGE_DATETIME` is NULL for features and recurring credits
- `ITEM_START_DATETIME` and `ITEM_END_DATETIME` are NULL for one-time charges

### Data Duplication
- Each service order appears once per line item (feature, recurring credit, or one-time charge)
- If a service order has multiple line items, it will appear multiple times

### Join Strategy
- **INNER JOIN** for features and charges - only shows service orders that have them
- **LEFT JOIN** for service lines - preserves service order even if service line doesn't exist

## Related Models

- **Service Orders with Charges** - Detailed view with all charge fields (not unified)
- **Service Orders Charges by Type** - Charges aggregated by type
- **Combined Installs and Trouble Tickets** - Technician visit data

## Next Steps

1. ✅ Create base model in Metabase
2. ⏳ Set semantic types (see `SERVICE_ORDERS_COMMISSION_DETAIL_SEMANTIC_TYPES.md`)
3. ⏳ Create enhanced model with custom columns (commission calculation)
4. ⏳ Add metrics and aggregations
5. ⏳ Create dashboards and reports for sales commissions

