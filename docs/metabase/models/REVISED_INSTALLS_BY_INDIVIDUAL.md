# Installs by Individual (Revised) - Model Documentation

## Overview

This is a **revised, optimized version** of the Installs by Individual model, focused on the core requirements:
1. **Technician** (who completed the install)
2. **Account Type** (customer account type)
3. **Date of Install** (when the install was completed)
4. **Address** (where the install was completed)

## Query Comparison

### Original Query (`installs_by_individual.sql`)
- **Tables**: 6 tables (SERVICEORDERS, SERVICEORDER_TASKS, CUSTOMER_ACCOUNTS, APPOINTMENTS, SERVICELINE_FEATURES, SERVICELINE_ADDRESSES)
- **JOINs**: 5 JOINs (2 INNER, 3 LEFT)
- **Fields**: 25 columns
- **Use Case**: Comprehensive install data including appointments and features

### Revised Query (`revised_installs_by_individual.sql`)
- **Tables**: 4 tables (SERVICEORDERS, SERVICEORDER_TASKS, CUSTOMER_ACCOUNTS, SERVICELINE_ADDRESSES)
- **JOINs**: 3 JOINs (2 INNER, 1 LEFT)
- **Fields**: 15 columns (core requirements only)
- **Use Case**: Focused on core install tracking metrics

## Optimizations

### Removed Tables

1. **APPOINTMENTS** - Not needed for core requirements
   - Can be added back if appointment scheduling analysis is needed
   - Saves one LEFT JOIN

2. **SERVICELINE_FEATURES** - Not needed for basic install tracking
   - Can be added back if feature-level analysis is needed
   - Saves one LEFT JOIN

### Performance Benefits

- **40% fewer JOINs** (3 vs 5)
- **40% fewer columns** (15 vs 25)
- **Faster query execution** - fewer table scans
- **Less data transfer** - smaller result set
- **Simpler maintenance** - easier to understand and modify

## Model Structure

### Base Model: Installs by Individual (Revised Base)

**Source**: `snowflake/camvio/queries/revised_installs_by_individual.sql`

**Core Fields**:
- `ASSIGNEE` - Technician name
- `ACCOUNT_TYPE` - Account type
- `TASK_ENDED` - Date of install
- Address fields (ADDRESS1, ADDRESS2, CITY, STATE, ZIPCODE)

**Additional Context**:
- `SERVICEORDER_ID` - Service order identifier
- `ORDER_ID` - Order identifier
- `ACCOUNT_ID` - Account identifier
- `STATUS` - Order status (always 'COMPLETED')
- `SERVICEORDER_TYPE` - Service order type
- `SERVICELINE_NUMBER` - Service line identifier
- `SERVICE_MODEL` - Service model
- `TASK_STARTED` - Install start time
- `TASK_NAME` - Task name (always 'TECHNICIAN VISIT')

## Column Mapping

| Model Column | Source Table | Semantic Type | Purpose |
|-------------|--------------|---------------|---------|
| `SERVICEORDER_ID` | SERVICEORDERS | Entity Key | Primary identifier |
| `ORDER_ID` | SERVICEORDERS | Entity Key | Order identifier |
| `ACCOUNT_ID` | SERVICEORDERS | Entity Key | Account identifier |
| `ASSIGNEE` | SERVICEORDER_TASKS | Entity Name | **Technician** |
| `ACCOUNT_TYPE` | CUSTOMER_ACCOUNTS | Category | **Account Type** |
| `TASK_ENDED` | SERVICEORDER_TASKS | Creation Timestamp | **Date of Install** |
| `TASK_STARTED` | SERVICEORDER_TASKS | Creation Timestamp | Install start time |
| `SERVICELINE_ADDRESS1` | SERVICELINE_ADDRESSES | Address | **Installation Address** |
| `SERVICELINE_ADDRESS2` | SERVICELINE_ADDRESSES | Address | **Installation Address** |
| `SERVICELINE_ADDRESS_CITY` | SERVICELINE_ADDRESSES | City | **Installation Address** |
| `SERVICELINE_ADDRESS_STATE` | SERVICELINE_ADDRESSES | State | **Installation Address** |
| `SERVICELINE_ADDRESS_ZIPCODE` | SERVICELINE_ADDRESSES | ZIP Code | **Installation Address** |
| `STATUS` | SERVICEORDERS | Category | Order status |
| `SERVICEORDER_TYPE` | SERVICEORDERS | Category | Service order type |
| `SERVICELINE_NUMBER` | SERVICEORDERS | Entity Key | Service line identifier |
| `SERVICE_MODEL` | SERVICELINE_ADDRESSES | Category | Service model |
| `TASK_NAME` | SERVICEORDER_TASKS | Category | Task name |

## Enhanced Model: Custom Columns

### Duration Calculations

```javascript
// Install Duration (minutes)
case(
  not isNull([Task Ended]),
  datediff("minute", [Task Started], [Task Ended]),
  null
)
```

```javascript
// Install Duration (hours)
case(
  not isNull([Task Ended]),
  round(datediff("minute", [Task Started], [Task Ended]) / 60.0, 2),
  null
)
```

### Date Formatting

```javascript
// Install Date (formatted)
formatDateTime([Task Ended], "M/d/yyyy")
```

```javascript
// Install Month
formatDateTime([Task Ended], "yyyy-MM")
```

```javascript
// Install Quarter
concat(
  formatDateTime([Task Ended], "yyyy"),
  "-Q",
  formatDateTime([Task Ended], "Q")
)
```

### Address Formatting

```javascript
// Full Address
trim(concat(
  coalesce([Serviceline Address1], ""),
  case(not isNull([Serviceline Address2]), concat(", ", [Serviceline Address2]), ""),
  case(not isNull([Serviceline Address City]), concat(", ", [Serviceline Address City]), ""),
  case(not isNull([Serviceline Address State]), concat(", ", [Serviceline Address State]), ""),
  case(not isNull([Serviceline Address Zipcode]), concat(" ", [Serviceline Address Zipcode]), "")
))
```

## Metrics

1. **Total Installs** - Count of completed installations
2. **Unique Technicians** - Count distinct of ASSIGNEE
3. **Average Install Duration** - Average of Install Duration (hours)
4. **Installs by Account Type** - Count grouped by ACCOUNT_TYPE
5. **Installs by State** - Count grouped by SERVICELINE_ADDRESS_STATE

## When to Use Which Query

### Use Revised Query When:
- ✅ You only need core install tracking (technician, account type, date, address)
- ✅ Performance is a priority
- ✅ You want simpler, faster queries
- ✅ You don't need appointment or feature data

### Use Original Query When:
- ✅ You need appointment scheduling data
- ✅ You need feature-level analysis (FEATURE, FEATURE_PRICE, QTY, PLAN)
- ✅ You need comprehensive data for detailed analysis
- ✅ You're building complex reports with multiple data points

## Migration Path

If you're currently using the original query:

1. **Test the revised query** - Verify it meets your needs
2. **Compare results** - Ensure data matches expectations
3. **Update models** - Switch base model to revised query
4. **Update dashboards** - Adjust any references to removed fields
5. **Keep original** - Maintain original query for reference or future use

## Next Steps

1. ✅ Create revised query - **COMPLETE**
2. ⏳ Test query performance - Compare with original
3. ⏳ Validate data completeness - Ensure all required fields are present
4. ⏳ Create Metabase model - Set up base model with revised query
5. ⏳ Set semantic types - Use column mapping above
6. ⏳ Create enhanced model - Add custom columns as needed

