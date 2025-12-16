-- ============================================================================
-- Trouble Tickets with Visit Type and Partner (30 Day TT Only)
-- ============================================================================
-- Purpose:
--   Get trouble tickets from "Appointments with Orders and Tickets" where
--   "30 Day TT" is true, joined with "Combined Installs and Trouble Calls (Enriched)"
--   to get only VISIT_TYPE and Partner.
--
-- Requirements:
--   - Only records where 30 Day TT = true (Trouble Ticket within 30 days of serviceline start)
--   - All fields from Appointments with Orders and Tickets (Enriched)
--   - Only VISIT_TYPE and Partner from Combined Installs and Trouble Calls (Enriched)
--   - Single record per row (deduplication)
--
-- Join Key:
--   TROUBLE_TICKET_ID
--
-- Note: Partner is a custom column. This query includes ASSIGNEE which is used
--       to create the Partner custom column in Metabase using the Partner mapping.
-- ============================================================================

WITH appointments_30day_tt AS (
    -- Get all Trouble Ticket records from Appointments with Orders and Tickets
    -- Filter for 30 Day TT = true (within 30 days of serviceline start)
    SELECT 
        bd.TROUBLE_TICKET_ID,
        bd.ACCOUNT_ID,
        bd.SERVICELINE_NUMBER,
        bd.STATUS,
        bd.CREATED_DATETIME,
        bd.MODIFIED_DATETIME,
        bd.REPORTED_NAME,
        bd.RESOLUTION_NAME,
        bd.TROUBLE_TICKET_NOTES,
        sl.SERVICELINE_STARTDATE AS SERVICELINE_CREATED_DATETIME,
        COALESCE(soa.SERVICE_MODEL, sl.SERVICE_MODEL) AS SERVICE_MODEL,
        COALESCE(sla.SERVICELINE_ADDRESS_CITY, soa.SERVICEORDER_ADDRESS_CITY) AS ADDRESS_CITY,
        ca.ACCOUNT_TYPE,
        td.TOTAL_DURATION_DAYS,
        lot.TASK_NAME AS LATEST_OPEN_TASK_NAME,
        lot.ASSIGNEE AS LATEST_OPEN_TASK_ASSIGNEE,
        lot.TASK_STARTED AS LATEST_OPEN_TASK_STARTED,
        a.APPOINTMENT_ID,
        a.APPOINTMENT_TYPE,
        a.APPOINTMENT_TYPE_DESCRIPTION,
        a.APPOINTMENT_DATE,
        CASE 
            WHEN a.APPOINTMENT_ID IS NOT NULL THEN true
            ELSE false
        END AS HAS_APPOINTMENT
    FROM (
        -- Trouble Tickets from base_data
        SELECT 
            'Trouble Ticket' AS RECORD_TYPE,
            tt.ACCOUNT_ID,
            CAST(tt.SERVICELINE_NUMBER AS VARCHAR) AS SERVICELINE_NUMBER,
            tt.STATUS,
            tt.CREATED_DATETIME,
            tt.MODIFIED_DATETIME,
            tt.TROUBLE_TICKET_ID,
            tt.REPORTED_NAME,
            tt.RESOLUTION_NAME,
            ttn.CONCATENATED_NOTES AS TROUBLE_TICKET_NOTES
        FROM CAMVIO.PUBLIC.TROUBLE_TICKETS tt
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
    ) bd
    
    -- Join Service Lines for SERVICE_MODEL and SERVICELINE_STARTDATE
    LEFT JOIN CAMVIO.PUBLIC.SERVICELINES sl
        ON bd.SERVICELINE_NUMBER = sl.SERVICELINE_NUMBER
    
    -- Join Service Order Addresses (for SERVICE_MODEL fallback)
    LEFT JOIN CAMVIO.PUBLIC.SERVICEORDER_ADDRESSES soa
        ON bd.SERVICELINE_NUMBER = soa.SERVICELINE_NUMBER
    
    -- Join Service Line Addresses (for city)
    LEFT JOIN CAMVIO.PUBLIC.SERVICELINE_ADDRESSES sla
        ON bd.SERVICELINE_NUMBER = sla.SERVICELINE_NUMBER
    
    -- Join Customer Accounts
    LEFT JOIN CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS ca
        ON bd.ACCOUNT_ID = ca.ACCOUNT_ID
    
    -- Join Total Duration
    LEFT JOIN (
        SELECT
            tt.TROUBLE_TICKET_ID,
            CASE
                WHEN UPPER(TRIM(tt.STATUS)) = 'CLOSED' THEN
                    DATEDIFF(DAY, tt.CREATED_DATETIME, COALESCE(MAX(ttt.TASK_ENDED), tt.CREATED_DATETIME))
                ELSE
                    DATEDIFF(DAY, tt.CREATED_DATETIME, CURRENT_DATE())
            END AS TOTAL_DURATION_DAYS
        FROM CAMVIO.PUBLIC.TROUBLE_TICKETS tt
        LEFT JOIN CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS ttt
            ON tt.TROUBLE_TICKET_ID = ttt.TROUBLE_TICKET_ID
        GROUP BY tt.TROUBLE_TICKET_ID, tt.STATUS, tt.CREATED_DATETIME
    ) td
        ON bd.TROUBLE_TICKET_ID = td.TROUBLE_TICKET_ID
    
    -- Join Latest Open Task
    LEFT JOIN (
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
    ) lot
        ON bd.TROUBLE_TICKET_ID = lot.TROUBLE_TICKET_ID
        AND lot.rn = 1
        AND UPPER(TRIM(bd.STATUS)) != 'CLOSED'
    
    -- Join Appointments
    LEFT JOIN (
        SELECT
            APPOINTMENT_ID,
            APPOINTMENT_TYPE,
            APPOINTMENT_TYPE_DESCRIPTION,
            APPOINTMENT_DATE,
            CAST(TROUBLE_TICKET_ID AS NUMBER) AS TROUBLE_TICKET_ID
        FROM CAMVIO.PUBLIC.APPOINTMENTS
        WHERE TROUBLE_TICKET_ID IS NOT NULL
            AND TRY_CAST(TROUBLE_TICKET_ID AS NUMBER) IS NOT NULL
    ) a
        ON bd.TROUBLE_TICKET_ID = a.TROUBLE_TICKET_ID
    
    -- Filter for 30 Day TT = true (within 30 days of serviceline start)
    WHERE DATEDIFF(DAY, sl.SERVICELINE_STARTDATE, bd.CREATED_DATETIME) <= 30
        AND sl.SERVICELINE_STARTDATE IS NOT NULL
        AND bd.CREATED_DATETIME IS NOT NULL
),

combined_visits_partner_only AS (
    -- Get only ASSIGNEE (for Partner) from Combined Installs, deduplicated
    SELECT
        tt.TROUBLE_TICKET_ID,
        INITCAP(REPLACE(lt.ASSIGNEE, '.', ' ')) AS ASSIGNEE,
        ROW_NUMBER() OVER (
            PARTITION BY tt.TROUBLE_TICKET_ID 
            ORDER BY lt.TASK_ENDED DESC NULLS LAST
        ) AS rn
    FROM CAMVIO.PUBLIC.TROUBLE_TICKETS tt
    INNER JOIN (
        SELECT
            trouble_ticket_id,
            task_ended,
            assignee,
            ROW_NUMBER() OVER (
                PARTITION BY trouble_ticket_id
                ORDER BY task_ended DESC NULLS LAST
            ) AS rn
        FROM CAMVIO.PUBLIC.TROUBLE_TICKET_TASKS
        WHERE task_name ILIKE '%Tech Visit%'
            AND task_ended IS NOT NULL
    ) lt 
        ON tt.trouble_ticket_id = lt.trouble_ticket_id
        AND lt.rn = 1
    WHERE tt.status ILIKE '%CLOSED%'
)

SELECT
    -- All fields from Appointments with Orders and Tickets (30 Day TT only)
    a.*,
    
    -- Only ASSIGNEE from Combined Installs (use to create Partner custom column)
    c.ASSIGNEE

FROM appointments_30day_tt a
LEFT JOIN combined_visits_partner_only c
    ON a.TROUBLE_TICKET_ID = c.TROUBLE_TICKET_ID
    AND c.rn = 1  -- Only get one record per TROUBLE_TICKET_ID

-- ============================================================================
-- Notes:
-- - Filtered to only include trouble tickets where days between SERVICELINE_CREATED_DATETIME
--   and CREATED_DATETIME is <= 30 (30 Day TT = true)
-- - Only includes ASSIGNEE from Combined Installs model
-- - Add "Partner" as a custom column in Metabase using ASSIGNEE and the Partner
--   mapping expression from COMBINED_INSTALLS_AND_TROUBLE_TICKETS_ENHANCED.md
-- - Deduplication uses ROW_NUMBER() to ensure single record per TROUBLE_TICKET_ID
-- ============================================================================
