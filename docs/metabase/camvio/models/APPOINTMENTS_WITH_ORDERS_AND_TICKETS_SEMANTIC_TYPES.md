# Service Orders and Trouble Tickets with Appointments (Base) - Semantic Types

## Overview

Semantic types in Metabase help the system understand what kind of data each column contains, enabling better visualizations, filtering, and data exploration. This document specifies the recommended semantic types for each column in the **Service Orders and Trouble Tickets with Appointments (Base)** model.

**Model**: Service Orders and Trouble Tickets with Appointments (Base)  
**Source**: `snowflake/camvio/queries/appointments_with_orders_and_tickets.sql`  
**Database**: Camvio Snowflake (read-only)

## Column Semantic Types

### Record Type and Common Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `RECORD_TYPE` | Calculated | **Category** | Record type ("Service Order" or "Trouble Ticket") | Primary dimension for filtering |
| `ACCOUNT_ID` | `bd.ACCOUNT_ID` | **Entity Key** | Account identifier | Common field (available for both types) |
| `SERVICELINE_NUMBER` | `bd.SERVICELINE_NUMBER` | **Entity Key** | Service line number (VARCHAR) | Common field (available for both types) |

### Service Order Fields (populated when RECORD_TYPE = "Service Order")

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `SERVICEORDER_ID` | `bd.SERVICEORDER_ID` | **Entity Key** | Service order identifier | Only populated when RECORD_TYPE = "Service Order" |
| `ORDER_ID` | `bd.ORDER_ID` | **Entity Key** | Order identifier | Only populated when RECORD_TYPE = "Service Order" |
| `STATUS` | `bd.STATUS` | **Category** | Service order status | Only populated when RECORD_TYPE = "Service Order" |
| `SERVICEORDER_TYPE` | `bd.SERVICEORDER_TYPE` | **Category** | Service order type | Only populated when RECORD_TYPE = "Service Order" |
| `SALES_AGENT` | `bd.SALES_AGENT` | **Entity Name** | Sales agent for commissions | ⭐ Required for commission calculations, only populated when RECORD_TYPE = "Service Order" |

### Feature Aggregate Fields (service orders with features only)

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `TOTAL_FEATURE_PRICE` | `fa.TOTAL_FEATURE_PRICE` | **Currency** | Sum of (feature price × quantity) | Only populated for service orders with features |
| `TOTAL_FEATURE_AMOUNT` | `fa.TOTAL_FEATURE_AMOUNT` | **Currency** | Sum of (feature price × quantity) | Only populated for service orders with features |
| `FEATURE_COUNT` | `fa.FEATURE_COUNT` | **Quantity** | Number of distinct features | Only populated for service orders with features |
| `TOTAL_FEATURE_QUANTITY` | `fa.TOTAL_FEATURE_QUANTITY` | **Quantity** | Total quantity of all features | Only populated for service orders with features |

### Trouble Ticket Fields (populated when RECORD_TYPE = "Trouble Ticket")

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `TROUBLE_TICKET_ID` | `bd.TROUBLE_TICKET_ID` | **Entity Key** | Trouble ticket identifier | Only populated when RECORD_TYPE = "Trouble Ticket" |
| `STATUS` | `bd.STATUS` | **Category** | Trouble ticket status | Only populated when RECORD_TYPE = "Trouble Ticket" |
| `REPORTED_NAME` | `bd.REPORTED_NAME` | **Entity Name** | Name of person who reported the trouble ticket | Only populated when RECORD_TYPE = "Trouble Ticket" |
| `RESOLUTION_NAME` | `bd.RESOLUTION_NAME` | **Entity Name** | Name of person who resolved the trouble ticket | Only populated when RECORD_TYPE = "Trouble Ticket" |
| `TROUBLE_TICKET_NOTES` | `bd.TROUBLE_TICKET_NOTES` | **Description** | Concatenated notes per trouble ticket | Only populated when RECORD_TYPE = "Trouble Ticket", notes separated by ' \| ' |

### Trouble Ticket Task Fields (populated based on STATUS)

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `TOTAL_DURATION_DAYS` | `td.TOTAL_DURATION_DAYS` | **Duration** | Total duration in days | Available for all trouble tickets. For non-CLOSED: days from CREATED_DATETIME to TODAY. For CLOSED: days from CREATED_DATETIME to latest TASK_ENDED |
| `LATEST_OPEN_TASK_NAME` | `lot.TASK_NAME` | **Category** | Name of the latest open task | Only populated for non-CLOSED trouble tickets, from the task with latest TASK_STARTED where TASK_ENDED IS NULL |
| `LATEST_OPEN_TASK_ASSIGNEE` | `lot.ASSIGNEE` | **Entity Name** | Assignee of the latest open task | Only populated for non-CLOSED trouble tickets, from the task with latest TASK_STARTED where TASK_ENDED IS NULL |
| `LATEST_OPEN_TASK_STARTED` | `lot.TASK_STARTED` | **Creation Timestamp** | Start date/time of the latest open task | Only populated for non-CLOSED trouble tickets, from the task with latest TASK_STARTED where TASK_ENDED IS NULL |

### Common Supporting Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `SERVICE_MODEL` | `COALESCE(soa.SERVICE_MODEL, sl.SERVICE_MODEL)` | **Category** | Service model | SERVICEORDER_ADDRESSES for service orders, SERVICELINES for trouble tickets |
| `ADDRESS_CITY` | `COALESCE(sla.SERVICELINE_ADDRESS_CITY, soa.SERVICEORDER_ADDRESS_CITY)` | **City** | Address city | SERVICELINE_ADDRESS_CITY for both types (serviceline level), SERVICEORDER_ADDRESS_CITY as fallback for service orders |
| `CREATED_DATETIME` | `bd.CREATED_DATETIME` | **Creation Timestamp** | Record creation date/time | From SERVICEORDERS for service orders, TROUBLE_TICKETS for trouble tickets |
| `MODIFIED_DATETIME` | `bd.MODIFIED_DATETIME` | **Modification Timestamp** | Record last modification date/time | From SERVICEORDERS for service orders, TROUBLE_TICKETS for trouble tickets |
| `SERVICELINE_CREATED_DATETIME` | `sl.SERVICELINE_STARTDATE` | **Creation Timestamp** | Service line creation date/time | From SERVICELINES.SERVICELINE_STARTDATE (available for both service orders and trouble tickets via SERVICELINE_NUMBER) |
| `ACCOUNT_TYPE` | `ca.ACCOUNT_TYPE` | **Category** | Account type classification | From CUSTOMER_ACCOUNTS |

### Appointment Fields (populated when appointment exists)

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `APPOINTMENT_ID` | `a.APPOINTMENT_ID` | **Entity Key** | Unique appointment identifier | NULL when no appointment exists |
| `APPOINTMENT_TYPE` | `a.APPOINTMENT_TYPE` | **Category** | Appointment type ("O" or "TT") | NULL when no appointment exists |
| `APPOINTMENT_TYPE_DESCRIPTION` | `a.APPOINTMENT_TYPE_DESCRIPTION` | **Description** | Description of appointment type | NULL when no appointment exists |
| `APPOINTMENT_DATE` | `a.APPOINTMENT_DATE` | **Creation Timestamp** | Date of the appointment | NULL when no appointment exists |
| `APPOINTMENT_ORDER_ID` | `a.ORDER_ID` | **Entity Key** | Order ID from appointments | NULL when no appointment exists |
| `APPOINTMENT_TROUBLE_TICKET_ID` | `a.TROUBLE_TICKET_ID` | **Entity Key** | Trouble ticket ID from appointments | NULL when no appointment exists |
| `HAS_APPOINTMENT` | Calculated | **Boolean** | Whether an appointment exists for this record | Use to filter records with/without appointments |

## Semantic Type Categories Reference

### Primary Types

- **Entity Key**: Unique identifiers (IDs, primary keys, codes used for joins)
- **Entity Name**: Names of entities (people, companies, etc.)
- **Category**: Categorical data (status, type, classification)
- **Description**: Text descriptions
- **Creation Timestamp**: Date/time fields
- **Modification Timestamp**: Date/time fields for last modification
- **Currency**: Monetary values (prices, amounts)
- **Quantity**: Numeric quantities
- **Duration**: Time durations (seconds, minutes, hours)
- **Boolean**: True/false values
- **City**: City names (for geographic filtering)

## Important Notes

### NULL Values and Conditional Fields

⚠️ **Important**: Many fields are conditionally populated based on RECORD_TYPE:

**Service Order Fields** (NULL when RECORD_TYPE = "Trouble Ticket"):
- `SERVICEORDER_ID`, `ORDER_ID`, `SERVICEORDER_TYPE`, `SALES_AGENT`
- All feature aggregate fields (`TOTAL_FEATURE_PRICE`, etc.)

**Trouble Ticket Fields** (NULL when RECORD_TYPE = "Service Order"):
- `TROUBLE_TICKET_ID`, `REPORTED_NAME`, `RESOLUTION_NAME`, `TROUBLE_TICKET_NOTES`

**Trouble Ticket Task Fields** (conditionally populated based on STATUS):
- `TOTAL_DURATION_DAYS`: Available for all trouble tickets (NULL for service orders)
- `LATEST_OPEN_TASK_NAME`, `LATEST_OPEN_TASK_ASSIGNEE`, `LATEST_OPEN_TASK_STARTED`: Only populated for non-CLOSED trouble tickets (NULL for CLOSED tickets and all service orders)

**Common Fields** (available for both):
- `ACCOUNT_ID`, `SERVICELINE_NUMBER`, `STATUS`, `SERVICE_MODEL`, `ADDRESS_CITY`, `CREATED_DATETIME`, `MODIFIED_DATETIME`, `SERVICELINE_CREATED_DATETIME`, `ACCOUNT_TYPE`

**SERVICE_MODEL**:
- Service Orders: From SERVICEORDER_ADDRESSES.SERVICE_MODEL
- Trouble Tickets: From SERVICELINES.SERVICE_MODEL
- Uses COALESCE to get service model from the appropriate source
- NULL if neither source has a service model

**Feature Aggregate Fields** (NULL when):
- RECORD_TYPE = "Trouble Ticket" (trouble tickets)
- RECORD_TYPE = "Service Order" but service order has no features

**Appointment Fields** (NULL when):
- No appointment exists for the record (use `HAS_APPOINTMENT = false` to filter)

### Key Fields for Analysis

- **Record Type Analysis**: Use `RECORD_TYPE` (Category) - primary dimension
- **Appointment Coverage**: Use `HAS_APPOINTMENT` (Boolean) to identify records with/without appointments
- **Service Model Analysis**: Use `SERVICE_MODEL` (Category) - available for both types
- **Sales Agent Analysis**: Use `SALES_AGENT` (Entity Name) - ⭐ required for commission calculations
- **Feature Pricing Analysis**: Use `TOTAL_FEATURE_PRICE` (Currency) + `SERVICE_MODEL` (Category) - filter to `RECORD_TYPE = 'Service Order'` and `TOTAL_FEATURE_PRICE IS NOT NULL`
- **Date Analysis**: Use `CREATED_DATETIME` (Creation Timestamp) or `MODIFIED_DATETIME` (Modification Timestamp) for time-based analysis, or `APPOINTMENT_DATE` (filter to `HAS_APPOINTMENT = true`)
- **Account Analysis**: Use `ACCOUNT_TYPE` (Category) for account-based grouping
- **Trouble Ticket Duration Analysis**: Use `TOTAL_DURATION_DAYS` (Duration) - filter to `RECORD_TYPE = 'Trouble Ticket'` AND `TOTAL_DURATION_DAYS IS NOT NULL` (available for all trouble tickets regardless of STATUS)
- **Trouble Ticket Open Tasks**: Use `LATEST_OPEN_TASK_NAME` (Category), `LATEST_OPEN_TASK_ASSIGNEE` (Entity Name), `LATEST_OPEN_TASK_STARTED` (Creation Timestamp) - filter to `RECORD_TYPE = 'Trouble Ticket'` AND `STATUS != 'CLOSED'`

### Field Prefixes

Fields are NOT prefixed in this model (unlike the previous appointments-first version):
- **No prefix** = Common fields or type-specific fields (use RECORD_TYPE to distinguish)
- **`APPOINTMENT_`** prefix = Appointment fields (e.g., `APPOINTMENT_ORDER_ID`, `APPOINTMENT_TROUBLE_TICKET_ID`)

### SERVICELINE_NUMBER Handling

- `SERVICELINE_NUMBER` is VARCHAR (cast for consistent joins)
- Invalid values ('0', '0000000000') are filtered out in the WHERE clause

### Trouble Ticket Notes

- `TROUBLE_TICKET_NOTES` contains concatenated notes per trouble ticket
- Notes are separated by ' | ' (pipe with spaces)
- Only non-empty notes are included
- NULL for service orders

## Setting Semantic Types in Metabase

1. Navigate to the model in Metabase
2. Go to the model settings
3. For each column, set the semantic type according to this document
4. Pay special attention to:
   - **Entity Keys** (for proper joins)
   - **Currency fields** (`TOTAL_FEATURE_PRICE`, `TOTAL_FEATURE_AMOUNT`) - for proper formatting
   - **Boolean fields** (`HAS_APPOINTMENT`) - for proper true/false filtering
   - **Creation Timestamps** (`APPOINTMENT_DATE`) - for date-based filtering
   - **Category fields** - for proper grouping
   - **City fields** (`SERVICELINE_ADDRESS_CITY`) - for geographic filtering

## Usage Patterns

### Pattern 1: Record Type Distribution
- **Dimensions**: `RECORD_TYPE`, `ACCOUNT_TYPE`
- **Metrics**: `COUNT(DISTINCT SERVICEORDER_ID)`, `COUNT(DISTINCT TROUBLE_TICKET_ID)`
- **Filter**: None (shows all records)

### Pattern 2: Service Orders with Features
- **Filter**: `RECORD_TYPE = 'Service Order'` AND `TOTAL_FEATURE_PRICE IS NOT NULL`
- **Dimensions**: `SERVICE_MODEL`, `SERVICEORDER_TYPE`
- **Metrics**: `SUM(TOTAL_FEATURE_PRICE)`, `AVG(TOTAL_FEATURE_PRICE)`, `COUNT(DISTINCT SERVICEORDER_ID)`

### Pattern 3: Records with Appointments
- **Filter**: `HAS_APPOINTMENT = true`
- **Dimensions**: `RECORD_TYPE`, `APPOINTMENT_TYPE`
- **Metrics**: `COUNT(DISTINCT SERVICEORDER_ID)`, `COUNT(DISTINCT TROUBLE_TICKET_ID)`
- **Use Case**: Understand appointment coverage

### Pattern 4: Records without Appointments
- **Filter**: `HAS_APPOINTMENT = false`
- **Dimensions**: `RECORD_TYPE`, `ACCOUNT_TYPE`
- **Metrics**: `COUNT(DISTINCT SERVICEORDER_ID)`, `COUNT(DISTINCT TROUBLE_TICKET_ID)`
- **Use Case**: Identify records missing appointments

### Pattern 5: Feature Pricing by Service Model
- **Filter**: `RECORD_TYPE = 'Service Order'` AND `SERVICE_MODEL IS NOT NULL` AND `TOTAL_FEATURE_PRICE IS NOT NULL`
- **Dimensions**: `SERVICE_MODEL`
- **Metrics**: 
  - `SUM(TOTAL_FEATURE_PRICE)` - Total pricing
  - `SUM(TOTAL_FEATURE_AMOUNT)` - Total amount
  - `AVG(FEATURE_COUNT)` - Average features per service order

### Pattern 6: Trouble Tickets with Notes
- **Filter**: `RECORD_TYPE = 'Trouble Ticket'` AND `TROUBLE_TICKET_NOTES IS NOT NULL`
- **Dimensions**: `STATUS`, `REPORTED_NAME`
- **Metrics**: `COUNT(DISTINCT TROUBLE_TICKET_ID)`
- **Use Case**: Understand trouble ticket documentation

### Pattern 7: Appointment Dates Analysis
- **Filter**: `HAS_APPOINTMENT = true`
- **Dimensions**: 
  - `YEAR(APPOINTMENT_DATE)`, `MONTH(APPOINTMENT_DATE)`
  - `RECORD_TYPE`
- **Metrics**: `COUNT(DISTINCT APPOINTMENT_ID)`
- **Use Case**: Track appointment trends over time

### Pattern 8: Service Orders vs Trouble Tickets Comparison
- **Dimensions**: `RECORD_TYPE`
- **Metrics**: 
  - `COUNT(DISTINCT SERVICEORDER_ID)` - Number of service orders
  - `COUNT(DISTINCT TROUBLE_TICKET_ID)` - Number of trouble tickets
  - `COUNT(DISTINCT CASE WHEN HAS_APPOINTMENT THEN SERVICEORDER_ID END)` - Service orders with appointments
  - `COUNT(DISTINCT CASE WHEN HAS_APPOINTMENT THEN TROUBLE_TICKET_ID END)` - Trouble tickets with appointments
- **Use Case**: Compare service orders and trouble tickets, with appointment coverage

### Pattern 9: Trouble Tickets Duration Analysis
- **Filter**: `RECORD_TYPE = 'Trouble Ticket'` AND `TOTAL_DURATION_DAYS IS NOT NULL`
- **Dimensions**: `SERVICE_MODEL`, `ACCOUNT_TYPE`, `STATUS`
- **Metrics**: 
  - `AVG(TOTAL_DURATION_DAYS)` - Average duration (days)
  - `SUM(TOTAL_DURATION_DAYS)` - Total duration (days)
  - `COUNT(DISTINCT TROUBLE_TICKET_ID)` - Number of tickets
- **Use Case**: Analyze duration for all trouble tickets (can filter by STATUS to analyze CLOSED vs non-CLOSED separately)

### Pattern 10: Non-CLOSED Trouble Tickets - Open Tasks
- **Filter**: `RECORD_TYPE = 'Trouble Ticket'` AND `STATUS != 'CLOSED'` AND `LATEST_OPEN_TASK_NAME IS NOT NULL`
- **Dimensions**: `LATEST_OPEN_TASK_NAME`, `LATEST_OPEN_TASK_ASSIGNEE`, `STATUS`
- **Metrics**: `COUNT(DISTINCT TROUBLE_TICKET_ID)`
- **Use Case**: Track open tasks and assignments for active trouble tickets
