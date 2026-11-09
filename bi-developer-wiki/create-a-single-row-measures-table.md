# Single Row Measures Table

Source: https://sites.google.com/view/bideveloperwiki/home/create-a-single-row-measures-table

```dax
KPI - Management Fees =

VAR value1 = 1
VAR value2 = 2

RETURN

ROW("Value 1", value1, "Value 2", value2)
```
