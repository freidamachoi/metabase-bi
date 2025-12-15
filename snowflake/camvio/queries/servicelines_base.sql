-- ============================================================================
-- Camvio – Servicelines Base - BASE MODEL
-- ============================================================================
-- Purpose:
--   Reusable base model at serviceline grain for subscriber, feature, and
--   location analysis in Metabase.
--
-- Grain:
--   One row per record in CAMVIO.PUBLIC.SERVICELINES (i.e., per serviceline).
--
-- Source / Usage in Metabase:
--   1. Create model: "Camvio – Servicelines (Base)"
--   2. Use this SQL as the model query.
--   3. Create additional/enhanced models (e.g. "Subscribers by Account Type",
--      "Subscribers by Feature", "Subscribers by Area") on top of this base.
--
-- Joins:
--   - CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS     (account context)
--   - CAMVIO.PUBLIC.SERVICELINE_ADDRESSES (service location, mapping IDs)
--   - CAMVIO.PUBLIC.SERVICELINE_FEATURES  (plans/features per serviceline)
--
-- Key Derived Columns:
--   - IS_ACTIVE_SERVICELINE : 1 when serviceline is currently active
--   - SERVICE_TYPE          : 'Internet' / 'Voice' / 'Other' from SERVICE_MODEL
--   - SERVICE_LOCATION_KEY  : stable key for location-level analysis
--
-- See: docs/metabase/camvio/models/SERVICELINES_BASE.md for documentation.
-- ============================================================================

WITH feature_agg AS (
  -- Aggregate plans/features at the serviceline grain so the base model
  -- exposes one row per serviceline with comma-separated feature lists.
  SELECT
    ACCOUNT_ID,
    ACCOUNT_NUMBER,
    SERVICE_MODEL,
    SERVICELINE_NUMBER,
    LISTAGG(DISTINCT PLAN, ', ')     WITHIN GROUP (ORDER BY PLAN)    AS PLANS,
    LISTAGG(DISTINCT FEATURE, ', ')  WITHIN GROUP (ORDER BY FEATURE) AS FEATURES
  FROM CAMVIO.PUBLIC.SERVICELINE_FEATURES
  GROUP BY
    ACCOUNT_ID,
    ACCOUNT_NUMBER,
    SERVICE_MODEL,
    SERVICELINE_NUMBER
)

SELECT
    -- =======================================================================
    -- Serviceline keys
    -- =======================================================================
    s.ACCOUNT_ID,
    s.ACCOUNT_NUMBER,
    s.SERVICE_MODEL,
    s.SERVICELINE_NUMBER,

    -- =======================================================================
    -- Account context (from CUSTOMER_ACCOUNTS)
    -- =======================================================================
    ca.ACCOUNT_STATUS,
    ca.ACCOUNT_TYPE,
    ca.ACCOUNT_CREATED,
    ca.BILLCYCLE,
    ca.AUTOPAY_FLAG,

    -- =======================================================================
    -- Serviceline status and dates
    -- =======================================================================
    s.SERVICELINE_STATUS,
    s.SERVICELINE_STARTDATE,
    s.SERVICELINE_ENDDATE,

    -- =======================================================================
    -- Address / location (from SERVICELINE_ADDRESSES)
    -- =======================================================================
    a.SERVICELINE_ADDRESS1,
    a.SERVICELINE_ADDRESS2,
    a.SERVICELINE_ADDRESS3,
    a.SERVICELINE_ADDRESS_CITY,
    a.SERVICELINE_ADDRESS_STATE,
    CAST(a.SERVICELINE_ADDRESS_ZIPCODE AS VARCHAR) AS SERVICELINE_ADDRESS_ZIPCODE,
    a.SERVICELINE_ADDRESS_VERIFIED,
    a.MAPPING_ADDRESS_ID,
    a.MAPPING_AREA_ID,
    a.MAPPING_REF_AREA1,
    a.SERVICELINE_LATITUDE,
    a.SERVICELINE_LONGITUDE,

    -- =======================================================================
    -- Aggregated plans/features (from SERVICELINE_FEATURES)
    -- =======================================================================
    f.PLANS,
    f.FEATURES,

    -- =======================================================================
    -- Reusable derived fields
    -- =======================================================================
    -- Active serviceline flag, matching existing subscriber logic:
    CASE
      WHEN s.SERVICELINE_STATUS ILIKE '%active%'
       AND s.SERVICELINE_ENDDATE IS NULL
      THEN 1 ELSE 0
    END AS IS_ACTIVE_SERVICELINE,

    -- Normalized service type based on SERVICE_MODEL:
    CASE
      WHEN LOWER(s.SERVICE_MODEL) LIKE '%internet%' THEN 'Internet'
      WHEN LOWER(s.SERVICE_MODEL) LIKE '%voice%'    THEN 'Voice'
      ELSE 'Other'
    END AS SERVICE_TYPE,

    -- Hybrid service location key: prefers MAPPING_ADDRESS_ID but falls back
    -- to a deterministic hash of normalized address fields. This allows
    -- building location-level models later without changing this base.
    COALESCE(
      a.MAPPING_ADDRESS_ID,
      MD5(
        CONCAT_WS(
          '|',
          UPPER(TRIM(a.SERVICELINE_ADDRESS1)),
          UPPER(TRIM(a.SERVICELINE_ADDRESS_CITY)),
          UPPER(TRIM(a.SERVICELINE_ADDRESS_STATE)),
          CAST(a.SERVICELINE_ADDRESS_ZIPCODE AS VARCHAR)
        )
      )
    ) AS SERVICE_LOCATION_KEY

FROM CAMVIO.PUBLIC.SERVICELINES s
JOIN CAMVIO.PUBLIC.CUSTOMER_ACCOUNTS ca
  ON s.ACCOUNT_ID = ca.ACCOUNT_ID
LEFT JOIN CAMVIO.PUBLIC.SERVICELINE_ADDRESSES a
  ON s.ACCOUNT_ID         = a.ACCOUNT_ID
 AND s.SERVICE_MODEL      = a.SERVICE_MODEL
 AND s.SERVICELINE_NUMBER = a.SERVICELINE_NUMBER
LEFT JOIN feature_agg f
  ON s.ACCOUNT_ID         = f.ACCOUNT_ID
 AND s.ACCOUNT_NUMBER     = f.ACCOUNT_NUMBER
 AND s.SERVICE_MODEL      = f.SERVICE_MODEL
 AND s.SERVICELINE_NUMBER = f.SERVICELINE_NUMBER;

-- ============================================================================
-- Notes:
-- - This is a Camvio-only base model (no Fybe join).
-- - Subscriber counts should continue to use the established rule:
--     "Active subscriber" ≈ active Internet serviceline, i.e.
--       IS_ACTIVE_SERVICELINE = 1 AND SERVICE_TYPE = 'Internet'.
-- - Additional Metabase models can aggregate this base by:
--     ACCOUNT_TYPE, MAPPING_AREA_ID, SERVICE_MODEL, PLANS, FEATURES, etc.
-- ============================================================================


