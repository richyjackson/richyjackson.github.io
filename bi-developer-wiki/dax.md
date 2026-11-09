# DAX
## Creating a calculated table
```dax
P&L Matrix =

    VAR CurrYear    = MAX('P&L Summary'[Year])
    VAR PrevYear    = CurrYear - 1
    VAR CurrQuarter = CALCULATE(MAX('P&L Summary'[Quarter Number]), 'P&L Summary'[Year] = CurrYear)

    VAR QtrPos6Number = CurrQuarter
    VAR QtrPos6Year   = CurrYear
    VAR QtrPos6Name   = CALCULATE(MAX('P&L Summary'[Quarter Name]), 'P&L Summary'[Year] = CurrYear)

    VAR QtrPos5Number = IF(QtrPos6Number = 1, 4, QtrPos6Number - 1)
    VAR QtrPos5Year   = IF(QtrPos6Number = 1, QtrPos6Year - 1, QtrPos6Year)
    VAR QtrPos5Name   = CALCULATE(MAX('P&L Summary'[Quarter Name]), 'P&L Summary'[Year] = QtrPos5Year, 'P&L Summary'[Quarter Number] = QtrPos5Number)

    VAR QtrPos4Number = IF(QtrPos5Number = 1, 4, QtrPos5Number - 1)
    VAR QtrPos4Year   = IF(QtrPos5Number = 1, QtrPos5Year - 1, QtrPos5Year)
    VAR QtrPos4Name   = CALCULATE(MAX('P&L Summary'[Quarter Name]), 'P&L Summary'[Year] = QtrPos4Year, 'P&L Summary'[Quarter Number] = QtrPos4Number)

    VAR QtrPos3Number = IF(QtrPos4Number = 1, 4, QtrPos4Number - 1)
    VAR QtrPos3Year   = IF(QtrPos4Number = 1, QtrPos4Year - 1, QtrPos4Year)
    VAR QtrPos3Name   = CALCULATE(MAX('P&L Summary'[Quarter Name]), 'P&L Summary'[Year] = QtrPos3Year, 'P&L Summary'[Quarter Number] = QtrPos3Number)

    VAR QtrPos2Number = IF(QtrPos3Number = 1, 4, QtrPos3Number - 1)
    VAR QtrPos2Year   = IF(QtrPos3Number = 1, QtrPos3Year - 1, QtrPos3Year)
    VAR QtrPos2Name   = CALCULATE(MAX('P&L Summary'[Quarter Name]), 'P&L Summary'[Year] = QtrPos2Year, 'P&L Summary'[Quarter Number] = QtrPos2Number)

    VAR QtrPos1Number = IF(QtrPos2Number = 1, 4, QtrPos2Number - 1)
    VAR QtrPos1Year   = IF(QtrPos2Number = 1, QtrPos1Year - 1, QtrPos2Year)
    VAR QtrPos1Name   = CALCULATE(MAX('P&L Summary'[Quarter Name]), 'P&L Summary'[Year] = QtrPos1Year, 'P&L Summary'[Quarter Number] = QtrPos1Number)

    RETURN

    UNION(

        SUMMARIZE(
            FILTER('P&L Summary', 'P&L Summary'[Year] = PrevYear),
                'P&L Summary'[Team],
                'P&L Summary'[Main Category],
                'P&L Summary'[Sub Category],
                'P&L Summary'[Sub Category Order],
                'P&L Summary'[Account],
                'P&L Summary'[Date],
                'P&L Summary'[Value],
                'P&L Summary'[Quarter Name],
                'P&L Summary'[Year], "Measure", "Full Yr PY", "Order", 9),

        SUMMARIZE(
            FILTER('P&L Summary', 'P&L Summary'[Year] = PrevYear && 'P&L Summary'[Quarter Number] <= CurrQuarter),
                'P&L Summary'[Team],
                'P&L Summary'[Main Category],
                'P&L Summary'[Sub Category],
                'P&L Summary'[Sub Category Order],
                'P&L Summary'[Account],
                'P&L Summary'[Date],
                'P&L Summary'[Value],
                'P&L Summary'[Quarter Name],
                'P&L Summary'[Year], "Measure", "YTD PY", "Order", 8),

        SUMMARIZE(
            FILTER('P&L Summary', 'P&L Summary'[Year] = CurrYear),
                'P&L Summary'[Team],
                'P&L Summary'[Main Category],
                'P&L Summary'[Sub Category],
                'P&L Summary'[Sub Category Order],
                'P&L Summary'[Account],
                'P&L Summary'[Date],
                'P&L Summary'[Value],
                'P&L Summary'[Quarter Name],
                'P&L Summary'[Year], "Measure", "YTD", "Order", 7),

        SUMMARIZE(
            FILTER('P&L Summary', 'P&L Summary'[Quarter Name] = QtrPos6Name),
                'P&L Summary'[Team],
                'P&L Summary'[Main Category],
                'P&L Summary'[Sub Category],
                'P&L Summary'[Sub Category Order],
                'P&L Summary'[Account],
                'P&L Summary'[Date],
                'P&L Summary'[Value],
                'P&L Summary'[Quarter Name],
                'P&L Summary'[Year], "Measure", SUBSTITUTE('P&L Summary'[Quarter Name], UNICHAR(32), UNICHAR(10)), "Order", 6),

        SUMMARIZE(
            FILTER('P&L Summary', 'P&L Summary'[Quarter Name] = QtrPos5Name),
                'P&L Summary'[Team],
                'P&L Summary'[Main Category],
                'P&L Summary'[Sub Category],
                'P&L Summary'[Sub Category Order],
                'P&L Summary'[Account],
                'P&L Summary'[Date],
                'P&L Summary'[Value],
                'P&L Summary'[Quarter Name],
                'P&L Summary'[Year], "Measure", SUBSTITUTE('P&L Summary'[Quarter Name], UNICHAR(32), UNICHAR(10)), "Order", 5),

        SUMMARIZE(
            FILTER('P&L Summary', 'P&L Summary'[Quarter Name] = QtrPos4Name),
                'P&L Summary'[Team],
                'P&L Summary'[Main Category],
                'P&L Summary'[Sub Category],
                'P&L Summary'[Sub Category Order],
                'P&L Summary'[Account],
                'P&L Summary'[Date],
                'P&L Summary'[Value],
                'P&L Summary'[Quarter Name],
                'P&L Summary'[Year], "Measure", SUBSTITUTE('P&L Summary'[Quarter Name], UNICHAR(32), UNICHAR(10)), "Order", 4),

        SUMMARIZE(
            FILTER('P&L Summary', 'P&L Summary'[Quarter Name] = QtrPos3Name),
                'P&L Summary'[Team],
                'P&L Summary'[Main Category],
                'P&L Summary'[Sub Category],
                'P&L Summary'[Sub Category Order],
                'P&L Summary'[Account],
                'P&L Summary'[Date],
                'P&L Summary'[Value],
                'P&L Summary'[Quarter Name],
                'P&L Summary'[Year], "Measure", SUBSTITUTE('P&L Summary'[Quarter Name], UNICHAR(32), UNICHAR(10)), "Order", 3),

        SUMMARIZE(
            FILTER('P&L Summary', 'P&L Summary'[Quarter Name] = QtrPos2Name),
                'P&L Summary'[Team],
                'P&L Summary'[Main Category],
                'P&L Summary'[Sub Category],
                'P&L Summary'[Sub Category Order],
                'P&L Summary'[Account],
                'P&L Summary'[Date],
                'P&L Summary'[Value],
                'P&L Summary'[Quarter Name],
                'P&L Summary'[Year], "Measure", SUBSTITUTE('P&L Summary'[Quarter Name], UNICHAR(32), UNICHAR(10)), "Order", 2),

        SUMMARIZE(
            FILTER('P&L Summary', 'P&L Summary'[Quarter Name] = QtrPos1Name),
                'P&L Summary'[Team],
                'P&L Summary'[Main Category],
                'P&L Summary'[Sub Category],
                'P&L Summary'[Sub Category Order],
                'P&L Summary'[Account],
                'P&L Summary'[Date],
                'P&L Summary'[Value],
                'P&L Summary'[Quarter Name],
                'P&L Summary'[Year], "Measure", SUBSTITUTE('P&L Summary'[Quarter Name], UNICHAR(32), UNICHAR(10)), "Order", 1)

    )
```
## Create a Single Row Measures Table
```dax
KPI - Management Fees =

VAR value1 = 1
VAR value2 = 2

RETURN

ROW("Value 1", value1, "Value 2", value2)
```

## Creating Tables
### Create date table from all dates in model

```dax
Dates = CALENDARAUTO()
```

### Using SUMMARIZE

This works in the same way as a SQL Group By clause.

Duplicate values will be removed even without an aggregation column. If you do not want this then best use the Add Columns function.

An alias must be provided for aggregation columns as is done in SQL, however it is not possible to rename existing columns without aggregation.

```dax
new_table =

SUMMARIZE('my_table', my_table[ID], "Alias for column", SUM(my_table[Value]))
```

### Using SELECTCOLUMNS

This simply extracts the column information you want without aggregating the data. It therefore will keep duplicate values.

You could use a UNION statement as shown which also retains all values. To remove duplicates you would add a DISTINCT function in front of the dataset.

All columns can be renamed with an alias and custom values can also be added as below.

```dax
my_table =

DISTINCT(
  UNION(
    SELECTCOLUMNS(
      'table_1',
      "Col 1", table_1[col_1], "Col 2", table_1[col2], "Alias 1", "Alias Value"),

    SELECTCOLUMNS(
      'table_2',
      "Col 1", table_2[col_1], "Col 2", table_2[col2], "Alias 1", "Alias Value")
))
```

## Using SWITCH

```dax
my_column =

SWITCH(
  TRUE(),
  MONTH('my_table'[date]) = 1, "Q1",
  MONTH('my_table'[date]) = 2, "Q1",
  MONTH('my_table'[date]) = 3, "Q1",
  MONTH('my_table'[date]) = 4, "Q2",
  MONTH('my_table'[date]) = 5, "Q2",
  MONTH('my_table'[date]) = 6, "Q2",
  MONTH('my_table'[date]) = 7, "Q3",
  MONTH('my_table'[date]) = 8, "Q3",
  MONTH('my_table'[date]) = 9, "Q3",
  MONTH('my_table'[date]) = 10, "Q4",
  MONTH('my_table'[date]) = 11, "Q4",
  MONTH('my_table'[date]) = 12, "Q4"
)
```
