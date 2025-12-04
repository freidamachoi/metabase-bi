# Combined Installs and Trouble Tickets - Unified Model

## Overview

This unified model combines **completed installations** and **closed trouble tickets** into a single view of all technician visits. This allows for comprehensive reporting across both service types.

## Model Structure

**Source**: `snowflake/camvio/queries/combined_installs_and_trouble_tickets.sql`

**Type**: UNION ALL query combining two result sets

## Data Sources

### 1. Installs (Service Orders)
- **Source Table**: `SERVICEORDERS` + `SERVICEORDER_TASKS`
- **Filters**: 
  - `TASK_NAME` = 'TECHNICIAN VISIT'
  - `STATUS` = 'COMPLETED'
  - `SERVICE_MODEL` = 'INTERNET'
- **Latest Task**: Uses `ROW_NUMBER()` to get latest `TASK_ENDED` per `ORDER_ID`

### 2. Trouble Tickets
- **Source Table**: `TROUBLE_TICKETS` + `TROUBLE_TICKET_TASKS`
- **Filters**:
  - `TASK_NAME` ILIKE '%Tech Visit%'
  - `STATUS` ILIKE '%CLOSED%'
- **Latest Task**: Uses `ROW_NUMBER()` to get latest `TASK_ENDED` per `TROUBLE_TICKET_ID`

## Key Fields

| Field Name | Description | Install Value | Trouble Ticket Value |
|-----------|-------------|---------------|---------------------|
| `VISIT_TYPE` | Type of visit | 'Install' | 'Trouble Ticket' |
| `VISIT_ID` | Primary identifier | `ORDER_ID` | NULL |
| `TROUBLE_TICKET_ID` | Trouble ticket ID | NULL | `TROUBLE_TICKET_ID` |
| `SERVICEORDER_ID` | Service order ID | `SERVICEORDER_ID` | NULL |
| `ACCOUNT_ID` | Account identifier | `ACCOUNT_ID` | `ACCOUNT_ID` |
| `ASSIGNEE` | Technician name | From latest task | From latest task |
| `ACCOUNT_TYPE` | Account type | `ACCOUNT_TYPE` | `ACCOUNT_TYPE` |
| `TASK_ENDED` | Date of visit | Latest task date | Latest task date |
| `STATUS` | Order status | 'COMPLETED' | NULL |
| `TROUBLE_TICKET_STATUS` | Ticket status | NULL | 'CLOSED' |
| `SERVICEORDER_TYPE` | Service order type | `SERVICEORDER_TYPE` | NULL |
| `SERVICE_MODEL` | Service model | 'INTERNET' | From address |
| Address fields | Installation address | From `SERVICELINE_ADDRESSES` | From `SERVICELINE_ADDRESSES` |

## Usage Patterns

### Filter by Visit Type

```sql
-- Only installs
WHERE VISIT_TYPE = 'Install'

-- Only trouble tickets
WHERE VISIT_TYPE = 'Trouble Ticket'
```

### Get Primary Identifier

```sql
-- Use VISIT_ID for installs, TROUBLE_TICKET_ID for trouble tickets
CASE 
    WHEN VISIT_TYPE = 'Install' THEN VISIT_ID
    ELSE TROUBLE_TICKET_ID
END AS PRIMARY_ID
```

### Aggregate Across Both Types

```sql
-- Total visits by technician
SELECT 
    ASSIGNEE,
    COUNT(*) as total_visits,
    SUM(CASE WHEN VISIT_TYPE = 'Install' THEN 1 ELSE 0 END) as installs,
    SUM(CASE WHEN VISIT_TYPE = 'Trouble Ticket' THEN 1 ELSE 0 END) as trouble_tickets
FROM combined_model
GROUP BY ASSIGNEE
```

## Advantages of Unified Model

1. **Single Source of Truth**: All technician visits in one place
2. **Consistent Reporting**: Same structure for both types
3. **Easy Comparison**: Compare installs vs trouble tickets side-by-side
4. **Unified Metrics**: Aggregate across both types easily
5. **Simpler Dashboards**: One model instead of two separate models

## Alternative: Separate Models + Join

If you prefer separate models:

1. **Create Model 1**: "Installs by Individual (Base)" - uses `revised_installs_by_individual.sql`
2. **Create Model 2**: "Trouble Tickets (Base)" - uses trouble ticket query
3. **Create Model 3**: "Combined Visits" - joins both models

**However**, there's **no natural join key** between installs and trouble tickets:
- Installs use `ORDER_ID`
- Trouble tickets use `TROUBLE_TICKET_ID`
- They're independent entities

**UNION ALL approach is recommended** because:
- No join key needed
- Simpler structure
- Better performance (single query)
- Easier to maintain

## Custom Columns for Enhanced Model

### Visit Identifier

```javascript
// Primary Visit ID
case(
  [Visit Type] = "Install",
  [Visit Id],
  [Trouble Ticket Id]
)
```

### Status Field

```javascript
// Unified Status
case(
  [Visit Type] = "Install",
  [Status],
  [Trouble Ticket Status]
)
```

### Visit Type Label

```javascript
// Formatted Visit Type
case(
  [Visit Type] = "Install",
  "Installation",
  "Trouble Ticket"
)
```

## Metrics

1. **Total Visits** - Count of all visits (installs + trouble tickets)
2. **Total Installs** - Count where VISIT_TYPE = 'Install'
3. **Total Trouble Tickets** - Count where VISIT_TYPE = 'Trouble Ticket'
4. **Unique Technicians** - Count distinct of ASSIGNEE
5. **Visits by Type** - Count grouped by VISIT_TYPE
6. **Visits by Account Type** - Count grouped by ACCOUNT_TYPE
7. **Average Visits per Technician** - Average visits per ASSIGNEE

## Recommended Filters

- **VISIT_TYPE**: Filter to 'Install' or 'Trouble Ticket'
- **Date Range**: Filter by `TASK_ENDED`
- **Technician**: Filter by `ASSIGNEE`
- **Account Type**: Filter by `ACCOUNT_TYPE`
- **State**: Filter by `SERVICELINE_ADDRESS_STATE`

## Semantic Types

| Field | Semantic Type | Notes |
|-------|---------------|-------|
| `VISIT_TYPE` | Category | 'Install' or 'Trouble Ticket' |
| `VISIT_ID` | Entity Key | ORDER_ID for installs |
| `TROUBLE_TICKET_ID` | Entity Key | Trouble ticket ID |
| `SERVICEORDER_ID` | Entity Key | Service order ID (NULL for trouble tickets) |
| `ACCOUNT_ID` | Entity Key | Account identifier |
| `ASSIGNEE` | Entity Name | Technician name |
| `ACCOUNT_TYPE` | Category | Account type |
| `TASK_ENDED` | Creation Timestamp | Date of visit |
| Address fields | Address/City/State/ZIP | Installation address |
| `SERVICE_MODEL` | Category | Service model type |

