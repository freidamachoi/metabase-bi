-- ============================================================================
-- Installs by Individual (Completed) - BASE MODEL
-- ============================================================================
-- Source: Tableau query (transitioning to Metabase)
-- Purpose: Get installs by individual technician who completed the install
-- Filters: TECHNICIAN VISIT tasks on COMPLETED service orders
-- 
-- METABASE USAGE:
-- This query should be used as a BASE MODEL in Metabase:
-- 1. Create model: "Installs by Individual (Base)"
-- 2. Use this SQL as the model query
-- 3. Create enhanced model: "Installs by Individual (Enhanced)"
-- 4. Base enhanced model on the base model
-- 5. Add custom columns and calculations in the enhanced model
-- 
-- See: docs/metabase/models/INSTALLS_BY_INDIVIDUAL.md for details
-- ============================================================================

SELECT 
    so.ORDER_ID,
    so.ACCOUNT_ID,
    so.STATUS,
    so.SERVICELINE_NUMBER,
    so.SERVICEORDER_TYPE,
    so.SERVICEORDER_ID,
    st.TASK_NAME,
    st.TASK_STARTED,
    st.TASK_ENDED,
    st.ASSIGNEE,
    ca.ACCOUNT_TYPE,
    a.APPOINTMENT_TYPE,
    a.APPOINTMENT_TYPE_DESCRIPTION,
    a.APPOINTMENT_DATE,
    a.APPOINTMENT_ID,
    sf.FEATURE,
    sf.FEATURE_PRICE,
    sf.QTY,
    sf.PLAN,
    sa.SERVICE_MODEL,
    sa.SERVICELINE_ADDRESS1,
    sa.SERVICELINE_ADDRESS2,
    sa.SERVICELINE_ADDRESS_CITY,
    sa.SERVICELINE_ADDRESS_STATE,
    sa.SERVICELINE_ADDRESS_ZIPCODE
FROM CAMVIO.PUBLIC.SERVICEORDERS so
JOIN CAMVIO.PUBLIC.SERVICEORDER_TASKS st 
    ON so.SERVICEORDER_ID = st.SERVICEORDER_ID
JOIN CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS ca 
    ON so.ACCOUNT_ID = ca.ACCOUNT_ID
LEFT JOIN CAMVIO.PUBLIC.APPOINTMENTS a
    ON so.ORDER_ID = a.ORDER_ID
LEFT JOIN CAMVIO.PUBLIC.SERVICELINE_FEATURES sf
    ON so.SERVICELINE_NUMBER = sf.SERVICELINE_NUMBER
LEFT JOIN CAMVIO.PUBLIC.SERVICELINE_ADDRESSES sa
    ON so.SERVICELINE_NUMBER = sa.SERVICELINE_NUMBER
WHERE UPPER(st.TASK_NAME) = 'TECHNICIAN VISIT'
    AND UPPER(so.STATUS) = 'COMPLETED';

-- ============================================================================
-- Notes:
-- - This query is Camvio-only (no Fybe join)
-- - Can be enhanced to join with Fybe data using WORK_PACKAGE = SERVICEORDER_ID
-- - ASSIGNEE field contains the technician/individual who completed the install
-- - TASK_ENDED indicates when the technician visit was completed
-- ============================================================================

