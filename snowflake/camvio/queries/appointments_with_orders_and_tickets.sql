-- ============================================================================
-- Appointments with Service Orders and Trouble Tickets
-- ============================================================================
-- Purpose: Get all appointments with their associated service orders or trouble tickets
-- 
-- Logic:
-- - APPOINTMENT_TYPE = "O" (letter O) → Related to Service Order (join via ORDER_ID)
-- - APPOINTMENT_TYPE = "TT" → Related to Trouble Ticket (join via TROUBLE_TICKET_ID)
-- Note: APPOINTMENT_TYPE is a string field - comparisons are case-insensitive and trimmed
--
-- METABASE USAGE:
-- This query can be used as a BASE MODEL in Metabase to show all appointments
-- with their related service orders or trouble tickets
-- ============================================================================

SELECT 
    -- Appointment Fields
    a.APPOINTMENT_ID,
    a.APPOINTMENT_TYPE,
    a.APPOINTMENT_TYPE_DESCRIPTION,
    a.APPOINTMENT_DATE,
    a.ORDER_ID,  -- Numeric ORDER_ID from appointments
    a.TROUBLE_TICKET_ID,  -- Numeric TROUBLE_TICKET_ID from appointments
    a.ACCOUNT_ID,
    a.SERVICELINE_NUMBER,  -- VARCHAR for fallback joins
    
    -- Service Order Fields (populated when APPOINTMENT_TYPE = "0")
    so.SERVICEORDER_ID,
    so.ORDER_ID AS SO_ORDER_ID,    -- Service order ORDER_ID (numeric)
    so.STATUS AS SO_STATUS,
    so.SERVICEORDER_TYPE,
    CAST(so.SERVICELINE_NUMBER AS VARCHAR) AS SO_SERVICELINE_NUMBER,  -- VARCHAR for fallback joins
    so.ACCOUNT_ID AS SO_ACCOUNT_ID,
    -- Service Model from service line (always available for service orders with service lines)
    sl.SERVICE_MODEL,
    -- Service Line Address (from SERVICELINE_ADDRESSES)
    sa.SERVICELINE_ADDRESS_CITY,
    -- Feature aggregates for service orders (NULL for trouble tickets or service orders without features)
    fa.TOTAL_FEATURE_PRICE,
    fa.TOTAL_FEATURE_AMOUNT,
    fa.FEATURE_COUNT,
    fa.TOTAL_FEATURE_QUANTITY,
    
    -- Trouble Ticket Fields (populated when APPOINTMENT_TYPE = "TT")
    tt.TROUBLE_TICKET_ID AS TT_TROUBLE_TICKET_ID,  -- Numeric trouble ticket ID from TROUBLE_TICKETS table
    tt.STATUS AS TT_STATUS,
    CAST(tt.SERVICELINE_NUMBER AS VARCHAR) AS TT_SERVICELINE_NUMBER,  -- VARCHAR for fallback joins
    tt.ACCOUNT_ID AS TT_ACCOUNT_ID,
    
    -- Common Fields
    ca.ACCOUNT_TYPE,
    
    -- Indicator Fields
    CASE 
        WHEN a.APPOINTMENT_TYPE = 'O' THEN 'Service Order'  -- 'O' (letter O) for service orders
        WHEN a.APPOINTMENT_TYPE = 'TT' THEN 'Trouble Ticket'  -- 'TT' for trouble tickets
        ELSE 'Unknown'
    END AS APPOINTMENT_RELATION_TYPE,
    
    CASE 
        WHEN a.APPOINTMENT_TYPE = 'O' AND so.SERVICEORDER_ID IS NOT NULL THEN true  -- 'O' (letter O) for service orders
        WHEN a.APPOINTMENT_TYPE = 'TT' AND tt.TROUBLE_TICKET_ID IS NOT NULL THEN true  -- 'TT' for trouble tickets
        ELSE false
    END AS HAS_RELATED_RECORD

FROM (
    -- Subquery to safely read ORDER_ID by casting to VARCHAR first to avoid read error
    -- This avoids the "Numeric value 'I_0000009005' is not recognized" error during table read
    -- ORDER_ID column is numeric but contains some string values - we convert those to NULL
    SELECT 
        APPOINTMENT_ID,
        UPPER(TRIM(APPOINTMENT_TYPE)) AS APPOINTMENT_TYPE,  -- Normalize: uppercase and trim for consistent comparison
        APPOINTMENT_TYPE_DESCRIPTION,
        APPOINTMENT_DATE,
        TRY_TO_NUMBER(ORDER_ID::VARCHAR) AS ORDER_ID,  -- Cast to VARCHAR first, then convert to number (NULL if fails)
        TRY_TO_NUMBER(TROUBLE_TICKET_ID::VARCHAR) AS TROUBLE_TICKET_ID,  -- Convert to number, NULL if conversion fails
        ACCOUNT_ID,
        CAST(SERVICELINE_NUMBER AS VARCHAR) AS SERVICELINE_NUMBER  -- Cast to VARCHAR for fallback joins
    FROM CAMVIO.PUBLIC.APPOINTMENTS
) a

-- Join to Customer Accounts (common to both)
LEFT JOIN CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS ca
    ON a.ACCOUNT_ID = ca.ACCOUNT_ID

-- Join to Service Orders when APPOINTMENT_TYPE = "O" (letter O)
-- Join using ORDER_ID (better join field than SERVICELINE_NUMBER + ACCOUNT_ID)
-- APPOINTMENT_TYPE is normalized to uppercase in subquery, so 'O' matches regardless of case
LEFT JOIN CAMVIO.PUBLIC.SERVICEORDERS so
    ON a.APPOINTMENT_TYPE = 'O'  -- 'O' (letter O) for service orders
    AND (
        -- Primary join: ORDER_ID (when conversion succeeded)
        (a.ORDER_ID IS NOT NULL AND a.ORDER_ID = so.ORDER_ID)
        OR
        -- Fallback join: SERVICELINE_NUMBER + ACCOUNT_ID (when ORDER_ID conversion failed)
        (a.SERVICELINE_NUMBER = CAST(so.SERVICELINE_NUMBER AS VARCHAR) AND a.ACCOUNT_ID = so.ACCOUNT_ID)
    )

-- Join to Service Lines to get SERVICE_MODEL (always available for service orders with service lines)
LEFT JOIN CAMVIO.PUBLIC.SERVICELINES sl
    ON so.SERVICELINE_NUMBER = sl.SERVICELINE_NUMBER

-- Join to Service Line Addresses to get address information
LEFT JOIN CAMVIO.PUBLIC.SERVICELINE_ADDRESSES sa
    ON so.SERVICELINE_NUMBER = sa.SERVICELINE_NUMBER

-- Feature aggregates (only for service orders with features)
-- Exclude invalid SERVICELINE_NUMBER values ('0', '0000000000') from aggregation
LEFT JOIN (
    SELECT
        sf.SERVICELINE_NUMBER,
        COUNT(DISTINCT sf.FEATURE) AS FEATURE_COUNT,
        SUM(sf.FEATURE_PRICE * sf.QTY) AS TOTAL_FEATURE_PRICE,  -- Total price (price × quantity) for all features
        SUM(sf.FEATURE_PRICE * sf.QTY) AS TOTAL_FEATURE_AMOUNT,  -- Total amount (price × quantity) for all features
        SUM(sf.QTY) AS TOTAL_FEATURE_QUANTITY
    FROM CAMVIO.PUBLIC.SERVICELINE_FEATURES sf
    WHERE CAST(sf.SERVICELINE_NUMBER AS VARCHAR) NOT IN ('0', '0000000000')
        AND sf.SERVICELINE_NUMBER IS NOT NULL
    GROUP BY sf.SERVICELINE_NUMBER
) fa
    ON so.SERVICELINE_NUMBER = fa.SERVICELINE_NUMBER

-- Join to Trouble Tickets when APPOINTMENT_TYPE = "TT"
-- Join using TROUBLE_TICKET_ID (better join field than SERVICELINE_NUMBER + ACCOUNT_ID)
-- APPOINTMENT_TYPE is normalized to uppercase in subquery, so 'TT' matches regardless of case
LEFT JOIN CAMVIO.PUBLIC.TROUBLE_TICKETS tt
    ON a.APPOINTMENT_TYPE = 'TT'  -- 'TT' for trouble tickets
    AND (
        -- Primary join: TROUBLE_TICKET_ID (when conversion succeeded)
        (a.TROUBLE_TICKET_ID IS NOT NULL AND a.TROUBLE_TICKET_ID = tt.TROUBLE_TICKET_ID)
        OR
        -- Fallback join: SERVICELINE_NUMBER + ACCOUNT_ID (when TROUBLE_TICKET_ID conversion failed)
        (a.SERVICELINE_NUMBER = CAST(tt.SERVICELINE_NUMBER AS VARCHAR) AND a.ACCOUNT_ID = tt.ACCOUNT_ID)
    )

WHERE a.SERVICELINE_NUMBER NOT IN ('0', '0000000000')
    AND a.SERVICELINE_NUMBER IS NOT NULL

ORDER BY a.APPOINTMENT_DATE DESC NULLS LAST, a.APPOINTMENT_ID;

-- ============================================================================
-- Query Structure:
-- 
-- Uses LEFT JOINs to include all appointments, even if the related
-- service order or trouble ticket doesn't exist (or join keys don't match)
--
-- Key Fields:
-- - APPOINTMENT_ID: Unique appointment identifier
-- - APPOINTMENT_TYPE: "O" (letter O) for service orders, "TT" for trouble tickets
-- - APPOINTMENT_RELATION_TYPE: Human-readable type indicator
-- - HAS_RELATED_RECORD: Boolean indicating if join was successful
--
-- Service Order Fields (when APPOINTMENT_TYPE = "O"):
-- - SERVICEORDER_ID, SO_STATUS, SERVICEORDER_TYPE, SERVICE_MODEL (from SERVICELINES), SERVICELINE_ADDRESS_CITY, etc.
--
-- Trouble Ticket Fields (when APPOINTMENT_TYPE = "TT"):
-- - TROUBLE_TICKET_ID, TT_STATUS, etc.
--
-- Usage Notes:
-- - Filter by APPOINTMENT_TYPE to see only service orders or trouble tickets
-- - Use HAS_RELATED_RECORD to identify appointments without matching records
-- - Primary join keys: ORDER_ID (for service orders) and TROUBLE_TICKET_ID (for trouble tickets)
-- - Fallback join keys: SERVICELINE_NUMBER + ACCOUNT_ID (used when ID is NULL or conversion failed)
-- - ORDER_ID and TROUBLE_TICKET_ID are numeric across all tables
-- - Excludes appointments where SERVICELINE_NUMBER is '0' or '0000000000' (invalid service line numbers)
-- - Feature aggregates subquery also excludes invalid SERVICELINE_NUMBER values to prevent incorrect calculations
-- - SERVICE_MODEL comes from SERVICELINES table (always available for service orders with service lines)
-- - Feature aggregates only populated when service orders have features
-- ============================================================================
