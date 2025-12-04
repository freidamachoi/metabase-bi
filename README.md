# Metabase BI Project

A Business Intelligence project using Metabase to analyze and visualize data from two Snowflake instances: **Fybe** (fully controlled) and **Camvio** (read-only access).

## Project Overview

This repository contains:
- **Snowflake SQL Views**: Custom views created in the Fybe Snowflake instance
- **Metabase Custom Columns**: Definitions for calculated fields, metrics, and enriched data models
- **Documentation**: Specifications for Metabase reports, models, and dashboards

## Architecture

### Data Sources

#### 1. Fybe Snowflake Instance
- **Access Level**: Full control (read/write)
- **Location**: `snowflake/fybe/`
- **Capabilities**: Can create views, materialized views, dynamic tables, and other database objects
- **Current Views**:
  - `DROP_BURY_BY_DAY_V`: Drop and bury tasks combined with date spine for time-series analysis
  - `VW_RENDER_TICKETS`: Filtered render tickets view (excludes QA/test projects)
  - `VW_RENDER_UNITS`: Render units with labor code enrichment

#### 2. Camvio Snowflake Instance
- **Access Level**: Read-only
- **Location**: `snowflake/camvio/`
- **Limitations**: Cannot create views, materialized views, or dynamic tables
- **Strategy**: Joins and data transformations must be performed in Metabase
- **Status**: Documentation of available tables/views needed

## Directory Structure

```
.
├── README.md                          # This file
├── .gitignore                         # Git ignore rules
├── docs/
│   └── metabase/
│       ├── Custom Column Definitions - Render.md  # Metabase custom column definitions
│       ├── drop_bury_custom_columns.txt          # Additional column definitions
│       └── models/                               # Metabase model documentation
│           └── INSTALLS_BY_INDIVIDUAL.md        # Installs by Individual model structure
└── snowflake/
    ├── fybe/                          # Fybe instance SQL views
    │   ├── DROP_BURY_BY_DAY_V.sql
    │   ├── VW_RENDER_TICKETS.sql
    │   └── VW_RENDER_UNITS.sql
    └── camvio/                        # Camvio instance documentation (read-only)
        └── (documentation needed)
```

## Metabase Models & Reports

### Drop Bury by Day (Base)
- **Source**: `DROP_BURY_BY_DAY_V` view from Fybe Snowflake
- **Purpose**: Time-series analysis of drop and bury tasks
- **Key Fields**: Date dimensions, drop/bury task details, status fields, dates

### Drop Bury by Day (Enriched)
- **Base Model**: Drop Bury by Day (Base)
- **Custom Columns**: 
  - Drop/Bury status normalization and ranking
  - Stage labels and jeopardy indicators
  - Days open, completion age, SLA tracking
  - Overall status and stage calculations
- **Metrics**: Task creation/completion counts by day

### Render Unit Report (Base)
- **Source**: `VW_RENDER_UNITS` view from Fybe Snowflake
- **Purpose**: Unit-level task tracking with labor codes

### Render Material Report (Enriched)
- **Base Model**: Render Unit Report (Base)
- **Filter**: Task type = Material
- **Custom Columns**: Approval status, NLR flags, category classification, task type formatting

### Render Labor Unit Report (Enriched)
- **Base Model**: Render Unit Report (Base)
- **Custom Columns**: Similar to Material Report plus financial calculations (Gross $, Net $)

### Render Tickets (Base)
- **Source**: `VW_RENDER_TICKETS` view from Fybe Snowflake
- **Purpose**: Ticket-level task tracking

### Render Tickets (Enriched)
- **Base Model**: Render Tickets (Base)
- **Custom Columns**: Status normalization, jeopardy/overdue indicators, category classification, time-to-complete metrics
- **Metrics**: Total tickets, completion rates, approval rates, release rates

## Current Status

### ✅ Completed
- Fybe Snowflake views created and documented
- Metabase custom column definitions documented
- Project structure organized

### 🚧 In Progress
- Git repository initialization
- GitHub repository setup

### 📋 Needed from Camvio Instance
To enable cross-instance analysis and reporting, we need documentation of:

1. **Available Tables/Views**:
   - List of all accessible tables and views
   - Schema names and table structures
   - Key fields and data types
   - Relationships between tables

2. **Key Identifiers**:
   - Primary keys for joining with Fybe data
   - Common fields (e.g., PROJECT_ID, ASSET_ID, TASK_ID)
   - Date/time fields for time-series analysis

3. **Data Dictionary**:
   - Field descriptions and business meanings
   - Status values and their meanings
   - Code values and their descriptions

4. **Sample Queries**:
   - Common query patterns
   - Join relationships
   - Filtering requirements

### 🔄 Recommended Next Steps

1. **Document Camvio Schema**:
   - Create `snowflake/camvio/SCHEMA_DOCUMENTATION.md` with:
     - Available tables/views
     - Key fields and relationships
     - Sample data structure

2. **Metabase Join Strategy**:
   - Document join keys between Fybe and Camvio
   - Create Metabase models that combine data from both instances
   - Test performance and optimize queries

3. **Additional Metabase Models**:
   - Create unified models combining Fybe + Camvio data
   - Document any additional custom columns needed
   - Create dashboards and visualizations

## Usage

### Viewing SQL Definitions
All Snowflake views are stored in `snowflake/fybe/` and can be executed directly in Snowflake.

### Metabase Setup
1. Connect Metabase to both Snowflake instances
2. Create base models pointing to the views/tables
3. Add custom columns as defined in `docs/metabase/Custom Column Definitions - Render.md`
4. Create metrics as specified in the documentation
5. Build dashboards and reports

### Adding New Views
1. Create SQL view in Fybe Snowflake instance
2. Save SQL to `snowflake/fybe/[VIEW_NAME].sql`
3. Document the view in this README
4. Update Metabase custom column definitions if needed

## Contributing

When adding new features:
1. Update relevant SQL files in `snowflake/fybe/`
2. Document custom columns in `docs/metabase/`
3. Update this README with new models/views
4. Commit with descriptive messages

## Notes

- **Metabase Custom Columns**: Use Java-like syntax (Metabase's expression language)
- **Snowflake Views**: All views are created in `DATA_LAKE.ANALYTICS` schema
- **Date Handling**: Views use `ANALYTICS.CALENDAR_DIM` for date spine generation
- **Performance**: Consider materialized views for frequently accessed data

## Questions or Issues

For questions about:
- **Fybe Data**: Review SQL views in `snowflake/fybe/`
- **Metabase Setup**: See `docs/metabase/Custom Column Definitions - Render.md`
- **Camvio Data**: Documentation needed (see "Needed from Camvio Instance" above)

