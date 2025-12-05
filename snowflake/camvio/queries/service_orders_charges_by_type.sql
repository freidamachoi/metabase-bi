-- ============================================================================
-- Service Orders - Charges by Type (Aggregated) - BASE MODEL
-- ============================================================================
-- Purpose: Get completed service orders with charges aggregated by type:
--   - Recurring credits grouped by RECURRING_CREDIT_NAME (type)
--   - Other charges/credits grouped by ITEM_TYPE (type)
-- 
-- METABASE USAGE:
-- This query should be used as a BASE MODEL in Metabase:
-- 1. Create model: "Service Orders Charges by Type (Base)"
-- 2. Use this SQL as the model query
-- 3. Create enhanced model: "Service Orders Charges by Type (Enhanced)"
-- 4. Base enhanced model on the base model
-- 5. Add custom columns and calculations in the enhanced model
-- 
-- IMPORTANT NOTES:
-- - This query uses UNION ALL to separate recurring credits and other charges
-- - Recurring credits are grouped by RECURRING_CREDIT_NAME
-- - Other charges are grouped by ITEM_TYPE
-- - One row per service order per charge type
-- ============================================================================

-- Recurring Credits by Type
SELECT
    -- Charge Type Identifier
    'Recurring Credit' AS CHARGE_TYPE,
    
    -- Service Order Identifiers
    so.ORDER_ID,
    so.SERVICEORDER_ID,
    so.ACCOUNT_ID,
    so.ACCOUNT_NUMBER,
    
    -- Service Order Details
    so.STATUS AS SERVICEORDER_STATUS,
    so.SERVICEORDER_TYPE,
    so.SERVICELINE_NUMBER,
    so.SALES_AGENT,  -- Required: Sales agent for commissions
    so.CREATED_DATETIME AS SERVICEORDER_CREATED,
    so.MODIFIED_DATETIME AS SERVICEORDER_MODIFIED,
    so.APPLY_DATE,
    so.TARGET_DATETIME,
    
    -- Service Line Details (from SERVICELINES table)
    sl.SERVICELINE_STARTDATE,  -- Required: Service line start date
    sl.SERVICELINE_ENDDATE,
    sl.SERVICELINE_STATUS,
    sl.SERVICE_MODEL AS SERVICELINE_SERVICE_MODEL,
    
    -- Charge Type and Amount (Recurring Credits)
    arc.RECURRING_CREDIT_NAME AS CHARGE_TYPE_NAME,  -- Type field for recurring credits
    SUM(arc.RECURRING_CREDIT_AMOUNT) AS CHARGE_AMOUNT,  -- Sum by type
    COUNT(*) AS CHARGE_COUNT,  -- Count of charges of this type
    arc.ACCOUNT_RECURRING_STATUS AS CHARGE_STATUS,
    MIN(arc.RECURRING_CREDIT_START_DATETIME) AS CHARGE_EARLIEST_START,
    MAX(arc.RECURRING_CREDIT_END_DATETIME) AS CHARGE_LATEST_END,
    
    -- NULL fields for other charges (to align with UNION)
    CAST(NULL AS TEXT) AS OCC_ITEM_TYPE,
    CAST(NULL AS TEXT) AS OCC_ITEM_NAME,
    CAST(NULL AS TIMESTAMP_NTZ) AS OCC_DATETIME

FROM CAMVIO.PUBLIC.SERVICEORDERS so

-- Join to Service Lines to get SERVICELINE_STARTDATE
LEFT JOIN CAMVIO.PUBLIC.SERVICELINES sl
    ON so.SERVICELINE_NUMBER = sl.SERVICELINE_NUMBER

-- Join to Account Recurring Credits (recurring charges) - grouped by type
INNER JOIN CAMVIO.PUBLIC.ACCOUNT_RECURRING_CREDITS arc
    ON so.ACCOUNT_ID = arc.ACCOUNT_ID

WHERE UPPER(so.STATUS) = 'COMPLETED'

GROUP BY
    -- Service Order Identifiers
    so.ORDER_ID,
    so.SERVICEORDER_ID,
    so.ACCOUNT_ID,
    so.ACCOUNT_NUMBER,
    
    -- Service Order Details
    so.STATUS,
    so.SERVICEORDER_TYPE,
    so.SERVICELINE_NUMBER,
    so.SALES_AGENT,  -- Required: Sales agent for commissions
    so.CREATED_DATETIME,
    so.MODIFIED_DATETIME,
    so.APPLY_DATE,
    so.TARGET_DATETIME,
    
    -- Service Line Details
    sl.SERVICELINE_STARTDATE,
    sl.SERVICELINE_ENDDATE,
    sl.SERVICELINE_STATUS,
    sl.SERVICE_MODEL,
    
    -- Recurring Credits Type
    arc.RECURRING_CREDIT_NAME,
    arc.ACCOUNT_RECURRING_STATUS

UNION ALL

-- Other Charges/Credits by Type
SELECT
    -- Charge Type Identifier
    'Other Charge' AS CHARGE_TYPE,
    
    -- Service Order Identifiers
    so.ORDER_ID,
    so.SERVICEORDER_ID,
    so.ACCOUNT_ID,
    so.ACCOUNT_NUMBER,
    
    -- Service Order Details
    so.STATUS AS SERVICEORDER_STATUS,
    so.SERVICEORDER_TYPE,
    so.SERVICELINE_NUMBER,
    so.SALES_AGENT,  -- Required: Sales agent for commissions
    so.CREATED_DATETIME AS SERVICEORDER_CREATED,
    so.MODIFIED_DATETIME AS SERVICEORDER_MODIFIED,
    so.APPLY_DATE,
    so.TARGET_DATETIME,
    
    -- Service Line Details (from SERVICELINES table)
    sl.SERVICELINE_STARTDATE,  -- Required: Service line start date
    sl.SERVICELINE_ENDDATE,
    sl.SERVICELINE_STATUS,
    sl.SERVICE_MODEL AS SERVICELINE_SERVICE_MODEL,
    
    -- Charge Type and Amount (Other Charges)
    aocc.ITEM_TYPE AS CHARGE_TYPE_NAME,  -- Type field for other charges
    SUM(aocc.OCC_AMOUNT) AS CHARGE_AMOUNT,  -- Sum by type
    COUNT(*) AS CHARGE_COUNT,  -- Count of charges of this type
    aocc.OCC_STATUS AS CHARGE_STATUS,
    MIN(aocc.OCC_DATETIME) AS CHARGE_EARLIEST_START,
    MAX(aocc.OCC_DATETIME) AS CHARGE_LATEST_END,
    
    -- Additional fields for other charges
    aocc.ITEM_TYPE AS OCC_ITEM_TYPE,
    aocc.ITEM_NAME AS OCC_ITEM_NAME,
    MAX(aocc.OCC_DATETIME) AS OCC_DATETIME

FROM CAMVIO.PUBLIC.SERVICEORDERS so

-- Join to Service Lines to get SERVICELINE_STARTDATE
LEFT JOIN CAMVIO.PUBLIC.SERVICELINES sl
    ON so.SERVICELINE_NUMBER = sl.SERVICELINE_NUMBER

-- Join to Account Other Charges/Credits (one-time charges) - grouped by type
INNER JOIN CAMVIO.PUBLIC.ACCOUNT_OTHER_CHARGES_CREDITS aocc
    ON so.ACCOUNT_ID = aocc.ACCOUNT_ID

WHERE UPPER(so.STATUS) = 'COMPLETED'

GROUP BY
    -- Service Order Identifiers
    so.ORDER_ID,
    so.SERVICEORDER_ID,
    so.ACCOUNT_ID,
    so.ACCOUNT_NUMBER,
    
    -- Service Order Details
    so.STATUS,
    so.SERVICEORDER_TYPE,
    so.SERVICELINE_NUMBER,
    so.SALES_AGENT,  -- Required: Sales agent for commissions
    so.CREATED_DATETIME,
    so.MODIFIED_DATETIME,
    so.APPLY_DATE,
    so.TARGET_DATETIME,
    
    -- Service Line Details
    sl.SERVICELINE_STARTDATE,
    sl.SERVICELINE_ENDDATE,
    sl.SERVICELINE_STATUS,
    sl.SERVICE_MODEL,
    
    -- Other Charges Type
    aocc.ITEM_TYPE,
    aocc.ITEM_NAME,
    aocc.OCC_STATUS;

-- ============================================================================
-- Notes:
-- 
-- 1. AGGREGATION BY TYPE:
--    - Recurring credits are grouped by RECURRING_CREDIT_NAME (the "type")
--    - Other charges are grouped by ITEM_TYPE (the "type")
--    - Amounts are summed (SUM) for each type per service order
--
-- 2. UNION ALL STRUCTURE:
--    - First SELECT: Recurring credits by RECURRING_CREDIT_NAME
--    - Second SELECT: Other charges by ITEM_TYPE
--    - CHARGE_TYPE field distinguishes between 'Recurring Credit' and 'Other Charge'
--    - CHARGE_TYPE_NAME contains the actual type (RECURRING_CREDIT_NAME or ITEM_TYPE)
--
-- 3. MULTIPLE ROWS PER SERVICE ORDER:
--    - You'll get one row per service order per recurring credit type
--    - You'll get one row per service order per other charge type
--    - If a service order has 2 recurring credit types and 3 other charge types,
--      you'll get 2 + 3 = 5 rows total
--
-- 4. FILTERING:
--    - Uses INNER JOIN for charges (only shows service orders that have charges)
--    - If you want to see all service orders (even without charges), change to LEFT JOIN
--
-- 5. TO GET TOTAL AMOUNTS BY TYPE ACROSS ALL SERVICE ORDERS:
--    SELECT
--        CHARGE_TYPE,
--        CHARGE_TYPE_NAME,
--        SUM(CHARGE_AMOUNT) AS total_amount_by_type
--    FROM service_orders_charges_by_type
--    GROUP BY CHARGE_TYPE, CHARGE_TYPE_NAME
--    ORDER BY total_amount_by_type DESC;
--
-- 6. TO GET AMOUNTS BY TYPE FOR A SPECIFIC SERVICE ORDER:
--    SELECT
--        CHARGE_TYPE,
--        CHARGE_TYPE_NAME,
--        CHARGE_AMOUNT
--    FROM service_orders_charges_by_type
--    WHERE SERVICEORDER_ID = <your_service_order_id>
--    ORDER BY CHARGE_TYPE, CHARGE_TYPE_NAME;
-- ============================================================================

