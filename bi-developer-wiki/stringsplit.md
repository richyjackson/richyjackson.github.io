# SQL STRINGSPLIT

Source: https://sites.google.com/view/bideveloperwiki/home/stringsplit

Transform Rows To Columns

STRINGSPLIT allows you to transform repeating cell patterns within a cell to rows.

For example you can split commas in an address to entries in their individual columns.

```sql
WITH dataset AS (
    SELECT
        item_id,
        item_value,
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(RTRIM(item_value), CHAR(10), ','), CHAR(13), ','), ',,', ','), ',,', ','), ',,', ',') transformed
    FROM
        item
    WHERE
        item_type_id = 7
),

split AS (
    SELECT
        item_id,
        'Address' + CAST(ROW_NUMBER() OVER (PARTITION BY item_id ORDER BY item_id) AS VARCHAR(10)) AS ColumnName,
        [value]
    FROM
        dataset
        CROSS APPLY STRING_SPLIT(transformed, ',')
)

SELECT *
FROM
    Split AS SourceTable
    PIVOT (MAX([Value]) FOR ColumnName IN (Address1, Address2, Address3)) AS PVT
;
```
