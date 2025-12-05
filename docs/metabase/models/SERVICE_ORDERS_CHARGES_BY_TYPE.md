# Service Orders Charges by Type - Metabase Model Documentation

## Overview

This model provides a view of **completed service orders** with charges **aggregated by type**:
- **Recurring credits** grouped by `RECURRING_CREDIT_NAME` (type)
- **Other charges/credits** grouped by `ITEM_TYPE` (type)

**Model Type**: BASE MODEL  
**Source Query**: `snowflake/camvio/queries/service_orders_charges_by_type.sql`  
**Database**: Camvio Snowflake (read-only)

## Purpose

This model enables analysis of:
1. **Recurring credit amounts by type** - Sum of `RECURRING_CREDIT_AMOUNT` grouped by `RECURRING_CREDIT_NAME`
2. **Other charge amounts by type** - Sum of `OCC_AMOUNT` grouped by `ITEM_TYPE`
3. **Service orders with charges** - Only shows service orders that have charges (INNER JOIN)
4. **Charge counts by type** - Number of charges of each type per service order

## Model Structure

### Base Model: "Service Orders Charges by Type (Base)"
- **Query**: `service_orders_charges_by_type.sql`
- **Structure**: UNION ALL query combining two result sets:
  - **First SELECT**: Recurring credits grouped by `RECURRING_CREDIT_NAME`
  - **Second SELECT**: Other charges grouped by `ITEM_TYPE`
- **Filters**: Only `COMPLETED` service orders with charges (INNER JOIN)
- **Joins**: 
  - SERVICELINES (LEFT JOIN) - for service line start date
  - ACCOUNT_RECURRING_CREDITS (INNER JOIN) - for recurring credits
  - ACCOUNT_OTHER_CHARGES_CREDITS (INNER JOIN) - for other charges

### Enhanced Model: "Service Orders Charges by Type (Enhanced)"
- **Base**: "Service Orders Charges by Type (Base)"
- **Custom Columns**: TBD (add calculated fields as needed)
- **Metrics**: TBD (add aggregations as needed)

## Key Fields

### Charge Type Identifier
- `CHARGE_TYPE` - Either 'Recurring Credit' or 'Other Charge'
- `CHARGE_TYPE_NAME` - The actual type:
  - For recurring credits: `RECURRING_CREDIT_NAME`
  - For other charges: `ITEM_TYPE`

### Charge Amounts
- `CHARGE_AMOUNT` - ⭐ **Sum of charges by type** per service order
  - For recurring credits: Sum of `RECURRING_CREDIT_AMOUNT`
  - For other charges: Sum of `OCC_AMOUNT`
- `CHARGE_COUNT` - Number of charges of this type per service order

### Service Order Identifiers
- `ORDER_ID` - Order identifier
- `SERVICEORDER_ID` - Service order identifier (joins to Fybe WORK_PACKAGE)
- `ACCOUNT_ID` - Account identifier
- `ACCOUNT_NUMBER` - Account number

### Service Line Details
- `SERVICELINE_STARTDATE` - ⭐ **Service line start date** (required field)
- `SERVICELINE_ENDDATE` - Service line end date
- `SERVICELINE_STATUS` - Service line status
- `SERVICELINE_SERVICE_MODEL` - Service model type

### Charge Details
- `CHARGE_STATUS` - Status of the charge
  - For recurring credits: `ACCOUNT_RECURRING_STATUS`
  - For other charges: `OCC_STATUS`
- `CHARGE_EARLIEST_START` - Earliest start date for this charge type
- `CHARGE_LATEST_END` - Latest end date for this charge type

## Important Notes

### Multiple Rows Per Service Order

⚠️ **This model will create multiple rows per service order if:**
- A service order has multiple recurring credit types (different `RECURRING_CREDIT_NAME`)
- A service order has multiple other charge types (different `ITEM_TYPE`)

**Example**: If a service order has 2 recurring credit types and 3 other charge types, you'll get 2 + 3 = 5 rows for that service order.

### Only Service Orders with Charges

⚠️ **This query only shows service orders that have charges** (INNER JOIN).

If you want to see all service orders (even without charges), you would need to modify the query to use LEFT JOIN instead of INNER JOIN.

### Aggregation by Type

- **Recurring Credits**: Grouped by `RECURRING_CREDIT_NAME`
  - `CHARGE_AMOUNT` = Sum of all `RECURRING_CREDIT_AMOUNT` for that type
  - `CHARGE_COUNT` = Count of charges of that type

- **Other Charges**: Grouped by `ITEM_TYPE`
  - `CHARGE_AMOUNT` = Sum of all `OCC_AMOUNT` for that type
  - `CHARGE_COUNT` = Count of charges of that type

## Usage Patterns

### Pattern 1: Total Amounts by Type Across All Service Orders

```sql
SELECT
    CHARGE_TYPE,
    CHARGE_TYPE_NAME,
    SUM(CHARGE_AMOUNT) AS total_amount_by_type,
    SUM(CHARGE_COUNT) AS total_charges_by_type
FROM service_orders_charges_by_type
GROUP BY CHARGE_TYPE, CHARGE_TYPE_NAME
ORDER BY total_amount_by_type DESC;
```

### Pattern 2: Charges by Type for a Specific Service Order

```sql
SELECT
    CHARGE_TYPE,
    CHARGE_TYPE_NAME,
    CHARGE_AMOUNT,
    CHARGE_COUNT,
    CHARGE_STATUS
FROM service_orders_charges_by_type
WHERE SERVICEORDER_ID = <your_service_order_id>
ORDER BY CHARGE_TYPE, CHARGE_TYPE_NAME;
```

### Pattern 3: Recurring Credits Only

```sql
SELECT
    SERVICEORDER_ID,
    ORDER_ID,
    CHARGE_TYPE_NAME AS recurring_credit_type,
    CHARGE_AMOUNT AS total_recurring_amount,
    CHARGE_COUNT AS recurring_charge_count
FROM service_orders_charges_by_type
WHERE CHARGE_TYPE = 'Recurring Credit'
ORDER BY CHARGE_AMOUNT DESC;
```

### Pattern 4: Other Charges Only

```sql
SELECT
    SERVICEORDER_ID,
    ORDER_ID,
    CHARGE_TYPE_NAME AS charge_type,
    CHARGE_AMOUNT AS total_occ_amount,
    CHARGE_COUNT AS occ_count
FROM service_orders_charges_by_type
WHERE CHARGE_TYPE = 'Other Charge'
ORDER BY CHARGE_AMOUNT DESC;
```

### Pattern 5: Service Orders with Both Types of Charges

```sql
SELECT
    SERVICEORDER_ID,
    ORDER_ID,
    SUM(CASE WHEN CHARGE_TYPE = 'Recurring Credit' THEN CHARGE_AMOUNT ELSE 0 END) AS total_recurring,
    SUM(CASE WHEN CHARGE_TYPE = 'Other Charge' THEN CHARGE_AMOUNT ELSE 0 END) AS total_other,
    SUM(CHARGE_AMOUNT) AS total_all_charges
FROM service_orders_charges_by_type
GROUP BY SERVICEORDER_ID, ORDER_ID
HAVING total_recurring > 0 AND total_other > 0
ORDER BY total_all_charges DESC;
```

## Data Quality Considerations

### NULL Values
- `SERVICELINE_STARTDATE` may be NULL if service line doesn't exist
- `CHARGE_AMOUNT` should never be NULL (INNER JOIN ensures charges exist)
- `OCC_ITEM_TYPE`, `OCC_ITEM_NAME`, `OCC_DATETIME` are NULL for recurring credits

### Data Duplication
- Each service order appears once per charge type
- If a service order has multiple charge types, it will appear multiple times

### Join Strategy
- **INNER JOIN** for charges - only shows service orders that have charges
- **LEFT JOIN** for service lines - preserves service order even if service line doesn't exist

## Related Models

- **Service Orders with Charges** - Detailed view with all charge fields (not aggregated)
- **Combined Installs and Trouble Tickets** - Technician visit data

## Next Steps

1. ✅ Create base model in Metabase
2. ⏳ Set semantic types (see `SERVICE_ORDERS_CHARGES_BY_TYPE_COLUMN_MAPPING.md`)
3. ⏳ Create enhanced model with custom columns
4. ⏳ Add metrics and aggregations
5. ⏳ Create dashboards and reports

