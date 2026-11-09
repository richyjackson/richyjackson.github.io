# Creating Tables

Source: https://sites.google.com/view/bideveloperwiki/home/creating-tables

## Create date table from all dates in model

```dax
Dates = CALENDARAUTO()
```

## Using SUMMARIZE

This works in the same way as a SQL Group By clause.

Duplicate values will be removed even without an aggregation column. If you do not want this then best use the Add Columns function

An alias must be provided for aggregation columns as is done in SQL, however it is not possible to rename existing columns without aggregation.

```dax
new_table =

SUMMARIZE('my_table', my_table[ID], "Alias for column", SUM(my_table[Value]))
```

## Using SELECTCOLUMNS

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
