-- ============================================================================
-- Servicelines Active/Inactive Events
-- ============================================================================
-- Purpose:
--   Create an event log showing when servicelines became active or inactive.
--   This can be grouped by month in Metabase to show monthly counts.
--
-- Approach:
--   - UNION ALL of active events (SERVICELINE_STARTDATE) and inactive events (SERVICELINE_ENDDATE)
--   - Each row represents one event (activation or deactivation)
--   - Can be aggregated by month in Metabase to show trends
--
-- METABASE USAGE:
--   1. Create model: "Servicelines Active/Inactive Events"
--   2. Use this SQL as the model query
--   3. Create a question that:
--      - Groups by MONTH(EVENT_DATE) and EVENT_TYPE
--      - Counts distinct SERVICELINE_NUMBER
--   4. Create a line chart with:
--      - X-axis: EVENT_DATE (grouped by month)
--      - Y-axis: Count of servicelines, split by EVENT_TYPE
-- ============================================================================

WITH servicelines_base AS (
    -- Reuse the servicelines_base query logic (simplified for event log)
    SELECT
        s.ACCOUNT_ID,
        s.ACCOUNT_NUMBER,
        s.SERVICE_MODEL,
        s.SERVICELINE_NUMBER,
        ca.ACCOUNT_STATUS,
        ca.ACCOUNT_TYPE,
        s.SERVICELINE_STATUS,
        s.SERVICELINE_STARTDATE,
        s.SERVICELINE_ENDDATE,
        CASE
            WHEN s.SERVICELINE_STATUS ILIKE '%active%'
             AND s.SERVICELINE_ENDDATE IS NULL
             AND ca.ACCOUNT_STATUS ILIKE '%active%'
            THEN 1 ELSE 0
        END AS IS_ACTIVE_SERVICELINE,
        CASE
            WHEN LOWER(s.SERVICE_MODEL) LIKE '%internet%' THEN 'Internet'
            WHEN LOWER(s.SERVICE_MODEL) LIKE '%voice%'    THEN 'Voice'
            ELSE 'Other'
        END AS SERVICE_TYPE
    FROM CAMVIO.PUBLIC.SERVICELINES s
    JOIN CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS ca
        ON s.ACCOUNT_ID = ca.ACCOUNT_ID
)

-- Active events (when servicelines became active)
SELECT 
    SERVICELINE_STARTDATE AS EVENT_DATE,
    'Active' AS EVENT_TYPE,
    SERVICELINE_NUMBER,
    ACCOUNT_ID,
    ACCOUNT_NUMBER,
    SERVICE_MODEL,
    ACCOUNT_STATUS,
    ACCOUNT_TYPE,
    SERVICELINE_STATUS,
    SERVICE_TYPE,
    IS_ACTIVE_SERVICELINE
FROM servicelines_base
WHERE SERVICELINE_STARTDATE IS NOT NULL

UNION ALL

-- Inactive events (when servicelines became inactive)
SELECT 
    SERVICELINE_ENDDATE AS EVENT_DATE,
    'Inactive' AS EVENT_TYPE,
    SERVICELINE_NUMBER,
    ACCOUNT_ID,
    ACCOUNT_NUMBER,
    SERVICE_MODEL,
    ACCOUNT_STATUS,
    ACCOUNT_TYPE,
    SERVICELINE_STATUS,
    SERVICE_TYPE,
    IS_ACTIVE_SERVICELINE
FROM servicelines_base
WHERE SERVICELINE_ENDDATE IS NOT NULL

ORDER BY EVENT_DATE, EVENT_TYPE;

-- ============================================================================
-- Notes:
-- - Active events use SERVICELINE_STARTDATE as the event date
-- - Inactive events use SERVICELINE_ENDDATE as the event date
-- - In Metabase, group by MONTH(EVENT_DATE) and EVENT_TYPE to get monthly counts
-- - This creates an event log that can be aggregated by month to show trends
-- ============================================================================

