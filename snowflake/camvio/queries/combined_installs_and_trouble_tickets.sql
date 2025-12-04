-- ============================================================================
-- Combined Installs and Trouble Tickets - UNIFIED MODEL
-- ============================================================================
-- Purpose: Combine completed installations and closed trouble tickets
--          into a single unified view of technician visits
-- 
-- Combines:
-- 1. Service Order Installs (INTERNET service, COMPLETED status)
-- 2. Trouble Tickets (CLOSED status, Tech Visit tasks)
--
-- Both use latest TASK_ENDED date per order/ticket
-- 
-- METABASE USAGE:
-- This query creates a unified model showing all technician visits:
-- 1. Create model: "Technician Visits (Combined)" or similar
-- 2. Use this SQL as the model query
-- 3. Add VISIT_TYPE field distinguishes between 'Install' and 'Trouble Ticket'
-- ============================================================================

SELECT 
    -- Visit Type Identifier
    'Install' AS VISIT_TYPE,
    
    -- Identifiers (Install uses ORDER_ID as primary)
    latest.ORDER_ID AS VISIT_ID,                -- Primary identifier for installs
    latest.SERVICEORDER_ID,
    CAST(NULL AS NUMBER) AS TROUBLE_TICKET_ID,  -- NULL for installs
    latest.ACCOUNT_ID,
    
    -- Core Requirements
    latest.ASSIGNEE,                            -- Technician/Individual
    ca.ACCOUNT_TYPE,                           -- Account Type
    latest.TASK_ENDED,                         -- Date of Visit (latest task ended date)
    
    -- Address Information
    sa.SERVICELINE_ADDRESS1,
    sa.SERVICELINE_ADDRESS2,
    sa.SERVICELINE_ADDRESS_CITY,
    sa.SERVICELINE_ADDRESS_STATE,
    CAST(sa.SERVICELINE_ADDRESS_ZIPCODE AS TEXT) AS SERVICELINE_ADDRESS_ZIPCODE,
    
    -- Additional Context
    latest.STATUS,                             -- Service order status
    CAST(NULL AS TEXT) AS TROUBLE_TICKET_STATUS, -- NULL for installs
    latest.SERVICEORDER_TYPE,                  -- Service order type
    sa.SERVICE_MODEL,                         -- Service model (should be 'INTERNET')
    latest.TASK_NAME                           -- Task name

FROM (
    -- Subquery to get the latest task per order (INSTALLS)
    SELECT 
        so.ORDER_ID,
        so.SERVICEORDER_ID,
        so.ACCOUNT_ID,
        so.STATUS,
        so.SERVICEORDER_TYPE,
        so.SERVICELINE_NUMBER,
        st.ASSIGNEE,
        st.TASK_ENDED,
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

WHERE latest.rn = 1  -- Only get the row with the latest TASK_ENDED per ORDER_ID

UNION ALL

SELECT 
    -- Visit Type Identifier
    'Trouble Ticket' AS VISIT_TYPE,
    
    -- Identifiers (Trouble Ticket uses TROUBLE_TICKET_ID as primary)
    CAST(NULL AS NUMBER) AS VISIT_ID,          -- NULL for trouble tickets (use TROUBLE_TICKET_ID)
    CAST(NULL AS NUMBER) AS SERVICEORDER_ID,   -- NULL for trouble tickets
    tt.TROUBLE_TICKET_ID,
    tt.ACCOUNT_ID,
    
    -- Core Requirements
    lt.ASSIGNEE,                               -- Technician/Individual
    ca.ACCOUNT_TYPE,                           -- Account Type
    lt.TASK_ENDED,                             -- Date of Visit (latest task ended date)
    
    -- Address Information
    sa.SERVICELINE_ADDRESS1,
    sa.SERVICELINE_ADDRESS2,
    sa.SERVICELINE_ADDRESS_CITY,
    sa.SERVICELINE_ADDRESS_STATE,
    CAST(sa.SERVICELINE_ADDRESS_ZIPCODE AS TEXT) AS SERVICELINE_ADDRESS_ZIPCODE,
    
    -- Additional Context
    CAST(NULL AS TEXT) AS STATUS,               -- NULL for trouble tickets
    tt.STATUS AS TROUBLE_TICKET_STATUS,        -- Trouble ticket status
    CAST(NULL AS TEXT) AS SERVICEORDER_TYPE,    -- NULL for trouble tickets
    sa.SERVICE_MODEL,                          -- Service model
    lt.TASK_NAME                               -- Task name

FROM CAMVIO.PUBLIC.TROUBLE_TICKETS tt

-- Get latest task per trouble ticket
INNER JOIN (
    SELECT
        trouble_ticket_id,
        task_name,
        task_ended,
        assignee,
        ROW_NUMBER() OVER (
            PARTITION BY trouble_ticket_id
            ORDER BY task_ended DESC NULLS LAST
        ) AS rn
    FROM CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS
    WHERE task_name ILIKE '%Tech Visit%'
        AND task_ended IS NOT NULL
) lt ON tt.trouble_ticket_id = lt.trouble_ticket_id
    AND lt.rn = 1

-- Required: Get account type
INNER JOIN CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS ca 
    ON tt.account_id = ca.account_id

-- Get address (LEFT JOIN in case address doesn't exist)
LEFT JOIN CAMVIO.PUBLIC.SERVICELINE_ADDRESSES sa
    ON tt.serviceline_number = sa.serviceline_number

WHERE tt.status ILIKE '%CLOSED%';

-- ============================================================================
-- Query Structure:
-- 
-- Uses UNION ALL to combine two result sets:
-- 1. INSTALLS: Service orders with COMPLETED status, INTERNET service
-- 2. TROUBLE TICKETS: Closed trouble tickets with Tech Visit tasks
--
-- Common Fields (aligned in both queries):
-- - VISIT_TYPE: 'Install' or 'Trouble Ticket' (distinguishes the source)
-- - VISIT_ID: ORDER_ID for installs, NULL for trouble tickets
-- - TROUBLE_TICKET_ID: NULL for installs, TROUBLE_TICKET_ID for trouble tickets
-- - ASSIGNEE: Technician name
-- - ACCOUNT_TYPE: Account type
-- - TASK_ENDED: Date of visit
-- - Address fields: Installation/ticket address
-- - SERVICE_MODEL: Service model type
--
-- Benefits:
-- - Single unified model for all technician visits
-- - Can filter by VISIT_TYPE to see installs vs trouble tickets
-- - Can aggregate across both types
-- - Consistent structure for reporting
--
-- Usage in Metabase:
-- - Filter by VISIT_TYPE to separate installs and trouble tickets
-- - Use VISIT_ID or TROUBLE_TICKET_ID depending on VISIT_TYPE
-- - Aggregate by ASSIGNEE, ACCOUNT_TYPE, date, etc. across both types
-- ============================================================================

