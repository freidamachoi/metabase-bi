-- ============================================================================
-- Service Orders Commission Detail - BASE MODEL
-- ============================================================================
-- Purpose: Get completed service orders with unified line items for commission calculation:
--   - Features (with rate and quantity)
--   - Recurring credits (with quantity and amount)
--   - One-time charges (with quantity and amount)
-- 
-- Commission Formula: (net feature rate * quantity) - recurring credits + one-time charges
-- 
-- METABASE USAGE:
-- This query should be used as a BASE MODEL in Metabase:
-- 1. Create model: "Service Orders Commission Detail (Base)"
-- 2. Use this SQL as the model query
-- 3. Create enhanced model: "Service Orders Commission Detail (Enhanced)"
-- 4. Base enhanced model on the base model
-- 5. Add custom columns and calculations in the enhanced model
-- 
-- IMPORTANT NOTES:
-- - This query uses UNION ALL to combine features, recurring credits, and one-time charges
-- - Each line represents one item (feature, recurring credit, or one-time charge)
-- - Can be grouped by ORDER_ID to calculate total commission per order
-- - TYPE field distinguishes between 'Feature', 'Recurring Credit', and 'One-Time Charge'
-- ============================================================================

-- Features (Service Line Features)
SELECT
    -- Line Item Type
    'Feature' AS LINE_ITEM_TYPE,
    
    -- Service Order Identifiers
    so.ORDER_ID,
    so.SERVICEORDER_ID,
    so.ACCOUNT_ID,
    so.ACCOUNT_NUMBER,
    
    -- Service Order Details
    so.STATUS AS SERVICEORDER_STATUS,
    so.SERVICEORDER_TYPE,
    so.SERVICELINE_NUMBER,
    INITCAP(REPLACE(so.SALES_AGENT, '.', ' ')) AS SALES_AGENT,  -- Required: Sales agent for commissions (title case, split on '.')
    so.CREATED_DATETIME AS SERVICEORDER_CREATED,
    so.MODIFIED_DATETIME AS SERVICEORDER_MODIFIED,
    so.APPLY_DATE,
    so.TARGET_DATETIME,
    
    -- Service Line Details
    sl.SERVICELINE_STARTDATE,  -- Required: Service line start date
    sl.SERVICELINE_ENDDATE,
    sl.SERVICELINE_STATUS,
    sl.SERVICE_MODEL AS SERVICELINE_SERVICE_MODEL,
    
    -- Feature Details
    sf.FEATURE AS ITEM_NAME,  -- Feature/service name
    sf.PLAN AS ITEM_PLAN,
    sf.FEATURE_PRICE AS RATE,  -- Rate per unit
    sf.QTY AS QUANTITY,  -- Quantity
    CASE WHEN UPPER(sf.FEATURE) LIKE '%PROMO%' THEN -(sf.FEATURE_PRICE * sf.QTY) ELSE sf.FEATURE_PRICE * sf.QTY END AS AMOUNT,  -- Total amount (rate * quantity), negative if contains "PROMO"
    sf.START_DATETIME AS ITEM_START_DATETIME,
    sf.END_DATETIME AS ITEM_END_DATETIME,
    
    -- NULL fields for charges (to align with UNION)
    CAST(NULL AS TEXT) AS RECURRING_CREDIT_NAME,
    CAST(NULL AS TEXT) AS ITEM_TYPE,
    CAST(NULL AS TIMESTAMP_NTZ) AS CHARGE_DATETIME

FROM CAMVIO.PUBLIC.SERVICEORDERS so

-- Join to Service Lines to get SERVICELINE_STARTDATE
LEFT JOIN CAMVIO.PUBLIC.SERVICELINES sl
    ON so.SERVICELINE_NUMBER = sl.SERVICELINE_NUMBER

-- Join to Service Line Features (services on the order with rates)
INNER JOIN CAMVIO.PUBLIC.SERVICELINE_FEATURES sf
    ON so.SERVICELINE_NUMBER = sf.SERVICELINE_NUMBER

WHERE UPPER(so.STATUS) = 'COMPLETED'

UNION ALL

-- Recurring Credits (Account Recurring Credits)
SELECT
    -- Line Item Type
    'Recurring Credit' AS LINE_ITEM_TYPE,
    
    -- Service Order Identifiers
    so.ORDER_ID,
    so.SERVICEORDER_ID,
    so.ACCOUNT_ID,
    so.ACCOUNT_NUMBER,
    
    -- Service Order Details
    so.STATUS AS SERVICEORDER_STATUS,
    so.SERVICEORDER_TYPE,
    so.SERVICELINE_NUMBER,
    INITCAP(REPLACE(so.SALES_AGENT, '.', ' ')) AS SALES_AGENT,  -- Required: Sales agent for commissions (title case, split on '.')
    so.CREATED_DATETIME AS SERVICEORDER_CREATED,
    so.MODIFIED_DATETIME AS SERVICEORDER_MODIFIED,
    so.APPLY_DATE,
    so.TARGET_DATETIME,
    
    -- Service Line Details
    sl.SERVICELINE_STARTDATE,  -- Required: Service line start date
    sl.SERVICELINE_ENDDATE,
    sl.SERVICELINE_STATUS,
    sl.SERVICE_MODEL AS SERVICELINE_SERVICE_MODEL,
    
    -- Recurring Credit Details
    arc.RECURRING_CREDIT_NAME AS ITEM_NAME,  -- Recurring credit name
    CAST(NULL AS TEXT) AS ITEM_PLAN,
    arc.RECURRING_CREDIT_AMOUNT AS RATE,  -- Rate per unit (same as amount for recurring credits)
    1 AS QUANTITY,  -- Quantity = 1 per recurring credit record
    CASE WHEN UPPER(arc.RECURRING_CREDIT_NAME) LIKE '%PROMO%' THEN -arc.RECURRING_CREDIT_AMOUNT ELSE arc.RECURRING_CREDIT_AMOUNT END AS AMOUNT,  -- Total amount, negative if contains "PROMO"
    arc.RECURRING_CREDIT_START_DATETIME AS ITEM_START_DATETIME,
    arc.RECURRING_CREDIT_END_DATETIME AS ITEM_END_DATETIME,
    
    -- Additional fields for recurring credits
    arc.RECURRING_CREDIT_NAME,
    CAST(NULL AS TEXT) AS ITEM_TYPE,
    CAST(NULL AS TIMESTAMP_NTZ) AS CHARGE_DATETIME

FROM CAMVIO.PUBLIC.SERVICEORDERS so

-- Join to Service Lines to get SERVICELINE_STARTDATE
LEFT JOIN CAMVIO.PUBLIC.SERVICELINES sl
    ON so.SERVICELINE_NUMBER = sl.SERVICELINE_NUMBER

-- Join to Account Recurring Credits (recurring charges)
INNER JOIN CAMVIO.PUBLIC.ACCOUNT_RECURRING_CREDITS arc
    ON so.ACCOUNT_ID = arc.ACCOUNT_ID

WHERE UPPER(so.STATUS) = 'COMPLETED'

UNION ALL

-- One-Time Charges (Account Other Charges/Credits)
SELECT
    -- Line Item Type
    'One-Time Charge' AS LINE_ITEM_TYPE,
    
    -- Service Order Identifiers
    so.ORDER_ID,
    so.SERVICEORDER_ID,
    so.ACCOUNT_ID,
    so.ACCOUNT_NUMBER,
    
    -- Service Order Details
    so.STATUS AS SERVICEORDER_STATUS,
    so.SERVICEORDER_TYPE,
    so.SERVICELINE_NUMBER,
    INITCAP(REPLACE(so.SALES_AGENT, '.', ' ')) AS SALES_AGENT,  -- Required: Sales agent for commissions (title case, split on '.')
    so.CREATED_DATETIME AS SERVICEORDER_CREATED,
    so.MODIFIED_DATETIME AS SERVICEORDER_MODIFIED,
    so.APPLY_DATE,
    so.TARGET_DATETIME,
    
    -- Service Line Details
    sl.SERVICELINE_STARTDATE,  -- Required: Service line start date
    sl.SERVICELINE_ENDDATE,
    sl.SERVICELINE_STATUS,
    sl.SERVICE_MODEL AS SERVICELINE_SERVICE_MODEL,
    
    -- One-Time Charge Details
    aocc.ITEM_NAME AS ITEM_NAME,  -- Item name
    CAST(NULL AS TEXT) AS ITEM_PLAN,
    aocc.OCC_AMOUNT AS RATE,  -- Rate per unit (same as amount for one-time charges)
    1 AS QUANTITY,  -- Quantity = 1 per one-time charge record
    CASE WHEN UPPER(aocc.ITEM_NAME) LIKE '%PROMO%' THEN -aocc.OCC_AMOUNT ELSE aocc.OCC_AMOUNT END AS AMOUNT,  -- Total amount, negative if contains "PROMO"
    CAST(NULL AS TIMESTAMP_NTZ) AS ITEM_START_DATETIME,
    CAST(NULL AS TIMESTAMP_NTZ) AS ITEM_END_DATETIME,
    
    -- Additional fields for one-time charges
    CAST(NULL AS TEXT) AS RECURRING_CREDIT_NAME,
    aocc.ITEM_TYPE AS ITEM_TYPE,
    aocc.OCC_DATETIME AS CHARGE_DATETIME

FROM CAMVIO.PUBLIC.SERVICEORDERS so

-- Join to Service Lines to get SERVICELINE_STARTDATE
LEFT JOIN CAMVIO.PUBLIC.SERVICELINES sl
    ON so.SERVICELINE_NUMBER = sl.SERVICELINE_NUMBER

-- Join to Account Other Charges/Credits (one-time charges)
INNER JOIN CAMVIO.PUBLIC.ACCOUNT_OTHER_CHARGES_CREDITS aocc
    ON so.ACCOUNT_ID = aocc.ACCOUNT_ID

WHERE UPPER(so.STATUS) = 'COMPLETED';

-- ============================================================================
-- Notes:
-- 
-- 1. UNIFIED STRUCTURE:
--    - All three types (Features, Recurring Credits, One-Time Charges) are combined
--    - Common fields: ORDER_ID, SERVICEORDER_ID, SALES_AGENT, RATE, QUANTITY, AMOUNT
--    - TYPE field: 'Feature', 'Recurring Credit', or 'One-Time Charge'
--
-- 2. COMMISSION CALCULATION:
--    - Features: AMOUNT = RATE * QUANTITY (positive for commission)
--    - Recurring Credits: AMOUNT = RATE * QUANTITY (negative for commission, subtracts)
--    - One-Time Charges: AMOUNT = RATE * QUANTITY (positive for commission, adds)
--    - Commission per ORDER_ID = SUM(CASE WHEN LINE_ITEM_TYPE = 'Feature' THEN AMOUNT ELSE 0 END)
--                                 - SUM(CASE WHEN LINE_ITEM_TYPE = 'Recurring Credit' THEN AMOUNT ELSE 0 END)
--                                 + SUM(CASE WHEN LINE_ITEM_TYPE = 'One-Time Charge' THEN AMOUNT ELSE 0 END)
--
-- 3. QUANTITY FIELD:
--    - Features: Uses actual QTY from SERVICELINE_FEATURES
--    - Recurring Credits: Set to 1 (each record represents one recurring credit)
--    - One-Time Charges: Set to 1 (each record represents one one-time charge)
--
-- 4. MULTIPLE ROWS PER SERVICE ORDER:
--    - One row per feature (if multiple features exist)
--    - One row per recurring credit (if multiple recurring credits exist)
--    - One row per one-time charge (if multiple one-time charges exist)
--    - Can be grouped by ORDER_ID to get total commission per order
--
-- 5. FILTERING:
--    - Uses INNER JOIN for features and charges (only shows service orders that have them)
--    - If you want to see all service orders (even without features/charges), change to LEFT JOIN
--
-- 6. TO GET COMMISSION PER ORDER:
--    SELECT
--        ORDER_ID,
--        SERVICEORDER_ID,
--        SALES_AGENT,
--        SUM(CASE WHEN LINE_ITEM_TYPE = 'Feature' THEN AMOUNT ELSE 0 END) AS total_feature_amount,
--        SUM(CASE WHEN LINE_ITEM_TYPE = 'Recurring Credit' THEN AMOUNT ELSE 0 END) AS total_recurring_credits,
--        SUM(CASE WHEN LINE_ITEM_TYPE = 'One-Time Charge' THEN AMOUNT ELSE 0 END) AS total_one_time_charges,
--        SUM(CASE WHEN LINE_ITEM_TYPE = 'Feature' THEN AMOUNT ELSE 0 END)
--            - SUM(CASE WHEN LINE_ITEM_TYPE = 'Recurring Credit' THEN AMOUNT ELSE 0 END)
--            + SUM(CASE WHEN LINE_ITEM_TYPE = 'One-Time Charge' THEN AMOUNT ELSE 0 END) AS commission_amount
--    FROM service_orders_commission_detail
--    GROUP BY ORDER_ID, SERVICEORDER_ID, SALES_AGENT
--    ORDER BY commission_amount DESC;
-- ============================================================================

