# Servicelines Base - Metabase Model

## Model Hierarchy

This follows the same two-tier pattern as other Camvio models:

1. **Base Model**: `Camvio – Servicelines (Base)` – raw serviceline-level data with joins and light derived fields.
2. **Enhanced / Aggregate Models**: built on top of the base (e.g. Subscribers by Account Type, Subscribers by Feature, Subscribers by Area).

## Base Model: Camvio – Servicelines (Base)

**Source SQL**: `snowflake/camvio/queries/servicelines_base.sql`  
**Connection**: Camvio Snowflake instance (`CAMVIO-GOFYBE`, schema `PUBLIC`)  
**Grain**: One row per record in `PUBLIC.SERVICELINES` (per serviceline).

### Purpose

- Provide a **single, consistent foundation** for all serviceline- and subscriber-related questions in Metabase.
- Centralize **joins** and **core derived fields** (e.g. active flag, service type, location key).
- Support multiple downstream models:
  - Active subscribers by account type
  - Subscribers by feature/plan
  - Subscribers by geography or mapping area

### Tables Joined

- `SERVICELINES` (main table; serviceline grain)
- `CUSTOMER_ACCOUNTS` (INNER JOIN on `ACCOUNT_ID`)
- `SERVICELINE_ADDRESSES` (LEFT JOIN on `ACCOUNT_ID`, `SERVICE_MODEL`, `SERVICELINE_NUMBER`)
- `SERVICELINE_FEATURES` (aggregated via `feature_agg` CTE; LEFT JOIN on serviceline keys)

### Key Fields

- **Keys / Identifiers**
  - `ACCOUNT_ID`, `ACCOUNT_NUMBER`
  - `SERVICE_MODEL`
  - `SERVICELINE_NUMBER`
  - `SERVICE_LOCATION_KEY` – hybrid location identifier (uses `MAPPING_ADDRESS_ID` when present, else address hash)

- **Account Context (from `CUSTOMER_ACCOUNTS`)**
  - `ACCOUNT_STATUS`
  - `ACCOUNT_TYPE`
  - `ACCOUNT_CREATED`
  - `BILLCYCLE`
  - `AUTOPAY_FLAG`

- **Serviceline Status & Dates**
  - `SERVICELINE_STATUS`
  - `SERVICELINE_STARTDATE`
  - `SERVICELINE_ENDDATE`

- **Address / Location (from `SERVICELINE_ADDRESSES`)**
  - `SERVICELINE_ADDRESS1`, `SERVICELINE_ADDRESS2`, `SERVICELINE_ADDRESS3`
  - `SERVICELINE_ADDRESS_CITY`, `SERVICELINE_ADDRESS_STATE`, `SERVICELINE_ADDRESS_ZIPCODE`
  - `SERVICELINE_ADDRESS_VERIFIED`
  - `MAPPING_ADDRESS_ID`
  - `MAPPING_AREA_ID`
  - `MAPPING_REF_AREA1`
  - `SERVICELINE_LATITUDE`, `SERVICELINE_LONGITUDE`

- **Features / Plans (aggregated from `SERVICELINE_FEATURES`)**
  - `PLANS` – comma-separated list of plans on the serviceline
  - `FEATURES` – comma-separated list of features on the serviceline

- **Derived Fields (for consistent business logic)**
  - `IS_ACTIVE_SERVICELINE` – 1 when `SERVICELINE_STATUS` is active and `SERVICELINE_ENDDATE` is NULL.
  - `SERVICE_TYPE` – normalized string derived from `SERVICE_MODEL`:
    - `'Internet'` when `SERVICE_MODEL` contains "internet"
    - `'Voice'` when `SERVICE_MODEL` contains "voice"
    - `'Other'` otherwise

### Semantic Types

**Semantic Types**: See [`SERVICELINES_BASE_SEMANTIC_TYPES.md`](./SERVICELINES_BASE_SEMANTIC_TYPES.md) for recommended semantic type settings for each column.

At a high level:

- **IDs / Keys**: `ACCOUNT_ID`, `ACCOUNT_NUMBER`, `SERVICELINE_NUMBER`, `MAPPING_ADDRESS_ID`, `SERVICE_LOCATION_KEY` → Entity Key.
- **Flags / Categories**: `IS_ACTIVE_SERVICELINE`, `SERVICE_TYPE`, `ACCOUNT_STATUS`, `SERVICELINE_ADDRESS_VERIFIED`, `AUTOPAY_FLAG` → Category.
- **Categories**: `ACCOUNT_TYPE`, `SERVICE_MODEL`, `MAPPING_AREA_ID`, state/city fields → Category.
- **Location**: latitude/longitude + address fields → Latitude, Longitude, Address, City, State, ZIP Code.
- **Timestamps**: `SERVICELINE_STARTDATE`, `SERVICELINE_ENDDATE`, `ACCOUNT_CREATED` → Creation Timestamp.

## Example Downstream Models / Questions

### 1. Active Internet Subscribers by Account Type

- **Base**: `Camvio – Servicelines (Base)`
- **Filter**:
  - `IS_ACTIVE_SERVICELINE = 1`
  - `SERVICE_TYPE = 'Internet'`
- **Group By**: `ACCOUNT_TYPE`
- **Metric**: `Count` (one per active internet serviceline; matches existing 7,923 baseline).

### 2. Active Internet Subscribers by Feature

- **Base**: `Camvio – Servicelines (Base)` or a feature-level model.
- **Filter**:
  - `IS_ACTIVE_SERVICELINE = 1`
  - `SERVICE_TYPE = 'Internet'`
- **Group By**: `FEATURES` (from base) or individual `FEATURE` if using a feature-exploded model.

### 3. Subscribers by Mapping Area

- **Base**: `Camvio – Servicelines (Base)`
- **Filter**:
  - `IS_ACTIVE_SERVICELINE = 1`
  - `SERVICE_TYPE = 'Internet'`
- **Group By**: `MAPPING_AREA_ID` or `SERVICE_LOCATION_KEY`
- **Metric**: `Count` (active internet servicelines as subscriber proxy).

## Usage Notes

1. Treat `Camvio – Servicelines (Base)` as the **canonical source** for subscriber and serviceline analysis.
2. Build additional Metabase models on top of this base rather than re-implementing joins/logic.
3. Existing subscriber count logic (`IS_ACTIVE_SERVICELINE = 1 AND SERVICE_TYPE = 'Internet'`) should continue to reproduce the validated 7,923 active subscribers.
4. When `MAPPING_ADDRESS_ID` data quality improves, location-level models can progressively rely more on `SERVICE_LOCATION_KEY` without changing this base query.


