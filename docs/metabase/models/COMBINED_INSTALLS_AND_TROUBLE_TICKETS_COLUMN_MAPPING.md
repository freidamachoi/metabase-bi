# Combined Installs and Trouble Tickets - Column Mapping & Semantic Types

## Overview

This document maps each column in the **Combined Installs and Trouble Tickets** Metabase model to its corresponding database column(s) and recommended semantic types.

**Model Type**: UNION ALL query combining two result sets (Installs + Trouble Tickets)

## Column Mapping Table

| Model Column Name | Source (Installs) | Source (Trouble Tickets) | Semantic Type | Notes |
|------------------|-------------------|-------------------------|---------------|-------|
| `VISIT_TYPE` | Literal: 'Install' | Literal: 'Trouble Ticket' | **Category** | Distinguishes between installs and trouble tickets |
| `VISIT_ID` | `latest.ORDER_ID`<br>`CAMVIO.PUBLIC.SERVICEORDERS` | `CAST(NULL AS NUMBER)` | **Entity Key** | ORDER_ID for installs, NULL for trouble tickets |
| `SERVICEORDER_ID` | `latest.SERVICEORDER_ID`<br>`CAMVIO.PUBLIC.SERVICEORDERS` | `CAST(NULL AS NUMBER)` | **Entity Key** | Service order ID (NULL for trouble tickets) |
| `TROUBLE_TICKET_ID` | `CAST(NULL AS NUMBER)` | `tt.TROUBLE_TICKET_ID`<br>`CAMVIO.PUBLIC.TROUBLE_TICKETS` | **Entity Key** | Trouble ticket ID (NULL for installs) |
| `ACCOUNT_ID` | `latest.ACCOUNT_ID`<br>`CAMVIO.PUBLIC.SERVICEORDERS` | `tt.ACCOUNT_ID`<br>`CAMVIO.PUBLIC.TROUBLE_TICKETS` | **Entity Key** | Account identifier (from both sources) |
| `ASSIGNEE` | `latest.ASSIGNEE`<br>`CAMVIO.PUBLIC.SERVICEORDER_TASKS` | `lt.ASSIGNEE`<br>`CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS` | **Entity Name** | **Technician name** (from latest task) |
| `ACCOUNT_TYPE` | `ca.ACCOUNT_TYPE`<br>`CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS` | `ca.ACCOUNT_TYPE`<br>`CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS` | **Category** | **Account type** (from both sources) |
| `TASK_ENDED` | `latest.TASK_ENDED`<br>`CAMVIO.PUBLIC.SERVICEORDER_TASKS` | `lt.TASK_ENDED`<br>`CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS` | **Creation Timestamp** | **Date of visit** (latest task ended date) |
| `SERVICELINE_ADDRESS1` | `sa.SERVICELINE_ADDRESS1`<br>`CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | `sa.SERVICELINE_ADDRESS1`<br>`CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | **Address** | **Installation address** line 1 |
| `SERVICELINE_ADDRESS2` | `sa.SERVICELINE_ADDRESS2`<br>`CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | `sa.SERVICELINE_ADDRESS2`<br>`CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | **Address** | **Installation address** line 2 |
| `SERVICELINE_ADDRESS_CITY` | `sa.SERVICELINE_ADDRESS_CITY`<br>`CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | `sa.SERVICELINE_ADDRESS_CITY`<br>`CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | **City** | **Installation address** city |
| `SERVICELINE_ADDRESS_STATE` | `sa.SERVICELINE_ADDRESS_STATE`<br>`CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | `sa.SERVICELINE_ADDRESS_STATE`<br>`CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | **State** | **Installation address** state |
| `SERVICELINE_ADDRESS_ZIPCODE` | `sa.SERVICELINE_ADDRESS_ZIPCODE`<br>`CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | `sa.SERVICELINE_ADDRESS_ZIPCODE`<br>`CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | **ZIP Code** | **Installation address** ZIP code |
| `STATUS` | `latest.STATUS`<br>`CAMVIO.PUBLIC.SERVICEORDERS` | `tt.STATUS`<br>`CAMVIO.PUBLIC.TROUBLE_TICKETS` | **Category** | **Unified status field** - Service order status for installs, trouble ticket status for trouble tickets |
| `TROUBLE_TICKET_STATUS` | `latest.STATUS`<br>`CAMVIO.PUBLIC.SERVICEORDERS` | `tt.STATUS`<br>`CAMVIO.PUBLIC.TROUBLE_TICKETS` | **Category** | Same as STATUS (kept for consistency/backward compatibility) |
| `SERVICEORDER_TYPE` | `latest.SERVICEORDER_TYPE`<br>`CAMVIO.PUBLIC.SERVICEORDERS` | `CAST(NULL AS TEXT)` | **Category** | Service order type (NULL for trouble tickets) |
| `SERVICE_MODEL` | `sa.SERVICE_MODEL`<br>`CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | `sa.SERVICE_MODEL`<br>`CAMVIO.PUBLIC.SERVICELINE_ADDRESSES` | **Category** | Service model type |
| `TASK_NAME` | `latest.TASK_NAME`<br>`CAMVIO.PUBLIC.SERVICEORDER_TASKS` | `lt.TASK_NAME`<br>`CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS` | **Category** | Task name (should be 'TECHNICIAN VISIT' or contains 'Tech Visit') |

## Detailed Field Breakdown

### VISIT_TYPE
- **Type**: Literal value (not from database)
- **Installs**: `'Install'`
- **Trouble Tickets**: `'Trouble Ticket'`
- **Semantic Type**: **Category**
- **Purpose**: Distinguishes between the two data sources

### VISIT_ID
- **Installs**: `CAMVIO.PUBLIC.SERVICEORDERS.ORDER_ID` (via `latest` subquery)
- **Trouble Tickets**: `NULL`
- **Semantic Type**: **Entity Key**
- **Purpose**: Primary identifier for installs (ORDER_ID)

### SERVICEORDER_ID
- **Installs**: `CAMVIO.PUBLIC.SERVICEORDERS.SERVICEORDER_ID` (via `latest` subquery)
- **Trouble Tickets**: `NULL`
- **Semantic Type**: **Entity Key**
- **Purpose**: Service order identifier (joins to Fybe WORK_PACKAGE)

### TROUBLE_TICKET_ID
- **Installs**: `NULL`
- **Trouble Tickets**: `CAMVIO.PUBLIC.TROUBLE_TICKETS.TROUBLE_TICKET_ID`
- **Semantic Type**: **Entity Key**
- **Purpose**: Primary identifier for trouble tickets

### ACCOUNT_ID
- **Installs**: `CAMVIO.PUBLIC.SERVICEORDERS.ACCOUNT_ID` (via `latest` subquery)
- **Trouble Tickets**: `CAMVIO.PUBLIC.TROUBLE_TICKETS.ACCOUNT_ID`
- **Semantic Type**: **Entity Key**
- **Purpose**: Customer account identifier

### ASSIGNEE
- **Installs**: `CAMVIO.PUBLIC.SERVICEORDER_TASKS.ASSIGNEE` (via `latest` subquery, from latest task)
- **Trouble Tickets**: `CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS.ASSIGNEE` (via `lt` subquery, from latest task)
- **Semantic Type**: **Entity Name**
- **Purpose**: **Technician/individual who completed the visit**

### ACCOUNT_TYPE
- **Installs**: `CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS.ACCOUNT_TYPE` (joined via `ca`)
- **Trouble Tickets**: `CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS.ACCOUNT_TYPE` (joined via `ca`)
- **Semantic Type**: **Category**
- **Purpose**: **Account type** (e.g., Residential, Business)

### TASK_ENDED
- **Installs**: `CAMVIO.PUBLIC.SERVICEORDER_TASKS.TASK_ENDED` (via `latest` subquery, latest task)
- **Trouble Tickets**: `CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS.TASK_ENDED` (via `lt` subquery, latest task)
- **Semantic Type**: **Creation Timestamp**
- **Purpose**: **Date of visit** (when the technician visit was completed)

### Address Fields (SERVICELINE_ADDRESS*)
- **Installs**: `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.*` (joined via `sa` on SERVICELINE_NUMBER)
- **Trouble Tickets**: `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.*` (joined via `sa` on SERVICELINE_NUMBER)
- **Semantic Types**: 
  - `SERVICELINE_ADDRESS1`, `SERVICELINE_ADDRESS2` → **Address**
  - `SERVICELINE_ADDRESS_CITY` → **City**
  - `SERVICELINE_ADDRESS_STATE` → **State**
  - `SERVICELINE_ADDRESS_ZIPCODE` → **ZIP Code**
- **Purpose**: **Installation/ticket address**

### STATUS
- **Installs**: `CAMVIO.PUBLIC.SERVICEORDERS.STATUS` (via `latest` subquery, should be 'COMPLETED')
- **Trouble Tickets**: `CAMVIO.PUBLIC.TROUBLE_TICKETS.STATUS` (should contain 'CLOSED')
- **Semantic Type**: **Category**
- **Purpose**: **Unified status field** - Works for both installs and trouble tickets

### TROUBLE_TICKET_STATUS
- **Installs**: `CAMVIO.PUBLIC.SERVICEORDERS.STATUS` (same as STATUS for installs)
- **Trouble Tickets**: `CAMVIO.PUBLIC.TROUBLE_TICKETS.STATUS` (same as STATUS for trouble tickets)
- **Semantic Type**: **Category**
- **Purpose**: Same as STATUS (kept for consistency/backward compatibility)

### SERVICEORDER_TYPE
- **Installs**: `CAMVIO.PUBLIC.SERVICEORDERS.SERVICEORDER_TYPE` (via `latest` subquery)
- **Trouble Tickets**: `NULL`
- **Semantic Type**: **Category**
- **Purpose**: Service order type

### SERVICE_MODEL
- **Installs**: `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICE_MODEL` (joined via `sa`, filtered to 'INTERNET')
- **Trouble Tickets**: `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICE_MODEL` (joined via `sa`)
- **Semantic Type**: **Category**
- **Purpose**: Service model type

### TASK_NAME
- **Installs**: `CAMVIO.PUBLIC.SERVICEORDER_TASKS.TASK_NAME` (via `latest` subquery, should be 'TECHNICIAN VISIT')
- **Trouble Tickets**: `CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS.TASK_NAME` (via `lt` subquery, should contain 'Tech Visit')
- **Semantic Type**: **Category**
- **Purpose**: Task name

## Table Reference

### Installs Query Tables

1. **SERVICEORDERS** (alias: `so` in subquery, `latest` in outer query)
   - **Full Name**: `CAMVIO.PUBLIC.SERVICEORDERS`
   - **Fields Used**: ORDER_ID, SERVICEORDER_ID, ACCOUNT_ID, STATUS, SERVICEORDER_TYPE, SERVICELINE_NUMBER

2. **SERVICEORDER_TASKS** (alias: `st` in subquery)
   - **Full Name**: `CAMVIO.PUBLIC.SERVICEORDER_TASKS`
   - **Fields Used**: ASSIGNEE, TASK_ENDED, TASK_NAME
   - **Join**: `so.SERVICEORDER_ID = st.SERVICEORDER_ID`

3. **CUSTOMER_ACCOUNTS** (alias: `ca`)
   - **Full Name**: `CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS`
   - **Fields Used**: ACCOUNT_TYPE
   - **Join**: `latest.ACCOUNT_ID = ca.ACCOUNT_ID`

4. **SERVICELINE_ADDRESSES** (alias: `sa`)
   - **Full Name**: `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES`
   - **Fields Used**: All address fields, SERVICE_MODEL
   - **Join**: `latest.SERVICELINE_NUMBER = sa.SERVICELINE_NUMBER`
   - **Filter**: `UPPER(sa.SERVICE_MODEL) = 'INTERNET'`

### Trouble Tickets Query Tables

1. **TROUBLE_TICKETS** (alias: `tt`)
   - **Full Name**: `CAMVIO.PUBLIC.TROUBLE_TICKETS`
   - **Fields Used**: TROUBLE_TICKET_ID, ACCOUNT_ID, SERVICELINE_NUMBER, STATUS
   - **Filter**: `tt.status ILIKE '%CLOSED%'`

2. **TROUBLE_TICKET_TASKS** (alias: `lt` in subquery)
   - **Full Name**: `CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS`
   - **Fields Used**: trouble_ticket_id, task_name, task_ended, assignee
   - **Join**: `tt.trouble_ticket_id = lt.trouble_ticket_id`
   - **Filter**: `task_name ILIKE '%Tech Visit%'`

3. **CUSTOMER_ACCOUNTS** (alias: `ca`)
   - **Full Name**: `CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS`
   - **Fields Used**: ACCOUNT_TYPE
   - **Join**: `tt.account_id = ca.account_id`

4. **SERVICELINE_ADDRESSES** (alias: `sa`)
   - **Full Name**: `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES`
   - **Fields Used**: All address fields, SERVICE_MODEL
   - **Join**: `tt.serviceline_number = sa.serviceline_number` (LEFT JOIN)

## Semantic Types Summary

### Entity Keys (IDs)
- `VISIT_ID`, `SERVICEORDER_ID`, `TROUBLE_TICKET_ID`, `ACCOUNT_ID`

### Entity Name
- `ASSIGNEE` (technician name)

### Creation Timestamp
- `TASK_ENDED` (date of visit)

### Category
- `VISIT_TYPE`, `ACCOUNT_TYPE`, `STATUS`, `TROUBLE_TICKET_STATUS`, `SERVICEORDER_TYPE`, `SERVICE_MODEL`, `TASK_NAME`

### Geographic Fields
- `SERVICELINE_ADDRESS1`, `SERVICELINE_ADDRESS2` → **Address**
- `SERVICELINE_ADDRESS_CITY` → **City**
- `SERVICELINE_ADDRESS_STATE` → **State**
- `SERVICELINE_ADDRESS_ZIPCODE` → **ZIP Code**

## Important Notes

### NULL Values
- **Installs**: `TROUBLE_TICKET_ID` is NULL
- **Trouble Tickets**: `VISIT_ID`, `SERVICEORDER_ID`, `SERVICEORDER_TYPE` are NULL
- **Note**: `STATUS` and `TROUBLE_TICKET_STATUS` now have values for both types (unified status field)
- This is intentional - fields are NULL when not applicable to that visit type

### Latest Task Selection
- Both queries use `ROW_NUMBER()` window function to get the latest `TASK_ENDED` date
- For installs: Latest task per `ORDER_ID`
- For trouble tickets: Latest task per `TROUBLE_TICKET_ID`
- All task-related fields (ASSIGNEE, TASK_ENDED, TASK_NAME) come from the latest task

### Join Keys
- **Installs**: Uses `SERVICELINE_NUMBER` to join to addresses
- **Trouble Tickets**: Uses `SERVICELINE_NUMBER` to join to addresses
- Both use `ACCOUNT_ID` to join to customer accounts

## Setting Semantic Types in Metabase

1. Open the **Combined Installs and Trouble Tickets** model
2. Go to **Model settings** → **Column metadata**
3. Set semantic types according to the table above
4. Pay special attention to:
   - `VISIT_TYPE` → **Category** (for filtering)
   - `ASSIGNEE` → **Entity Name** (for grouping by technician)
   - `TASK_ENDED` → **Creation Timestamp** (for date filtering and time-based analysis)
   - Address fields → Appropriate geographic semantic types

## Custom Column Recommendations

### Primary Visit Identifier

```javascript
// Unified Visit ID
case(
  [Visit Type] = "Install",
  [Visit Id],
  [Trouble Ticket Id]
)
```

### Unified Status

**Note**: `STATUS` field is already unified - it contains the status for both installs and trouble tickets. No custom column needed unless you want to format it differently.

```javascript
// Formatted Status (optional)
case(
  [Visit Type] = "Install",
  concat("Install: ", [Status]),
  concat("Ticket: ", [Status])
)
```

