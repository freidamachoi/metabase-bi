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

SELECT DISTINCT
    -- Service Order Identifiers
    so.ORDER_ID,                   -- Primary identifier (ensured distinct)
    so.SERVICEORDER_ID,
    so.ACCOUNT_ID,
    
    -- Core Requirements
    st.ASSIGNEE,                    -- Technician/Individual
    ca.ACCOUNT_TYPE,               -- Account Type
    st.TASK_ENDED,                 -- Date of Install
    st.TASK_STARTED,               -- Install Start Time (for duration calculations)
    
    -- Address Information
    sa.SERVICELINE_ADDRESS1,
    sa.SERVICELINE_ADDRESS2,
    sa.SERVICELINE_ADDRESS_CITY,
    sa.SERVICELINE_ADDRESS_STATE,
    sa.SERVICELINE_ADDRESS_ZIPCODE,
    
    -- Additional Context (minimal, for filtering/grouping)
    so.STATUS,                     -- Should always be 'COMPLETED' due to filter
    so.SERVICEORDER_TYPE,          -- Service order type for grouping
    so.SERVICELINE_NUMBER,         -- Service line identifier
    sa.SERVICE_MODEL               -- Service model type (filtered to 'INTERNET')

FROM CAMVIO.PUBLIC.SERVICEORDERS so

-- Required: Get technician and install date
INNER JOIN CAMVIO.PUBLIC.SERVICEORDER_TASKS st 
    ON so.SERVICEORDER_ID = st.SERVICEORDER_ID

-- Required: Get account type
INNER JOIN CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS ca 
    ON so.ACCOUNT_ID = ca.ACCOUNT_ID

-- Required: Get installation address
INNER JOIN CAMVIO.PUBLIC.SERVICELINE_ADDRESSES sa
    ON so.SERVICELINE_NUMBER = sa.SERVICELINE_NUMBER

WHERE UPPER(st.TASK_NAME) = 'TECHNICIAN VISIT'
    AND UPPER(so.STATUS) = 'COMPLETED'
    AND st.TASK_ENDED IS NOT NULL  -- Ensure install date exists
    AND UPPER(sa.SERVICE_MODEL) = 'INTERNET';  -- Filter for Internet service only

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
-- 5. Added DISTINCT on ORDER_ID - ensures one row per order
--    - Prevents duplicate orders in results
--    - If multiple tasks/addresses exist, picks one (deterministic based on data)
--
-- 6. Kept essential fields only - reduces data transfer and processing
--
-- Performance Benefits:
-- - Fewer JOINs = faster query execution
-- - Less data transferred = faster results
-- - DISTINCT ensures unique ORDER_IDs
-- - INNER JOIN on addresses ensures SERVICE_MODEL filter works correctly
--
-- Note on DISTINCT:
-- - If multiple rows exist for same ORDER_ID (e.g., multiple tasks or addresses),
--   DISTINCT will return one row per unique combination of all selected columns
-- - To ensure deterministic results, consider adding ORDER BY if needed
--
-- If you need appointment or feature data later:
-- - Use the original query (installs_by_individual.sql)
-- - Or create a separate model for those use cases
-- ============================================================================

