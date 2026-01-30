# Metabase Custom Column Definitions (Fybe) – Vetro Service Locations

Custom column definitions for **Vetro service locations** models in Metabase, using Fybe data sources.

---

## State (default NC, CAPS)

Use when the source `[State]` may be null or mixed case. Null/empty becomes `'NC'`; all values are output in CAPS.

```java
upper(trim(coalesce([State], "NC")))
```

**Behavior:**
- If `[State]` is null or empty, the result is `"NC"`.
- Otherwise the value is trimmed and uppercased (e.g. `"nc"` → `"NC"`, `" north carolina "` → `"NORTH CAROLINA"`).

**Semantic type:** Category (or State, if available in your Metabase version).
