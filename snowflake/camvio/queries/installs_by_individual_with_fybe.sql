-- ============================================================================
-- Installs by Individual (Completed) - Enhanced with Fybe Data
-- ============================================================================
-- Enhanced version that joins Camvio install data with Fybe Render data
-- Join Key: WORK_PACKAGE (Fybe) = SERVICEORDER_ID (Camvio)
-- ============================================================================

SELECT 
    -- Camvio Service Order fields
    so.ORDER_ID,
    so.ACCOUNT_ID,
    so.STATUS as camvio_status,
    so.SERVICELINE_NUMBER,
    so.SERVICEORDER_TYPE,
    so.SERVICEORDER_ID,
    
    -- Camvio Task fields
    st.TASK_NAME,
    st.TASK_STARTED,
    st.TASK_ENDED,
    st.ASSIGNEE as technician_name,
    
    -- Camvio Customer Account fields
    ca.ACCOUNT_TYPE,
    
    -- Camvio Appointment fields
    a.APPOINTMENT_TYPE,
    a.APPOINTMENT_TYPE_DESCRIPTION,
    a.APPOINTMENT_DATE,
    a.APPOINTMENT_ID,
    
    -- Camvio Service Line Features
    sf.FEATURE,
    sf.FEATURE_PRICE,
    sf.QTY,
    sf.PLAN,
    
    -- Camvio Service Line Addresses
    sa.SERVICE_MODEL,
    sa.SERVICELINE_ADDRESS1,
    sa.SERVICELINE_ADDRESS2,
    sa.SERVICELINE_ADDRESS_CITY,
    sa.SERVICELINE_ADDRESS_STATE,
    sa.SERVICELINE_ADDRESS_ZIPCODE,
    
    -- Fybe Render Tickets (joined via WORK_PACKAGE = SERVICEORDER_ID)
    f.TASK_ID as fybe_task_id,
    f.PROJECT_ID,
    f.TASK as fybe_task,
    f.STATUS as fybe_status,
    f.WORK_PACKAGE,
    f.STREET_ADDRESS as fybe_street_address,
    f.ROAD_NAME,
    f.DATE_RELEASED,
    f.DATE_COMPLETED as fybe_date_completed,
    f.DATE_APPROVED,
    f.CONTRACTOR as fybe_contractor,
    f.WORK_ACTIVITY,
    f.LABELS_WORK_ORDER
    
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
-- Join with Fybe Render Tickets
LEFT JOIN DATA_LAKE.ANALYTICS.VW_RENDER_TICKETS f
    ON CAST(f.WORK_PACKAGE AS NUMBER) = so.SERVICEORDER_ID
WHERE UPPER(st.TASK_NAME) = 'TECHNICIAN VISIT'
    AND UPPER(so.STATUS) = 'COMPLETED';

-- ============================================================================
-- Notes:
-- - Enhanced version includes Fybe Render data
-- - LEFT JOIN ensures Camvio records are preserved even if no Fybe match
-- - WORK_PACKAGE is cast to NUMBER to match SERVICEORDER_ID type
-- - Can add VW_RENDER_UNITS join if unit-level data is needed
-- ============================================================================

