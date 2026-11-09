# Query Report Server Useage

Source: https://sites.google.com/view/bideveloperwiki/home/query-report-server-useage

```sql
SELECT
    cat.ItemID,
    @@SERVERNAME 'Server',
    CAST(LEFT(cat.[Path], LEN(cat.[Path]) - CHARINDEX('/', REVERSE(cat.[Path]))) AS VARCHAR(100)) 'Path',
    cat.[Name],
    cat.CreationDate,
    usr.UserName CreatedBy
FROM
    [ReportServer].[dbo].[Catalog] cat
    LEFT JOIN ReportServer.dbo.Users usr ON usr.UserID = cat.CreatedByID
WHERE
    cat.[Type] IN (2,13)
ORDER BY cat.ItemID
```
