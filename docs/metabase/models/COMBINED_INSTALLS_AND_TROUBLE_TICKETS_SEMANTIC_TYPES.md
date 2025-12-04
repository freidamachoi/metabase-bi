# Combined Installs and Trouble Tickets - Semantic Types Reference

## Overview

This document provides a quick reference for setting semantic types in Metabase for the **Combined Installs and Trouble Tickets** model.

**For detailed column mapping**: See [`COMBINED_INSTALLS_AND_TROUBLE_TICKETS_COLUMN_MAPPING.md`](./COMBINED_INSTALLS_AND_TROUBLE_TICKETS_COLUMN_MAPPING.md)

## Semantic Types by Column

| Column Name | Database Column (Installs) | Database Column (Trouble Tickets) | Semantic Type | Priority |
|------------|----------------------------|----------------------------------|---------------|----------|
| `VISIT_TYPE` | Literal: 'Install' | Literal: 'Trouble Ticket' | **Category** | ⭐ **HIGH** |
| `VISIT_ID` | `SERVICEORDERS.ORDER_ID` | NULL | **Entity Key** | ⭐ **HIGH** |
| `SERVICEORDER_ID` | `SERVICEORDERS.SERVICEORDER_ID` | NULL | **Entity Key** | Medium |
| `TROUBLE_TICKET_ID` | NULL | `TROUBLE_TICKETS.TROUBLE_TICKET_ID` | **Entity Key** | ⭐ **HIGH** |
| `ACCOUNT_ID` | `SERVICEORDERS.ACCOUNT_ID` | `TROUBLE_TICKETS.ACCOUNT_ID` | **Entity Key** | Medium |
| `ASSIGNEE` | `SERVICEORDER_TASKS.ASSIGNEE` | `TROUBLE_TICKET_TASKS.ASSIGNEE` | **Entity Name** | ⭐ **HIGH** |
| `ACCOUNT_TYPE` | `CUSTOMER_ACCOUNTS.ACCOUNT_TYPE` | `CUSTOMER_ACCOUNTS.ACCOUNT_TYPE` | **Category** | ⭐ **HIGH** |
| `TASK_ENDED` | `SERVICEORDER_TASKS.TASK_ENDED` | `TROUBLE_TICKET_TASKS.TASK_ENDED` | **Creation Timestamp** | ⭐ **HIGH** |
| `SERVICELINE_ADDRESS1` | `SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS1` | `SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS1` | **Address** | Medium |
| `SERVICELINE_ADDRESS2` | `SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS2` | `SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS2` | **Address** | Low |
| `SERVICELINE_ADDRESS_CITY` | `SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_CITY` | `SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_CITY` | **City** | Medium |
| `SERVICELINE_ADDRESS_STATE` | `SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_STATE` | `SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_STATE` | **State** | ⭐ **HIGH** |
| `SERVICELINE_ADDRESS_ZIPCODE` | `SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_ZIPCODE` | `SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_ZIPCODE` | **ZIP Code** | Medium |
| `STATUS` | `SERVICEORDERS.STATUS` | NULL | **Category** | Medium |
| `TROUBLE_TICKET_STATUS` | NULL | `TROUBLE_TICKETS.STATUS` | **Category** | Medium |
| `SERVICEORDER_TYPE` | `SERVICEORDERS.SERVICEORDER_TYPE` | NULL | **Category** | Low |
| `SERVICE_MODEL` | `SERVICELINE_ADDRESSES.SERVICE_MODEL` | `SERVICELINE_ADDRESSES.SERVICE_MODEL` | **Category** | Medium |
| `TASK_NAME` | `SERVICEORDER_TASKS.TASK_NAME` | `TROUBLE_TICKET_TASKS.TASK_NAME` | **Category** | Low |

## Priority Fields for Analysis

### ⭐ High Priority (Set These First)

1. **VISIT_TYPE** (Category) - Essential for filtering/separating installs vs trouble tickets
2. **ASSIGNEE** (Entity Name) - Primary analysis dimension (technician)
3. **TASK_ENDED** (Creation Timestamp) - Primary time dimension
4. **ACCOUNT_TYPE** (Category) - Key grouping dimension
5. **SERVICELINE_ADDRESS_STATE** (State) - Geographic analysis
6. **VISIT_ID** (Entity Key) - Primary identifier for installs
7. **TROUBLE_TICKET_ID** (Entity Key) - Primary identifier for trouble tickets

## Full Database Column Paths

### Installs Query Columns

```
CAMVIO.PUBLIC.SERVICEORDERS.ORDER_ID → VISIT_ID
CAMVIO.PUBLIC.SERVICEORDERS.SERVICEORDER_ID → SERVICEORDER_ID
CAMVIO.PUBLIC.SERVICEORDERS.ACCOUNT_ID → ACCOUNT_ID
CAMVIO.PUBLIC.SERVICEORDERS.STATUS → STATUS
CAMVIO.PUBLIC.SERVICEORDERS.SERVICEORDER_TYPE → SERVICEORDER_TYPE
CAMVIO.PUBLIC.SERVICEORDER_TASKS.ASSIGNEE → ASSIGNEE
CAMVIO.PUBLIC.SERVICEORDER_TASKS.TASK_ENDED → TASK_ENDED
CAMVIO.PUBLIC.SERVICEORDER_TASKS.TASK_NAME → TASK_NAME
CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS.ACCOUNT_TYPE → ACCOUNT_TYPE
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS1 → SERVICELINE_ADDRESS1
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS2 → SERVICELINE_ADDRESS2
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_CITY → SERVICELINE_ADDRESS_CITY
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_STATE → SERVICELINE_ADDRESS_STATE
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_ZIPCODE → SERVICELINE_ADDRESS_ZIPCODE
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICE_MODEL → SERVICE_MODEL
```

### Trouble Tickets Query Columns

```
CAMVIO.PUBLIC.TROUBLE_TICKETS.TROUBLE_TICKET_ID → TROUBLE_TICKET_ID
CAMVIO.PUBLIC.TROUBLE_TICKETS.ACCOUNT_ID → ACCOUNT_ID
CAMVIO.PUBLIC.TROUBLE_TICKETS.STATUS → TROUBLE_TICKET_STATUS
CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS.ASSIGNEE → ASSIGNEE
CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS.TASK_ENDED → TASK_ENDED
CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS.TASK_NAME → TASK_NAME
CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS.ACCOUNT_TYPE → ACCOUNT_TYPE
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS1 → SERVICELINE_ADDRESS1
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS2 → SERVICELINE_ADDRESS2
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_CITY → SERVICELINE_ADDRESS_CITY
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_STATE → SERVICELINE_ADDRESS_STATE
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICELINE_ADDRESS_ZIPCODE → SERVICELINE_ADDRESS_ZIPCODE
CAMVIO.PUBLIC.SERVICELINE_ADDRESSES.SERVICE_MODEL → SERVICE_MODEL
```

## Setting Semantic Types in Metabase

### Method 1: Model Settings (Recommended)

1. Open the **Combined Installs and Trouble Tickets** model
2. Click **Model settings** (gear icon)
3. Go to **Column metadata** tab
4. For each column:
   - Set **Semantic type** from dropdown
   - Review **Database column** (shown automatically)
5. Save changes

### Method 2: Individual Column Settings

1. Open the model
2. Click on a column header
3. Select **Column settings**
4. Set **Semantic type**
5. Save

## Quick Setup Checklist

- [ ] Set `VISIT_TYPE` → **Category**
- [ ] Set `ASSIGNEE` → **Entity Name**
- [ ] Set `TASK_ENDED` → **Creation Timestamp**
- [ ] Set `ACCOUNT_TYPE` → **Category**
- [ ] Set `VISIT_ID` → **Entity Key**
- [ ] Set `TROUBLE_TICKET_ID` → **Entity Key**
- [ ] Set `SERVICEORDER_ID` → **Entity Key**
- [ ] Set `ACCOUNT_ID` → **Entity Key**
- [ ] Set address fields → **Address/City/State/ZIP Code**
- [ ] Set status fields → **Category**
- [ ] Set `SERVICE_MODEL` → **Category**
- [ ] Set `TASK_NAME` → **Category**

## Notes

- **NULL Values**: Some fields are intentionally NULL for one visit type (e.g., `TROUBLE_TICKET_ID` is NULL for installs)
- **Latest Task**: Both queries use window functions to get the latest task, so all task fields come from the most recent task
- **Geographic Fields**: Setting correct semantic types enables map visualizations in Metabase
- **Entity Name**: Setting `ASSIGNEE` as Entity Name enables better person name handling and search

