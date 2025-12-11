-- ============================================================================
-- Service Orders and Trouble Tickets with Appointments (Base)
-- ============================================================================
-- Purpose: Get all service orders and trouble tickets, with appointments when they exist
-- 
-- Architecture:
-- - UNION ALL of SERVICEORDERS and TROUBLE_TICKETS (base data)
-- - Feature aggregates for service orders
-- - Concatenated notes for trouble tickets
-- - OUTER JOIN to APPOINTMENTS (when they exist)
-- - Supporting tables: SERVICELINES, SERVICELINE_ADDRESSES, CUSTOMER_ACCOUNTS
--
-- METABASE USAGE:
-- This query can be used as a BASE MODEL in Metabase to show all service orders
-- and trouble tickets, with appointments as optional enrichment. This provides
-- complete coverage of all records, not just those with appointments.
-- ============================================================================

WITH base_data AS (
    -- Service Orders
    SELECT 
        'Service Order' AS RECORD_TYPE,
        
        -- Common Identifiers
        so.ACCOUNT_ID,
        CAST(so.SERVICELINE_NUMBER AS VARCHAR) AS SERVICELINE_NUMBER,
        
        -- Service Order Specific Fields
        so.SERVICEORDER_ID,
        so.ORDER_ID,
        so.STATUS,
        so.SERVICEORDER_TYPE,
        INITCAP(REPLACE(so.SALES_AGENT, '.', ' ')) AS SALES_AGENT,  -- Required: Sales agent for commissions (title case, split on '.')
        so.CREATED_DATETIME,
        so.MODIFIED_DATETIME,
        
        -- Trouble Ticket Specific Fields (NULL for service orders)
        CAST(NULL AS NUMBER) AS TROUBLE_TICKET_ID,
        CAST(NULL AS TEXT) AS REPORTED_NAME,
        CAST(NULL AS TEXT) AS RESOLUTION_NAME,
        CAST(NULL AS TEXT) AS TROUBLE_TICKET_NOTES,
        
        -- Join Keys for Appointments
        so.ORDER_ID AS APPOINTMENT_JOIN_ORDER_ID,
        CAST(NULL AS NUMBER) AS APPOINTMENT_JOIN_TROUBLE_TICKET_ID,
        so.SERVICELINE_NUMBER AS APPOINTMENT_JOIN_SERVICELINE_NUMBER,
        so.ACCOUNT_ID AS APPOINTMENT_JOIN_ACCOUNT_ID
        
    FROM CAMVIO.PUBLIC.SERVICEORDERS so
    WHERE CAST(so.SERVICELINE_NUMBER AS VARCHAR) NOT IN ('0', '0000000000')
        AND so.SERVICELINE_NUMBER IS NOT NULL
    
    UNION ALL
    
    -- Trouble Tickets
    SELECT 
        'Trouble Ticket' AS RECORD_TYPE,
        
        -- Common Identifiers
        tt.ACCOUNT_ID,
        CAST(tt.SERVICELINE_NUMBER AS VARCHAR) AS SERVICELINE_NUMBER,
        
        -- Service Order Specific Fields (NULL for trouble tickets)
        CAST(NULL AS NUMBER) AS SERVICEORDER_ID,
        CAST(NULL AS NUMBER) AS ORDER_ID,
        tt.STATUS,
        CAST(NULL AS TEXT) AS SERVICEORDER_TYPE,
        CAST(NULL AS TEXT) AS SALES_AGENT,
        tt.CREATED_DATETIME,
        tt.MODIFIED_DATETIME,
        
        -- Trouble Ticket Specific Fields
        tt.TROUBLE_TICKET_ID,
        tt.REPORTED_NAME,
        tt.RESOLUTION_NAME,
        ttn.CONCATENATED_NOTES AS TROUBLE_TICKET_NOTES,
        
        -- Join Keys for Appointments
        CAST(NULL AS NUMBER) AS APPOINTMENT_JOIN_ORDER_ID,
        tt.TROUBLE_TICKET_ID AS APPOINTMENT_JOIN_TROUBLE_TICKET_ID,
        tt.SERVICELINE_NUMBER AS APPOINTMENT_JOIN_SERVICELINE_NUMBER,
        tt.ACCOUNT_ID AS APPOINTMENT_JOIN_ACCOUNT_ID
        
    FROM CAMVIO.PUBLIC.TROUBLE_TICKETS tt
    
    -- Concatenate trouble ticket notes per trouble ticket ID
    LEFT JOIN (
        SELECT
            TROUBLE_TICKET_ID,
            LISTAGG(NOTE, ' | ') WITHIN GROUP (ORDER BY CREATED_DATETIME) AS CONCATENATED_NOTES
        FROM CAMVIO.PUBLIC.TROUBLE_TICKET_NOTES
        WHERE NOTE IS NOT NULL
            AND TRIM(NOTE) != ''
        GROUP BY TROUBLE_TICKET_ID
    ) ttn
        ON tt.TROUBLE_TICKET_ID = ttn.TROUBLE_TICKET_ID
    
    WHERE CAST(tt.SERVICELINE_NUMBER AS VARCHAR) NOT IN ('0', '0000000000')
        AND tt.SERVICELINE_NUMBER IS NOT NULL
),

-- Feature aggregates for service orders (exclude invalid SERVICELINE_NUMBER values)
feature_aggregates AS (
    SELECT
        sf.SERVICELINE_NUMBER,
        COUNT(DISTINCT sf.FEATURE) AS FEATURE_COUNT,
        SUM(sf.FEATURE_PRICE * sf.QTY) AS TOTAL_FEATURE_PRICE,
        SUM(sf.FEATURE_PRICE * sf.QTY) AS TOTAL_FEATURE_AMOUNT,
        SUM(sf.QTY) AS TOTAL_FEATURE_QUANTITY
    FROM CAMVIO.PUBLIC.SERVICELINE_FEATURES sf
    WHERE CAST(sf.SERVICELINE_NUMBER AS VARCHAR) NOT IN ('0', '0000000000')
        AND sf.SERVICELINE_NUMBER IS NOT NULL
    GROUP BY sf.SERVICELINE_NUMBER
),

-- Total duration for trouble tickets (calculated based on STATUS)
-- For non-CLOSED: days from CREATED_DATETIME to TODAY
-- For CLOSED: days from CREATED_DATETIME to latest TASK_ENDED
ticket_duration AS (
    SELECT
        tt.TROUBLE_TICKET_ID,
        CASE
            WHEN UPPER(TRIM(tt.STATUS)) = 'CLOSED' THEN
                -- CLOSED: Calculate days from CREATED_DATETIME to latest TASK_ENDED
                DATEDIFF(DAY, tt.CREATED_DATETIME, COALESCE(MAX(ttt.TASK_ENDED), tt.CREATED_DATETIME))
            ELSE
                -- Non-CLOSED: Calculate days from CREATED_DATETIME to TODAY
                DATEDIFF(DAY, tt.CREATED_DATETIME, CURRENT_DATE())
        END AS TOTAL_DURATION_DAYS
    FROM CAMVIO.PUBLIC.TROUBLE_TICKETS tt
    LEFT JOIN CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS ttt
        ON tt.TROUBLE_TICKET_ID = ttt.TROUBLE_TICKET_ID
    GROUP BY tt.TROUBLE_TICKET_ID, tt.STATUS, tt.CREATED_DATETIME
),

-- Latest open task for trouble tickets (TASK_ENDED IS NULL, ordered by TASK_STARTED DESC)
-- Note: Will be filtered to non-CLOSED tickets in the JOIN condition
latest_open_task AS (
    SELECT
        ttt.TROUBLE_TICKET_ID,
        ttt.TASK_NAME,
        INITCAP(REPLACE(ttt.ASSIGNEE, '.', ' ')) AS ASSIGNEE,
        ttt.TASK_STARTED,
        ROW_NUMBER() OVER (
            PARTITION BY ttt.TROUBLE_TICKET_ID
            ORDER BY ttt.TASK_STARTED DESC NULLS LAST
        ) AS rn
    FROM CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS ttt
    WHERE ttt.TASK_ENDED IS NULL
)

SELECT 
    -- Record Type
    bd.RECORD_TYPE,
    
    -- Common Identifiers
    bd.ACCOUNT_ID,
    bd.SERVICELINE_NUMBER,
    
    -- Service Order Fields
    bd.SERVICEORDER_ID,
    bd.ORDER_ID,
    bd.STATUS,
    bd.SERVICEORDER_TYPE,
    bd.SALES_AGENT,
    
    -- Feature Aggregates (populated for service orders with features)
    fa.TOTAL_FEATURE_PRICE,
    fa.TOTAL_FEATURE_AMOUNT,
    fa.FEATURE_COUNT,
    fa.TOTAL_FEATURE_QUANTITY,
    
    -- Trouble Ticket Fields
    bd.TROUBLE_TICKET_ID,
    bd.REPORTED_NAME,
    bd.RESOLUTION_NAME,
    bd.TROUBLE_TICKET_NOTES,
    
    -- Trouble Ticket Task Fields (populated based on STATUS)
    -- Total duration in days - available for all trouble tickets
    -- For non-CLOSED: days from CREATED_DATETIME to TODAY
    -- For CLOSED: days from CREATED_DATETIME to latest TASK_ENDED
    CASE 
        WHEN bd.RECORD_TYPE = 'Trouble Ticket' 
        THEN td.TOTAL_DURATION_DAYS 
        ELSE NULL 
    END AS TOTAL_DURATION_DAYS,
    -- For non-CLOSED tickets: Latest open task information (only one task per ticket)
    CASE 
        WHEN bd.RECORD_TYPE = 'Trouble Ticket' AND UPPER(TRIM(bd.STATUS)) != 'CLOSED' 
        THEN lot.TASK_NAME 
        ELSE NULL 
    END AS LATEST_OPEN_TASK_NAME,
    CASE 
        WHEN bd.RECORD_TYPE = 'Trouble Ticket' AND UPPER(TRIM(bd.STATUS)) != 'CLOSED' 
        THEN lot.ASSIGNEE 
        ELSE NULL 
    END AS LATEST_OPEN_TASK_ASSIGNEE,
    CASE 
        WHEN bd.RECORD_TYPE = 'Trouble Ticket' AND UPPER(TRIM(bd.STATUS)) != 'CLOSED' 
        THEN lot.TASK_STARTED 
        ELSE NULL 
    END AS LATEST_OPEN_TASK_STARTED,
    
    -- Service Model: SERVICEORDER_ADDRESSES for service orders, SERVICELINES for trouble tickets
    COALESCE(soa.SERVICE_MODEL, sl.SERVICE_MODEL) AS SERVICE_MODEL,
    -- Address City: SERVICELINE_ADDRESSES for both (serviceline level), SERVICEORDER_ADDRESSES as fallback for service orders
    COALESCE(sla.SERVICELINE_ADDRESS_CITY, soa.SERVICEORDER_ADDRESS_CITY) AS ADDRESS_CITY,
    
    -- Timestamp Fields (available for both service orders and trouble tickets)
    bd.CREATED_DATETIME,
    bd.MODIFIED_DATETIME,
    
    -- Service Line Creation Date (available for both service orders and trouble tickets via SERVICELINE_NUMBER)
    sl.SERVICELINE_STARTDATE AS SERVICELINE_CREATED_DATETIME,
    
    -- Account Information
    ca.ACCOUNT_TYPE,
    
    -- Appointment Fields (NULL when no appointment exists)
    a.APPOINTMENT_ID,
    a.APPOINTMENT_TYPE,
    a.APPOINTMENT_TYPE_DESCRIPTION,
    a.APPOINTMENT_DATE,
    a.ORDER_ID AS APPOINTMENT_ORDER_ID,
    a.TROUBLE_TICKET_ID AS APPOINTMENT_TROUBLE_TICKET_ID,
    
    -- Indicator Fields
    CASE 
        WHEN a.APPOINTMENT_ID IS NOT NULL THEN true
        ELSE false
    END AS HAS_APPOINTMENT

FROM base_data bd

-- Join Feature Aggregates (only for service orders)
LEFT JOIN feature_aggregates fa
    ON bd.RECORD_TYPE = 'Service Order'
    AND bd.SERVICELINE_NUMBER = fa.SERVICELINE_NUMBER

-- Join Service Order Addresses for service orders (SERVICE_MODEL and city)
LEFT JOIN CAMVIO.PUBLIC.SERVICEORDER_ADDRESSES soa
    ON bd.RECORD_TYPE = 'Service Order'
    AND bd.SERVICEORDER_ID = soa.SERVICEORDER_ID

-- Join Service Lines for SERVICE_MODEL (for trouble tickets, fallback for service orders)
LEFT JOIN CAMVIO.PUBLIC.SERVICELINES sl
    ON bd.SERVICELINE_NUMBER = sl.SERVICELINE_NUMBER

-- Join Service Line Addresses for all records (city fallback for service orders, primary for trouble tickets)
LEFT JOIN CAMVIO.PUBLIC.SERVICELINE_ADDRESSES sla
    ON bd.SERVICELINE_NUMBER = sla.SERVICELINE_NUMBER

-- Join Customer Accounts for account type
LEFT JOIN CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS ca
    ON bd.ACCOUNT_ID = ca.ACCOUNT_ID

-- Join ticket duration (for all trouble tickets)
LEFT JOIN ticket_duration td
    ON bd.RECORD_TYPE = 'Trouble Ticket'
    AND bd.TROUBLE_TICKET_ID = td.TROUBLE_TICKET_ID

-- Join latest open task (only for non-CLOSED trouble tickets)
LEFT JOIN latest_open_task lot
    ON bd.RECORD_TYPE = 'Trouble Ticket'
    AND bd.TROUBLE_TICKET_ID = lot.TROUBLE_TICKET_ID
    AND UPPER(TRIM(bd.STATUS)) != 'CLOSED'
    AND lot.rn = 1

-- OUTER JOIN to Appointments (when they exist)
-- Join using ORDER_ID for service orders, TROUBLE_TICKET_ID for trouble tickets
-- Fallback to SERVICELINE_NUMBER + ACCOUNT_ID only when primary ID is missing AND appointment doesn't have the other type's ID
LEFT JOIN (
    -- Subquery to safely read ORDER_ID by casting to VARCHAR first to avoid read error
    SELECT 
        APPOINTMENT_ID,
        UPPER(TRIM(APPOINTMENT_TYPE)) AS APPOINTMENT_TYPE,
        APPOINTMENT_TYPE_DESCRIPTION,
        APPOINTMENT_DATE,
        TRY_TO_NUMBER(ORDER_ID::VARCHAR) AS ORDER_ID,
        TRY_TO_NUMBER(TROUBLE_TICKET_ID::VARCHAR) AS TROUBLE_TICKET_ID,
        ACCOUNT_ID,
        CAST(SERVICELINE_NUMBER AS VARCHAR) AS SERVICELINE_NUMBER
    FROM CAMVIO.PUBLIC.APPOINTMENTS
    WHERE CAST(SERVICELINE_NUMBER AS VARCHAR) NOT IN ('0', '0000000000')
        AND SERVICELINE_NUMBER IS NOT NULL
) a
    ON (
        -- Service Order joins: ORDER_ID (primary) or SERVICELINE_NUMBER + ACCOUNT_ID (fallback only if appointment has no TROUBLE_TICKET_ID)
        (bd.RECORD_TYPE = 'Service Order' 
         AND (
             (bd.APPOINTMENT_JOIN_ORDER_ID IS NOT NULL AND a.ORDER_ID = bd.APPOINTMENT_JOIN_ORDER_ID)
             OR
             (bd.APPOINTMENT_JOIN_ORDER_ID IS NULL 
              AND a.TROUBLE_TICKET_ID IS NULL 
              AND bd.SERVICELINE_NUMBER = a.SERVICELINE_NUMBER 
              AND bd.ACCOUNT_ID = a.ACCOUNT_ID)
         ))
        OR
        -- Trouble Ticket joins: TROUBLE_TICKET_ID (primary) or SERVICELINE_NUMBER + ACCOUNT_ID (fallback only if appointment has no ORDER_ID)
        (bd.RECORD_TYPE = 'Trouble Ticket'
         AND (
             (bd.APPOINTMENT_JOIN_TROUBLE_TICKET_ID IS NOT NULL AND a.TROUBLE_TICKET_ID = bd.APPOINTMENT_JOIN_TROUBLE_TICKET_ID)
             OR
             (bd.APPOINTMENT_JOIN_TROUBLE_TICKET_ID IS NULL 
              AND a.ORDER_ID IS NULL 
              AND bd.SERVICELINE_NUMBER = a.SERVICELINE_NUMBER 
              AND bd.ACCOUNT_ID = a.ACCOUNT_ID)
         ))
    )

WHERE 
    -- Exclude records where ADDRESS_CITY contains 'GOAT RODEO'
    (COALESCE(sla.SERVICELINE_ADDRESS_CITY, soa.SERVICEORDER_ADDRESS_CITY) IS NULL
     OR COALESCE(sla.SERVICELINE_ADDRESS_CITY, soa.SERVICEORDER_ADDRESS_CITY) NOT LIKE '%GOAT RODEO%')

ORDER BY 
    CASE WHEN a.APPOINTMENT_DATE IS NOT NULL THEN 0 ELSE 1 END,  -- Appointments first
    a.APPOINTMENT_DATE DESC NULLS LAST,
    bd.RECORD_TYPE,
    bd.SERVICEORDER_ID NULLS LAST,
    bd.TROUBLE_TICKET_ID NULLS LAST;

-- ============================================================================
-- Query Structure:
-- 
-- Uses UNION ALL to combine SERVICEORDERS and TROUBLE_TICKETS, then
-- OUTER JOINs to APPOINTMENTS to include appointments when they exist.
-- This provides complete coverage of all service orders and trouble tickets,
-- regardless of whether they have appointments.
--
-- Key Fields:
-- - RECORD_TYPE: "Service Order" or "Trouble Ticket" (distinguishes the source)
-- - SERVICEORDER_ID: Service order identifier (NULL for trouble tickets)
-- - TROUBLE_TICKET_ID: Trouble ticket identifier (NULL for service orders)
-- - ACCOUNT_ID, SERVICELINE_NUMBER: Common fields (available for both types)
-- - HAS_APPOINTMENT: Boolean indicating if an appointment exists
--
-- Service Order Fields:
-- - SERVICEORDER_ID, ORDER_ID, STATUS, SERVICEORDER_TYPE, SALES_AGENT
-- - Feature aggregates (TOTAL_FEATURE_PRICE, etc.) - only populated when features exist
--
-- Trouble Ticket Fields:
-- - TROUBLE_TICKET_ID, STATUS, REPORTED_NAME, RESOLUTION_NAME
-- - TROUBLE_TICKET_NOTES: Concatenated notes per trouble ticket (separated by ' | ')
-- - TOTAL_DURATION_DAYS: Total duration in days (converted from seconds, available for all trouble tickets)
-- - LATEST_OPEN_TASK_NAME, LATEST_OPEN_TASK_ASSIGNEE, LATEST_OPEN_TASK_STARTED: Latest open task info (only for non-CLOSED tickets)
--
-- Appointment Fields (NULL when no appointment):
-- - APPOINTMENT_ID, APPOINTMENT_TYPE, APPOINTMENT_TYPE_DESCRIPTION, APPOINTMENT_DATE
--
-- Common Fields (available for both):
-- - SERVICE_MODEL (from SERVICEORDER_ADDRESSES for service orders, SERVICELINES for trouble tickets)
-- - ADDRESS_CITY (from SERVICELINE_ADDRESSES for both types, with SERVICEORDER_ADDRESSES as fallback for service orders)
-- - CREATED_DATETIME, MODIFIED_DATETIME (from SERVICEORDERS for service orders, TROUBLE_TICKETS for trouble tickets)
-- - SERVICELINE_CREATED_DATETIME (from SERVICELINES.SERVICELINE_STARTDATE for both types via SERVICELINE_NUMBER)
-- - ACCOUNT_TYPE (from CUSTOMER_ACCOUNTS)
--
-- Usage Notes:
-- - Filter by RECORD_TYPE to see only service orders or trouble tickets
-- - Filter by HAS_APPOINTMENT to see records with/without appointments
-- - Feature aggregates only populated for service orders with features
-- - Trouble ticket notes are concatenated per trouble ticket ID
-- - Excludes records where SERVICELINE_NUMBER is '0' or '0000000000' (invalid service line numbers)
-- ============================================================================
