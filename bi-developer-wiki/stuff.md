# SQL STUFF

Source: https://sites.google.com/view/bideveloperwiki/home/stuff

```sql
WITH dataset AS (
    SELECT
        item_id,
        provider_id,
        ISNULL(item_description + ' - ', '') + item_value + ISNULL(' - ' + item_notes, '') agency
    FROM
        [item]
    WHERE
        item_type_id = 5
),

stuffed AS (
    SELECT
        provider_id,
        STUFF((
            SELECT
                '| ' + agency
            FROM
                dataset AS T1
            WHERE
                T1.provider_id = t2.provider_id
            FOR XML PATH ('')), 1, 2, '') CombinedAgency
    FROM
        dataset as T2
    GROUP BY
        provider_id
)

SELECT
    provider_id,
    (SELECT [item_type_id] FROM item_type WHERE item_type = 'Agency Code') item_type_id,
    REPLACE(CombinedAgency, '| ', CHAR(10) + CHAR(13)) CombinedAgency
FROM
    Stuffed
```
