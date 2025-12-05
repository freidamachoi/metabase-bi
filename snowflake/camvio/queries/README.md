# Camvio Queries

This directory contains SQL queries for the Camvio Snowflake instance, including queries migrated from Tableau and new queries for Metabase.

## Query Files

### `installs_by_individual.sql`
- **Source**: Tableau (migrating to Metabase)
- **Purpose**: Get installs by individual technician who completed the install (comprehensive version)
- **Filters**: 
  - `TASK_NAME` = 'TECHNICIAN VISIT'
  - `STATUS` = 'COMPLETED'
- **Key Fields**: ASSIGNEE (technician), TASK_ENDED, appointment details, service line features
- **Tables**: 6 tables (includes APPOINTMENTS and SERVICELINE_FEATURES)
- **Note**: Currently Camvio-only (no Fybe join)
- **Use When**: You need appointment or feature-level data

### `revised_installs_by_individual.sql` ⭐ **RECOMMENDED FOR CORE USE CASE**
- **Purpose**: Optimized version focused on core requirements (technician, account type, date, address)
- **Filters**: 
  - `TASK_NAME` = 'TECHNICIAN VISIT'
  - `STATUS` = 'COMPLETED'
  - `TASK_ENDED IS NOT NULL`
- **Key Fields**: ASSIGNEE (technician), ACCOUNT_TYPE, TASK_ENDED (date), address fields
- **Tables**: 4 tables (removed APPOINTMENTS and SERVICELINE_FEATURES)
- **Optimizations**: 40% fewer JOINs, 40% fewer columns, faster performance
- **Use When**: You only need core install tracking metrics (technician, account type, date, address)

### `installs_by_individual_with_fybe.sql`
- **Enhanced version** of `installs_by_individual.sql`
- **Adds**: Fybe Render Tickets data via `WORK_PACKAGE` = `SERVICEORDER_ID` join
- **Purpose**: Same as above, but enriched with Fybe project and work activity data
- **Use Case**: When you need both Camvio service order details and Fybe work details

### `combined_installs_and_trouble_tickets.sql` ⭐ **UNIFIED MODEL**
- **Purpose**: Combines completed installations and closed trouble tickets into one unified view
- **Structure**: UNION ALL query combining installs and trouble tickets
- **Key Feature**: `VISIT_TYPE` field distinguishes between 'Install' and 'Trouble Ticket'
- **Use Case**: When you need a single model showing all technician visits (installs + trouble tickets)
- **Benefits**: 
  - Single source of truth for all technician visits
  - Easy to filter by type or aggregate across both
  - Consistent structure for reporting

### `service_orders_with_charges.sql` ⭐ **SERVICE ORDERS WITH CHARGES**
- **Purpose**: Get completed service orders with service lines, features, and account charges
- **Key Features**:
  - Service lines (including SERVICELINE_STARTDATE)
  - Service line features (services on the order with rates/PRICE)
  - Account recurring credits (recurring charges)
  - Account other charges/credits (one-time charges)
- **Filters**: 
  - `STATUS` = 'COMPLETED'
- **Key Fields**: 
  - `SERVICELINE_STARTDATE` (service line start date)
  - `FEATURE_PRICE` (rate associated with each service feature)
  - `RECURRING_CREDIT_AMOUNT` (recurring charge amount)
  - `OCC_AMOUNT` (one-time charge amount)
- **Tables**: 5 tables (SERVICEORDERS, SERVICELINES, SERVICELINE_FEATURES, ACCOUNT_RECURRING_CREDITS, ACCOUNT_OTHER_CHARGES_CREDITS)
- **Note**: Creates multiple rows per service order if multiple features or charges exist
- **Use When**: You need to analyze completed services, their features/rates, and associated charges

### `service_orders_charges_by_type.sql` ⭐ **CHARGES BY TYPE (AGGREGATED)**
- **Purpose**: Get completed service orders with charges **aggregated by type**
- **Key Features**:
  - Recurring credits grouped by `RECURRING_CREDIT_NAME` (type)
  - Other charges grouped by `ITEM_TYPE` (type)
  - Amounts summed by type per service order
- **Structure**: UNION ALL query separating recurring credits and other charges
- **Filters**: 
  - `STATUS` = 'COMPLETED'
  - Only shows service orders that have charges (INNER JOIN)
- **Key Fields**: 
  - `CHARGE_TYPE` ('Recurring Credit' or 'Other Charge')
  - `CHARGE_TYPE_NAME` (RECURRING_CREDIT_NAME or ITEM_TYPE)
  - `CHARGE_AMOUNT` (sum of amounts by type)
  - `CHARGE_COUNT` (count of charges by type)
  - `SERVICELINE_STARTDATE` (service line start date)
- **Tables**: 4 tables (SERVICEORDERS, SERVICELINES, ACCOUNT_RECURRING_CREDITS, ACCOUNT_OTHER_CHARGES_CREDITS)
- **Note**: One row per service order per charge type
- **Use When**: You need to analyze charge amounts grouped by type (e.g., "How much in recurring credits by credit name?" or "How much in other charges by item type?")

## Usage in Metabase

### Model Structure

**`installs_by_individual.sql`** is designed to be used as a **base model** in Metabase:

1. **Base Model**: `Installs by Individual (Base)`
   - Use the SQL from `installs_by_individual.sql` as the model query
   - This provides raw data from Camvio
   - No custom columns or calculations

2. **Enhanced Model**: `Installs by Individual (Enhanced)`
   - Create a new model based on the base model
   - Add custom columns, calculated fields, and business logic
   - See `docs/metabase/models/INSTALLS_BY_INDIVIDUAL.md` for custom column examples

### Other Usage Options

These queries can also be used as:
1. **Native Queries**: Direct SQL queries in Metabase (for ad-hoc analysis)
2. **Reference**: Examples of how to join Camvio tables

## Adding New Queries

When adding new queries:
1. Use descriptive file names (snake_case)
2. Include header comments with purpose and key filters
3. Document any special join logic or data type conversions
4. Note if query is Camvio-only or includes Fybe joins
5. Update this README with query description

## Notes

- All queries use `CAMVIO.PUBLIC` schema prefix
- Fybe queries use `DATA_LAKE.ANALYTICS` schema prefix
- Remember: `ORDER_ID` ≠ `SERVICEORDER_ID` - only `SERVICEORDER_ID` relates to Fybe `WORK_PACKAGE`

