-- ============================================================================
-- Camvio Snowflake Discovery Queries
-- ============================================================================
-- Run these queries in the Camvio Snowflake instance to discover structure
-- Use the results to populate SCHEMA_DOCUMENTATION.md
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. LIST ALL AVAILABLE SCHEMAS
-- ----------------------------------------------------------------------------
-- Shows all schemas you have access to
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
-- 3. LIST ALL COLUMNS FOR ALL TABLES/VIEWS
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

-- ----------------------------------------------------------------------------
-- 4. FOCUS ON PUBLIC SCHEMA (Your main schema)
-- ----------------------------------------------------------------------------
-- Tables in PUBLIC schema
SELECT 
    table_name,
    table_type,
    row_count,
    bytes,
    created,
    last_altered
FROM information_schema.tables
WHERE table_schema = 'PUBLIC'
ORDER BY table_name;

-- Columns in PUBLIC schema tables
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
WHERE table_schema = 'PUBLIC'
ORDER BY table_name, ordinal_position;

-- ----------------------------------------------------------------------------
-- 5. FIND PRIMARY KEYS AND UNIQUE CONSTRAINTS
-- ----------------------------------------------------------------------------
-- Primary keys
SELECT 
    tc.table_schema,
    tc.table_name,
    kcu.column_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.constraint_type = 'PRIMARY KEY'
    AND tc.table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY tc.table_schema, tc.table_name, kcu.ordinal_position;

-- All constraints (Primary Keys, Foreign Keys, Unique)
SELECT 
    tc.table_schema,
    tc.table_name,
    tc.constraint_type,
    tc.constraint_name,
    kcu.column_name,
    kcu.ordinal_position
FROM information_schema.table_constraints tc
LEFT JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
WHERE tc.table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY tc.table_schema, tc.table_name, tc.constraint_type, kcu.ordinal_position;

-- ----------------------------------------------------------------------------
-- 6. FIND FOREIGN KEY RELATIONSHIPS
-- ----------------------------------------------------------------------------
-- Foreign keys (if any exist)
SELECT 
    kcu.table_schema AS foreign_table_schema,
    kcu.table_name AS foreign_table_name,
    kcu.column_name AS foreign_column_name,
    ccu.table_schema AS referenced_table_schema,
    ccu.table_name AS referenced_table_name,
    ccu.column_name AS referenced_column_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
    AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
    AND tc.table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY kcu.table_schema, kcu.table_name;

-- ----------------------------------------------------------------------------
-- 7. SEARCH FOR COMMON JOIN KEY FIELDS
-- ----------------------------------------------------------------------------
-- Find columns that might be join keys (PROJECT_ID, ASSET_ID, TASK_ID, etc.)
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
    )
ORDER BY table_schema, table_name, column_name;

-- Specific common keys
SELECT 
    table_schema,
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
    AND UPPER(column_name) IN (
        'PROJECT_ID', 'ASSET_ID', 'TASK_ID', 'CONTRACTOR',
        'PROJECTID', 'ASSETID', 'TASKID',
        'ID', 'KEY', 'PRIMARY_KEY'
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
    )
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

-- ----------------------------------------------------------------------------
-- 10. GET SAMPLE DATA FROM A SPECIFIC TABLE
-- ----------------------------------------------------------------------------
-- Replace 'YOUR_TABLE_NAME' with actual table name
-- Uncomment and modify as needed:

/*
SELECT *
FROM PUBLIC.YOUR_TABLE_NAME
LIMIT 10;
*/

-- Get distinct values for a status column (example)
-- Replace 'YOUR_TABLE_NAME' and 'STATUS_COLUMN' with actual names:

/*
SELECT DISTINCT STATUS_COLUMN, COUNT(*) as count
FROM PUBLIC.YOUR_TABLE_NAME
GROUP BY STATUS_COLUMN
ORDER BY count DESC;
*/

-- ----------------------------------------------------------------------------
-- 11. SUMMARY STATISTICS FOR A TABLE
-- ----------------------------------------------------------------------------
-- Replace 'YOUR_TABLE_NAME' with actual table name:

/*
SELECT 
    COUNT(*) as total_rows,
    COUNT(DISTINCT PROJECT_ID) as distinct_projects,  -- Adjust column names
    MIN(CREATED_DATE) as earliest_date,                -- Adjust column names
    MAX(CREATED_DATE) as latest_date                   -- Adjust column names
FROM PUBLIC.YOUR_TABLE_NAME;
*/

-- ----------------------------------------------------------------------------
-- 12. VIEW DEFINITIONS (if you have access)
-- ----------------------------------------------------------------------------
-- Get the SQL definition of views
SELECT 
    table_schema,
    table_name,
    view_definition
FROM information_schema.views
WHERE table_schema NOT IN ('INFORMATION_SCHEMA')
ORDER BY table_schema, table_name;

-- ----------------------------------------------------------------------------
-- 13. TABLE/VIEW COMMENTS
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

-- ----------------------------------------------------------------------------
-- 14. COLUMN COMMENTS
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

-- ----------------------------------------------------------------------------
-- 15. QUICK OVERVIEW QUERY
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

