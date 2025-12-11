# Service Orders and Trouble Tickets with Appointments (Base) - Metabase Model Documentation

## Overview

This model provides a **unified view of all service orders and trouble tickets**, with appointments included when they exist. It uses a UNION ALL architecture to combine service orders and trouble tickets, then enriches them with appointments, feature aggregates, and supporting information.

**Model Type**: BASE MODEL  
**Source Query**: `snowflake/camvio/queries/appointments_with_orders_and_tickets.sql`  
**Database**: Camvio Snowflake (read-only)

## Purpose

This model enables analysis of:
1. **Complete coverage** - All service orders and trouble tickets, regardless of whether they have appointments
2. **Service order analysis** - All service orders with feature pricing aggregates
3. **Trouble ticket analysis** - All trouble tickets with concatenated notes
4. **Appointment enrichment** - Appointments included when they exist (optional)
5. **Unified reporting** - Single model for both service orders and trouble tickets

## Model Structure

### Base Model: "Service Orders and Trouble Tickets with Appointments (Base)"
- **Query**: `appointments_with_orders_and_tickets.sql`
- **Architecture**: UNION ALL of SERVICEORDERS and TROUBLE_TICKETS, then OUTER JOIN to APPOINTMENTS
- **Filters**: 
  - Excludes `SERVICELINE_NUMBER = '0'` or `'0000000000'` (invalid service line numbers)
  - Excludes NULL `SERVICELINE_NUMBER`
- **CTEs**:
  - `base_data`: UNION ALL of service orders and trouble tickets
  - `feature_aggregates`: Aggregated feature pricing for service orders
- **Joins**: 
  - SERVICELINES (LEFT JOIN) - for SERVICE_MODEL
  - SERVICELINE_ADDRESSES (LEFT JOIN) - for address city (primary for both types, since both have SERVICELINE_NUMBER)
  - SERVICEORDER_ADDRESSES (LEFT JOIN) - for address city fallback and SERVICE_MODEL (service orders only)
  - SERVICELINE_FEATURES (aggregated, LEFT JOIN) - feature pricing aggregates for service orders
  - TROUBLE_TICKET_NOTES (aggregated, LEFT JOIN) - concatenated notes for trouble tickets
  - CUSTOMER_ACCOUNTS (LEFT JOIN) - for account type
  - APPOINTMENTS (OUTER JOIN) - when appointments exist

## Important Notes

### Record Type
- **RECORD_TYPE = "Service Order"** → Service order record
  - Includes SERVICEORDER_ID, ORDER_ID, SALES_AGENT, feature aggregates
  - TROUBLE_TICKET_ID, REPORTED_NAME, RESOLUTION_NAME, TROUBLE_TICKET_NOTES are NULL
- **RECORD_TYPE = "Trouble Ticket"** → Trouble ticket record
  - Includes TROUBLE_TICKET_ID, STATUS, REPORTED_NAME, RESOLUTION_NAME, concatenated notes
  - SERVICEORDER_ID, ORDER_ID, SALES_AGENT, feature aggregates are NULL

### Appointment Enrichment
Appointments are **optional enrichment** - they are OUTER JOINed to the base data:
- **HAS_APPOINTMENT = true** → Record has an associated appointment
- **HAS_APPOINTMENT = false** → Record has no appointment
- Appointment fields (APPOINTMENT_ID, APPOINTMENT_DATE, etc.) are NULL when no appointment exists

### Join Strategy for Appointments
The query uses a **dual join strategy** for appointments:
1. **Primary join**: 
   - Service Orders: Uses ORDER_ID
   - Trouble Tickets: Uses TROUBLE_TICKET_ID
2. **Fallback join**: Uses SERVICELINE_NUMBER + ACCOUNT_ID when ID conversion failed

This ensures maximum join success even when ORDER_ID contains invalid values.

### Service Model
`SERVICE_MODEL` comes from different sources based on record type:
- **Service Orders**: From `SERVICEORDER_ADDRESSES.SERVICE_MODEL`
- **Trouble Tickets**: From `SERVICELINES.SERVICE_MODEL`
- The query uses `COALESCE` to get the service model from the appropriate source.

### Feature Aggregates
Feature pricing aggregates are **only populated for service orders that have features**:
- `TOTAL_FEATURE_PRICE` - Sum of (feature price × quantity) for all features
- `TOTAL_FEATURE_AMOUNT` - Sum of (feature price × quantity) for all features (same as TOTAL_FEATURE_PRICE)
- `FEATURE_COUNT` - Number of distinct features
- `TOTAL_FEATURE_QUANTITY` - Total quantity of all features

These fields will be **NULL for**:
- Trouble tickets
- Service orders without features

### Trouble Ticket Notes
`TROUBLE_TICKET_NOTES` contains **concatenated notes per trouble ticket**:
- Notes are aggregated using `LISTAGG` per TROUBLE_TICKET_ID
- Notes are separated by ' | ' (pipe with spaces)
- Only non-empty notes are included
- NULL for service orders

### Data Type Handling
- **ORDER_ID** and **TROUBLE_TICKET_ID**: Numeric (converted from VARCHAR in appointments subquery to handle invalid values)
- **SERVICELINE_NUMBER**: VARCHAR (cast for consistent joins)
- **APPOINTMENT_TYPE**: Normalized to uppercase and trimmed for consistent comparison

## Key Fields

| Field Name | Type | Semantic Type | Description | Notes |
|------------|------|---------------|-------------|-------|
| `RECORD_TYPE` | TEXT | Category | Record type ("Service Order" or "Trouble Ticket") | Distinguishes the source |
| `ACCOUNT_ID` | NUMBER | Entity Key | Account identifier | Common field (available for both types) |
| `SERVICELINE_NUMBER` | TEXT | Entity Key | Service line number (VARCHAR) | Common field (available for both types) |
| `SERVICEORDER_ID` | NUMBER | Entity Key | Service order identifier | Only populated when RECORD_TYPE = "Service Order" |
| `ORDER_ID` | NUMBER | Entity Key | Order identifier | Only populated when RECORD_TYPE = "Service Order" |
| `STATUS` | TEXT | Category | Status | Service order status or trouble ticket status |
| `SERVICEORDER_TYPE` | TEXT | Category | Service order type | Only populated when RECORD_TYPE = "Service Order" |
| `SALES_AGENT` | TEXT | Entity Name | Sales agent for commissions | ⭐ Required for commission calculations, only populated when RECORD_TYPE = "Service Order" |
| `TROUBLE_TICKET_ID` | NUMBER | Entity Key | Trouble ticket identifier | Only populated when RECORD_TYPE = "Trouble Ticket" |
| `REPORTED_NAME` | TEXT | Entity Name | Name of person who reported the trouble ticket | Only populated when RECORD_TYPE = "Trouble Ticket" |
| `RESOLUTION_NAME` | TEXT | Entity Name | Name of person who resolved the trouble ticket | Only populated when RECORD_TYPE = "Trouble Ticket" |
| `TROUBLE_TICKET_NOTES` | TEXT | Description | Concatenated notes per trouble ticket | Only populated when RECORD_TYPE = "Trouble Ticket" |
| `TOTAL_DURATION_DAYS` | NUMBER | Duration | Total duration in days | Available for all trouble tickets. For non-CLOSED: days from CREATED_DATETIME to TODAY. For CLOSED: days from CREATED_DATETIME to latest TASK_ENDED |
| `LATEST_OPEN_TASK_NAME` | TEXT | Category | Name of the latest open task | Only populated for non-CLOSED trouble tickets |
| `LATEST_OPEN_TASK_ASSIGNEE` | TEXT | Entity Name | Assignee of the latest open task | Only populated for non-CLOSED trouble tickets |
| `LATEST_OPEN_TASK_STARTED` | TIMESTAMP | Creation Timestamp | Start date/time of the latest open task | Only populated for non-CLOSED trouble tickets |
| `SERVICE_MODEL` | TEXT | Category | Service model | SERVICEORDER_ADDRESSES for service orders, SERVICELINES for trouble tickets |
| `ADDRESS_CITY` | TEXT | City | Address city | SERVICELINE_ADDRESS_CITY for both types (serviceline level), SERVICEORDER_ADDRESS_CITY as fallback for service orders |
| `CREATED_DATETIME` | TIMESTAMP | Creation Timestamp | Record creation date/time | From SERVICEORDERS for service orders, TROUBLE_TICKETS for trouble tickets |
| `MODIFIED_DATETIME` | TIMESTAMP | Modification Timestamp | Record last modification date/time | From SERVICEORDERS for service orders, TROUBLE_TICKETS for trouble tickets |
| `SERVICELINE_CREATED_DATETIME` | TIMESTAMP | Creation Timestamp | Service line creation date/time | From SERVICELINES.SERVICELINE_STARTDATE (available for both service orders and trouble tickets via SERVICELINE_NUMBER) |
| `ACCOUNT_TYPE` | TEXT | Category | Account type classification | From CUSTOMER_ACCOUNTS |
| `TOTAL_FEATURE_PRICE` | NUMBER | Currency | Sum of (feature price × quantity) | Only populated for service orders with features |
| `TOTAL_FEATURE_AMOUNT` | NUMBER | Currency | Sum of (feature price × quantity) | Only populated for service orders with features |
| `FEATURE_COUNT` | NUMBER | Quantity | Number of distinct features | Only populated for service orders with features |
| `TOTAL_FEATURE_QUANTITY` | NUMBER | Quantity | Total quantity of all features | Only populated for service orders with features |
| `APPOINTMENT_ID` | NUMBER | Entity Key | Unique appointment identifier | NULL when no appointment exists |
| `APPOINTMENT_TYPE` | TEXT | Category | Appointment type ("O" or "TT") | NULL when no appointment exists |
| `APPOINTMENT_TYPE_DESCRIPTION` | TEXT | Description | Description of appointment type | NULL when no appointment exists |
| `APPOINTMENT_DATE` | DATE | Creation Timestamp | Date of the appointment | NULL when no appointment exists |
| `APPOINTMENT_ORDER_ID` | NUMBER | Entity Key | Order ID from appointments | NULL when no appointment exists |
| `APPOINTMENT_TROUBLE_TICKET_ID` | NUMBER | Entity Key | Trouble ticket ID from appointments | NULL when no appointment exists |
| `HAS_APPOINTMENT` | BOOLEAN | Boolean | Whether an appointment exists for this record | Use to filter records with/without appointments |

### Entity Keys
- `SERVICEORDER_ID` - Service order identifier (service orders only)
- `TROUBLE_TICKET_ID` - Trouble ticket identifier (trouble tickets only)
- `ORDER_ID` - Order identifier (service orders only)
- `ACCOUNT_ID` - Account identifier (common)
- `SERVICELINE_NUMBER` - Service line number (common)
- `APPOINTMENT_ID` - Appointment identifier (when appointment exists)

### Important Dimensions
- `RECORD_TYPE` - "Service Order" or "Trouble Ticket" (primary dimension)
- `HAS_APPOINTMENT` - Whether appointment exists (for filtering)
- `ACCOUNT_TYPE` - Account type classification
- `SERVICE_MODEL` - Service model from service line
- `STATUS` - Service order or trouble ticket status

### Important Metrics
- `TOTAL_FEATURE_PRICE` - Total feature pricing (service orders only)
- `TOTAL_FEATURE_AMOUNT` - Total feature amount (price × qty) (service orders only)
- `FEATURE_COUNT` - Number of features (service orders only)

## Tables/Views Used

### SERVICEORDERS (alias: `so`)
**Full Name**: `CAMVIO.PUBLIC.SERVICEORDERS`  
**Purpose**: Service order information (first part of UNION ALL)

**Key Columns**:
- `SERVICEORDER_ID` - Service order identifier
- `ORDER_ID` - Order identifier
- `STATUS` - Service order status
- `SERVICEORDER_TYPE` - Type of service order
- `SALES_AGENT` - Sales agent for commissions
- `SERVICELINE_NUMBER` - Service line number (join key)
- `CREATED_DATETIME` - Service order creation date/time
- `MODIFIED_DATETIME` - Service order last modification date/time

**Filtering**: Excludes `SERVICELINE_NUMBER = '0'` or `'0000000000'`

### TROUBLE_TICKETS (alias: `tt`)
**Full Name**: `CAMVIO.PUBLIC.TROUBLE_TICKETS`  
**Purpose**: Trouble ticket information (second part of UNION ALL)

**Key Columns**:
- `TROUBLE_TICKET_ID` - Trouble ticket identifier
- `STATUS` - Trouble ticket status
- `REPORTED_NAME` - Name of person who reported the ticket
- `RESOLUTION_NAME` - Name of person who resolved the ticket
- `SERVICELINE_NUMBER` - Service line number (join key)
- `CREATED_DATETIME` - Trouble ticket creation date/time
- `MODIFIED_DATETIME` - Trouble ticket last modification date/time

**Filtering**: Excludes `SERVICELINE_NUMBER = '0'` or `'0000000000'`

### TROUBLE_TICKET_NOTES (alias: `ttn`)
**Full Name**: `CAMVIO.PUBLIC.TROUBLE_TICKET_NOTES`  
**Purpose**: Notes associated with trouble tickets (aggregated)

**Join**: LEFT JOIN on `tt.TROUBLE_TICKET_ID = ttn.TROUBLE_TICKET_ID`

**Aggregation**: `LISTAGG(NOTE, ' | ') WITHIN GROUP (ORDER BY CREATED_DATETIME)` per TROUBLE_TICKET_ID

**Key Fields**:
- `TROUBLE_TICKET_ID` - Join key
- `NOTE` - Note text (concatenated)
- `CREATED_DATETIME` - Note creation date (used for ordering)

### SERVICELINES (alias: `sl`)
**Full Name**: `CAMVIO.PUBLIC.SERVICELINES`  
**Purpose**: Service line information, including SERVICE_MODEL (for trouble tickets, fallback for service orders) and SERVICELINE_STARTDATE (creation date)

**Join**: LEFT JOIN on `bd.SERVICELINE_NUMBER = sl.SERVICELINE_NUMBER`

**Key Fields**:
- `SERVICELINE_NUMBER` - Join key
- `SERVICE_MODEL` - Service model type (used for trouble tickets)
- `SERVICELINE_STARTDATE` - Service line creation date (available for both service orders and trouble tickets)

### SERVICEORDER_ADDRESSES (alias: `soa`)
**Full Name**: `CAMVIO.PUBLIC.SERVICEORDER_ADDRESSES`  
**Purpose**: Service order address information (for service orders only)

**Join**: LEFT JOIN on `bd.RECORD_TYPE = 'Service Order' AND bd.SERVICEORDER_ID = soa.SERVICEORDER_ID`

**Key Fields**:
- `SERVICEORDER_ID` - Join key
- `SERVICE_MODEL` - Service model type (used for service orders)
- `SERVICEORDER_ADDRESS_CITY` - City of the service order address

### SERVICELINE_ADDRESSES (alias: `sla`)
**Full Name**: `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES`  
**Purpose**: Service line address information (primary source for both service orders and trouble tickets, since both have SERVICELINE_NUMBER)

**Join**: LEFT JOIN on `bd.SERVICELINE_NUMBER = sla.SERVICELINE_NUMBER` (for all record types)

**Key Fields**:
- `SERVICELINE_NUMBER` - Join key
- `SERVICELINE_ADDRESS_CITY` - City of the service line address

**Note**: The query uses:
- `COALESCE(soa.SERVICE_MODEL, sl.SERVICE_MODEL)` to get the service model from SERVICEORDER_ADDRESSES for service orders, or SERVICELINES for trouble tickets
- `COALESCE(sla.SERVICELINE_ADDRESS_CITY, soa.SERVICEORDER_ADDRESS_CITY)` to get the city from SERVICELINE_ADDRESSES first (for both types), with SERVICEORDER_ADDRESSES as fallback for service orders

### Feature Aggregates (alias: `fa`)
**Source**: Aggregated from `CAMVIO.PUBLIC.SERVICELINE_FEATURES`  
**Purpose**: Feature pricing aggregates by service line

**Join**: LEFT JOIN on `bd.RECORD_TYPE = 'Service Order' AND bd.SERVICELINE_NUMBER = fa.SERVICELINE_NUMBER`

**Aggregations**:
- `TOTAL_FEATURE_PRICE` - SUM of (FEATURE_PRICE × QTY)
- `TOTAL_FEATURE_AMOUNT` - SUM of (FEATURE_PRICE × QTY)
- `FEATURE_COUNT` - COUNT(DISTINCT FEATURE)
- `TOTAL_FEATURE_QUANTITY` - SUM of QTY

**Note**: Only populated when service orders have features

### APPOINTMENTS (alias: `a`)
**Full Name**: `CAMVIO.PUBLIC.APPOINTMENTS`  
**Purpose**: Appointment information (optional enrichment)

**Join**: OUTER JOIN using ORDER_ID (for service orders) or TROUBLE_TICKET_ID (for trouble tickets), with fallback to SERVICELINE_NUMBER + ACCOUNT_ID

**Key Columns**:
- `APPOINTMENT_ID` - Unique appointment identifier
- `APPOINTMENT_TYPE` - "O" (letter O) for service orders, "TT" for trouble tickets
- `APPOINTMENT_DATE` - Date of the appointment
- `ORDER_ID` - Order ID (for service order appointments)
- `TROUBLE_TICKET_ID` - Trouble ticket ID (for trouble ticket appointments)

**Note**: All appointment fields are NULL when no appointment exists

## Related Documentation

- **Semantic Types**: See [`APPOINTMENTS_WITH_ORDERS_AND_TICKETS_SEMANTIC_TYPES.md`](./APPOINTMENTS_WITH_ORDERS_AND_TICKETS_SEMANTIC_TYPES.md)
- **Column Mapping**: See [`APPOINTMENTS_WITH_ORDERS_AND_TICKETS_COLUMN_MAPPING.md`](./APPOINTMENTS_WITH_ORDERS_AND_TICKETS_COLUMN_MAPPING.md) (to be created if needed)

## Usage Examples

### Example Query 1: All Service Orders and Trouble Tickets
Analyze all records by type:
- **Dimensions**: `RECORD_TYPE`, `ACCOUNT_TYPE`
- **Metrics**: `COUNT(DISTINCT SERVICEORDER_ID)`, `COUNT(DISTINCT TROUBLE_TICKET_ID)`
- **Use Case**: Understand distribution of service orders vs trouble tickets

### Example Query 2: Service Orders with Features
Analyze service orders with feature pricing:
- **Filter**: `RECORD_TYPE = 'Service Order'` AND `TOTAL_FEATURE_PRICE IS NOT NULL`
- **Dimensions**: `SERVICE_MODEL`, `SERVICEORDER_TYPE`
- **Metrics**: 
  - `COUNT(DISTINCT SERVICEORDER_ID)` - Number of service orders
  - `SUM(TOTAL_FEATURE_PRICE)` - Total feature pricing
  - `AVG(TOTAL_FEATURE_PRICE)` - Average feature pricing per service order

### Example Query 3: Records with Appointments
Identify records that have appointments:
- **Filter**: `HAS_APPOINTMENT = true`
- **Dimensions**: `RECORD_TYPE`, `APPOINTMENT_TYPE`
- **Metrics**: `COUNT(DISTINCT SERVICEORDER_ID)`, `COUNT(DISTINCT TROUBLE_TICKET_ID)`
- **Use Case**: Understand appointment coverage

### Example Query 4: Records without Appointments
Identify records missing appointments:
- **Filter**: `HAS_APPOINTMENT = false`
- **Dimensions**: `RECORD_TYPE`, `ACCOUNT_TYPE`
- **Metrics**: `COUNT(DISTINCT SERVICEORDER_ID)`, `COUNT(DISTINCT TROUBLE_TICKET_ID)`
- **Use Case**: Identify records that need appointments

### Example Query 5: Feature Pricing by Service Model
Analyze feature pricing by service model:
- **Filter**: `RECORD_TYPE = 'Service Order'` AND `SERVICE_MODEL IS NOT NULL` AND `TOTAL_FEATURE_PRICE IS NOT NULL`
- **Dimensions**: `SERVICE_MODEL`
- **Metrics**: 
  - `SUM(TOTAL_FEATURE_PRICE)` - Total pricing
  - `SUM(TOTAL_FEATURE_AMOUNT)` - Total amount
  - `AVG(FEATURE_COUNT)` - Average features per service order
- **Use Case**: Understand feature pricing across service models

### Example Query 6: Trouble Tickets with Notes
Analyze trouble tickets with notes:
- **Filter**: `RECORD_TYPE = 'Trouble Ticket'` AND `TROUBLE_TICKET_NOTES IS NOT NULL`
- **Dimensions**: `STATUS`, `REPORTED_NAME`
- **Metrics**: `COUNT(DISTINCT TROUBLE_TICKET_ID)`
- **Use Case**: Understand trouble ticket documentation

### Example Query 7: Appointment Dates Analysis
Analyze appointments by date:
- **Filter**: `HAS_APPOINTMENT = true`
- **Dimensions**: 
  - `YEAR(APPOINTMENT_DATE)`, `MONTH(APPOINTMENT_DATE)`
  - `RECORD_TYPE`
- **Metrics**: `COUNT(DISTINCT APPOINTMENT_ID)`
- **Use Case**: Track appointment trends over time

### Example Query 8: Records by Creation Date
Analyze records by creation date:
- **Dimensions**: 
  - `YEAR(CREATED_DATETIME)`, `MONTH(CREATED_DATETIME)`
  - `RECORD_TYPE`
- **Metrics**: `COUNT(DISTINCT SERVICEORDER_ID)`, `COUNT(DISTINCT TROUBLE_TICKET_ID)`
- **Use Case**: Track service order and trouble ticket creation trends over time

### Example Query 9: Service Line vs Record Creation Date Comparison
Compare serviceline creation date with record creation date (useful for trouble tickets):
- **Filter**: `RECORD_TYPE = 'Trouble Ticket'` (or `RECORD_TYPE = 'Service Order'`)
- **Dimensions**: 
  - `YEAR(SERVICELINE_CREATED_DATETIME)`, `YEAR(CREATED_DATETIME)`
  - `RECORD_TYPE`
- **Metrics**: `COUNT(DISTINCT TROUBLE_TICKET_ID)` or `COUNT(DISTINCT SERVICEORDER_ID)`
- **Custom Column**: Calculate days between `SERVICELINE_CREATED_DATETIME` and `CREATED_DATETIME`
- **Use Case**: Understand time between serviceline creation and trouble ticket/service order creation

## Notes

- **Record Type**: Use `RECORD_TYPE` to distinguish between service orders and trouble tickets
- **Appointment Coverage**: Use `HAS_APPOINTMENT` to identify records with/without appointments
- **SERVICE_MODEL**: Available for both service orders and trouble tickets with service lines
- **Feature Aggregates**: Only populated for service orders that have features - will be NULL for trouble tickets or service orders without features
- **Trouble Ticket Notes**: Concatenated per trouble ticket ID, separated by ' | '
- **SERVICELINE_NUMBER Filtering**: Invalid service line numbers ('0', '0000000000') are excluded
- **Dual Join Strategy**: The query uses both ORDER_ID/TROUBLE_TICKET_ID and SERVICELINE_NUMBER + ACCOUNT_ID to maximize appointment join success
- **Data Type Handling**: ORDER_ID and TROUBLE_TICKET_ID are converted from VARCHAR to NUMBER in appointments subquery, with invalid values becoming NULL
- **Complete Coverage**: This model includes ALL service orders and trouble tickets, not just those with appointments
