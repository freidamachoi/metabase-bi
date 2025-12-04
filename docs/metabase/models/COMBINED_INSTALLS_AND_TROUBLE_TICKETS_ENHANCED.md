# Combined Installs and Trouble Tickets (Enhanced) - Custom Columns

## Overview

This document contains custom column definitions for the **Combined Installs and Trouble Tickets (Enhanced)** model, which is based on the **Combined Installs and Trouble Tickets (Base)** model.

## Base Model

**Source**: `Combined Installs and Trouble Tickets (Base)`  
**Query**: `snowflake/camvio/queries/combined_installs_and_trouble_tickets.sql`

## Custom Columns

### Rate

**Purpose**: Calculate rate based on visit type and account type

**Business Logic**:
- **Installs**:
  - Residential: $162
  - Business: $172
  - Enterprise: $172 (same as Business)
- **Trouble Tickets**:
  - Residential: $75
  - Business: $80
  - Enterprise: $80 (same as Business)

**Metabase Expression**:

```javascript
coalesce(
  case(
    // Install - Residential
    [Visit Type] = "Install" and [Account Type] = "Residential",
    162,
    
    // Install - Business
    [Visit Type] = "Install" and [Account Type] = "Business",
    172,
    
    // Install - Enterprise (same as Business)
    [Visit Type] = "Install" and [Account Type] = "Enterprise",
    172,
    
    // Trouble Ticket - Residential
    [Visit Type] = "Trouble Ticket" and [Account Type] = "Residential",
    75,
    
    // Trouble Ticket - Business
    [Visit Type] = "Trouble Ticket" and [Account Type] = "Business",
    80,
    
    // Trouble Ticket - Enterprise (same as Business)
    [Visit Type] = "Trouble Ticket" and [Account Type] = "Enterprise",
    80
  ),
  0  // Default value if no conditions match (should not occur if data is clean)
)
```

**Semantic Type**: **Currency** or **Number**

**Notes**:
- Assumes Account Type values are exactly "Residential", "Business", and "Enterprise" (case-sensitive)
- Enterprise has the same rate as Business for both Install and Trouble Ticket visit types
- If Account Type has different values or casing, adjust the conditions accordingly
- Consider adding error handling if other Account Types exist

### Alternative: Case-Insensitive Version

If Account Type values might have different casing:

```javascript
coalesce(
  case(
    // Install - Residential
    [Visit Type] = "Install" and upper(trim([Account Type])) = "RESIDENTIAL",
    162,
    
    // Install - Business
    [Visit Type] = "Install" and upper(trim([Account Type])) = "BUSINESS",
    172,
    
    // Install - Enterprise (same as Business)
    [Visit Type] = "Install" and upper(trim([Account Type])) = "ENTERPRISE",
    172,
    
    // Trouble Ticket - Residential
    [Visit Type] = "Trouble Ticket" and upper(trim([Account Type])) = "RESIDENTIAL",
    75,
    
    // Trouble Ticket - Business
    [Visit Type] = "Trouble Ticket" and upper(trim([Account Type])) = "BUSINESS",
    80,
    
    // Trouble Ticket - Enterprise (same as Business)
    [Visit Type] = "Trouble Ticket" and upper(trim([Account Type])) = "ENTERPRISE",
    80
  ),
  0  // Default value if no conditions match
)
```

### Partner

**Purpose**: Map ASSIGNEE (technician) values to Partner names for grouping and reporting

**Business Logic**: Maps each ASSIGNEE value to a Partner name. This is a rigid mapping that requires maintenance as ASSIGNEE values change.

**Metabase Expression** (Template - Update with actual ASSIGNEE and Partner values):

```javascript
coalesce(
  case(
    // Partner 1 - Example assignees
    [Assignee] = "John Smith",
    "Partner A",
    [Assignee] = "Jane Doe",
    "Partner A",
    
    // Partner 2 - Example assignees
    [Assignee] = "Bob Johnson",
    "Partner B",
    [Assignee] = "Alice Williams",
    "Partner B",
    
    // Partner 3 - Example assignees
    [Assignee] = "Charlie Brown",
    "Partner C",
    
    // Add more mappings as needed...
    // [Assignee] = "Technician Name",
    // "Partner Name"
  ),
  "Unknown"  // Default value if ASSIGNEE doesn't match any mapping
)
```

**Case-Insensitive Version** (Recommended if ASSIGNEE values might have inconsistent casing):

```javascript
coalesce(
  case(
    // Partner 1 - Example assignees (case-insensitive)
    upper(trim([Assignee])) = "JOHN SMITH",
    "Partner A",
    upper(trim([Assignee])) = "JANE DOE",
    "Partner A",
    
    // Partner 2 - Example assignees
    upper(trim([Assignee])) = "BOB JOHNSON",
    "Partner B",
    upper(trim([Assignee])) = "ALICE WILLIAMS",
    "Partner B",
    
    // Partner 3 - Example assignees
    upper(trim([Assignee])) = "CHARLIE BROWN",
    "Partner C",
    
    // Add more mappings as needed...
    // upper(trim([Assignee])) = "TECHNICIAN NAME",
    // "Partner Name"
  ),
  "Unknown"  // Default value if ASSIGNEE doesn't match any mapping
)
```

**Semantic Type**: **Category**

**Notes**:
- ⚠️ **Maintenance Required**: This mapping is rigid and must be updated whenever:
  - New ASSIGNEE values appear in the data
  - ASSIGNEE values change (e.g., name corrections, spelling changes)
  - Partner assignments change
- **Case Sensitivity**: Use the case-insensitive version if ASSIGNEE values might have inconsistent casing
- **Default Value**: "Unknown" helps identify unmapped ASSIGNEE values that need to be added to the mapping
- **Best Practice**: Regularly review rows with Partner = "Unknown" to identify new ASSIGNEE values that need mapping

**Getting List of ASSIGNEE Values**:

To get a list of all unique ASSIGNEE values for mapping:

```sql
-- Get all unique ASSIGNEE values
SELECT DISTINCT [Assignee]
FROM [Combined Installs and Trouble Calls (Base)]
WHERE [Assignee] IS NOT NULL
ORDER BY [Assignee];
```

### Order/Trouble Ticket #

**Purpose**: Create a unified identifier field that contains ORDER_ID for installs and TROUBLE_TICKET_ID for trouble tickets

**Business Logic**: Uses ORDER_ID when available (installs), otherwise uses TROUBLE_TICKET_ID (trouble tickets). Since one is always NULL and the other has a value, this creates a single field for the primary identifier.

**Metabase Expression**:

```javascript
coalesce([Order Id], [Trouble Ticket Id])
```

**Alternative with Formatting** (if you want to prefix the values):

```javascript
coalesce(
  case(
    [Order Id] IS NOT NULL,
    concat("Order: ", [Order Id]),
    [Trouble Ticket Id] IS NOT NULL,
    concat("Ticket: ", [Trouble Ticket Id])
  ),
  "Unknown"
)
```

**Semantic Type**: **Entity Key** or **Number** (depending on whether you want it formatted as text)

**Notes**:
- **Simple Version**: The basic `coalesce()` expression is recommended - it returns the non-NULL value directly
- **Formatting Version**: Use the alternative if you want to distinguish between orders and tickets in the display value
- **Data Type**: ORDER_ID and TROUBLE_TICKET_ID are both numbers, so the result will be a number
- **Always Has Value**: Since one field is always NULL and the other always has a value, this field will never be NULL (unless both are somehow NULL, which shouldn't happen)

## Additional Custom Columns (Future)

### Total Revenue

```javascript
// Total Revenue per visit
[Rate] * 1
// Or if quantity is needed:
// [Rate] * coalesce([Quantity], 1)
```

### Rate Category

```javascript
// Categorize rates
coalesce(
  case(
    [Rate] >= 150,
    "High",
    [Rate] >= 100,
    "Medium",
    [Rate] < 100,
    "Low"
  ),
  "Unknown"  // Default value if no conditions match
)
```

### Visit Type Label

```javascript
// Formatted visit type
case(
  [Visit Type] = "Install",
  "Installation",
  [Visit Type] = "Trouble Ticket",
  "Service Call",
  [Visit Type]
)
```

## Creating the Enhanced Model in Metabase

### Steps

1. **Create Base Model**:
   - Name: "Combined Installs and Trouble Calls (Base)"
   - Use SQL from `combined_installs_and_trouble_tickets.sql`
   - Set semantic types (see `COMBINED_INSTALLS_AND_TROUBLE_TICKETS_SEMANTIC_TYPES.md`)

2. **Create Enhanced Model**:
   - Name: "Combined Installs and Trouble Calls (Enhanced)"
   - Base model: "Combined Installs and Trouble Calls (Base)"
   - Add custom columns as defined above

3. **Add Custom Columns**:
   - Go to model settings
   - Add custom column: "Rate"
     - Paste the Rate expression above
     - Set semantic type to **Currency** or **Number**
   - Add custom column: "Partner"
     - Paste the Partner expression above (update with actual ASSIGNEE → Partner mappings)
     - Set semantic type to **Category**
   - Add custom column: "Order/Trouble Ticket #"
     - Paste the coalesce expression: `coalesce([Order Id], [Trouble Ticket Id])`
     - Set semantic type to **Entity Key** or **Number**

## Testing the Rate Column

### Validation Queries

After creating the enhanced model, validate the Rate column:

```sql
-- Check rate distribution
SELECT 
  [Visit Type],
  [Account Type],
  [Rate],
  COUNT(*) as count
FROM enhanced_model
GROUP BY [Visit Type], [Account Type], [Rate]
ORDER BY [Visit Type], [Account Type];
```

### Expected Results

| Visit Type | Account Type | Rate | Expected Count |
|-----------|--------------|------|----------------|
| Install | Residential | 162 | [number of installs] |
| Install | Business | 172 | [number of installs] |
| Install | Enterprise | 172 | [number of installs] |
| Trouble Ticket | Residential | 75 | [number of tickets] |
| Trouble Ticket | Business | 80 | [number of tickets] |
| Trouble Ticket | Enterprise | 80 | [number of tickets] |

## Notes

- **Rate values**: Confirm these are the correct rates for your business
- **Account Type values**: Verify the exact values in your data (may be "Residential", "RESIDENTIAL", "Business", "BUSINESS", "Enterprise", "ENTERPRISE", etc.)
- **Semantic Type**: Set Rate as **Currency** if these are dollar amounts, or **Number** if they're just numeric values
- **Null handling**: Uses `coalesce()` with a default value of 0 if conditions don't match - this helps identify data quality issues (rows with Rate = 0 indicate unexpected Visit Type/Account Type combinations)
- **Partner mapping**: The Partner field requires ongoing maintenance as ASSIGNEE values change. Regularly review and update the mapping expression to ensure all technicians are properly assigned to partners.

