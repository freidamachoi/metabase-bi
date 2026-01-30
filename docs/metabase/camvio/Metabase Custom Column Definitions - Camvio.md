# Metabase Custom Column Definitions (Camvio)

## Reusable Formulas

### Title Case (space or underscore between words)

Use when the source string has words separated by a space `" "` or an underscore `"_"`. Replace `[Your Column]` with your column name. Handles up to 6 words; extend the pattern for more.

**Step 1 – Normalize** (optional separate column): replace underscores with spaces so all delimiters are spaces.

```java
replace([Your Column], "_", " ")
```

**Step 2 – Title case** (single formula; uses normalized string inline):

```java
trim(
  concat(
    concat(
      upper(substring(splitPart(replace([Your Column], "_", " "), " ", 1), 1, 1)),
      lower(substring(splitPart(replace([Your Column], "_", " "), " ", 1), 2, length(splitPart(replace([Your Column], "_", " "), " ", 1)) - 1))
    ),
    case(
      isNull(splitPart(replace([Your Column], "_", " "), " ", 2)),
      "",
      concat(
        " ",
        concat(
          upper(substring(splitPart(replace([Your Column], "_", " "), " ", 2), 1, 1)),
          lower(substring(splitPart(replace([Your Column], "_", " "), " ", 2), 2, length(splitPart(replace([Your Column], "_", " "), " ", 2)) - 1))
        )
      )
    ),
    case(
      isNull(splitPart(replace([Your Column], "_", " "), " ", 3)),
      "",
      concat(
        " ",
        concat(
          upper(substring(splitPart(replace([Your Column], "_", " "), " ", 3), 1, 1)),
          lower(substring(splitPart(replace([Your Column], "_", " "), " ", 3), 2, length(splitPart(replace([Your Column], "_", " "), " ", 3)) - 1))
        )
      )
    ),
    case(
      isNull(splitPart(replace([Your Column], "_", " "), " ", 4)),
      "",
      concat(
        " ",
        concat(
          upper(substring(splitPart(replace([Your Column], "_", " "), " ", 4), 1, 1)),
          lower(substring(splitPart(replace([Your Column], "_", " "), " ", 4), 2, length(splitPart(replace([Your Column], "_", " "), " ", 4)) - 1))
        )
      )
    ),
    case(
      isNull(splitPart(replace([Your Column], "_", " "), " ", 5)),
      "",
      concat(
        " ",
        concat(
          upper(substring(splitPart(replace([Your Column], "_", " "), " ", 5), 1, 1)),
          lower(substring(splitPart(replace([Your Column], "_", " "), " ", 5), 2, length(splitPart(replace([Your Column], "_", " "), " ", 5)) - 1))
        )
      )
    ),
    case(
      isNull(splitPart(replace([Your Column], "_", " "), " ", 6)),
      "",
      concat(
        " ",
        concat(
          upper(substring(splitPart(replace([Your Column], "_", " "), " ", 6), 1, 1)),
          lower(substring(splitPart(replace([Your Column], "_", " "), " ", 6), 2, length(splitPart(replace([Your Column], "_", " "), " ", 6)) - 1))
        )
      )
    )
  )
)
```

**Alternative (two columns):** Create a "Clean" column with `replace([Your Column], "_", " ")`, then use the existing **Item Status**-style formula on that column (split on `" "`, title-case each part). That avoids repeating the replace and keeps the expression shorter.

### Title Case with spaces (replace underscore and period)

Replaces `"_"` and `"."` with a single space, then title-cases the result. Replace `[Your Column]` with your column name. Handles up to 6 words; extend the pattern for more.

**Normalize step** (replace `_` and `.` with space):

```java
replace(replace([Your Column], "_", " "), ".", " ")
```

**Full formula** (normalize + title case in one expression):

```java
trim(
  concat(
    concat(
      upper(substring(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 1), 1, 1)),
      lower(substring(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 1), 2, length(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 1)) - 1))
    ),
    case(
      isNull(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 2)),
      "",
      concat(
        " ",
        concat(
          upper(substring(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 2), 1, 1)),
          lower(substring(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 2), 2, length(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 2)) - 1))
        )
      )
    ),
    case(
      isNull(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 3)),
      "",
      concat(
        " ",
        concat(
          upper(substring(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 3), 1, 1)),
          lower(substring(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 3), 2, length(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 3)) - 1))
        )
      )
    ),
    case(
      isNull(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 4)),
      "",
      concat(
        " ",
        concat(
          upper(substring(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 4), 1, 1)),
          lower(substring(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 4), 2, length(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 4)) - 1))
        )
      )
    ),
    case(
      isNull(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 5)),
      "",
      concat(
        " ",
        concat(
          upper(substring(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 5), 1, 1)),
          lower(substring(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 5), 2, length(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 5)) - 1))
        )
      )
    ),
    case(
      isNull(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 6)),
      "",
      concat(
        " ",
        concat(
          upper(substring(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 6), 1, 1)),
          lower(substring(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 6), 2, length(splitPart(replace(replace([Your Column], "_", " "), ".", " "), " ", 6)) - 1))
        )
      )
    )
  )
)
```

**Behavior:** `"some_value.here"` → `"Some Value Here"`, `"word_one.word_two"` → `"Word One Word Two"`. Result is trimmed.

**Alternative (two columns):** Create a "Clean" column with `replace(replace([Your Column], "_", " "), ".", " ")`, then use the **Item Status**-style title-case formula on that column.

### Address Line (House Number + Street Direction + Street Name + Street Suffix)

Concatenates address parts in CAPS with exactly one space between non-empty parts and no leading or trailing spaces. Empty/NULL parts are skipped so there are no double spaces.

```java
trim(
  concat(
    trim(upper(coalesce([House Number], ""))),
    case(
      trim(upper(coalesce([Street Direction], ""))) = "",
      "",
      concat(
        case(trim(upper(coalesce([House Number], ""))) = "", "", " "),
        trim(upper(coalesce([Street Direction], "")))
      )
    ),
    case(
      trim(upper(coalesce([Street Name], ""))) = "",
      "",
      concat(
        case(
          trim(upper(coalesce([House Number], ""))) = "" and trim(upper(coalesce([Street Direction], ""))) = "",
          "",
          " "
        ),
        trim(upper(coalesce([Street Name], "")))
      )
    ),
    case(
      trim(upper(coalesce([Street Suffix], ""))) = "",
      "",
      concat(
        case(
          trim(upper(coalesce([House Number], ""))) = "" and trim(upper(coalesce([Street Direction], ""))) = "" and trim(upper(coalesce([Street Name], ""))) = "",
          "",
          " "
        ),
        trim(upper(coalesce([Street Suffix], "")))
      )
    )
  )
)
```

**Behavior:**
- Each part is trimmed and uppercased; NULL is treated as empty.
- A single space is added before a part only when that part is non-empty and at least one part before it is non-empty.
- Final result is trimmed so there is no leading or trailing space.

---

## Appointments with Orders and Tickets (Enriched)

### Status Clean

```java
replace(
  replace(replace([Status], "_", " "), "-", " "),
  ".",
  " "
)
```

### Item Status 

```java
trim(
  concat(
    concat(
      upper(
        substring(
          splitPart([Status Clean], " ", 1),
          1,
          1
        )
      ),
      lower(
        substring(
          splitPart([Status Clean], " ", 1),
          2,
          length(
            splitPart([Status Clean], " ", 1)
          ) - 1
        )
      )
    ),
    case(
      isNull(splitPart([Status Clean], " ", 2)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Status Clean], " ", 2),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Status Clean], " ", 2),
              2,
              length(
                splitPart([Status Clean], " ", 2)
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Status Clean], " ", 3)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Status Clean], " ", 3),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Status Clean], " ", 3),
              2,
              length(
                splitPart([Status Clean], " ", 3)
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Status Clean], " ", 4)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Status Clean], " ", 4),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Status Clean], " ", 4),
              2,
              length(
                splitPart([Status Clean], " ", 4)
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Status Clean], " ", 5)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Status Clean], " ", 5),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Status Clean], " ", 5),
              2,
              length(
                splitPart([Status Clean], " ", 5)
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Status Clean], " ", 6)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Status Clean], " ", 6),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Status Clean], " ", 6),
              2,
              length(
                splitPart([Status Clean], " ", 6)
              ) - 1
            )
          )
        )
      )
    )
  )
)
```

### Serviceorder Type Clean

```java
replace(
  replace(replace([Serviceorder Type], "_", " "), "-", " "),
  ".",
  " "
)
```

### Service Order Type 

```java
trim(
  concat(
    concat(
      upper(
        substring(
          splitPart([Serviceorder Type Clean], " ", 1),
          1,
          1
        )
      ),
      lower(
        substring(
          splitPart([Serviceorder Type Clean], " ", 1),
          2,
          length(
            splitPart([Serviceorder Type Clean], " ", 1)
          ) - 1
        )
      )
    ),
    case(
      isNull(splitPart([Serviceorder Type Clean], " ", 2)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Serviceorder Type Clean], " ", 2),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Serviceorder Type Clean], " ", 2),
              2,
              length(
                splitPart([Serviceorder Type Clean], " ", 2)
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Serviceorder Type Clean], " ", 3)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Serviceorder Type Clean], " ", 3),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Serviceorder Type Clean], " ", 3),
              2,
              length(
                splitPart([Serviceorder Type Clean], " ", 3)
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Serviceorder Type Clean], " ", 4)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Serviceorder Type Clean], " ", 4),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Serviceorder Type Clean], " ", 4),
              2,
              length(
                splitPart([Serviceorder Type Clean], " ", 4)
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Serviceorder Type Clean], " ", 5)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Serviceorder Type Clean], " ", 5),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Serviceorder Type Clean], " ", 5),
              2,
              length(
                splitPart([Serviceorder Type Clean], " ", 5)
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Serviceorder Type Clean], " ", 6)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Serviceorder Type Clean], " ", 6),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Serviceorder Type Clean], " ", 6),
              2,
              length(
                splitPart([Serviceorder Type Clean], " ", 6)
              ) - 1
            )
          )
        )
      )
    )
  )
)
```

### City

```java
trim(
  concat(
    concat(
      upper(
        substring(
          splitPart(
            trim(
              replace([Serviceline Address City], "-", " ")
            ),
            " ",
            1
          ),
          1,
          1
        )
      ),
      lower(
        substring(
          splitPart(
            trim(
              replace([Serviceline Address City], "-", " ")
            ),
            " ",
            1
          ),
          2,
          length(
            splitPart(
              trim(
                replace([Serviceline Address City], "-", " ")
              ),
              " ",
              1
            )
          ) - 1
        )
      )
    ),
    case(
      isNull(
        splitPart(
          trim(
            replace([Serviceline Address City], "-", " ")
          ),
          " ",
          2
        )
      ),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart(
                trim(
                  replace([Serviceline Address City], "-", " ")
                ),
                " ",
                2
              ),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart(
                trim(
                  replace([Serviceline Address City], "-", " ")
                ),
                " ",
                2
              ),
              2,
              length(
                splitPart(
                  trim(
                    replace([Serviceline Address City], "-", " ")
                  ),
                  " ",
                  2
                )
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(
        splitPart(
          trim(
            replace([Serviceline Address City], "-", " ")
          ),
          " ",
          3
        )
      ),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart(
                trim(
                  replace([Serviceline Address City], "-", " ")
                ),
                " ",
                3
              ),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart(
                trim(
                  replace([Serviceline Address City], "-", " ")
                ),
                " ",
                3
              ),
              2,
              length(
                splitPart(
                  trim(
                    replace([Serviceline Address City], "-", " ")
                  ),
                  " ",
                  3
                )
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(
        splitPart(
          trim(
            replace([Serviceline Address City], "-", " ")
          ),
          " ",
          4
        )
      ),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart(
                trim(
                  replace([Serviceline Address City], "-", " ")
                ),
                " ",
                4
              ),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart(
                trim(
                  replace([Serviceline Address City], "-", " ")
                ),
                " ",
                4
              ),
              2,
              length(
                splitPart(
                  trim(
                    replace([Serviceline Address City], "-", " ")
                  ),
                  " ",
                  4
                )
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(
        splitPart(
          trim(
            replace([Serviceline Address City], "-", " ")
          ),
          " ",
          5
        )
      ),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart(
                trim(
                  replace([Serviceline Address City], "-", " ")
                ),
                " ",
                5
              ),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart(
                trim(
                  replace([Serviceline Address City], "-", " ")
                ),
                " ",
                5
              ),
              2,
              length(
                splitPart(
                  trim(
                    replace([Serviceline Address City], "-", " ")
                  ),
                  " ",
                  5
                )
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(
        splitPart(
          trim(
            replace([Serviceline Address City], "-", " ")
          ),
          " ",
          6
        )
      ),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart(
                trim(
                  replace([Serviceline Address City], "-", " ")
                ),
                " ",
                6
              ),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart(
                trim(
                  replace([Serviceline Address City], "-", " ")
                ),
                " ",
                6
              ),
              2,
              length(
                splitPart(
                  trim(
                    replace([Serviceline Address City], "-", " ")
                  ),
                  " ",
                  6
                )
              ) - 1
            )
          )
        )
      )
    )
  )
)
```

## Trouble Ticket Assignee (Formatted)

### Assignee Formatted

```java
case(
  isNull([Trouble Ticket Assignee]),
  "Unassigned",
  case(
    trim([Trouble Ticket Assignee]) = "",
    "Unassigned",
  case(
    contains([Trouble Ticket Assignee], "@"),
    concat(
      upper(
        substring(
          splitPart([Trouble Ticket Assignee], "@", 1),
          1,
          1
        )
      ),
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Trouble Ticket Assignee], "@", 1),
              2,
              1
            )
          ),
          lower(
            substring(
              splitPart([Trouble Ticket Assignee], "@", 1),
              3,
              length(
                splitPart([Trouble Ticket Assignee], "@", 1)
              ) - 2
            )
          )
        )
      )
    ),
    case(
      contains(lower([Trouble Ticket Assignee]), "distribution"),
      case(
        contains(lower([Trouble Ticket Assignee]), "customercare"),
        "Customer Care",
        case(
          contains(lower([Trouble Ticket Assignee]), "osp"),
          "OSP",
          [Trouble Ticket Assignee]
        )
      ),
      [Trouble Ticket Assignee]
    )
  )
  )
)
```

### Within 30 Days of Serviceline Start

```java
case(
  [Record Type] = "Trouble Ticket",
  COALESCE(
    datetimeDiff([SERVICELINE_CREATED_DATETIME], [CREATED_DATETIME], "day"),
    999999
  ) <= 30,
  false
)
```

## Title Case (Handles Spaces, '/', and '-')

### Title Case String

**Purpose**: Title cases a string, handling spaces, forward slashes ('/'), and dashes ('-'). All delimiters are normalized to spaces in the output.

**Usage**: Replace `[Your Field]` with the field you want to title case.

```java
trim(
  concat(
    concat(
      upper(
        substring(
          splitPart(
            replace(
              replace(replace([Your Field], "/", " "), "-", " "),
              "  ",
              " "
            ),
            " ",
            1
          ),
          1,
          1
        )
      ),
      lower(
        substring(
          splitPart(
            replace(
              replace(replace([Your Field], "/", " "), "-", " "),
              "  ",
              " "
            ),
            " ",
            1
          ),
          2,
          length(
            splitPart(
              replace(
                replace(replace([Your Field], "/", " "), "-", " "),
                "  ",
                " "
              ),
              " ",
              1
            )
          ) - 1
        )
      )
    ),
    case(
      isNull(
        splitPart(
          replace(
            replace(replace([Your Field], "/", " "), "-", " "),
            "  ",
            " "
          ),
          " ",
          2
        )
      ),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart(
                replace(
                  replace(replace([Your Field], "/", " "), "-", " "),
                  "  ",
                  " "
                ),
                " ",
                2
              ),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart(
                replace(
                  replace(replace([Your Field], "/", " "), "-", " "),
                  "  ",
                  " "
                ),
                " ",
                2
              ),
              2,
              length(
                splitPart(
                  replace(
                    replace(replace([Your Field], "/", " "), "-", " "),
                    "  ",
                    " "
                  ),
                  " ",
                  2
                )
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(
        splitPart(
          replace(
            replace(replace([Your Field], "/", " "), "-", " "),
            "  ",
            " "
          ),
          " ",
          3
        )
      ),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart(
                replace(
                  replace(replace([Your Field], "/", " "), "-", " "),
                  "  ",
                  " "
                ),
                " ",
                3
              ),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart(
                replace(
                  replace(replace([Your Field], "/", " "), "-", " "),
                  "  ",
                  " "
                ),
                " ",
                3
              ),
              2,
              length(
                splitPart(
                  replace(
                    replace(replace([Your Field], "/", " "), "-", " "),
                    "  ",
                    " "
                  ),
                  " ",
                  3
                )
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(
        splitPart(
          replace(
            replace(replace([Your Field], "/", " "), "-", " "),
            "  ",
            " "
          ),
          " ",
          4
        )
      ),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart(
                replace(
                  replace(replace([Your Field], "/", " "), "-", " "),
                  "  ",
                  " "
                ),
                " ",
                4
              ),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart(
                replace(
                  replace(replace([Your Field], "/", " "), "-", " "),
                  "  ",
                  " "
                ),
                " ",
                4
              ),
              2,
              length(
                splitPart(
                  replace(
                    replace(replace([Your Field], "/", " "), "-", " "),
                    "  ",
                    " "
                  ),
                  " ",
                  4
                )
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(
        splitPart(
          replace(
            replace(replace([Your Field], "/", " "), "-", " "),
            "  ",
            " "
          ),
          " ",
          5
        )
      ),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart(
                replace(
                  replace(replace([Your Field], "/", " "), "-", " "),
                  "  ",
                  " "
                ),
                " ",
                5
              ),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart(
                replace(
                  replace(replace([Your Field], "/", " "), "-", " "),
                  "  ",
                  " "
                ),
                " ",
                5
              ),
              2,
              length(
                splitPart(
                  replace(
                    replace(replace([Your Field], "/", " "), "-", " "),
                    "  ",
                    " "
                  ),
                  " ",
                  5
                )
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(
        splitPart(
          replace(
            replace(replace([Your Field], "/", " "), "-", " "),
            "  ",
            " "
          ),
          " ",
          6
        )
      ),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart(
                replace(
                  replace(replace([Your Field], "/", " "), "-", " "),
                  "  ",
                  " "
                ),
                " ",
                6
              ),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart(
                replace(
                  replace(replace([Your Field], "/", " "), "-", " "),
                  "  ",
                  " "
                ),
                " ",
                6
              ),
              2,
              length(
                splitPart(
                  replace(
                    replace(replace([Your Field], "/", " "), "-", " "),
                    "  ",
                    " "
                  ),
                  " ",
                  6
                )
              ) - 1
            )
          )
        )
      )
    )
  )
)
```

**Notes**:
- This expression handles up to 6 words/parts. If you need more, add additional `case()` blocks for parts 7, 8, etc.
- All delimiters ('/', '-', and spaces) are normalized to single spaces in the output
- Empty/null parts are skipped
- Multiple consecutive spaces are collapsed to single spaces
- Replace `[Your Field]` with the actual field name you want to title case

**Example**:
- Input: `"john-smith/jones"` → Output: `"John Smith Jones"`
- Input: `"MARY JANE-WATSON"` → Output: `"Mary Jane Watson"`
- Input: `"test/example-case"` → Output: `"Test Example Case"`

## Title Case (Single Word)

**Purpose**: Formats a single word to title case (first letter uppercase, rest lowercase).

**Usage**: Replace `[Your Field]` with the field you want to title case.

```java
concat(
  upper(
    substring([Your Field], 1, 1)
  ),
  lower(
    substring([Your Field], 2, length([Your Field]) - 1)
  )
)
```

**Notes**:
- Works for single words only
- First character is uppercased
- All remaining characters are lowercased
- Handles null/empty values gracefully (returns empty string if field is null/empty)

**Example**:
- Input: `"JOHN"` → Output: `"John"`
- Input: `"mary"` → Output: `"Mary"`
- Input: `"SMITH"` → Output: `"Smith"`

## Inactive Account with Ended Serviceline

### Inactive Account Ended Serviceline Flag

**Purpose**: Returns 1 if account is not active AND serviceline has an end date, otherwise 0.

**Usage**: Use with Servicelines Base model or any model that has `ACCOUNT_STATUS` and `SERVICELINE_ENDDATE` fields.

```java
case(
  contains(lower([ACCOUNT_STATUS]), "active"),
  0,
  case(
    isNull([SERVICELINE_ENDDATE]),
    0,
    1
  )
)
```

**Notes**:
- Returns 1 when:
  - ACCOUNT_STATUS does NOT contain "active" (case-insensitive)
  - AND SERVICELINE_ENDDATE is NOT NULL
- Returns 0 otherwise
- Useful for identifying inactive accounts with ended servicelines

**Example**:
- ACCOUNT_STATUS = "Inactive", SERVICELINE_ENDDATE = "2024-01-15" → Returns `1`
- ACCOUNT_STATUS = "Active", SERVICELINE_ENDDATE = "2024-01-15" → Returns `0`
- ACCOUNT_STATUS = "Inactive", SERVICELINE_ENDDATE = NULL → Returns `0`
- ACCOUNT_STATUS = "Active", SERVICELINE_ENDDATE = NULL → Returns `0`