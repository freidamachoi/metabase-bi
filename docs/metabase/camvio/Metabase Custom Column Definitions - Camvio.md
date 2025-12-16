# Metabase Custom Column Definitions (Camvio)

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
          splitPart([Address City], " ", 1),
          1,
          1
        )
      ),
      lower(
        substring(
          splitPart([Address City], " ", 1),
          2,
          length(
            splitPart([Address City], " ", 1)
          ) - 1
        )
      )
    ),
    case(
      isNull(splitPart([Address City], " ", 2)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Address City], " ", 2),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Address City], " ", 2),
              2,
              length(
                splitPart([Address City], " ", 2)
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Address City], " ", 3)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Address City], " ", 3),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Address City], " ", 3),
              2,
              length(
                splitPart([Address City], " ", 3)
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Address City], " ", 4)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Address City], " ", 4),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Address City], " ", 4),
              2,
              length(
                splitPart([Address City], " ", 4)
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Address City], " ", 5)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Address City], " ", 5),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Address City], " ", 5),
              2,
              length(
                splitPart([Address City], " ", 5)
              ) - 1
            )
          )
        )
      )
    ),
    case(
      isNull(splitPart([Address City], " ", 6)),
      "",
      concat(
        " ",
        concat(
          upper(
            substring(
              splitPart([Address City], " ", 6),
              1,
              1
            )
          ),
          lower(
            substring(
              splitPart([Address City], " ", 6),
              2,
              length(
                splitPart([Address City], " ", 6)
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