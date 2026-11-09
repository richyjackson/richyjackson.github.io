# SQL UNPIVOT

Source: https://sites.google.com/view/bideveloperwiki/home/unpivot

Transpose Columns to Rows

```sql
SELECT [Resource]
    ,[Initiative]
    ,Dates
    ,Allocation
FROM (
    SELECT [Resource],[Initiative],[01-Jan],[08-Jan],[15-Jan] FROM [ResourceAllocation].[dbo].[PM resource]) r
UNPIVOT
    (Allocation for Dates IN ([01-Jan],[08-Jan],[15-Jan])) d
```
