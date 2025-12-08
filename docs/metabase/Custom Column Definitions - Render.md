# Metabase Custom Column Definitions

## Drop Bury by Day (Base)

Includes all fields from DROP_BURY_BY_DAY_V. This includes drop bury unit tasks combined with a date spine.

## Drop Bury by Day (Enriched)

Leverages Drop Bury by Day (Base)

### Drop NLR

```java
lower(trim([Bury Work Activity])) =
  "no longer required"
```

### Drop in Jeopardy

```java
lower(trim(coalesce([Drop Status], ""))) = "jeopardy"
```

### Drop Status (norm)

```java
lower(trim(coalesce([Drop Status], "")))
```

### Drop Stage Rank

```java
case(
  [Drop NLR],
  6,
  NOT isNull([Drop Approved])
  OR contains([Drop Status (norm)], "approved"),
  6,
  NOT isNull([Drop Completed])
  OR contains([Drop Status (norm)], "completed"),
  5,
  NOT isNull([Drop Released])
  OR contains([Drop Status (norm)], "released"),
  4,
  contains([Drop Status (norm)], "releasable"),
  3,
  contains([Drop Status (norm)], "allocated"),
  2,
  NOT isNull([Drop Created]),
  1,
  0
)
```

### Drop Stage Base Label

```java
case(
  [Drop Stage Rank] = 4,
  "Drop Approved",
  [Drop Stage Rank] = 3,
  "Drop Completed",
  [Drop Stage Rank] = 2,
  "Drop Released",
  [Drop Stage Rank] = 1,
  "Drop Created",
  "No Drop"
)
```

### Drop Stage Label

```java
concat(
  case([Drop In Jeopardy], "⚠ ", ""),
  case(
    [Drop Stage Rank] = 6,
    "Drop Approved",
    [Drop Stage Rank] = 5,
    "Drop Completed",
    [Drop Stage Rank] = 4,
    "Drop Released",
    [Drop Stage Rank] = 3,
    "Drop Releasable",
    [Drop Stage Rank] = 2,
    "Drop Allocated",
    [Drop Stage Rank] = 1,
    "Drop Blueprinted",
    "No Drop"
  )
)
```

### Drop State

```java
case(
  lower(trim(coalesce([Drop Status], ""))) =
    "jeopardy",
  "Actually Jeopardy",
  lower(trim(coalesce([Drop Work Activity], ""))) =
    "no longer required",
  "NLR",
  NOT isNull([Drop Approved])
  OR NOT isNull([Drop Completed]),
  "Green",
  datetimeDiff([Drop Created], now(), "day") > 5,
  "Overdue",
  datetimeDiff([Drop Created], now(), "day") > 3,
  "In Jeopardy",
  "Green"
)
```

### Drop Days Open

```java
case(
  [Drop Stage Rank] < 5,
  datetimeDiff([Drop Created], now(), "day"),
  datetimeDiff([Drop Created], [Drop Completed], "day")
)
```

### Drop Complete Age

```java
case(
  [Drop Stage Rank] = 5,
  datetimeDiff([Drop Completed], now(), "day"),
  0
)
```

### Has Bury

```java
notNull([Bury Task])
```

### Bury Status (norm)

```java
lower(trim(coalesce([Bury Status], "")))
```

### Bury Status (norm)

```java
lower(trim(coalesce([Bury Status], "")))
```

### Bury NLR

```java
lower(trim([Bury Work Activity])) =
  "no longer required"
AND NOT isNull([Bury Work Activity])
```

### Bury Required

```java
[Has Bury]
AND (NOT [Bury NLR] OR isNull([Bury Work Activity]))
```

### Bury SLA Date

```java
datetimeAdd([Bury Created], 7, "day")
```

### Bury Subrank

```java
case(
  [Bury NLR],
  6,
  NOT isNull([Bury Approved])
  OR contains([Bury Status (norm)], "approved"),
  6,
  NOT isNull([Bury Completed])
  OR contains([Bury Status (norm)], "completed"),
  5,
  NOT isNull([Bury Released])
  OR contains([Bury Status (norm)], "released"),
  4,
  contains([Bury Status (norm)], "releasable"),
  3,
  contains([Bury Status (norm)], "allocated"),
  2,
  NOT isNull([Bury Created]),
  1,
  0
)
```

### Bury In Jeopardy

```java
lower(trim(coalesce([Bury Status], ""))) = "jeopardy"
```

### Bury Stage Label

```java
concat(
  case([Bury In Jeopardy], "⚠ ", ""),
  case(
    [Bury Subrank] = 6,
    "Bury Approved",
    [Bury Subrank] = 5,
    "Bury Completed",
    [Bury Subrank] = 4,
    "Bury Released",
    [Bury Subrank] = 3,
    "Bury Releasable",
    [Bury Subrank] = 2,
    "Bury Allocated",
    [Bury Subrank] = 1,
    "Bury Blueprinted",
    "No Bury"
  )
)
```

### Bury Completed Age

```java
case(
  [Bury Subrank] = 5,
  datetimeDiff([Bury Completed], now(), "day"),
  0
)
```

### Bury Days Open

```java
case(
  [Bury Subrank] < 5,
  datetimeDiff([Bury Created], now(), "day"),
  datetimeDiff([Bury Created], [Bury Completed], "day")
)
```

### Bury Days to Due

```java
datetimeDiff(now(), [Bury SLA Date], "day")
```

### Overall Stage Label

```java
case(
  [Overall Stage Rank] = 12,
  "Bury Approved",
  [Overall Stage Rank] = 11,
  "Bury Completed",
  [Overall Stage Rank] = 10,
  "Bury Released",
  [Overall Stage Rank] = 9,
  "Bury Releasable",
  [Overall Stage Rank] = 8,
  "Bury Allocated",
  [Overall Stage Rank] = 7,
  "Bury Blueprinted",
  [Overall Stage Rank] = 6,
  "Drop Approved",
  [Overall Stage Rank] = 5,
  "Drop Completed",
  [Overall Stage Rank] = 4,
  "Drop Released",
  [Overall Stage Rank] = 3,
  "Drop Releasable",
  [Overall Stage Rank] = 2,
  "Drop Allocated",
  [Overall Stage Rank] = 1,
  "Drop Blueprinted",
  "No Stage"
)
```

### Overall Stage Rank

```java
case(
  [Bury Required],
  case(
    [Drop Stage Rank] >= 6 + [Bury Subrank],
    [Drop Stage Rank],
    6 + [Bury Subrank]
  ),
  [Drop Stage Rank]
)
```

### Overall Status

```java
case(
  isNull([Drop Task]),
  "No Drop",
  lower(trim(coalesce([Drop Status], ""))) = "jeopardy"
  OR [Has Bury]
  AND NOT lower(
    trim(coalesce([Bury Work Activity], ""))
  ) =
    "no longer required"
  AND lower(trim(coalesce([Bury Status], ""))) =
    "jeopardy",
  "Placed In Jeopardy",
  NOT [Has Bury]
  AND [Drop Days Open] >= 7
  AND isNull([Drop Completed])
  AND NOT lower(
    trim(coalesce([Drop Work Activity], ""))
  ) =
    "no longer required",
  "Jeopardy",
  NOT [Has Bury]
  AND NOT isNull([Drop Approved])
  AND NOT isNull([Drop Completed])
  OR [Has Bury]
  AND NOT lower(
    trim(coalesce([Bury Work Activity], ""))
  ) =
    "no longer required"
  AND NOT isNull([Bury Approved])
  AND NOT isNull([Drop Approved])
  AND NOT isNull([Drop Completed]),
  "Complete",
  [Has Bury]
  AND NOT lower(
    trim(coalesce([Bury Work Activity], ""))
  ) =
    "no longer required"
  AND NOT (
    NOT isNull([Bury Approved])
    OR NOT isNull([Bury Completed])
  ),
  case(
    [Bury Days to Due] < 0,
    "Overdue",
    [Bury Days to Due] <= 3,
    "Jeopardy",
    "On Schedule"
  ),
  [Has Bury]
  AND NOT lower(
    trim(coalesce([Bury Work Activity], ""))
  ) =
    "no longer required"
  AND NOT (
    NOT isNull([Bury Completed])
    AND NOT isNull([Bury Approved])
  ),
  case(
    [Bury Completed Age] > 3,
    "Approve Bury",
    [Bury Completed Age] > 5,
    "Bury Approval Overdue",
    "On Schedule"
  ),
  case(
    NOT isNull([Drop Approved])
    AND NOT isNull([Drop Completed]),
    "On Schedule",
    [Drop Complete Age] > 5,
    "Drop Approval Overdue",
    [Drop Complete Age] > 2,
    "Approve Drop",
    "On Schedule"
  )
)
```

### Drop Days to Complete

```java
case(
  NOT isNull([Drop Created]),
  datetimeDiff(
    [Drop Created],
    coalesce([Drop Completed], now()),
    "day"
  )
)
```

### Bury Days to Complete

```java
case(
  [Has Bury] AND NOT isNull([Bury Created]),
  datetimeDiff(
    [Bury Created],
    coalesce([Bury Completed], now()),
    "day"
  )
)
```

### Overall Days to Complete

```java
case(
  NOT [Has Bury] AND NOT isNull([Drop Created]),
  datetimeDiff(
    [Drop Created],
    coalesce([Drop Completed], now()),
    "day"
  ),
  [Has Bury]
  AND NOT isNull([Drop Created])
  AND NOT isNull([Bury Completed]),
  datetimeDiff(
    [Drop Created],
    [Bury Completed],
    "day"
  ),
  [Has Bury]
  AND NOT isNull([Drop Created])
  AND isNull([Bury Completed]),
  datetimeDiff([Drop Created], now(), "day")
)
```

## Drop Bury by Day (Enriched) - Metrics

These are separate metrics (aggregations) to be created in Metabase, not custom columns. **Group by `DATE_DAY`** to display both metrics on the same visualization.

### Total Drop Tasks Created by Day

Counts distinct drop tasks where `[Drop Created]` matches the `[DATE_DAY]` for that row.

```java
DistinctIf([Drop Task ID], [Drop Created] = [DATE_DAY])
```

### Total Drop Tasks Completed by Day

Counts distinct drop tasks where `[Drop Completed]` matches the `[DATE_DAY]` for that row.

```java
DistinctIf([Drop Task ID], [Drop Completed] = [DATE_DAY])
```

**Visualization Setup:**
- Group by: `DATE_DAY`
- Add both metrics above to the same chart (line chart, bar chart, etc.)
- Both will display on the same visualization showing created vs. completed by day

### Total Drop Tasks (All)

```java
Distinct([Drop Task ID])
```

### Completion Rate by Day

Create as a custom metric dividing:
- Numerator: `DistinctIf([Drop Task ID], [Drop Completed] = [DATE_DAY])`
- Denominator: `DistinctIf([Drop Task ID], [Drop Created] = [DATE_DAY])`

Group by: `DATE_DAY`

## Render Unit Report (Base)

All available fields in the VW_RENDER_UNITS

## Render Material Report (Enriched)

Leverages Render Unit Report (Base) filters task type = Material

### Is Approved

```java
notNull([Approved Date])
```
### Task NLR

```java
lower(trim([Work Activity])) = "no longer required"
AND notNull([Work Activity])
```

### Labels General (norm)

```java
if(
  isNull([Labels General]),
  "",
  lower([Labels General])
)
```

### Is Rejected

```java
contains([Labels General (norm)], "disapproved")
```

### Primary Category

```java
coalesce(
  case(
    contains(trim(splitPart([Labels General (norm)], ",", 1)), "cable placing"), "Cable Placing",
    contains(trim(splitPart([Labels General (norm)], ",", 1)), "path"), "Path",
    contains(trim(splitPart([Labels General (norm)], ",", 1)), "splicing"), "Splicing",
    ""
  ),
  ""
)
```

### Secondary Category

```java
coalesce(
  case(
    NOT isNull(trim(splitPart([Labels General (norm)], ",", 2)))
      and contains(trim(splitPart([Labels General (norm)], ",", 2)), "cable placing"), "Cable Placing",
    NOT isNull(trim(splitPart([Labels General (norm)], ",", 2)))
      and contains(trim(splitPart([Labels General (norm)], ",", 2)), "path"), "Path",
    NOT isNull(trim(splitPart([Labels General (norm)], ",", 2)))
      and contains(trim(splitPart([Labels General (norm)], ",", 2)), "splicing"), "Splicing",
    ""
  ),
  ""
)
```

### Task Type Clean

```java
replace(
  replace(replace([Task Type], "_", " "), "-", " "),
  ".",
  " "
)
```

### @ Task Type

```java
trim(
  concat(
    case(
      lower(splitPart([Task Type Clean], " ", 1)) =
        "ug",
      "UG",
      lower(splitPart([Task Type Clean], " ", 1)) =
        "olt",
      "OLT",
      lower(splitPart([Task Type Clean], " ", 1)) =
        "mst",
      "MST",
      lower(splitPart([Task Type Clean], " ", 1)) =
        "fdh",
      "FDH",
      concat(
        upper(
          substring(
            splitPart([Task Type Clean], " ", 1),
            1,
            1
          )
        ),
        lower(
          substring(
            splitPart([Task Type Clean], " ", 1),
            2,
            length(
              splitPart([Task Type Clean], " ", 1)
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Task Type Clean], " ", 2)),
      "",
      concat(
        " ",
        case(
          lower(splitPart([Task Type Clean], " ", 2)) =
            "ug",
          "UG",
          lower(splitPart([Task Type Clean], " ", 2)) =
            "olt",
          "OLT",
          lower(splitPart([Task Type Clean], " ", 2)) =
            "mst",
          "MST",
          lower(splitPart([Task Type Clean], " ", 2)) =
            "fdh",
          "FDH",
          concat(
            upper(
              substring(
                splitPart([Task Type Clean], " ", 2),
                1,
                1
              )
            ),
            lower(
              substring(
                splitPart([Task Type Clean], " ", 2),
                2,
                length(
                  splitPart([Task Type Clean], " ", 2)
                )
              )
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Task Type Clean], " ", 3)),
      "",
      concat(
        " ",
        case(
          lower(splitPart([Task Type Clean], " ", 3)) =
            "ug",
          "UG",
          lower(splitPart([Task Type Clean], " ", 3)) =
            "olt",
          "OLT",
          lower(splitPart([Task Type Clean], " ", 3)) =
            "mst",
          "MST",
          lower(splitPart([Task Type Clean], " ", 3)) =
            "fdh",
          "FDH",
          concat(
            upper(
              substring(
                splitPart([Task Type Clean], " ", 3),
                1,
                1
              )
            ),
            lower(
              substring(
                splitPart([Task Type Clean], " ", 3),
                2,
                length(
                  splitPart([Task Type Clean], " ", 3)
                )
              )
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Task Type Clean], " ", 4)),
      "",
      concat(
        " ",
        case(
          lower(splitPart([Task Type Clean], " ", 4)) =
            "ug",
          "UG",
          lower(splitPart([Task Type Clean], " ", 4)) =
            "olt",
          "OLT",
          lower(splitPart([Task Type Clean], " ", 4)) =
            "mst",
          "MST",
          lower(splitPart([Task Type Clean], " ", 4)) =
            "fdh",
          "FDH",
          concat(
            upper(
              substring(
                splitPart([Task Type Clean], " ", 4),
                1,
                1
              )
            ),
            lower(
              substring(
                splitPart([Task Type Clean], " ", 4),
                2,
                length(
                  splitPart([Task Type Clean], " ", 4)
                )
              )
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Task Type Clean], " ", 5)),
      "",
      concat(
        " ",
        case(
          lower(splitPart([Task Type Clean], " ", 5)) =
            "ug",
          "UG",
          lower(splitPart([Task Type Clean], " ", 5)) =
            "olt",
          "OLT",
          lower(splitPart([Task Type Clean], " ", 5)) =
            "mst",
          "MST",
          lower(splitPart([Task Type Clean], " ", 5)) =
            "fdh",
          "FDH",
          concat(
            upper(
              substring(
                splitPart([Task Type Clean], " ", 5),
                1,
                1
              )
            ),
            lower(
              substring(
                splitPart([Task Type Clean], " ", 5),
                2,
                length(
                  splitPart([Task Type Clean], " ", 5)
                )
              )
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Task Type Clean], " ", 6)),
      "",
      concat(
        " ",
        case(
          lower(splitPart([Task Type Clean], " ", 6)) =
            "ug",
          "UG",
          lower(splitPart([Task Type Clean], " ", 6)) =
            "olt",
          "OLT",
          lower(splitPart([Task Type Clean], " ", 6)) =
            "mst",
          "MST",
          lower(splitPart([Task Type Clean], " ", 6)) =
            "fdh",
          "FDH",
          concat(
            upper(
              substring(
                splitPart([Task Type Clean], " ", 6),
                1,
                1
              )
            ),
            lower(
              substring(
                splitPart([Task Type Clean], " ", 6),
                2,
                length(
                  splitPart([Task Type Clean], " ", 6)
                )
              )
            )
          )
        )
      )
    )
  )
)
```

### Is Invoiced

```java
contains([Labels General (norm)], "invoiced")
```

### Is Deferred

```java
contains([Labels General (norm)], "defer")
```

## Render Labor Unit Report (Enriched)

Leverages Render Unit Report (Base)

### Is Approved

```java
notNull([Approved Date])
```

### Task NLR

```java
lower(trim([Work Activity])) = "no longer required"
AND notNull([Work Activity])
```

### Labels General (norm)

```java
if(
  isNull([Labels General]),
  "",
  lower([Labels General])
)
```

### IsDisapproved

```java
contains([Labels General (norm)], "disapproved")
```

### Primary Category

```java
coalesce(
  case(
    contains(trim(splitPart([Labels General (norm)], ",", 1)), "cable placing"), "Cable Placing",
    contains(trim(splitPart([Labels General (norm)], ",", 1)), "path"), "Path",
    contains(trim(splitPart([Labels General (norm)], ",", 1)), "splicing"), "Splicing",
    ""
  ),
  ""
)
```

### Secondary Category

```java
coalesce(
  case(
    NOT isNull(trim(splitPart([Labels General (norm)], ",", 2)))
      and contains(trim(splitPart([Labels General (norm)], ",", 2)), "cable placing"), "Cable Placing",
    NOT isNull(trim(splitPart([Labels General (norm)], ",", 2)))
      and contains(trim(splitPart([Labels General (norm)], ",", 2)), "path"), "Path",
    NOT isNull(trim(splitPart([Labels General (norm)], ",", 2)))
      and contains(trim(splitPart([Labels General (norm)], ",", 2)), "splicing"), "Splicing",
    ""
  ),
  ""
)
```

### Task Type Clean

```java
replace(
  replace(replace([Task Type], "_", " "), "-", " "),
  ".",
  " "
)
```

### Is Invoiced

```java
contains([Labels General (norm)], "invoiced")
```

### Is Fybe

```java
doesNotContain([Contractor], "fybe")
```

### Gross $

```java
[Actual Quantity] * [Labor Rate]
```

### Net $

```java
0.9 * [Gross $]
```

## Render Tickets (Base)

All fields from VW_RENDER_TICKETS (Snowflake)

## Render Tickets (Enriched)

Leverages Render Tickets (Base)

### NLR

```java
lower(trim([Work Activity])) = "no longer required"
```

### In Jeopardy

```java
lower(trim(coalesce([Status], ""))) = "jeopardy"
```

### Status

```java
trim(
  concat(
    case(
      isNull([Status]) OR length(trim(coalesce([Status], ""))) = 0,
      "",
      concat(
        upper(
          substring(
            trim(coalesce([Status], "")),
            1,
            1
          )
        ),
        lower(
          substring(
            trim(coalesce([Status], "")),
            2,
            length(trim(coalesce([Status], "")))
          )
        )
      )
    ),
    case(
      isNull(splitPart(trim(coalesce([Status], "")), " ", 2)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart(trim(coalesce([Status], "")), " ", 2),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart(trim(coalesce([Status], "")), " ", 2),
              2,
              length(splitPart(trim(coalesce([Status], "")), " ", 2))
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart(trim(coalesce([Status], "")), " ", 3)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart(trim(coalesce([Status], "")), " ", 3),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart(trim(coalesce([Status], "")), " ", 3),
              2,
              length(splitPart(trim(coalesce([Status], "")), " ", 3))
            )
          )
        )
      )
    )
  )
)
```

### Days to Due

```java
datetimeDiff(now(), [Target Date], "day")
```

### Status (with Jeopardy/Overdue)

```java
case(
  [In Jeopardy],
  "Placed in Jeopardy",
  NOT [Is Completed]
  AND NOT isNull([Days to Due])
  AND [Days to Due] <= 0,
  "Overdue",
  NOT [NLR]
  AND NOT [Is Completed]
  AND NOT isNull([Days to Due])
  AND [Days to Due] > 0
  AND [Days to Due] <= 3,
  "Jeopardy",
  [Status]
)
```

### Labels General (norm)

```java
if(
  isNull([Labels General]),
  "",
  lower([Labels General])
)
```

### IsDisapproved

```java
contains([Labels General (norm)], "disapproved")
```

### Primary Category

```java
coalesce(
  case(
    contains(trim(splitPart([Labels General (norm)], ",", 1)), "cable placing"), "Cable Placing",
    contains(trim(splitPart([Labels General (norm)], ",", 1)), "path"), "Path",
    contains(trim(splitPart([Labels General (norm)], ",", 1)), "splicing"), "Splicing",
    ""
  ),
  ""
)
```

### Secondary Category

```java
coalesce(
  case(
    NOT isNull(trim(splitPart([Labels General (norm)], ",", 2)))
      and contains(trim(splitPart([Labels General (norm)], ",", 2)), "cable placing"), "Cable Placing",
    NOT isNull(trim(splitPart([Labels General (norm)], ",", 2)))
      and contains(trim(splitPart([Labels General (norm)], ",", 2)), "path"), "Path",
    NOT isNull(trim(splitPart([Labels General (norm)], ",", 2)))
      and contains(trim(splitPart([Labels General (norm)], ",", 2)), "splicing"), "Splicing",
    ""
  ),
  ""
)
```

### Task Type Clean

```java
replace(
  replace(replace([Task Type], "_", " "), "-", " "),
  ".",
  " "
)
```

### Task Type

```java
trim(
  concat(
    case(
      lower(splitPart([Task Type Clean], " ", 1)) =
        "ug",
      "UG",
      lower(splitPart([Task Type Clean], " ", 1)) =
        "olt",
      "OLT",
      lower(splitPart([Task Type Clean], " ", 1)) =
        "mst",
      "MST",
      lower(splitPart([Task Type Clean], " ", 1)) =
        "fdh",
      "FDH",
      concat(
        upper(
          substring(
            splitPart([Task Type Clean], " ", 1),
            1,
            1
          )
        ),
        lower(
          substring(
            splitPart([Task Type Clean], " ", 1),
            2,
            length(
              splitPart([Task Type Clean], " ", 1)
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Task Type Clean], " ", 2)),
      "",
      concat(
        " ",
        case(
          lower(splitPart([Task Type Clean], " ", 2)) =
            "ug",
          "UG",
          lower(splitPart([Task Type Clean], " ", 2)) =
            "olt",
          "OLT",
          lower(splitPart([Task Type Clean], " ", 2)) =
            "mst",
          "MST",
          lower(splitPart([Task Type Clean], " ", 2)) =
            "fdh",
          "FDH",
          concat(
            upper(
              substring(
                splitPart([Task Type Clean], " ", 2),
                1,
                1
              )
            ),
            lower(
              substring(
                splitPart([Task Type Clean], " ", 2),
                2,
                length(
                  splitPart([Task Type Clean], " ", 2)
                )
              )
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Task Type Clean], " ", 3)),
      "",
      concat(
        " ",
        case(
          lower(splitPart([Task Type Clean], " ", 3)) =
            "ug",
          "UG",
          lower(splitPart([Task Type Clean], " ", 3)) =
            "olt",
          "OLT",
          lower(splitPart([Task Type Clean], " ", 3)) =
            "mst",
          "MST",
          lower(splitPart([Task Type Clean], " ", 3)) =
            "fdh",
          "FDH",
          concat(
            upper(
              substring(
                splitPart([Task Type Clean], " ", 3),
                1,
                1
              )
            ),
            lower(
              substring(
                splitPart([Task Type Clean], " ", 3),
                2,
                length(
                  splitPart([Task Type Clean], " ", 3)
                )
              )
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Task Type Clean], " ", 4)),
      "",
      concat(
        " ",
        case(
          lower(splitPart([Task Type Clean], " ", 4)) =
            "ug",
          "UG",
          lower(splitPart([Task Type Clean], " ", 4)) =
            "olt",
          "OLT",
          lower(splitPart([Task Type Clean], " ", 4)) =
            "mst",
          "MST",
          lower(splitPart([Task Type Clean], " ", 4)) =
            "fdh",
          "FDH",
          concat(
            upper(
              substring(
                splitPart([Task Type Clean], " ", 4),
                1,
                1
              )
            ),
            lower(
              substring(
                splitPart([Task Type Clean], " ", 4),
                2,
                length(
                  splitPart([Task Type Clean], " ", 4)
                )
              )
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Task Type Clean], " ", 5)),
      "",
      concat(
        " ",
        case(
          lower(splitPart([Task Type Clean], " ", 5)) =
            "ug",
          "UG",
          lower(splitPart([Task Type Clean], " ", 5)) =
            "olt",
          "OLT",
          lower(splitPart([Task Type Clean], " ", 5)) =
            "mst",
          "MST",
          lower(splitPart([Task Type Clean], " ", 5)) =
            "fdh",
          "FDH",
          concat(
            upper(
              substring(
                splitPart([Task Type Clean], " ", 5),
                1,
                1
              )
            ),
            lower(
              substring(
                splitPart([Task Type Clean], " ", 5),
                2,
                length(
                  splitPart([Task Type Clean], " ", 5)
                )
              )
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Task Type Clean], " ", 6)),
      "",
      concat(
        " ",
        case(
          lower(splitPart([Task Type Clean], " ", 6)) =
            "ug",
          "UG",
          lower(splitPart([Task Type Clean], " ", 6)) =
            "olt",
          "OLT",
          lower(splitPart([Task Type Clean], " ", 6)) =
            "mst",
          "MST",
          lower(splitPart([Task Type Clean], " ", 6)) =
            "fdh",
          "FDH",
          concat(
            upper(
              substring(
                splitPart([Task Type Clean], " ", 6),
                1,
                1
              )
            ),
            lower(
              substring(
                splitPart([Task Type Clean], " ", 6),
                2,
                length(
                  splitPart([Task Type Clean], " ", 6)
                )
              )
            )
          )
        )
      )
    )
  )
)
```

### Is Deferred

```java
contains([Labels General (norm)], "defer")
```

### Is Approved

```java
notNull([Date Approved])
```

### Is Completed

```java
notNull([Date Completed])
```

### Is Released

```java
notNull([Date Released])
```

### Released Age (Not Completed)

```java
case(
  [Is Released]
  AND NOT [Is Completed],
  datetimeDiff(
    coalesce([Date Released], now()),
    now(),
    "day"
  )
)
```

### Time to Complete

```java
case(
  [Is Released]
  AND [Is Completed],
  datetimeDiff(
    coalesce([Date Released], now()),
    coalesce([Date Completed], now()),
    "day"
  )
)
```

### Completed Age (Not Approved)

```java
case(
  [Is Completed]
  AND NOT [Is Approved],
  datetimeDiff(
    coalesce([Date Completed], now()),
    now(),
    "day"
  )
)
```

## Render Tickets (Enriched) - Metrics

These are separate metrics (aggregations) to be created in Metabase, not custom columns.

### Total Tickets

```java
Distinct([Task ID])
```

### Total Tickets Completed

```java
DistinctIf([Task ID], [Is Completed])
```

### Completion Rate

```java
DistinctIf([Task ID], [Is Completed])
/
Distinct([Task ID])
```

### Total Tickets Approved

```java
DistinctIf([Task ID], [Is Approved])
```

### Approval Rate (of Completed)

```java
DistinctIf([Task ID], [Is Approved])
/
DistinctIf([Task ID], [Is Completed])
```

### Total Tickets Releasable 

```java
DistinctIf([Task ID], [IsReleasable])
```

### Total Tickets Released

```java
DistinctIf([Task ID], [Is Released])
```

### Released Rate (of Releasable)

```java
[Total Tickets Releasable]/[Total Tickets Released]
```

### Release to Completion Rate

```java
DistinctIf([Task ID], [Is Released])
/
DistinctIf([Task ID], [Is Completed])
```