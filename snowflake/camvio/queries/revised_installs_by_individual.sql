-- ============================================================================
-- Installs by Individual (Completed) - REVISED BASE MODEL
-- ============================================================================
-- Purpose: Get completed installations by technician, account type, 
--          date of install, and installation address
-- 
-- Core Requirements:
-- 1. Technician (ASSIGNEE)
-- 2. Account Type
-- 3. Date of Install (TASK_ENDED)
-- 4. Address of Installation
--
-- Optimizations:
-- - Removed APPOINTMENTS table (not needed for core requirements)
-- - Removed SERVICELINE_FEATURES table (not needed for basic install tracking)
-- - Kept only essential fields for the core use case
-- - Reduced JOIN complexity for better performance
-- 
-- METABASE USAGE:
-- This query should be used as a BASE MODEL in Metabase:
-- 1. Create model: "Installs by Individual (Base)" or "Installs by Individual (Revised Base)"
-- 2. Use this SQL as the model query
-- 3. Create enhanced model with custom columns as needed
-- ============================================================================

SELECT 
    -- Service Order Identifiers
    latest.ORDER_ID,                   -- Primary identifier (one row per ORDER_ID)
    latest.SERVICEORDER_ID,
    latest.ACCOUNT_ID,
    
    -- Core Requirements
    latest.ASSIGNEE,                    -- Technician/Individual (from latest task)
    ca.ACCOUNT_TYPE,                   -- Account Type
    latest.TASK_ENDED,                 -- Date of Install (latest task ended date)
    latest.TASK_STARTED,               -- Install Start Time (from latest task, for duration calculations)
    
    -- Address Information
    sa.SERVICELINE_ADDRESS1,
    sa.SERVICELINE_ADDRESS2,
    sa.SERVICELINE_ADDRESS_CITY,
    sa.SERVICELINE_ADDRESS_STATE,
    sa.SERVICELINE_ADDRESS_ZIPCODE,
    
    -- Additional Context (minimal, for filtering/grouping)
    latest.STATUS,                     -- Should always be 'COMPLETED' due to filter
    latest.SERVICEORDER_TYPE,          -- Service order type for grouping
    sa.SERVICE_MODEL,                  -- Service model type (filtered to 'INTERNET')
    latest.TASK_NAME                   -- Should always be 'TECHNICIAN VISIT' due to filter

FROM (
    -- Subquery to get the latest task per order
    SELECT 
        so.ORDER_ID,
        so.SERVICEORDER_ID,
        so.ACCOUNT_ID,
        so.STATUS,
        so.SERVICEORDER_TYPE,
        so.SERVICELINE_NUMBER,
        st.ASSIGNEE,
        st.TASK_ENDED,
        st.TASK_STARTED,
        st.TASK_NAME,
        ROW_NUMBER() OVER (
            PARTITION BY so.ORDER_ID 
            ORDER BY st.TASK_ENDED DESC NULLS LAST
        ) as rn
    FROM CAMVIO.PUBLIC.SERVICEORDERS so
    INNER JOIN CAMVIO.PUBLIC.SERVICEORDER_TASKS st 
        ON so.SERVICEORDER_ID = st.SERVICEORDER_ID
    WHERE UPPER(st.TASK_NAME) = 'TECHNICIAN VISIT'
        AND UPPER(so.STATUS) = 'COMPLETED'
        AND st.TASK_ENDED IS NOT NULL
) latest

-- Required: Get account type
INNER JOIN CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS ca 
    ON latest.ACCOUNT_ID = ca.ACCOUNT_ID

-- Required: Get installation address
INNER JOIN CAMVIO.PUBLIC.SERVICELINE_ADDRESSES sa
    ON latest.SERVICELINE_NUMBER = sa.SERVICELINE_NUMBER
    AND UPPER(sa.SERVICE_MODEL) = 'INTERNET'  -- Filter for Internet service only

WHERE latest.rn = 1;  -- Only get the row with the latest TASK_ENDED per ORDER_ID

-- ============================================================================
-- Query Optimizations:
-- 
-- 1. Removed APPOINTMENTS table - not needed for core requirements
--    - Saves one LEFT JOIN
--    - Reduces query complexity
--
-- 2. Removed SERVICELINE_FEATURES table - not needed for basic install tracking
--    - Saves one LEFT JOIN
--    - Reduces query complexity
--    - Can be added back if feature-level analysis is needed
--
-- 3. Added TASK_ENDED IS NOT NULL filter - ensures we only get completed installs
--    - Improves data quality
--    - Reduces NULL handling in downstream analysis
--
-- 4. Added SERVICE_MODEL = 'INTERNET' filter - only Internet service installs
--    - Focuses on specific service type
--    - Changed SERVICELINE_ADDRESSES to INNER JOIN (required for filter)
--
-- 5. Uses ROW_NUMBER() window function - ensures one row per ORDER_ID
--    - Gets the latest TASK_ENDED date per ORDER_ID
--    - If multiple tasks exist, picks the one with the most recent TASK_ENDED
--    - Guarantees deterministic results (one row per ORDER_ID)
--
-- 6. Removed SERVICELINE_NUMBER field - not needed in final output
--
-- 6. Kept essential fields only - reduces data transfer and processing
--
-- Performance Benefits:
-- - Fewer JOINs = faster query execution
-- - Less data transferred = faster results
-- - Window function ensures one row per ORDER_ID with latest TASK_ENDED
-- - INNER JOIN on addresses ensures SERVICE_MODEL filter works correctly
--
-- Note on ROW_NUMBER():
-- - Uses window function to get the latest TASK_ENDED per ORDER_ID
-- - If multiple tasks exist for same ORDER_ID, returns the one with latest TASK_ENDED
-- - Guarantees exactly one row per ORDER_ID (deterministic)
-- - All fields (ASSIGNEE, TASK_STARTED, etc.) come from the row with latest TASK_ENDED
--
-- If you need appointment or feature data later:
-- - Use the original query (installs_by_individual.sql)
-- - Or create a separate model for those use cases
-- ============================================================================

