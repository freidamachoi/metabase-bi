# Installs by Individual (Base) - Column Mapping

## Overview

This document maps each column in the **Installs by Individual (Base)** Metabase model to its corresponding database column in the Camvio Snowflake instance.

## Column Mapping Table

**Note**: Column names in the model will appear without table prefixes (e.g., `SERVICEORDER_ID` not `so.SERVICEORDER_ID`). The "Database Column" column shows the table alias used in the SQL SELECT statement to disambiguate which table the column comes from.

| Model Column Name | Database Column (in SQL) | Source Table | Table Alias | Also Exists In |
|------------------|-------------------------|--------------|-------------|----------------|
| `ORDER_ID` | `so.ORDER_ID` | `CAMVIO.PUBLIC.SERVICEORDERS` | `so` | APPOINTMENTS, SERVICEORDER_ADDRESSES, SERVICEORDER_FEATURES, SERVICEORDER_NOTES |
| `ACCOUNT_ID` | `so.ACCOUNT_ID` | `CAMVIO.PUBLIC.SERVICEORDERS` | `so` | SERVICEORDER_TASKS, CUSTOMER_ACCOUNTS, APPOINTMENTS, SERVICELINE_FEATURES, SERVICELINE_ADDRESSES, and many others |
| `STATUS` | `so.STATUS` | `CAMVIO.PUBLIC.SERVICEORDERS` | `so` | SERVICEORDER_TASKS (different STATUS field) |
| `SERVICELINE_NUMBER` | `so.SERVICELINE_NUMBER` | `CAMVIO.PUBLIC.SERVICEORDERS` | `so` | SERVICEORDER_TASKS, APPOINTMENTS, SERVICELINE_FEATURES, SERVICELINE_ADDRESSES, and many others |
| `SERVICEORDER_TYPE` | `so.SERVICEORDER_TYPE` | `CAMVIO.PUBLIC.SERVICEORDERS` | `so` | (unique to SERVICEORDERS) |
| `SERVICEORDER_ID` | `so.SERVICEORDER_ID` | `CAMVIO.PUBLIC.SERVICEORDERS` | `so` | SERVICEORDER_TASKS, SERVICEORDER_ADDRESSES, SERVICEORDER_FEATURES, SERVICEORDER_NOTES |
| `TASK_NAME` | `st.TASK_NAME` | `CAMVIO.PUBLIC.SERVICEORDER_TASKS` | `st` |
| `TASK_STARTED` | `st.TASK_STARTED` | `CAMVIO.PUBLIC.SERVICEORDER_TASKS` | `st` |
| `TASK_ENDED` | `st.TASK_ENDED` | `CAMVIO.PUBLIC.SERVICEORDER_TASKS` | `st` |
| `ASSIGNEE` | `st.ASSIGNEE` | `CAMVIO.PUBLIC.SERVICEORDER_TASKS` | `st` |
| `ACCOUNT_TYPE` | `ca.ACCOUNT_TYPE` | `CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS` | `ca` |
| `APPOINTMENT_TYPE` | `a.APPOINTMENT_TYPE` | `CAMVIO.PUBLIC.APPOINTMENTS` | `a` |
| `APPOINTMENT_TYPE_DESCRIPTION` | `a.APPOINTMENT_TYPE_DESCRIPTION` | `CAMVIO.PUBLIC.APPOINTMENTS` | `a` |
| `APPOINTMENT_DATE` | `a.APPOINTMENT_DATE` | `CAMVIO.PUBLIC.APPOINTMENTS` | `a` |
| `APPOINTMENT_ID` | `a.APPOINTMENT_ID` | `CAMVIO.PUBLIC.APPOINTMENTS` | `a` |
| `FEATURE` | `sf.FEATURE` | `CAMVIO.PUBLIC.SERVICELINE_FEATURES` | `sf` |
| `FEATURE_PRICE` | `sf.FEATURE_PRICE` | `CAMVIO.PUBLIC.SERVICELINE_FEATURES` | `sf` |
| `QTY` | `sf.QTY` | `CAMVIO.PUBLIC.SERVICELINE_FEATURES` | `sf` |
| `PLAN` | `sf.PLAN` | `CAMVIO.PUBLIC.SERVICELINE_FEATURES` | `sf` |
| `SERVICE_MODEL` | `sa.SERVICE_MODEL` | `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | `sa` |
| `SERVICELINE_ADDRESS1` | `sa.SERVICELINE_ADDRESS1` | `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | `sa` |
| `SERVICELINE_ADDRESS2` | `sa.SERVICELINE_ADDRESS2` | `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | `sa` |
| `SERVICELINE_ADDRESS_CITY` | `sa.SERVICELINE_ADDRESS_CITY` | `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | `sa` |
| `SERVICELINE_ADDRESS_STATE` | `sa.SERVICELINE_ADDRESS_STATE` | `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | `sa` |
| `SERVICELINE_ADDRESS_ZIPCODE` | `sa.SERVICELINE_ADDRESS_ZIPCODE` | `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | `sa` |

## Table Reference

### SERVICEORDERS (alias: `so`)
**Full Table Name**: `CAMVIO.PUBLIC.SERVICEORDERS`

Columns from this table:
- `ORDER_ID`
- `ACCOUNT_ID`
- `STATUS`
- `SERVICELINE_NUMBER`
- `SERVICEORDER_TYPE`
- `SERVICEORDER_ID`

### SERVICEORDER_TASKS (alias: `st`)
**Full Table Name**: `CAMVIO.PUBLIC.SERVICEORDER_TASKS`

Columns from this table:
- `TASK_NAME`
- `TASK_STARTED`
- `TASK_ENDED`
- `ASSIGNEE`

**Join Condition**: `so.SERVICEORDER_ID = st.SERVICEORDER_ID` (INNER JOIN)

### CUSTOMER_ACCOUNTS (alias: `ca`)
**Full Table Name**: `CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS`

Columns from this table:
- `ACCOUNT_TYPE`

**Join Condition**: `so.ACCOUNT_ID = ca.ACCOUNT_ID` (INNER JOIN)

### APPOINTMENTS (alias: `a`)
**Full Table Name**: `CAMVIO.PUBLIC.APPOINTMENTS`

Columns from this table:
- `APPOINTMENT_TYPE`
- `APPOINTMENT_TYPE_DESCRIPTION`
- `APPOINTMENT_DATE`
- `APPOINTMENT_ID`

**Join Condition**: `so.ORDER_ID = a.ORDER_ID` (LEFT JOIN)

### SERVICELINE_FEATURES (alias: `sf`)
**Full Table Name**: `CAMVIO.PUBLIC.SERVICELINE_FEATURES`

Columns from this table:
- `FEATURE`
- `FEATURE_PRICE`
- `QTY`
- `PLAN`

**Join Condition**: `so.SERVICELINE_NUMBER = sf.SERVICELINE_NUMBER` (LEFT JOIN)

### SERVICELINE_ADDRESSES (alias: `sa`)
**Full Table Name**: `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES`

Columns from this table:
- `SERVICE_MODEL`
- `SERVICELINE_ADDRESS1`
- `SERVICELINE_ADDRESS2`
- `SERVICELINE_ADDRESS_CITY`
- `SERVICELINE_ADDRESS_STATE`
- `SERVICELINE_ADDRESS_ZIPCODE`

**Join Condition**: `so.SERVICELINE_NUMBER = sa.SERVICELINE_NUMBER` (LEFT JOIN)

## Full Database Column Paths

For reference when setting up the model in Metabase, here are the full database column paths:

```
CAMVIO.PUBLIC.SERVICEORDERS.ORDER_ID
CAMVIO.PUBLIC.SERVICEORDERS.ACCOUNT_ID
CAMVIO.PUBLIC.SERVICEORDERS.STATUS
CAMVIO.PUBLIC.SERVICEORDERS.SERVICELINE_NUMBER
CAMVIO.PUBLIC.SERVICEORDERS.SERVICEORDER_TYPE
CAMVIO.PUBLIC.SERVICEORDERS.SERVICEORDER_ID
CAMVIO.PUBLIC.SERVICEORDER_TASKS.TASK_NAME
CAMVIO.PUBLIC.SERVICEORDER_TASKS.TASK_STARTED
CAMVIO.PUBLIC.SERVICEORDER_TASKS.TASK_ENDED
CAMVIO.PUBLIC.SERVICEORDER_TASKS.ASSIGNEE
CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS.ACCOUNT_TYPE
CAMVIO.PUBLIC.APPOINTMENTS.APPOINTMENT_TYPE
CAMVIO.PUBLIC.APPOINTMENTS.APPOINTMENT_TYPE_DESCRIPTION
CAMVIO.PUBLIC.APPOINTMENTS.APPOINTMENT_DATE
CAMVIO.PUBLIC.APPOINTMENTS.APPOINTMENT_ID
CAMVIO.PUBLIC.SERVICELINE_FEATURES.FEATURE
CAMVIO.PUBLIC.SERVICELINE_FEATURES.FEATURE_PRICE
CAMVIO.PUBLIC.SERVICELINE_FEATURES.QTY
CAMVIO.PUBLIC.SERVICELINE_FEATURES.PLAN
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICE_MODEL
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS1
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS2
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_CITY
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_STATE
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_ZIPCODE
```

## Important: Column Name Disambiguation

### Columns That Exist in Multiple Tables

Several column names exist in multiple joined tables. The SELECT statement uses table aliases to specify which table's column is used. In the final Metabase model, the column name will **not** include the table alias, but this document clarifies which table each column comes from.

| Column Name | Exists In Tables | Used From Table | Notes |
|-------------|------------------|-----------------|-------|
| `SERVICEORDER_ID` | `SERVICEORDERS`, `SERVICEORDER_TASKS`, `SERVICEORDER_ADDRESSES`, `SERVICEORDER_FEATURES`, `SERVICEORDER_NOTES` | `SERVICEORDERS` (so) | Only `so.SERVICEORDER_ID` is selected |
| `ORDER_ID` | `SERVICEORDERS`, `APPOINTMENTS`, `SERVICEORDER_ADDRESSES`, `SERVICEORDER_FEATURES`, `SERVICEORDER_NOTES` | `SERVICEORDERS` (so) | Only `so.ORDER_ID` is selected |
| `ACCOUNT_ID` | `SERVICEORDERS`, `SERVICEORDER_TASKS`, `CUSTOMER_ACCOUNTS`, `APPOINTMENTS`, `SERVICELINE_FEATURES`, `SERVICELINE_ADDRESSES`, and many others | `SERVICEORDERS` (so) | Only `so.ACCOUNT_ID` is selected |
| `SERVICELINE_NUMBER` | `SERVICEORDERS`, `SERVICEORDER_TASKS`, `APPOINTMENTS`, `SERVICELINE_FEATURES`, `SERVICELINE_ADDRESSES`, and many others | `SERVICEORDERS` (so) | Only `so.SERVICELINE_NUMBER` is selected |

### Why This Matters

- **In the SQL query**: Table aliases (`so.`, `st.`, etc.) disambiguate which table's column is used
- **In the Metabase model**: Column names appear without table aliases (e.g., just `SERVICEORDER_ID`)
- **This document**: Clarifies which table each column originates from, preventing confusion

### Example

The query selects `so.SERVICEORDER_ID` from `SERVICEORDERS`, even though `SERVICEORDER_TASKS` also has a `SERVICEORDER_ID` column. In the Metabase model, the column will be named `SERVICEORDER_ID` and will contain values from the `SERVICEORDERS` table.

## Notes

- All columns use the same name in the model as in the database (no aliasing in SELECT)
- The query uses table aliases (`so`, `st`, `ca`, `a`, `sf`, `sa`) in the SELECT to disambiguate which table each column comes from
- In the final Metabase model, column names will **not** include table aliases - they will just be the column name (e.g., `SERVICEORDER_ID`, not `so.SERVICEORDER_ID`)
- This document clarifies which table each column originates from
- LEFT JOINs on APPOINTMENTS, SERVICELINE_FEATURES, and SERVICELINE_ADDRESSES may result in NULL values
- INNER JOINs on SERVICEORDER_TASKS and CUSTOMER_ACCOUNTS ensure these fields always have values
- The model filters for `TASK_NAME = 'TECHNICIAN VISIT'` and `STATUS = 'COMPLETED'`

## Usage in Metabase

When setting up the model in Metabase:

1. The SQL query from `installs_by_individual.sql` defines the model
2. Metabase will automatically detect column names from the SELECT statement
3. Column names in the model will match the database column names exactly
4. Use this mapping document to understand which table each column comes from
5. Set semantic types based on the column mapping (see `INSTALLS_BY_INDIVIDUAL_SEMANTIC_TYPES.md`)

