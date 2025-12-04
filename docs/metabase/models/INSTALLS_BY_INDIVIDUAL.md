# Installs by Individual - Metabase Models

## Model Hierarchy

This report uses a two-tier model structure:

1. **Base Model**: `Installs by Individual (Base)` - Raw data from Camvio
2. **Enhanced Model**: `Installs by Individual (Enhanced)` - Base model with custom columns and calculations

## Base Model: Installs by Individual (Base)

**Source**: `snowflake/camvio/queries/installs_by_individual.sql`

**Purpose**: Foundation model containing raw Camvio data for completed technician visits

**Connection**: Camvio Snowflake instance

**Key Features**:
- Filters for `TECHNICIAN VISIT` tasks on `COMPLETED` service orders
- Includes all necessary base fields from Camvio tables
- No custom columns or calculations
- Ready for use as-is or as foundation for enhanced model

**Semantic Types**: See [`INSTALLS_BY_INDIVIDUAL_SEMANTIC_TYPES.md`](./INSTALLS_BY_INDIVIDUAL_SEMANTIC_TYPES.md) for recommended semantic type settings for each column.

**Tables Joined**:
- `SERVICEORDERS` (main table)
- `SERVICEORDER_TASKS` (INNER JOIN)
- `CUSTOMER_ACCOUNTS` (INNER JOIN)
- `APPOINTMENTS` (LEFT JOIN)
- `SERVICELINE_FEATURES` (LEFT JOIN)
- `SERVICELINE_ADDRESSES` (LEFT JOIN)

**Key Fields**:
- `SERVICEORDER_ID` - Service order identifier
- `ORDER_ID` - Order identifier (different from SERVICEORDER_ID)
- `ASSIGNEE` - Technician/individual who completed the install
- `TASK_ENDED` - When the technician visit was completed
- `TASK_STARTED` - When the technician visit started
- `ACCOUNT_ID` - Customer account identifier
- `SERVICELINE_NUMBER` - Service line identifier
- Address fields (city, state, zipcode)
- Feature information (FEATURE, FEATURE_PRICE, QTY, PLAN)

## Enhanced Model: Installs by Individual (Enhanced)

**Base Model**: `Installs by Individual (Base)`

**Purpose**: Enriched version with custom columns, calculated fields, and business logic

**Custom Columns to Add**:

### 1. Duration Calculations

```javascript
// Task Duration (minutes)
case(
  not isNull([Task Ended]),
  datediff("minute", [Task Started], [Task Ended]),
  null
)
```

```javascript
// Task Duration (hours)
case(
  not isNull([Task Ended]),
  round(datediff("minute", [Task Started], [Task Ended]) / 60.0, 2),
  null
)
```

### 2. Date/Time Formatting

```javascript
// Task Date (formatted)
formatDateTime([Task Ended], "M/d/yyyy")
```

```javascript
// Task Time (formatted)
formatDateTime([Task Ended], "h:mm a")
```

```javascript
// Task Day of Week
formatDateTime([Task Ended], "EEEE")
```

### 3. Status Indicators

```javascript
// Is Completed
case(
  not isNull([Task Ended]),
  true,
  false
)
```

```javascript
// Completion Status
case(
  not isNull([Task Ended]),
  "Completed",
  "In Progress"
)
```

### 4. Address Formatting

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

### 5. Feature Value Calculations

```javascript
// Total Feature Value
case(
  not isNull([Feature Price]) and not isNull([Qty]),
  [Feature Price] * [Qty],
  null
)
```

### 6. Technician Performance Metrics

```javascript
// Technician Performance Category
case(
  [Task Duration (hours)] <= 1,
  "Fast",
  [Task Duration (hours)] <= 2,
  "Normal",
  [Task Duration (hours)] <= 4,
  "Slow",
  "Very Slow"
)
```

### 7. Time-based Grouping

```javascript
// Task Month
formatDateTime([Task Ended], "yyyy-MM")
```

```javascript
// Task Week
formatDateTime([Task Ended], "yyyy-'W'ww")
```

```javascript
// Task Quarter
concat(
  formatDateTime([Task Ended], "yyyy"),
  "-Q",
  formatDateTime([Task Ended], "Q")
)
```

### 8. Appointment Alignment

```javascript
// Appointment Match
case(
  not isNull([Appointment Date]) and not isNull([Task Ended]),
  abs(datediff("day", [Appointment Date], [Task Ended])) <= 1,
  null
)
```

```javascript
// Appointment Status
case(
  isNull([Appointment Date]),
  "No Appointment",
  [Appointment Match],
  "On Time",
  "Missed"
)
```

## Metrics to Create

### 1. Total Installs
- **Type**: Count
- **Description**: Total number of completed technician visits
- **Formula**: `Count`

### 2. Unique Technicians
- **Type**: Count Distinct
- **Description**: Number of unique technicians
- **Formula**: `Count distinct of [Assignee]`

### 3. Average Task Duration (hours)
- **Type**: Average
- **Description**: Average time to complete technician visit
- **Formula**: `Average of [Task Duration (hours)]`

### 4. Total Feature Value
- **Type**: Sum
- **Description**: Total value of features installed
- **Formula**: `Sum of [Total Feature Value]`

### 5. On-Time Appointment Rate
- **Type**: Custom Expression
- **Description**: Percentage of tasks completed within 1 day of appointment
- **Formula**: 
```javascript
case(
  count([Appointment Match]) > 0,
  (sum(case([Appointment Match], 1, 0)) / count([Appointment Match])) * 100,
  null
)
```

## Recommended Filters

- **Date Range**: Filter by `Task Ended` date
- **Technician**: Filter by `Assignee`
- **Service Order Type**: Filter by `Serviceorder Type`
- **Account Type**: Filter by `Account Type`
- **Service Model**: Filter by `Service Model`
- **State**: Filter by `Serviceline Address State`

## Usage Notes

1. **Base Model**: Use for raw data access or when you need all original fields
2. **Enhanced Model**: Use for reports and dashboards with calculated metrics
3. **Performance**: Base model is faster; use enhanced model when you need custom columns
4. **Updates**: Custom columns in enhanced model will automatically reflect changes in base model

## Future Enhancements

- Add Fybe data join (see `installs_by_individual_with_fybe.sql`)
- Add customer satisfaction scores
- Add technician certification levels
- Add equipment/inventory tracking
- Add cost analysis fields

