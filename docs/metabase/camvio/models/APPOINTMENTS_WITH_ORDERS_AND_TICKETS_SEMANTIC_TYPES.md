# Appointments with Orders and Tickets (Base) - Semantic Types

## Overview

Semantic types in Metabase help the system understand what kind of data each column contains, enabling better visualizations, filtering, and data exploration. This document specifies the recommended semantic types for each column in the **Appointments with Orders and Tickets (Base)** model.

**Model**: Appointments with Orders and Tickets (Base)  
**Source**: `snowflake/camvio/queries/appointments_with_orders_and_tickets.sql`  
**Database**: Camvio Snowflake (read-only)

## Column Semantic Types

### Appointment Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `APPOINTMENT_ID` | `a.APPOINTMENT_ID` | **Entity Key** | Unique appointment identifier | Primary key for appointments |
| `APPOINTMENT_TYPE` | `a.APPOINTMENT_TYPE` | **Category** | Appointment type ("O" or "TT") | Normalized to uppercase in query |
| `APPOINTMENT_TYPE_DESCRIPTION` | `a.APPOINTMENT_TYPE_DESCRIPTION` | **Description** | Description of appointment type | Text description field |
| `APPOINTMENT_DATE` | `a.APPOINTMENT_DATE` | **Creation Timestamp** | Date of the appointment | Use for date-based filtering and grouping |
| `ORDER_ID` | `a.ORDER_ID` | **Entity Key** | Order ID from appointments table | May be NULL for trouble ticket appointments |
| `TROUBLE_TICKET_ID` | `a.TROUBLE_TICKET_ID` | **Entity Key** | Trouble ticket ID from appointments table | May be NULL for service order appointments |
| `ACCOUNT_ID` | `a.ACCOUNT_ID` | **Entity Key** | Account identifier | Primary key for customer accounts |
| `SERVICELINE_NUMBER` | `a.SERVICELINE_NUMBER` | **Entity Key** | Service line number (VARCHAR) | Used for fallback joins, cast to VARCHAR |

### Service Order Fields (populated when APPOINTMENT_TYPE = "O")

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `SERVICEORDER_ID` | `so.SERVICEORDER_ID` | **Entity Key** | Service order identifier | Only populated when APPOINTMENT_TYPE = "O" |
| `SO_ORDER_ID` | `so.ORDER_ID` | **Entity Key** | Service order ORDER_ID | Only populated when APPOINTMENT_TYPE = "O" |
| `SO_STATUS` | `so.STATUS` | **Category** | Service order status | Only populated when APPOINTMENT_TYPE = "O" |
| `SO_SERVICEORDER_TYPE` | `so.SERVICEORDER_TYPE` | **Category** | Service order type | Only populated when APPOINTMENT_TYPE = "O" |
| `SO_SERVICELINE_NUMBER` | `so.SERVICELINE_NUMBER` | **Entity Key** | Service order service line number | VARCHAR, only populated when APPOINTMENT_TYPE = "O" |
| `SO_ACCOUNT_ID` | `so.ACCOUNT_ID` | **Entity Key** | Service order account ID | Only populated when APPOINTMENT_TYPE = "O" |
| `SERVICE_MODEL` | `sl.SERVICE_MODEL` | **Category** | Service model from service line | Always populated for service orders with service lines |
| `SERVICELINE_ADDRESS_CITY` | `sa.SERVICELINE_ADDRESS_CITY` | **City** | Service line address city | Only populated for service orders with address information |

### Feature Aggregate Fields (service orders with features only)

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `TOTAL_FEATURE_PRICE` | `fa.TOTAL_FEATURE_PRICE` | **Currency** | Sum of all feature prices | Only populated for service orders with features |
| `TOTAL_FEATURE_AMOUNT` | `fa.TOTAL_FEATURE_AMOUNT` | **Currency** | Sum of (feature price × quantity) | Only populated for service orders with features |
| `FEATURE_COUNT` | `fa.FEATURE_COUNT` | **Quantity** | Number of distinct features | Only populated for service orders with features |
| `TOTAL_FEATURE_QUANTITY` | `fa.TOTAL_FEATURE_QUANTITY` | **Quantity** | Total quantity of all features | Only populated for service orders with features |

### Trouble Ticket Fields (populated when APPOINTMENT_TYPE = "TT")

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `TT_TROUBLE_TICKET_ID` | `tt.TROUBLE_TICKET_ID` | **Entity Key** | Trouble ticket identifier | Only populated when APPOINTMENT_TYPE = "TT" |
| `TT_STATUS` | `tt.STATUS` | **Category** | Trouble ticket status | Only populated when APPOINTMENT_TYPE = "TT" |
| `TT_SERVICELINE_NUMBER` | `tt.SERVICELINE_NUMBER` | **Entity Key** | Trouble ticket service line number | VARCHAR, only populated when APPOINTMENT_TYPE = "TT" |
| `TT_ACCOUNT_ID` | `tt.ACCOUNT_ID` | **Entity Key** | Trouble ticket account ID | Only populated when APPOINTMENT_TYPE = "TT" |

### Common Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `ACCOUNT_TYPE` | `ca.ACCOUNT_TYPE` | **Category** | Account type classification | From CUSTOMER_ACCOUNTS table |

### Indicator Fields

| Column Name | Database Column | Semantic Type | Description | Notes |
|------------|-----------------|---------------|-------------|-------|
| `APPOINTMENT_RELATION_TYPE` | Calculated | **Category** | Human-readable type ("Service Order" or "Trouble Ticket") | Use for grouping/filtering |
| `HAS_RELATED_RECORD` | Calculated | **Boolean** | Whether join to service order/trouble ticket succeeded | Use to identify failed joins |

## Semantic Type Categories Reference

### Primary Types

- **Entity Key**: Unique identifiers (IDs, primary keys, codes used for joins)
- **Entity Name**: Names of entities (people, companies, etc.)
- **Category**: Categorical data (status, type, classification)
- **Description**: Text descriptions
- **Creation Timestamp**: Date/time fields
- **Currency**: Monetary values (prices, amounts)
- **Quantity**: Numeric quantities
- **Boolean**: True/false values

## Important Notes

### NULL Values and Conditional Fields

⚠️ **Important**: Many fields are conditionally populated based on APPOINTMENT_TYPE:

**Service Order Fields** (NULL when APPOINTMENT_TYPE = "TT"):
- `SERVICEORDER_ID`, `SO_ORDER_ID`, `SO_STATUS`, `SO_SERVICEORDER_TYPE`, etc.
- `SERVICE_MODEL` (from SERVICELINES) - NULL if service order has no service line
- All feature aggregate fields (`TOTAL_FEATURE_PRICE`, etc.)

**Trouble Ticket Fields** (NULL when APPOINTMENT_TYPE = "O"):
- `TT_TROUBLE_TICKET_ID`, `TT_STATUS`, etc.

**SERVICE_MODEL** (from SERVICELINES):
- Always populated for service order appointments that have a service line
- NULL if service order has no service line or if APPOINTMENT_TYPE = "TT"

**SERVICELINE_ADDRESS_CITY** (from SERVICELINE_ADDRESSES):
- Populated when service order has address information
- NULL if service order has no address information or if APPOINTMENT_TYPE = "TT"

**Feature Aggregate Fields** (NULL when):
- APPOINTMENT_TYPE = "TT" (trouble tickets)
- APPOINTMENT_TYPE = "O" but service order has no features

### Key Fields for Analysis

- **Appointment Type Analysis**: Use `APPOINTMENT_TYPE` (Category) or `APPOINTMENT_RELATION_TYPE` (Category)
- **Join Success Tracking**: Use `HAS_RELATED_RECORD` (Boolean) to identify failed joins
- **Service Model Analysis**: Use `SERVICE_MODEL` (Category) - always available for service orders with service lines
- **Feature Pricing Analysis**: Use `TOTAL_FEATURE_PRICE` (Currency) + `SERVICE_MODEL` (Category) - filter to `APPOINTMENT_TYPE = 'O'` and `TOTAL_FEATURE_PRICE IS NOT NULL`
- **Date Analysis**: Use `APPOINTMENT_DATE` (Creation Timestamp) for time-based analysis
- **Account Analysis**: Use `ACCOUNT_TYPE` (Category) for account-based grouping

### Field Prefixes

Fields are prefixed to avoid ambiguity:
- **`SO_`** prefix = Service Order fields (e.g., `SO_STATUS`, `SO_ORDER_ID`)
- **`TT_`** prefix = Trouble Ticket fields (e.g., `TT_STATUS`, `TT_TROUBLE_TICKET_ID`)
- **No prefix** = Appointment fields (e.g., `APPOINTMENT_ID`, `ORDER_ID`)

### SERVICELINE_NUMBER Handling

- `SERVICELINE_NUMBER` from appointments is VARCHAR (cast for fallback joins)
- `SO_SERVICELINE_NUMBER` and `TT_SERVICELINE_NUMBER` are also VARCHAR
- Invalid values ('0', '0000000000') are filtered out in the WHERE clause

## Setting Semantic Types in Metabase

1. Navigate to the model in Metabase
2. Go to the model settings
3. For each column, set the semantic type according to this document
4. Pay special attention to:
   - **Entity Keys** (for proper joins)
   - **Currency fields** (`TOTAL_FEATURE_PRICE`, `TOTAL_FEATURE_AMOUNT`) - for proper formatting
   - **Boolean fields** (`HAS_RELATED_RECORD`) - for proper true/false filtering
   - **Creation Timestamps** (`APPOINTMENT_DATE`) - for date-based filtering
   - **Category fields** - for proper grouping

## Usage Patterns

### Pattern 1: Appointment Type Distribution
- **Dimensions**: `APPOINTMENT_RELATION_TYPE`, `ACCOUNT_TYPE`
- **Metrics**: `COUNT(DISTINCT APPOINTMENT_ID)`
- **Filter**: None (shows all appointments)

### Pattern 2: Service Order Appointments with Features
- **Filter**: `APPOINTMENT_TYPE = 'O'` AND `TOTAL_FEATURE_PRICE IS NOT NULL`
- **Dimensions**: `SERVICE_MODEL`, `SO_SERVICEORDER_TYPE`
- **Metrics**: `SUM(TOTAL_FEATURE_PRICE)`, `AVG(TOTAL_FEATURE_PRICE)`, `COUNT(DISTINCT APPOINTMENT_ID)`

### Pattern 3: Failed Joins Analysis
- **Filter**: `HAS_RELATED_RECORD = false`
- **Dimensions**: `APPOINTMENT_TYPE`, `ACCOUNT_TYPE`
- **Metrics**: `COUNT(DISTINCT APPOINTMENT_ID)`
- **Use Case**: Identify data quality issues

### Pattern 4: Feature Pricing by Service Model
- **Filter**: `APPOINTMENT_TYPE = 'O'` AND `SERVICE_MODEL IS NOT NULL` AND `TOTAL_FEATURE_PRICE IS NOT NULL`
- **Dimensions**: `SERVICE_MODEL`
- **Metrics**: 
  - `SUM(TOTAL_FEATURE_PRICE)` - Total pricing
  - `SUM(TOTAL_FEATURE_AMOUNT)` - Total amount
  - `AVG(FEATURE_COUNT)` - Average features per appointment

### Pattern 5: Appointment-to-Order Relationships
- **Filter**: `APPOINTMENT_TYPE = 'O'`
- **Dimensions**: `SO_STATUS`, `SO_SERVICEORDER_TYPE`
- **Metrics**: 
  - `COUNT(DISTINCT APPOINTMENT_ID)` - Number of appointments
  - `COUNT(DISTINCT SERVICEORDER_ID)` - Number of unique service orders
- **Use Case**: Understand appointment-to-order relationships

### Pattern 6: Time-Based Analysis
- **Dimensions**: 
  - `YEAR(APPOINTMENT_DATE)`, `MONTH(APPOINTMENT_DATE)`
  - `APPOINTMENT_RELATION_TYPE`
- **Metrics**: `COUNT(DISTINCT APPOINTMENT_ID)`
- **Use Case**: Track appointment trends over time
