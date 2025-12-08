# How to Document Fybe Models

This guide explains the best ways to provide information about your existing Fybe Metabase models so they can be properly documented.

## Option 1: Fill Out the Template (Recommended)

1. Copy `models/TEMPLATE.md` to a new file named after your model (e.g., `models/DROP_BURY_BY_DAY.md`)
2. Fill in the template with your model details
3. Provide any additional files (semantic types, column mappings) as needed

**Best for**: When you have time to write structured documentation

## Option 2: Provide Structured Information

Provide the following information in any format (text, markdown, or even a conversation), and I'll create the documentation:

### Essential Information

1. **Model Name**: What is the model called in Metabase?
2. **Source**: 
   - Is it a SQL query? (path: `snowflake/fybe/queries/[name].sql`)
   - Is it a view? (path: `snowflake/fybe/[name].sql`)
   - Or a direct table/view reference?
3. **Purpose**: What is this model used for? What questions does it answer?
4. **Key Fields**: List the most important columns and what they represent
5. **Filters**: Any filters applied in the query/view?
6. **Joins**: What tables/views are joined? (if applicable)

### Nice to Have

7. **Custom Columns**: Any custom columns defined in Metabase? (can reference the Custom Column Definitions file)
8. **Semantic Types**: Any columns that need specific semantic types set?
9. **Common Use Cases**: How is this model typically used?
10. **Gotchas**: Any important caveats or things to watch out for?

**Best for**: Quick documentation when you want me to format it properly

## Option 3: Share Model Details from Metabase UI

You can provide:
- Screenshots of the model structure
- List of columns from Metabase
- Model settings/configuration
- Any notes you have

**Best for**: When you want to document quickly without writing much

## Option 4: Provide SQL Query/View

If the model is based on a SQL query or view:
- Share the SQL file path or contents
- I can analyze it and create documentation
- You can then review and add any Metabase-specific details

**Best for**: When the SQL already exists and you want documentation generated from it

## Documentation Files Structure

For each model, we typically create:

1. **Main Model File** (`[MODEL_NAME].md`)
   - Overview, purpose, structure
   - Key fields and usage examples

2. **Semantic Types** (`[MODEL_NAME]_SEMANTIC_TYPES.md`) - Optional
   - Recommended semantic type settings for each column
   - Helps with proper Metabase configuration

3. **Column Mapping** (`[MODEL_NAME]_COLUMN_MAPPING.md`) - Optional
   - Detailed mapping of source columns to model columns
   - Useful for complex queries with many joins

4. **Join Columns** (`[MODEL_NAME]_JOIN_COLUMNS.md`) - Optional
   - Reference for join keys
   - Useful when model has multiple joins

## Example: Quick Documentation Request

Here's an example of a minimal request that would work:

```
Model: Drop Bury by Day
Source: View - snowflake/fybe/DROP_BURY_BY_DAY_V.sql
Purpose: Track drop and bury tasks with daily date spine
Key Fields:
  - Drop Task ID
  - Bury Task ID  
  - Date (from date spine)
  - Drop Status
  - Bury Status
Custom Columns: See Custom Column Definitions file
```

This would be enough to create a basic documentation file that you can then enhance.

## Questions to Answer (if you have time)

1. What is the primary business question this model answers?
2. Who uses this model? (analysts, managers, etc.)
3. What are the most common filters/dimensions used?
4. Are there any calculated fields or custom columns?
5. Does this model join with any Camvio models? (if so, note the join keys)
6. Any performance considerations or data volume notes?

## Next Steps

Choose the option that works best for you, and I'll help create the documentation files in the proper format!
