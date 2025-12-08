# Installs by Individual (Base) - Join Columns Reference

## Overview

This document lists **all columns from all joined tables** in the Installs by Individual query, showing which table each column belongs to. This is essential for setting semantic types correctly in Metabase, especially for columns that have the same name across multiple tables.

## Join Structure

```
SERVICEORDERS (so) [MAIN TABLE]
├── JOIN SERVICEORDER_TASKS (st) ON so.SERVICEORDER_ID = st.SERVICEORDER_ID
├── JOIN CUSTOMER_ACCOUNTS (ca) ON so.ACCOUNT_ID = ca.ACCOUNT_ID
├── LEFT JOIN APPOINTMENTS (a) ON so.ORDER_ID = a.ORDER_ID
├── LEFT JOIN SERVICELINE_FEATURES (sf) ON so.SERVICELINE_NUMBER = sf.SERVICELINE_NUMBER
└── LEFT JOIN SERVICELINE_ADDRESSES (sa) ON so.SERVICELINE_NUMBER = sa.SERVICELINE_NUMBER
```

## All Columns by Table

### SERVICEORDERS (alias: `so`) - MAIN TABLE
**Full Name**: `CAMVIO.PUBLIC.SERVICEORDERS`

| Column Name | Selected in Query | Semantic Type | Notes |
|------------|-------------------|---------------|-------|
| `ORDER_ID` | ✅ Yes | Entity Key | Join key for APPOINTMENTS |
| `ACCOUNT_ID` | ✅ Yes | Entity Key | Join key for CUSTOMER_ACCOUNTS |
| `STATUS` | ✅ Yes | Category | Filtered to 'COMPLETED' |
| `SERVICELINE_NUMBER` | ✅ Yes | Entity Key | Join key for SERVICELINE_FEATURES and SERVICELINE_ADDRESSES |
| `SERVICEORDER_TYPE` | ✅ Yes | Category | - |
| `SERVICEORDER_ID` | ✅ Yes | Entity Key | Join key for SERVICEORDER_TASKS, also joins to Fybe WORK_PACKAGE |

**Note**: Only the columns marked "✅ Yes" appear in the final model. Other columns exist in the table but are not selected.

### SERVICEORDER_TASKS (alias: `st`)
**Full Name**: `CAMVIO.PUBLIC.SERVICEORDER_TASKS`  
**Join**: `INNER JOIN` on `so.SERVICEORDER_ID = st.SERVICEORDER_ID`

| Column Name | Selected in Query | Semantic Type | Also Exists In | Notes |
|------------|-------------------|---------------|----------------|-------|
| `SERVICEORDER_ID` | ❌ No (join key only) | Entity Key | SERVICEORDERS, SERVICEORDER_ADDRESSES, SERVICEORDER_FEATURES, SERVICEORDER_NOTES | Join key - not selected but used in JOIN |
| `ACCOUNT_ID` | ❌ No | Entity Key | SERVICEORDERS, CUSTOMER_ACCOUNTS, APPOINTMENTS, SERVICELINE_FEATURES, SERVICELINE_ADDRESSES | Exists but not selected |
| `SERVICELINE_NUMBER` | ❌ No | Entity Key | SERVICEORDERS, APPOINTMENTS, SERVICELINE_FEATURES, SERVICELINE_ADDRESSES | Exists but not selected |
| `TASK_ID` | ❌ No | Entity Key | - | Exists but not selected |
| `TASK_NAME` | ✅ Yes | Category | - | Filtered to 'TECHNICIAN VISIT' |
| `TASK_STARTED` | ✅ Yes | Creation Timestamp | - | - |
| `TASK_ENDED` | ✅ Yes | Creation Timestamp | - | - |
| `ASSIGNEE` | ✅ Yes | Entity Name | - | Technician name |
| `ASSIGNEE` | ✅ Yes | Entity Name | - | - |

**Important**: `SERVICEORDER_ID` in this table is the **join key** but is NOT selected in the query. The model will only have `SERVICEORDER_ID` from `SERVICEORDERS` (so).

### CUSTOMER_ACCOUNTS (alias: `ca`)
**Full Name**: `CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS`  
**Join**: `INNER JOIN` on `so.ACCOUNT_ID = ca.ACCOUNT_ID`

| Column Name | Selected in Query | Semantic Type | Also Exists In | Notes |
|------------|-------------------|---------------|----------------|-------|
| `ACCOUNT_ID` | ❌ No (join key only) | Entity Key | SERVICEORDERS, SERVICEORDER_TASKS, APPOINTMENTS, SERVICELINE_FEATURES, SERVICELINE_ADDRESSES | Join key - not selected but used in JOIN |
| `ACCOUNT_TYPE` | ✅ Yes | Category | - | - |

**Important**: `ACCOUNT_ID` in this table is the **join key** but is NOT selected in the query. The model will only have `ACCOUNT_ID` from `SERVICEORDERS` (so).

### APPOINTMENTS (alias: `a`)
**Full Name**: `CAMVIO.PUBLIC.APPOINTMENTS`  
**Join**: `LEFT JOIN` on `so.ORDER_ID = a.ORDER_ID`

| Column Name | Selected in Query | Semantic Type | Also Exists In | Notes |
|------------|-------------------|---------------|----------------|-------|
| `ORDER_ID` | ❌ No (join key only) | Entity Key | SERVICEORDERS, SERVICEORDER_ADDRESSES, SERVICEORDER_FEATURES, SERVICEORDER_NOTES | Join key - not selected but used in JOIN |
| `ACCOUNT_ID` | ❌ No | Entity Key | SERVICEORDERS, SERVICEORDER_TASKS, CUSTOMER_ACCOUNTS, SERVICELINE_FEATURES, SERVICELINE_ADDRESSES | Exists but not selected |
| `SERVICELINE_NUMBER` | ❌ No | Entity Key | SERVICEORDERS, SERVICEORDER_TASKS, SERVICELINE_FEATURES, SERVICELINE_ADDRESSES | Exists but not selected |
| `APPOINTMENT_ID` | ✅ Yes | Entity Key | - | - |
| `APPOINTMENT_TYPE` | ✅ Yes | Category | - | - |
| `APPOINTMENT_TYPE_DESCRIPTION` | ✅ Yes | Description | - | - |
| `APPOINTMENT_DATE` | ✅ Yes | Creation Timestamp | - | - |

**Important**: `ORDER_ID` in this table is the **join key** but is NOT selected in the query. The model will only have `ORDER_ID` from `SERVICEORDERS` (so).

### SERVICELINE_FEATURES (alias: `sf`)
**Full Name**: `CAMVIO.PUBLIC.SERVICELINE_FEATURES`  
**Join**: `LEFT JOIN` on `so.SERVICELINE_NUMBER = sf.SERVICELINE_NUMBER`

| Column Name | Selected in Query | Semantic Type | Also Exists In | Notes |
|------------|-------------------|---------------|----------------|-------|
| `SERVICELINE_NUMBER` | ❌ No (join key only) | Entity Key | SERVICEORDERS, SERVICEORDER_TASKS, APPOINTMENTS, SERVICELINE_ADDRESSES | Join key - not selected but used in JOIN |
| `ACCOUNT_ID` | ❌ No | Entity Key | SERVICEORDERS, SERVICEORDER_TASKS, CUSTOMER_ACCOUNTS, APPOINTMENTS, SERVICELINE_ADDRESSES | Exists but not selected |
| `FEATURE` | ✅ Yes | Category | - | - |
| `FEATURE_PRICE` | ✅ Yes | Currency | - | - |
| `QTY` | ✅ Yes | Quantity | - | - |
| `PLAN` | ✅ Yes | Category | - | - |

**Important**: `SERVICELINE_NUMBER` in this table is the **join key** but is NOT selected in the query. The model will only have `SERVICELINE_NUMBER` from `SERVICEORDERS` (so).

### SERVICELINE_ADDRESSES (alias: `sa`)
**Full Name**: `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES`  
**Join**: `LEFT JOIN` on `so.SERVICELINE_NUMBER = sa.SERVICELINE_NUMBER`

| Column Name | Selected in Query | Semantic Type | Also Exists In | Notes |
|------------|-------------------|---------------|----------------|-------|
| `SERVICELINE_NUMBER` | ❌ No (join key only) | Entity Key | SERVICEORDERS, SERVICEORDER_TASKS, APPOINTMENTS, SERVICELINE_FEATURES | Join key - not selected but used in JOIN |
| `ACCOUNT_ID` | ❌ No | Entity Key | SERVICEORDERS, SERVICEORDER_TASKS, CUSTOMER_ACCOUNTS, APPOINTMENTS, SERVICELINE_FEATURES | Exists but not selected |
| `SERVICE_MODEL` | ✅ Yes | Category | - | - |
| `SERVICELINE_ADDRESS1` | ✅ Yes | Address | - | - |
| `SERVICELINE_ADDRESS2` | ✅ Yes | Address | - | - |
| `SERVICELINE_ADDRESS_CITY` | ✅ Yes | City | - | - |
| `SERVICELINE_ADDRESS_STATE` | ✅ Yes | State | - | - |
| `SERVICELINE_ADDRESS_ZIPCODE` | ✅ Yes | ZIP Code | - | - |

**Important**: `SERVICELINE_NUMBER` in this table is the **join key** but is NOT selected in the query. The model will only have `SERVICELINE_NUMBER` from `SERVICEORDERS` (so).

## Join Key Columns Summary

These columns are used in JOIN conditions but may not be selected in the final model:

| Join Key Column | Used In Join | Selected From | Also Exists In |
|----------------|--------------|---------------|----------------|
| `SERVICEORDER_ID` | `so.SERVICEORDER_ID = st.SERVICEORDER_ID` | `SERVICEORDERS` (so) | SERVICEORDER_TASKS, SERVICEORDER_ADDRESSES, SERVICEORDER_FEATURES, SERVICEORDER_NOTES |
| `ACCOUNT_ID` | `so.ACCOUNT_ID = ca.ACCOUNT_ID` | `SERVICEORDERS` (so) | SERVICEORDER_TASKS, CUSTOMER_ACCOUNTS, APPOINTMENTS, SERVICELINE_FEATURES, SERVICELINE_ADDRESSES |
| `ORDER_ID` | `so.ORDER_ID = a.ORDER_ID` | `SERVICEORDERS` (so) | APPOINTMENTS, SERVICEORDER_ADDRESSES, SERVICEORDER_FEATURES, SERVICEORDER_NOTES |
| `SERVICELINE_NUMBER` | `so.SERVICELINE_NUMBER = sf.SERVICELINE_NUMBER`<br>`so.SERVICELINE_NUMBER = sa.SERVICELINE_NUMBER` | `SERVICEORDERS` (so) | SERVICEORDER_TASKS, APPOINTMENTS, SERVICELINE_FEATURES, SERVICELINE_ADDRESSES |

## Final Model Columns (What Actually Appears)

The final model will contain **only** the columns marked "✅ Yes" above. Here's the complete list:

1. `ORDER_ID` - from `SERVICEORDERS` (so)
2. `ACCOUNT_ID` - from `SERVICEORDERS` (so)
3. `STATUS` - from `SERVICEORDERS` (so)
4. `SERVICELINE_NUMBER` - from `SERVICEORDERS` (so)
5. `SERVICEORDER_TYPE` - from `SERVICEORDERS` (so)
6. `SERVICEORDER_ID` - from `SERVICEORDERS` (so)
7. `TASK_NAME` - from `SERVICEORDER_TASKS` (st)
8. `TASK_STARTED` - from `SERVICEORDER_TASKS` (st)
9. `TASK_ENDED` - from `SERVICEORDER_TASKS` (st)
10. `ASSIGNEE` - from `SERVICEORDER_TASKS` (st)
11. `ACCOUNT_TYPE` - from `CUSTOMER_ACCOUNTS` (ca)
12. `APPOINTMENT_TYPE` - from `APPOINTMENTS` (a)
13. `APPOINTMENT_TYPE_DESCRIPTION` - from `APPOINTMENTS` (a)
14. `APPOINTMENT_DATE` - from `APPOINTMENTS` (a)
15. `APPOINTMENT_ID` - from `APPOINTMENTS` (a)
16. `FEATURE` - from `SERVICELINE_FEATURES` (sf)
17. `FEATURE_PRICE` - from `SERVICELINE_FEATURES` (sf)
18. `QTY` - from `SERVICELINE_FEATURES` (sf)
19. `PLAN` - from `SERVICELINE_FEATURES` (sf)
20. `SERVICE_MODEL` - from `SERVICELINE_ADDRESSES` (sa)
21. `SERVICELINE_ADDRESS1` - from `SERVICELINE_ADDRESSES` (sa)
22. `SERVICELINE_ADDRESS2` - from `SERVICELINE_ADDRESSES` (sa)
23. `SERVICELINE_ADDRESS_CITY` - from `SERVICELINE_ADDRESSES` (sa)
24. `SERVICELINE_ADDRESS_STATE` - from `SERVICELINE_ADDRESSES` (sa)
25. `SERVICELINE_ADDRESS_ZIPCODE` - from `SERVICELINE_ADDRESSES` (sa)

## Setting Semantic Types in Metabase

When setting semantic types in Metabase:

1. **Identify the column** in the model
2. **Find it in this document** to see which table it comes from
3. **Set the semantic type** based on the table and column purpose
4. **Note**: Join key columns (like `SERVICEORDER_ID`, `ACCOUNT_ID`, etc.) only appear once in the model, from the `SERVICEORDERS` table, even though they exist in multiple joined tables

## Important Notes

- **Join keys are NOT duplicated**: Even though `SERVICEORDER_ID` exists in multiple tables, only `so.SERVICEORDER_ID` is selected, so it only appears once in the model
- **LEFT JOINs may have NULLs**: Columns from `APPOINTMENTS`, `SERVICELINE_FEATURES`, and `SERVICELINE_ADDRESSES` may be NULL if no matching record exists
- **INNER JOINs guarantee values**: Columns from `SERVICEORDER_TASKS` and `CUSTOMER_ACCOUNTS` will always have values (no NULLs)
- **Column names don't include table aliases**: In the Metabase model, `SERVICEORDER_ID` appears as just `SERVICEORDER_ID`, not `so.SERVICEORDER_ID`

