# Appointments with Orders and Tickets (Base) - Metabase Model Documentation

## Overview

This model provides a unified view of **all appointments** with their associated service orders or trouble tickets. It combines appointment data with related service order or trouble ticket information, including feature pricing aggregates for service orders.

**Model Type**: BASE MODEL  
**Source Query**: `snowflake/camvio/queries/appointments_with_orders_and_tickets.sql`  
**Database**: Camvio Snowflake (read-only)

## Purpose

This model enables analysis of:
1. **Appointment tracking** - All appointments with their related service orders or trouble tickets
2. **Service order appointments** - Appointments linked to service orders (APPOINTMENT_TYPE = "O")
3. **Trouble ticket appointments** - Appointments linked to trouble tickets (APPOINTMENT_TYPE = "TT")
4. **Feature pricing** - Total feature prices and amounts by service model for service order appointments
5. **Appointment-to-order/ticket relationships** - Track which appointments successfully joined to their related records

## Model Structure

### Base Model: "Appointments with Orders and Tickets (Base)"
- **Query**: `appointments_with_orders_and_tickets.sql`
- **Filters**: 
  - Excludes `SERVICELINE_NUMBER = '0'` or `'0000000000'` (invalid service line numbers)
  - Excludes NULL `SERVICELINE_NUMBER`
- **Joins**: 
  - CUSTOMER_ACCOUNTS (LEFT JOIN) - for account type
  - SERVICEORDERS (LEFT JOIN) - when APPOINTMENT_TYPE = "O"
  - SERVICELINES (LEFT JOIN) - for SERVICE_MODEL (always available for service orders with service lines)
  - SERVICELINE_ADDRESSES (LEFT JOIN) - for address information (city)
  - SERVICELINE_FEATURES (aggregated, LEFT JOIN) - feature pricing aggregates for service orders with features
  - TROUBLE_TICKETS (LEFT JOIN) - when APPOINTMENT_TYPE = "TT"

## Important Notes

### Appointment Type Logic
- **APPOINTMENT_TYPE = "O"** (letter O) → Related to Service Order
  - Joins via `ORDER_ID` (primary) or `SERVICELINE_NUMBER + ACCOUNT_ID` (fallback)
  - Includes feature aggregates (TOTAL_FEATURE_PRICE, etc.)
- **APPOINTMENT_TYPE = "TT"** → Related to Trouble Ticket
  - Joins via `TROUBLE_TICKET_ID` (primary) or `SERVICELINE_NUMBER + ACCOUNT_ID` (fallback)
  - Feature aggregates will be NULL

### Join Strategy
The query uses a **dual join strategy**:
1. **Primary join**: Uses ORDER_ID or TROUBLE_TICKET_ID when available
2. **Fallback join**: Uses SERVICELINE_NUMBER + ACCOUNT_ID when ID conversion fails

This ensures maximum join success even when ORDER_ID contains invalid values.

### Service Model
`SERVICE_MODEL` comes from the **SERVICELINES table** and is **always available for service order appointments** that have a service line, even if they don't have features. This ensures SERVICE_MODEL is populated whenever a service order has a service line.

### Feature Aggregates
Feature pricing aggregates are **only populated for service order appointments that have features**:
- `TOTAL_FEATURE_PRICE` - Sum of (feature price × quantity) for all features
- `TOTAL_FEATURE_AMOUNT` - Sum of (feature price × quantity) for all features (same as TOTAL_FEATURE_PRICE)
- `FEATURE_COUNT` - Number of distinct features
- `TOTAL_FEATURE_QUANTITY` - Total quantity of all features

These fields will be **NULL for**:
- Trouble ticket appointments
- Service order appointments without features

### Data Type Handling
- **ORDER_ID** and **TROUBLE_TICKET_ID**: Numeric (converted from VARCHAR in subquery to handle invalid values)
- **SERVICELINE_NUMBER**: VARCHAR (cast for consistent fallback joins)
- **APPOINTMENT_TYPE**: Normalized to uppercase and trimmed for consistent comparison

## Key Fields

| Field Name | Type | Semantic Type | Description | Notes |
|------------|------|---------------|-------------|-------|
| `APPOINTMENT_ID` | NUMBER | Entity Key | Unique appointment identifier | Primary key |
| `APPOINTMENT_TYPE` | TEXT | Category | Appointment type ("O" or "TT") | Normalized to uppercase |
| `APPOINTMENT_TYPE_DESCRIPTION` | TEXT | Description | Description of appointment type | |
| `APPOINTMENT_DATE` | DATE | Creation Timestamp | Date of the appointment | |
| `ORDER_ID` | NUMBER | Entity Key | Order ID from appointments table | May be NULL for trouble ticket appointments |
| `TROUBLE_TICKET_ID` | NUMBER | Entity Key | Trouble ticket ID from appointments table | May be NULL for service order appointments |
| `ACCOUNT_ID` | NUMBER | Entity Key | Account identifier | |
| `SERVICELINE_NUMBER` | TEXT | Entity Key | Service line number (VARCHAR) | Used for fallback joins |
| `SO_ORDER_ID` | NUMBER | Entity Key | Service order ORDER_ID | Only populated when APPOINTMENT_TYPE = "O" |
| `SERVICEORDER_ID` | NUMBER | Entity Key | Service order identifier | Only populated when APPOINTMENT_TYPE = "O" |
| `SO_STATUS` | TEXT | Category | Service order status | Only populated when APPOINTMENT_TYPE = "O" |
| `SO_SERVICEORDER_TYPE` | TEXT | Category | Service order type | Only populated when APPOINTMENT_TYPE = "O" |
| `TT_TROUBLE_TICKET_ID` | NUMBER | Entity Key | Trouble ticket ID | Only populated when APPOINTMENT_TYPE = "TT" |
| `TT_STATUS` | TEXT | Category | Trouble ticket status | Only populated when APPOINTMENT_TYPE = "TT" |
| `SERVICE_MODEL` | TEXT | Category | Service model from service line | Always populated for service orders with service lines |
| `SERVICELINE_ADDRESS_CITY` | TEXT | City | Service line address city | Only populated for service orders with address information |
| `TOTAL_FEATURE_PRICE` | NUMBER | Currency | Sum of all feature prices | Only populated for service orders with features |
| `TOTAL_FEATURE_AMOUNT` | NUMBER | Currency | Sum of (feature price × quantity) | Only populated for service orders with features |
| `FEATURE_COUNT` | NUMBER | Quantity | Number of distinct features | Only populated for service orders with features |
| `TOTAL_FEATURE_QUANTITY` | NUMBER | Quantity | Total quantity of all features | Only populated for service orders with features |
| `ACCOUNT_TYPE` | TEXT | Category | Account type | From CUSTOMER_ACCOUNTS |
| `APPOINTMENT_RELATION_TYPE` | TEXT | Category | Human-readable type ("Service Order" or "Trouble Ticket") | |
| `HAS_RELATED_RECORD` | BOOLEAN | Boolean | Whether join to service order/trouble ticket succeeded | |

### Entity Keys
- `APPOINTMENT_ID` - Unique appointment identifier (primary key)
- `ORDER_ID` - Order ID from appointments (may be NULL for trouble tickets)
- `TROUBLE_TICKET_ID` - Trouble ticket ID from appointments (may be NULL for service orders)
- `SERVICEORDER_ID` - Service order identifier (only for service order appointments)
- `TT_TROUBLE_TICKET_ID` - Trouble ticket identifier (only for trouble ticket appointments)
- `ACCOUNT_ID` - Account identifier

### Important Dimensions
- `APPOINTMENT_TYPE` - "O" for service orders, "TT" for trouble tickets
- `APPOINTMENT_RELATION_TYPE` - Human-readable type indicator
- `ACCOUNT_TYPE` - Account type classification
- `SERVICE_MODEL` - Service model from service line (service orders with service lines only)

### Important Metrics
- `TOTAL_FEATURE_PRICE` - Total feature pricing (service orders only)
- `TOTAL_FEATURE_AMOUNT` - Total feature amount (price × qty) (service orders only)
- `FEATURE_COUNT` - Number of features (service orders only)

## Tables/Views Used

### APPOINTMENTS (alias: `a`)
**Full Name**: `CAMVIO.PUBLIC.APPOINTMENTS`  
**Purpose**: Base table containing all appointment information

**Key Columns**:
- `APPOINTMENT_ID` - Unique appointment identifier
- `APPOINTMENT_TYPE` - "O" (letter O) for service orders, "TT" for trouble tickets
- `ORDER_ID` - Order ID (may contain invalid values, converted to NULL)
- `TROUBLE_TICKET_ID` - Trouble ticket ID
- `SERVICELINE_NUMBER` - Service line number (cast to VARCHAR)

**Filtering**: Excludes `SERVICELINE_NUMBER = '0'` or `'0000000000'`

### SERVICEORDERS (alias: `so`)
**Full Name**: `CAMVIO.PUBLIC.SERVICEORDERS`  
**Purpose**: Service order information (joined when APPOINTMENT_TYPE = "O")

**Join**: LEFT JOIN on ORDER_ID (primary) or SERVICELINE_NUMBER + ACCOUNT_ID (fallback)

**Key Columns**:
- `SERVICEORDER_ID` - Service order identifier
- `ORDER_ID` - Order identifier
- `STATUS` - Service order status
- `SERVICEORDER_TYPE` - Type of service order

### TROUBLE_TICKETS (alias: `tt`)
**Full Name**: `CAMVIO.PUBLIC.TROUBLE_TICKETS`  
**Purpose**: Trouble ticket information (joined when APPOINTMENT_TYPE = "TT")

**Join**: LEFT JOIN on TROUBLE_TICKET_ID (primary) or SERVICELINE_NUMBER + ACCOUNT_ID (fallback)

**Key Columns**:
- `TROUBLE_TICKET_ID` - Trouble ticket identifier
- `STATUS` - Trouble ticket status

### SERVICELINES (alias: `sl`)
**Full Name**: `CAMVIO.PUBLIC.SERVICELINES`  
**Purpose**: Service line information, including SERVICE_MODEL

**Join**: LEFT JOIN on `so.SERVICELINE_NUMBER = sl.SERVICELINE_NUMBER`

**Key Fields**:
- `SERVICELINE_NUMBER` - Join key
- `SERVICE_MODEL` - Service model type (always available for service orders with service lines)

### SERVICELINE_ADDRESSES (alias: `sa`)
**Full Name**: `CAMVIO.PUBLIC.SERVICELINE_ADDRESSES`  
**Purpose**: Service line address information

**Join**: LEFT JOIN on `so.SERVICELINE_NUMBER = sa.SERVICELINE_NUMBER`

**Key Fields**:
- `SERVICELINE_NUMBER` - Join key
- `SERVICELINE_ADDRESS_CITY` - City of the service line address

### Feature Aggregates (alias: `fa`)
**Source**: Aggregated from `CAMVIO.PUBLIC.SERVICELINE_FEATURES`  
**Purpose**: Feature pricing aggregates by service line

**Join**: LEFT JOIN on `so.SERVICELINE_NUMBER = fa.SERVICELINE_NUMBER`

**Aggregations**:
- `TOTAL_FEATURE_PRICE` - SUM of FEATURE_PRICE
- `TOTAL_FEATURE_AMOUNT` - SUM of (FEATURE_PRICE × QTY)
- `FEATURE_COUNT` - COUNT(DISTINCT FEATURE)
- `TOTAL_FEATURE_QUANTITY` - SUM of QTY

**Note**: Only populated when service orders have features

## Related Documentation

- **Semantic Types**: See [`APPOINTMENTS_WITH_ORDERS_AND_TICKETS_SEMANTIC_TYPES.md`](./APPOINTMENTS_WITH_ORDERS_AND_TICKETS_SEMANTIC_TYPES.md)
- **Column Mapping**: See [`APPOINTMENTS_WITH_ORDERS_AND_TICKETS_COLUMN_MAPPING.md`](./APPOINTMENTS_WITH_ORDERS_AND_TICKETS_COLUMN_MAPPING.md) (to be created if needed)

## Usage Examples

### Example Query 1: Appointments by Type
Analyze appointments by type:
- **Dimensions**: `APPOINTMENT_RELATION_TYPE`, `ACCOUNT_TYPE`
- **Metrics**: `COUNT(DISTINCT APPOINTMENT_ID)`
- **Use Case**: Understand distribution of service order vs trouble ticket appointments

### Example Query 2: Service Order Appointments with Features
Analyze service order appointments with feature pricing:
- **Filter**: `APPOINTMENT_TYPE = 'O'` AND `TOTAL_FEATURE_PRICE IS NOT NULL`
- **Dimensions**: `SERVICE_MODEL`, `SO_SERVICEORDER_TYPE`
- **Metrics**: 
  - `COUNT(DISTINCT APPOINTMENT_ID)` - Number of appointments
  - `SUM(TOTAL_FEATURE_PRICE)` - Total feature pricing
  - `AVG(TOTAL_FEATURE_PRICE)` - Average feature pricing per appointment

### Example Query 3: Failed Joins
Identify appointments that didn't join successfully:
- **Filter**: `HAS_RELATED_RECORD = false`
- **Dimensions**: `APPOINTMENT_TYPE`, `ACCOUNT_TYPE`
- **Metrics**: `COUNT(DISTINCT APPOINTMENT_ID)`
- **Use Case**: Identify data quality issues or missing relationships

### Example Query 4: Appointment-to-Order Analysis
Track appointments and their related service orders:
- **Filter**: `APPOINTMENT_TYPE = 'O'`
- **Dimensions**: `SO_STATUS`, `SO_SERVICEORDER_TYPE`
- **Metrics**: `COUNT(DISTINCT APPOINTMENT_ID)`, `COUNT(DISTINCT SERVICEORDER_ID)`
- **Use Case**: Understand appointment-to-order relationships

### Example Query 5: Feature Pricing by Service Model
Analyze feature pricing by service model:
- **Filter**: `APPOINTMENT_TYPE = 'O'` AND `SERVICE_MODEL IS NOT NULL` AND `TOTAL_FEATURE_PRICE IS NOT NULL`
- **Dimensions**: `SERVICE_MODEL`
- **Metrics**: 
  - `SUM(TOTAL_FEATURE_PRICE)` - Total pricing
  - `SUM(TOTAL_FEATURE_AMOUNT)` - Total amount (price × qty)
  - `AVG(FEATURE_COUNT)` - Average features per appointment
- **Use Case**: Understand feature pricing across service models

### Example Query 6: Appointment Dates Analysis
Analyze appointments by date:
- **Dimensions**: 
  - `YEAR(APPOINTMENT_DATE)`, `MONTH(APPOINTMENT_DATE)`
  - `APPOINTMENT_RELATION_TYPE`
- **Metrics**: `COUNT(DISTINCT APPOINTMENT_ID)`
- **Use Case**: Track appointment trends over time

## Notes

- **Appointment Type**: APPOINTMENT_TYPE is normalized to uppercase ("O" or "TT") for consistent comparison
- **Join Success**: Use `HAS_RELATED_RECORD` to identify appointments that successfully joined to their related records
- **SERVICE_MODEL**: Always available for service order appointments with service lines (from SERVICELINES table), even if they don't have features
- **Feature Aggregates**: Only populated for service order appointments that have features - will be NULL for trouble tickets or service orders without features
- **SERVICELINE_NUMBER Filtering**: Invalid service line numbers ('0', '0000000000') are excluded
- **Dual Join Strategy**: The query uses both ORDER_ID/TROUBLE_TICKET_ID and SERVICELINE_NUMBER + ACCOUNT_ID to maximize join success
- **Data Type Handling**: ORDER_ID and TROUBLE_TICKET_ID are converted from VARCHAR to NUMBER, with invalid values becoming NULL
