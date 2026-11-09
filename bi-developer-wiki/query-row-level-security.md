# Query Row Level Security

Source: https://sites.google.com/view/bideveloperwiki/home/query-row-level-security

```sql
SELECT
    [Name] 'Report', [ModelRoleName] 'Role', [UserName] 'User'
FROM
    [PBIReportServer].[dbo].[Catalog] c
    JOIN [PBIReportServer].[dbo].[DataModelRole] r ON r.ItemID = c.ItemID
    JOIN [PBIReportServer].[dbo].[UserDataModelRole] mr ON mr.DataModelRoleID = r.DataModelRoleID
    JOIN [PBIReportServer].[dbo].[Users] u ON u.UserID = mr.UserID
```
