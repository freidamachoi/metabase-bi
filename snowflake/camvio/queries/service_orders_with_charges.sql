-- ============================================================================
-- Service Orders with Service Lines, Features, and Account Charges - BASE MODEL
-- ============================================================================
-- Purpose: Get completed service orders with:
--   - Service lines (including SERVICELINE_STARTDATE)
--   - Service line features (services on the order with rates)
--   - Account recurring credits (recurring charges)
--   - Account other charges/credits (one-time charges)
-- 
-- METABASE USAGE:
-- This query should be used as a BASE MODEL in Metabase:
-- 1. Create model: "Service Orders with Charges (Base)"
-- 2. Use this SQL as the model query
-- 3. Create enhanced model: "Service Orders with Charges (Enhanced)"
-- 4. Base enhanced model on the base model
-- 5. Add custom columns and calculations in the enhanced model
-- 
-- IMPORTANT NOTES:
-- - This query will create multiple rows per service order if there are multiple
--   features (SERVICELINE_FEATURES) or multiple charges (ACCOUNT_RECURRING_CREDITS,
--   ACCOUNT_OTHER_CHARGES_CREDITS) per service order
-- - To get count of services completed, count distinct SERVICEORDER_ID or ORDER_ID
-- - To aggregate charges, sum RECURRING_CREDIT_AMOUNT and OCC_AMOUNT
-- ============================================================================

SELECT
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
    
    -- Service Line Features (services on the order with rates)
    sf.FEATURE,
    sf.FEATURE_PRICE,  -- Rate associated with each service feature
    sf.QTY,
    sf.PLAN,
    sf.START_DATETIME AS FEATURE_START_DATETIME,
    sf.END_DATETIME AS FEATURE_END_DATETIME,
    
    -- Account Recurring Credits (recurring charges)
    arc.RECURRING_CREDIT_NAME,
    arc.RECURRING_CREDIT_DESCRIPTION,
    arc.RECURRING_CREDIT_AMOUNT,  -- Recurring charge amount
    arc.ACCOUNT_RECURRING_STATUS,
    arc.RECURRING_CREDIT_START_DATETIME,
    arc.RECURRING_CREDIT_END_DATETIME,
    arc.ACCOUNT_RECURRING_VALID_FROM,
    arc.ACCOUNT_RECURRING_VALID_TO,
    arc.RECURRING_ITEM_NAME,
    arc.RECURRING_ITEM_DESCRIPTION,
    
    -- Account Other Charges/Credits (one-time charges)
    aocc.OCC_AMOUNT,  -- One-time charge amount
    aocc.OCC_DATETIME,
    aocc.OCC_STATUS,
    aocc.ITEM_TYPE,
    aocc.ITEM_NAME,
    aocc.ITEM_DESCRIPTION,
    aocc.OCC_USER,
    aocc.OCC_LOCATION,
    aocc.NOTES AS OCC_NOTES

FROM CAMVIO.PUBLIC.SERVICEORDERS so

-- Join to Service Lines to get SERVICELINE_STARTDATE
LEFT JOIN CAMVIO.PUBLIC.SERVICELINES sl
    ON so.SERVICELINE_NUMBER = sl.SERVICELINE_NUMBER

-- Join to Service Line Features to get services and rates
LEFT JOIN CAMVIO.PUBLIC.SERVICELINE_FEATURES sf
    ON so.SERVICELINE_NUMBER = sf.SERVICELINE_NUMBER

-- Join to Account Recurring Credits (recurring charges)
LEFT JOIN CAMVIO.PUBLIC.ACCOUNT_RECURRING_CREDITS arc
    ON so.ACCOUNT_ID = arc.ACCOUNT_ID

-- Join to Account Other Charges/Credits (one-time charges)
LEFT JOIN CAMVIO.PUBLIC.ACCOUNT_OTHER_CHARGES_CREDITS aocc
    ON so.ACCOUNT_ID = aocc.ACCOUNT_ID

WHERE UPPER(so.STATUS) = 'COMPLETED';

-- ============================================================================
-- Notes:
-- 
-- 1. MULTIPLE ROWS PER SERVICE ORDER:
--    - This query will create multiple rows if:
--      * A service order has multiple features (SERVICELINE_FEATURES)
--      * A service order has multiple recurring credits (ACCOUNT_RECURRING_CREDITS)
--      * A service order has multiple other charges (ACCOUNT_OTHER_CHARGES_CREDITS)
--    - To get one row per service order, use DISTINCT on SERVICEORDER_ID or ORDER_ID
--    - To get one row per service order + feature, use DISTINCT on SERVICEORDER_ID + FEATURE
--
-- 2. COUNTING SERVICES COMPLETED:
--    - Count distinct SERVICEORDER_ID or ORDER_ID to get number of services completed
--    - Example: COUNT(DISTINCT SERVICEORDER_ID)
--
-- 3. AGGREGATING CHARGES:
--    - Sum RECURRING_CREDIT_AMOUNT for total recurring charges per account/service order
--    - Sum OCC_AMOUNT for total one-time charges per account/service order
--    - Note: These will be duplicated across feature rows if multiple features exist
--
-- 4. SERVICELINE_STARTDATE:
--    - This field comes from SERVICELINES table
--    - May be NULL if service line doesn't exist or SERVICELINE_NUMBER doesn't match
--
-- 5. FEATURE_PRICE:
--    - This is the rate associated with each service feature
--    - May be NULL if no features exist for the service line
--
-- 6. JOIN STRATEGY:
--    - All joins are LEFT JOINs to preserve all completed service orders
--    - Even if service line, features, or charges don't exist, the service order will appear
-- ============================================================================

