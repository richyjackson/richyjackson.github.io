# Query Report Server Subscriptions

Source: https://sites.google.com/view/bideveloperwiki/home/query-report-server-subscriptions

```sql
SELECT
    @@SERVERNAME [Server],
    LEFT(cat.[Path], LEN(cat.[Path]) - CHARINDEX('/', REVERSE(cat.[Path]))) 'Path',
    cat.Name,
    cat.[Description],
    CAST(cat.CreationDate AS DATE) CreatedDate,
    cbu.UserName CreatedBy,
    CAST(cat.ModifiedDate AS DATE) ModifiedDate,
    mbu.UserName ModifiedBy,
    sub.EventType Subscription,
    sub.LastRunTime SubLastRunDate,
    sub.DeliveryExtension SubMethod,
    sub.LastStatus,
    CAST(sub.ModifiedDate AS DATE) SubModifiedDate,
    sur.UserName SubModifiedBy
FROM
    [Catalog] cat
    LEFT JOIN [ReportSchedule] rsc ON rsc.ReportID = cat.ItemID
    LEFT JOIN [Subscriptions] sub ON sub.SubscriptionID = rsc.SubscriptionID
    LEFT JOIN [Users] cbu ON cbu.UserID = cat.CreatedByID
    LEFT JOIN [Users] mbu ON mbu.UserID = cat.ModifiedByID
    LEFT JOIN [Users] sur ON sur.UserID = sub.ModifiedByID
WHERE
    sub.LastStatus IS NOT NULL
```
