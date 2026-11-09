# SQL Merge

Source: https://sites.google.com/view/bideveloperwiki/home/merge

## Update values, add new ones and delete

In 2016 SQL introduced the MERGE function allowing you to update values, add new ones and delete. This is a powerful all in one function which minimises and simplifies your code.

I frequently use this for performing mapping exercises between two systems and keeping them in sync with each other.

### Set up code

```sql
DECLARE @source AS TABLE (country VARCHAR(50), region_code VARCHAR(2))

INSERT INTO @source VALUES ('United Kingdom', 'GB')
INSERT INTO @source VALUES ('France', 'FR')
```

### Solution

- Would suggest writing a CTE to transform or filter any source data you wish to asses:

```sql
WITH source_data AS (
    SELECT
        country,
        region_code
    FROM
        countries
)
```

- Join your CTE to the table you wish to modify

```sql
MERGE INTO mapping.countries AS tgt
USING source_data AS src ON src.country = tgt.country
```

- Update fields where there is a match

```sql
WHEN MATCHED THEN UPDATE
SET tgt.region_code = src.region_code
```

- Add values which do not appear in your destination table

```sql
WHEN NOT MATCHED THAN INSERT VALUES (src.country)
```

- Remove values in your destination table which do not appear at source

```sql
WHEN NOT MATCHED BY SOURCE THEN DELETE
```

- All merged statements must be terminated by a semi colon

```sql
;
```
