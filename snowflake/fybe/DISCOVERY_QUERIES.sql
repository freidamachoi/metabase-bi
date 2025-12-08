-- ============================================================================
-- Fybe Snowflake Discovery Queries
-- ============================================================================
-- Run these queries in the Fybe Snowflake instance to discover structure
-- Database: DATA_LAKE
-- Primary Schemas: ANALYTICS, S3_STAGES
-- Use the results to populate SCHEMA_DOCUMENTATION.md
-- ============================================================================

-- Set the database context
USE DATABASE DATA_LAKE;

-- ----------------------------------------------------------------------------
-- 1. LIST ALL AVAILABLE SCHEMAS
-- ----------------------------------------------------------------------------
-- Shows all schemas you have access to in DATA_LAKE
SELECT 
    schema_name,
    schema_owner,
    created,
    last_altered
FROM information_schema.schemata
WHERE schema_name NOT IN ('INFORMATION_SCHEMA')
ORDER BY schema_name;

-- ----------------------------------------------------------------------------
-- 2. LIST ALL TABLES AND VIEWS
-- ----------------------------------------------------------------------------
-- Shows all tables and views in accessible schemas
SELECT 
    table_schema,
    table_name,
    table_type,  -- 'BASE TABLE' or 'VIEW'
    row_count,   -- Approximate row count (for tables)
    bytes,       -- Size in bytes
    created,
    last_altered
FROM information_schema.tables
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY table_schema, table_type, table_name;

-- Alternative: More detailed table information
SELECT 
    t.table_schema,
    t.table_name,
    t.table_type,
    t.row_count,
    t.bytes,
    t.created,
    t.last_altered,
    CASE 
        WHEN t.table_type = 'BASE TABLE' THEN 'Table'
        WHEN t.table_type = 'VIEW' THEN 'View'
        ELSE t.table_type
    END as object_type
FROM information_schema.tables t
WHERE t.table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY t.table_schema, t.table_name;

-- ----------------------------------------------------------------------------
-- 3. FOCUS ON PRIMARY SCHEMAS: ANALYTICS AND S3_STAGES
-- ----------------------------------------------------------------------------
-- Tables and views in ANALYTICS schema
SELECT 
    table_name,
    table_type,
    row_count,
    bytes,
    created,
    last_altered
FROM information_schema.tables
WHERE table_schema = 'ANALYTICS'
ORDER BY table_name;

-- Tables and views in S3_STAGES schema
SELECT 
    table_name,
    table_type,
    row_count,
    bytes,
    created,
    last_altered
FROM information_schema.tables
WHERE table_schema = 'S3_STAGES'
ORDER BY table_name;

-- Combined view of both primary schemas
SELECT 
    table_schema,
    table_name,
    table_type,
    row_count,
    bytes,
    created,
    last_altered
FROM information_schema.tables
WHERE table_schema IN ('ANALYTICS', 'S3_STAGES')
ORDER BY table_schema, table_name;

-- ----------------------------------------------------------------------------
-- 4. LIST ALL COLUMNS FOR ALL TABLES/VIEWS
-- ----------------------------------------------------------------------------
-- Comprehensive column information
SELECT 
    table_schema,
    table_name,
    column_name,
    ordinal_position,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale,
    is_nullable,
    column_default,
    comment
FROM information_schema.columns
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY table_schema, table_name, ordinal_position;

-- Columns in ANALYTICS schema tables
SELECT 
    table_name,
    column_name,
    ordinal_position,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale,
    is_nullable,
    column_default,
    comment
FROM information_schema.columns
WHERE table_schema = 'ANALYTICS'
ORDER BY table_name, ordinal_position;

-- Columns in S3_STAGES schema tables
SELECT 
    table_name,
    column_name,
    ordinal_position,
    data_type,
    character_maximum_length,
    numeric_precision,
    numeric_scale,
    is_nullable,
    column_default,
    comment
FROM information_schema.columns
WHERE table_schema = 'S3_STAGES'
ORDER BY table_name, ordinal_position;

-- ----------------------------------------------------------------------------
-- 5. FIND PRIMARY KEYS AND UNIQUE CONSTRAINTS
-- ----------------------------------------------------------------------------
-- Note: Snowflake INFORMATION_SCHEMA doesn't include column details for constraints
-- Use TABLE_CONSTRAINTS to find constraints, then use SHOW commands for column details

-- All constraints (shows constraint names and types, but not column names)
SELECT 
    tc.table_schema,
    tc.table_name,
    tc.constraint_type,
    tc.constraint_name
FROM information_schema.table_constraints tc
WHERE tc.table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY tc.table_schema, tc.table_name, tc.constraint_type;

-- Primary keys (constraint names only - use SHOW commands below for column details)
SELECT 
    tc.table_schema,
    tc.table_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
WHERE tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY tc.table_schema, tc.table_name;

-- Constraints in primary schemas
SELECT 
    tc.table_schema,
    tc.table_name,
    tc.constraint_type,
    tc.constraint_name
FROM information_schema.table_constraints tc
WHERE tc.table_schema IN ('ANALYTICS', 'S3_STAGES')
ORDER BY tc.table_schema, tc.table_name, tc.constraint_type;

-- Use SHOW commands to get detailed constraint information including column names
-- Run these commands and export results to CSV files:
-- SHOW PRIMARY KEYS IN SCHEMA ANALYTICS;
-- SHOW PRIMARY KEYS IN SCHEMA S3_STAGES;
-- SHOW UNIQUE KEYS IN SCHEMA ANALYTICS;
-- SHOW UNIQUE KEYS IN SCHEMA S3_STAGES;

-- ----------------------------------------------------------------------------
-- 6. FIND FOREIGN KEY RELATIONSHIPS
-- ----------------------------------------------------------------------------
-- Foreign keys (constraint names only - use SHOW commands below for detailed info)
-- Note: Snowflake INFORMATION_SCHEMA doesn't provide column details for foreign keys
SELECT 
    tc.table_schema AS foreign_table_schema,
    tc.table_name AS foreign_table_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY tc.table_schema, tc.table_name;

-- Foreign keys in primary schemas
SELECT 
    tc.table_schema AS foreign_table_schema,
    tc.table_name AS foreign_table_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema IN ('ANALYTICS', 'S3_STAGES')
ORDER BY tc.table_schema, tc.table_name;

-- Use SHOW commands to get detailed foreign key information including column mappings
-- Run these commands and export results to CSV files:
-- SHOW FOREIGN KEYS IN SCHEMA ANALYTICS;
-- SHOW FOREIGN KEYS IN SCHEMA S3_STAGES;
-- 
-- The SHOW FOREIGN KEYS output includes:
-- - pk_table: Referenced (primary key) table
-- - pk_schema: Referenced table schema
-- - fk_table: Foreign key table
-- - fk_schema: Foreign key table schema
-- - pk_column_name: Referenced column
-- - fk_column_name: Foreign key column

-- ----------------------------------------------------------------------------
-- 7. SEARCH FOR COMMON JOIN KEY FIELDS
-- ----------------------------------------------------------------------------
-- Find columns that might be join keys (ID fields, keys, etc.)
SELECT 
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
    AND (
        UPPER(column_name) LIKE '%ID%'
        OR UPPER(column_name) LIKE '%KEY%'
        OR UPPER(column_name) LIKE '%PROJECT%'
        OR UPPER(column_name) LIKE '%ASSET%'
        OR UPPER(column_name) LIKE '%TASK%'
        OR UPPER(column_name) LIKE '%CONTRACTOR%'
        OR UPPER(column_name) LIKE '%UNIT%'
        OR UPPER(column_name) LIKE '%TICKET%'
    )
ORDER BY table_schema, table_name, column_name;

-- Specific common keys in primary schemas
SELECT 
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema IN ('ANALYTICS', 'S3_STAGES')
    AND UPPER(column_name) IN (
        'PROJECT_ID', 'ASSET_ID', 'TASK_ID', 'CONTRACTOR',
        'PROJECTID', 'ASSETID', 'TASKID',
        'ID', 'KEY', 'PRIMARY_KEY',
        'UNIT_ID', 'TICKET_ID', 'RENDER_ID'
    )
ORDER BY table_schema, table_name, column_name;

-- ----------------------------------------------------------------------------
-- 8. FIND DATE/TIME FIELDS
-- ----------------------------------------------------------------------------
-- All date and timestamp columns
SELECT 
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
    AND data_type IN ('DATE', 'TIMESTAMP_NTZ', 'TIMESTAMP_LTZ', 'TIMESTAMP_TZ', 'TIME')
ORDER BY table_schema, table_name, column_name;

-- Date fields with common naming patterns
SELECT 
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
    AND (
        UPPER(column_name) LIKE '%DATE%'
        OR UPPER(column_name) LIKE '%TIME%'
        OR UPPER(column_name) LIKE '%CREATED%'
        OR UPPER(column_name) LIKE '%COMPLETED%'
        OR UPPER(column_name) LIKE '%APPROVED%'
        OR UPPER(column_name) LIKE '%RELEASED%'
        OR UPPER(column_name) LIKE '%UPDATED%'
        OR UPPER(column_name) LIKE '%MODIFIED%'
    )
ORDER BY table_schema, table_name, column_name;

-- Date fields in primary schemas
SELECT 
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema IN ('ANALYTICS', 'S3_STAGES')
    AND data_type IN ('DATE', 'TIMESTAMP_NTZ', 'TIMESTAMP_LTZ', 'TIMESTAMP_TZ', 'TIME')
ORDER BY table_schema, table_name, column_name;

-- ----------------------------------------------------------------------------
-- 9. FIND STATUS FIELDS
-- ----------------------------------------------------------------------------
-- Columns that might contain status information
SELECT 
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
    AND (
        UPPER(column_name) LIKE '%STATUS%'
        OR UPPER(column_name) LIKE '%STATE%'
        OR UPPER(column_name) LIKE '%STAGE%'
        OR UPPER(column_name) LIKE '%PHASE%'
    )
ORDER BY table_schema, table_name, column_name;

-- Status fields in primary schemas
SELECT 
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema IN ('ANALYTICS', 'S3_STAGES')
    AND (
        UPPER(column_name) LIKE '%STATUS%'
        OR UPPER(column_name) LIKE '%STATE%'
        OR UPPER(column_name) LIKE '%STAGE%'
        OR UPPER(column_name) LIKE '%PHASE%'
    )
ORDER BY table_schema, table_name, column_name;

-- ----------------------------------------------------------------------------
-- 10. S3_STAGES SCHEMA SPECIFIC QUERIES
-- ----------------------------------------------------------------------------
-- Since S3_STAGES reads from AWS, check for external tables or stages
-- External tables in S3_STAGES
SELECT 
    table_name,
    table_type,
    row_count,
    bytes,
    created,
    last_altered
FROM information_schema.tables
WHERE table_schema = 'S3_STAGES'
    AND table_type = 'EXTERNAL TABLE'
ORDER BY table_name;

-- All objects in S3_STAGES (tables, views, external tables)
SELECT 
    table_name,
    table_type,
    row_count,
    bytes,
    created,
    last_altered
FROM information_schema.tables
WHERE table_schema = 'S3_STAGES'
ORDER BY table_type, table_name;

-- ----------------------------------------------------------------------------
-- 11. GET SAMPLE DATA FROM A SPECIFIC TABLE
-- ----------------------------------------------------------------------------
-- Replace 'YOUR_TABLE_NAME' and schema with actual names
-- Uncomment and modify as needed:

/*
-- Sample from ANALYTICS schema
SELECT *
FROM ANALYTICS.YOUR_TABLE_NAME
LIMIT 10;

-- Sample from S3_STAGES schema
SELECT *
FROM S3_STAGES.YOUR_TABLE_NAME
LIMIT 10;
*/

-- Get distinct values for a status column (example)
-- Replace 'YOUR_TABLE_NAME', 'STATUS_COLUMN', and schema with actual names:

/*
SELECT DISTINCT STATUS_COLUMN, COUNT(*) as count
FROM ANALYTICS.YOUR_TABLE_NAME
GROUP BY STATUS_COLUMN
ORDER BY count DESC;
*/

-- ----------------------------------------------------------------------------
-- 12. SUMMARY STATISTICS FOR A TABLE
-- ----------------------------------------------------------------------------
-- Replace 'YOUR_TABLE_NAME' and schema with actual names:

/*
SELECT 
    COUNT(*) as total_rows,
    COUNT(DISTINCT ID_COLUMN) as distinct_ids,  -- Adjust column names
    MIN(CREATED_DATE) as earliest_date,         -- Adjust column names
    MAX(CREATED_DATE) as latest_date            -- Adjust column names
FROM ANALYTICS.YOUR_TABLE_NAME;
*/

-- ----------------------------------------------------------------------------
-- 13. VIEW DEFINITIONS (if you have access)
-- ----------------------------------------------------------------------------
-- Get the SQL definition of views
SELECT 
    table_schema,
    table_name,
    view_definition
FROM information_schema.views
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY table_schema, table_name;

-- View definitions in primary schemas
SELECT 
    table_schema,
    table_name,
    view_definition
FROM information_schema.views
WHERE table_schema IN ('ANALYTICS', 'S3_STAGES')
ORDER BY table_schema, table_name;

-- ----------------------------------------------------------------------------
-- 14. TABLE/VIEW COMMENTS
-- ----------------------------------------------------------------------------
-- Get comments/descriptions on tables and views
SELECT 
    table_schema,
    table_name,
    table_type,
    comment
FROM information_schema.tables
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
    AND comment IS NOT NULL
ORDER BY table_schema, table_name;

-- Comments in primary schemas
SELECT 
    table_schema,
    table_name,
    table_type,
    comment
FROM information_schema.tables
WHERE table_schema IN ('ANALYTICS', 'S3_STAGES')
    AND comment IS NOT NULL
ORDER BY table_schema, table_name;

-- ----------------------------------------------------------------------------
-- 15. COLUMN COMMENTS
-- ----------------------------------------------------------------------------
-- Get comments/descriptions on columns
SELECT 
    table_schema,
    table_name,
    column_name,
    comment
FROM information_schema.columns
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
    AND comment IS NOT NULL
ORDER BY table_schema, table_name, column_name;

-- Column comments in primary schemas
SELECT 
    table_schema,
    table_name,
    column_name,
    comment
FROM information_schema.columns
WHERE table_schema IN ('ANALYTICS', 'S3_STAGES')
    AND comment IS NOT NULL
ORDER BY table_schema, table_name, column_name;

-- ----------------------------------------------------------------------------
-- 16. QUICK OVERVIEW QUERY
-- ----------------------------------------------------------------------------
-- Run this first for a quick overview
SELECT 
    t.table_schema,
    t.table_name,
    t.table_type,
    t.row_count,
    COUNT(c.column_name) as column_count,
    SUM(CASE WHEN c.data_type IN ('DATE', 'TIMESTAMP_NTZ', 'TIMESTAMP_LTZ', 'TIMESTAMP_TZ') THEN 1 ELSE 0 END) as date_column_count,
    SUM(CASE WHEN UPPER(c.column_name) LIKE '%ID%' THEN 1 ELSE 0 END) as id_column_count,
    SUM(CASE WHEN UPPER(c.column_name) LIKE '%STATUS%' THEN 1 ELSE 0 END) as status_column_count
FROM information_schema.tables t
LEFT JOIN information_schema.columns c
    ON t.table_schema = c.table_schema
    AND t.table_name = c.table_name
WHERE t.table_schema NOT IN ('INFORMATION_SCHEMA')
GROUP BY t.table_schema, t.table_name, t.table_type, t.row_count
ORDER BY t.table_schema, t.table_name;

-- Quick overview for primary schemas only
SELECT 
    t.table_schema,
    t.table_name,
    t.table_type,
    t.row_count,
    COUNT(c.column_name) as column_count,
    SUM(CASE WHEN c.data_type IN ('DATE', 'TIMESTAMP_NTZ', 'TIMESTAMP_LTZ', 'TIMESTAMP_TZ') THEN 1 ELSE 0 END) as date_column_count,
    SUM(CASE WHEN UPPER(c.column_name) LIKE '%ID%' THEN 1 ELSE 0 END) as id_column_count,
    SUM(CASE WHEN UPPER(c.column_name) LIKE '%STATUS%' THEN 1 ELSE 0 END) as status_column_count
FROM information_schema.tables t
LEFT JOIN information_schema.columns c
    ON t.table_schema = c.table_schema
    AND t.table_name = c.table_name
WHERE t.table_schema IN ('ANALYTICS', 'S3_STAGES')
GROUP BY t.table_schema, t.table_name, t.table_type, t.row_count
ORDER BY t.table_schema, t.table_name;

-- ----------------------------------------------------------------------------
-- 17. COMPARE ANALYTICS VS S3_STAGES
-- ----------------------------------------------------------------------------
-- Compare table counts and types between schemas
SELECT 
    table_schema,
    table_type,
    COUNT(*) as object_count,
    SUM(row_count) as total_rows,
    SUM(bytes) as total_bytes
FROM information_schema.tables
WHERE table_schema IN ('ANALYTICS', 'S3_STAGES')
GROUP BY table_schema, table_type
ORDER BY table_schema, table_type;

-- ----------------------------------------------------------------------------
-- 18. FIND POTENTIAL RELATIONSHIPS BETWEEN SCHEMAS
-- ----------------------------------------------------------------------------
-- Find columns with similar names across ANALYTICS and S3_STAGES
-- This can help identify potential join relationships
SELECT 
    c1.table_schema as schema1,
    c1.table_name as table1,
    c1.column_name,
    c1.data_type as data_type1,
    c2.table_schema as schema2,
    c2.table_name as table2,
    c2.data_type as data_type2
FROM information_schema.columns c1
JOIN information_schema.columns c2
    ON UPPER(c1.column_name) = UPPER(c2.column_name)
    AND c1.data_type = c2.data_type
WHERE c1.table_schema = 'ANALYTICS'
    AND c2.table_schema = 'S3_STAGES'
    AND UPPER(c1.column_name) LIKE '%ID%'
ORDER BY c1.column_name, c1.table_name, c2.table_name;
