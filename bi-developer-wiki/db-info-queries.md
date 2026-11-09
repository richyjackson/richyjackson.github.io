# Dynamic DB Info Queries

Source: https://sites.google.com/view/bideveloperwiki/home/db-info-queries

## Role Members

```sql
DECLARE @databases AS TABLE (db VARCHAR(100), position INT)

INSERT INTO @databases
SELECT [name] db, ROW_NUMBER() OVER (ORDER BY [name]) position FROM [Reports].[sys].[databases]

DECLARE @position AS INT = 1
DECLARE @max_position AS INT = (SELECT MAX(position) FROM @databases)
DECLARE @results AS TABLE ([database] VARCHAR(100), [role] VARCHAR(100), [user] VARCHAR(100))

WHILE @position <= @max_position
BEGIN

DECLARE @database AS NVARCHAR(MAX) = (SELECT db FROM @databases WHERE position = @position)

DECLARE @sql AS NVARCHAR(MAX) = '
SELECT
''' + @database + ''' ''database'',
dp.[name] ''role'',
dp2.[name] ''user''
FROM
' + @database + '.[sys].[database_role_members] rm
LEFT JOIN ' + @database + '.[sys].[database_principals] dp ON dp.principal_id = rm.role_principal_id
LEFT JOIN ' + @database + '.[sys].[database_principals] dp2 ON dp2.principal_id = rm.member_principal_id'

INSERT INTO @results
EXEC [sys].[sp_sqlexec] @sql

SET @position = @position + 1

END

SELECT * FROM @results
```

## Role Permissions

```sql
ALTER PROC [dbo].[role_permissions] AS

DECLARE @databases AS TABLE (db VARCHAR(100), position INT)

INSERT INTO @databases
SELECT [name] db, ROW_NUMBER() OVER (ORDER BY [name]) position FROM [Reports].[sys].[databases]

DECLARE @position AS INT = 1
DECLARE @max_position AS INT = (SELECT MAX(position) FROM @databases)
DECLARE @results AS TABLE ([database] VARCHAR(100), [role] VARCHAR(100), [permission_name] VARCHAR(100))

WHILE @position <= @max_position
BEGIN

DECLARE @database AS NVARCHAR(MAX) = (SELECT db FROM @databases WHERE position = @position)

DECLARE @sql AS NVARCHAR(MAX) = '
SELECT DISTINCT
''' + @database + ''' [database], dpr.[name] role, permission_name
FROM '
+ @database + '.sys.database_permissions  dp JOIN ' + @database + '.sys.database_principals dpr ON dpr.principal_id = dp.grantee_principal_id
WHERE
dpr.[name] NOT LIKE ''%CLOSEAM%'' AND dpr.[name] NOT IN (''public'') and state_desc = ''grant'''

INSERT INTO @results
EXEC [sys].[sp_sqlexec] @sql

SET @position = @position + 1

END

SELECT * FROM @results
```

## Schema Owners

```sql
ALTER PROC [dbo].[schema_owners] AS

DECLARE @databases AS TABLE (db VARCHAR(100), position INT)

INSERT INTO @databases
SELECT [name] db, ROW_NUMBER() OVER (ORDER BY [name]) position FROM [Reports].[sys].[databases]

DECLARE @position AS INT = 1
DECLARE @max_position AS INT = (SELECT MAX(position) FROM @databases)
DECLARE @results AS TABLE (CATALOG_NAME VARCHAR(100), [SCHEMA_NAME] VARCHAR(100), SCHEMA_OWNER VARCHAR(100))

WHILE @position <= @max_position
BEGIN

DECLARE @database AS NVARCHAR(MAX) = (SELECT db FROM @databases WHERE position = @position)

DECLARE @sql AS NVARCHAR(MAX) = '
SELECT
[CATALOG_NAME],
[SCHEMA_NAME],
[SCHEMA_OWNER]
FROM
' + @database + '.[INFORMATION_SCHEMA].[SCHEMATA]'

INSERT INTO @results
EXEC [sys].[sp_sqlexec] @sql

SET @position = @position + 1

END

SELECT * FROM @results
```

## Server Columns

```sql
ALTER PROC [dbo].[server_columns] AS

DECLARE @databases AS TABLE (db VARCHAR(100), position INT)

INSERT INTO @databases
SELECT [name] db, ROW_NUMBER() OVER (ORDER BY [name]) position FROM [Reports].[sys].[databases] WHERE [name] NOT IN ('SSISDB', 'master', 'model', 'msdb', 'tempdb')

DECLARE @position AS INT = 1
DECLARE @max_position AS INT = (SELECT MAX(position) FROM @databases)
DECLARE @results AS TABLE ([database] VARCHAR(100), [table] VARCHAR(100), [column] VARCHAR(100), [masking_function] VARCHAR(100))

WHILE @position <= @max_position
BEGIN

DECLARE @database AS NVARCHAR(MAX) = (SELECT db FROM @databases WHERE position = @position)

DECLARE @sql AS NVARCHAR(MAX) = '
WITH masked_columns AS (
SELECT
t.TABLE_CATALOG AS ''database'',
t.TABLE_SCHEMA + ''.'' + t.TABLE_NAME ''table'',
m.[name] ''column'',
m.[masking_function]
FROM
' + @database + '.[sys].[masked_columns] m
JOIN ' + @database + '.[sys].[all_objects] o ON o.[object_id] = m.[object_id]
JOIN ' + @database + '.[INFORMATION_SCHEMA].[TABLES] t ON t.TABLE_NAME = o.[name]
)
SELECT
c.[TABLE_CATALOG] ''database'',
c.[TABLE_SCHEMA] + ''.'' + c.[TABLE_NAME] ''table'',
c.[COLUMN_NAME] ''column'',
m.[masking_function]
FROM '
+ @database + '.[INFORMATION_SCHEMA].[COLUMNS] c
LEFT JOIN masked_columns m ON m.[database] = c.[TABLE_CATALOG] AND c.[TABLE_SCHEMA] + ''.'' + c.[TABLE_NAME] = m.[table] AND c.[COLUMN_NAME] = m.[column]'

INSERT INTO @results
EXEC [sys].[sp_sqlexec] @sql

SET @position = @position + 1

END

SELECT * FROM @results
```
