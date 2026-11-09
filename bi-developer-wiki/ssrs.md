# SSRS

## Table of Contents

- [Query Report Server Subscriptions](#query-report-server-subscriptions)
- [Query Report Server Usage](#query-report-server-usage)
- [Query Row Level Security](#query-row-level-security)

## Query Report Server Subscriptions
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
## Query Report Server Usage
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
## Query Row Level Security
```sql
SELECT
    [Name] 'Report', [ModelRoleName] 'Role', [UserName] 'User'
FROM
    [PBIReportServer].[dbo].[Catalog] c
    JOIN [PBIReportServer].[dbo].[DataModelRole] r ON r.ItemID = c.ItemID
    JOIN [PBIReportServer].[dbo].[UserDataModelRole] mr ON mr.DataModelRoleID = r.DataModelRoleID
    JOIN [PBIReportServer].[dbo].[Users] u ON u.UserID = mr.UserID
```
