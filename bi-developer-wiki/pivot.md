# SQL PIVOT

Source: https://sites.google.com/view/bideveloperwiki/home/pivot

Transpose Rows into Columns

```sql
WITH dataset AS (
    SELECT
        CAST(YEAR([BARGAIN TRANSACTION DATE]) AS VARCHAR(5)) + CAST(MONTH([BARGAIN TRANSACTION DATE]) AS VARCHAR(5)) MonthID, [DominantTrade],
    FROM
        [dominant_trades] d
        INNER JOIN [dbo].[TRADEBargainsData] b ON b.[BARGAIN TRADE REF] = d.[BARGAIN TRADE REF]
    GROUP BY
        CAST(YEAR([BARGAIN TRANSACTION DATE]) AS VARCHAR(5)) + CAST(MONTH([BARGAIN TRANSACTION DATE]) AS VARCHAR(5)), [DominantTrade]
)

SELECT
    *
FROM
    dataset d
    PIVOT (COUNT([DominantTrade]) FOR [DominantTrade] IN ([ADV],[CDF],[CITS],[DIS],[DMS],[EXEC],[INT],[MPS],[No Dominant Trade],[SELF])) AS PVT
```
