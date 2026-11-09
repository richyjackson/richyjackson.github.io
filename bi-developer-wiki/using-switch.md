# Using switch

Source: https://sites.google.com/view/bideveloperwiki/home/using-switch

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
