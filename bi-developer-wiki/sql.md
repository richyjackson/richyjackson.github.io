# SQL

A consolidated, alphabetically organized collection of the SQL pages previously listed in the BI Developer Wiki.

## Table of Contents

- [Access Data via API](#access-data-via-api)
- [Constraints](#constraints)
- [Dynamic DB Info Queries](#dynamic-db-info-queries)
- [Find Column References on Server](#find-column-references-on-server)
- [Find Databases Referenced on Server](#find-databases-referenced-on-server)
- [Find Object References on Server](#find-object-references-on-server)
- [Import XML](#import-xml)
- [LDAP](#ldap)
- [MERGE](#merge)
- [PIVOT](#pivot)
- [Query Active Directory](#query-active-directory)
- [Query Linked Servers](#query-linked-servers)
- [Query Size of Databases](#query-size-of-databases)
- [Restore Database](#restore-database)
- [Row Counts for All Tables](#row-counts-for-all-tables)
- [STUFF](#stuff)
- [STRING_SPLIT](#string_split)
- [Temporal Tables](#temporal-tables)
- [UNPIVOT](#unpivot)

## Access Data via API

Source: https://sites.google.com/view/bideveloperwiki/home/access-data-via-api-in-sql

### JSON GET

Example includes where an API Key is granted only. It does not include a secret however I suspect this is available as a parameter in the path.

The JSON_VALUE function can extract any value in the tree as seen in ResponseText.

```sql
DECLARE @object INT;
DECLARE @responsetext VARCHAR(8000);
DECLARE @latitude VARCHAR(10) = '50'
DECLARE @longitude VARCHAR(10) = '0.11'
DECLARE @apikey VARCHAR(100) = '{your OpenWeatherMap API key}'
DECLARE @path VARCHAR(1000) =
'https://api.openweathermap.org/data/2.5/weather?' +
'lat=' + @latitude +
'&lon=' + @longitude +
'&appid=' + @apikey

EXEC sp_OACreate 'MSXML2.XMLHTTP', @object OUT;
EXEC sp_OAMethod @object, 'open', NULL, 'get',
                 @path,
                 'false'
EXEC sp_OAMethod @object, 'send'
EXEC sp_OAMethod @object, 'responseText', @responsetext OUTPUT

PRINT @responsetext

SELECT json_value(@responsetext, '$.main.temp')

EXEC sp_OADestroy @Object
```

## Constraints

Source: https://sites.google.com/view/bideveloperwiki/home/constraints

### CHECK constraint

```sql
ALTER TABLE [dbo].[projects] WITH CHECK ADD CONSTRAINT [ck_project_end_date] CHECK (([project_end_date]>[project_start_date]))
GO
ALTER TABLE [dbo].[projects] CHECK CONSTRAINT [ck_project_end_date]
```

## Dynamic DB Info Queries

Source: https://sites.google.com/view/bideveloperwiki/home/db-info-queries

### Role Members

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

### Role Permissions

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

### Schema Owners

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

### Server Columns

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

## Find Column References on Server

Source: https://sites.google.com/view/bideveloperwiki/home/find-column-references-on-server

Find references to columns in SP or View code through Looping.

```sql
ALTER PROC [dbo].[find_column_references] (@schema AS NVARCHAR(MAX), @table_name AS NVARCHAR(MAX), @column_name AS NVARCHAR(MAX)) AS

SET NOCOUNT ON

SET @schema = REPLACE(REPLACE(@schema, '[', ''), ']', '')
SET @table_name = REPLACE(REPLACE(@table_name, '[', ''), ']', '')

DECLARE @databases AS TABLE (db VARCHAR(100), position INT)

INSERT INTO @databases
SELECT [name] db, ROW_NUMBER() OVER (ORDER BY [name]) position FROM [Reports].[sys].[databases] WHERE [name] NOT IN ('master', 'model', 'msdb', 'tempdb', 'SSISDB')

DECLARE @position AS INT = 1
DECLARE @max_position AS INT = (SELECT MAX(position) FROM @databases)
DECLARE @results AS TABLE ([database_name] VARCHAR(MAX), object_type VARCHAR(MAX), [schema_name] VARCHAR(MAX), [name] VARCHAR(MAX), definition VARCHAR(MAX))

WHILE @position <= @max_position
BEGIN

DECLARE @database AS NVARCHAR(MAX) = (SELECT db FROM @databases WHERE position = @position)

DECLARE @sql AS NVARCHAR(MAX) = '
SELECT ''' + @database + ''' database_name, ''View'' object_type, [TABLE_SCHEMA] schema_name , [table_name] name, [VIEW_DEFINITION] definition
FROM ' + @database + '.[INFORMATION_SCHEMA].[VIEWS]
WHERE
REPLACE(REPLACE(VIEW_DEFINITION, ''['',''''), '']'', '''') LIKE ''%' + @schema + '.' + @table_name + '%''' + ' AND VIEW_DEFINITION LIKE ' + '''%' + @column_name + '%''
UNION
SELECT ''' + @database + ''' database_name, ''Stored Procedure'' type, [ROUTINE_SCHEMA], [ROUTINE_NAME], [ROUTINE_DEFINITION] definition
FROM ' + @database + '.[INFORMATION_SCHEMA].[ROUTINES]
WHERE
REPLACE(REPLACE(ROUTINE_DEFINITION, ''['',''''), '']'', '''') LIKE ''%' + @schema + '.' + @table_name + '%''' + ' AND ROUTINE_DEFINITION LIKE ' + '''%' + @column_name + '%''
UNION
SELECT [TABLE_CATALOG] database_name, ''Table'' type, [TABLE_SCHEMA] schema_name, [TABLE_NAME] name, [COLUMN_NAME] definition
FROM ' + @database + '.[INFORMATION_SCHEMA].[COLUMNS]
WHERE [COLUMN_NAME] = ''' + @column_name + '''
'

INSERT INTO @results
EXEC [sys].[sp_sqlexec] @sql

SET @position = @position + 1

END

SELECT * FROM @results

PRINT @sql
```

## Find Databases Referenced on Server

Source: https://sites.google.com/view/bideveloperwiki/home/find-databases-referenced-on-server

Find references to databases in SP or View code through Looping.

```sql
ALTER PROC [dbo].[find_database_references] (@database_name AS NVARCHAR(MAX)) AS

--SET @database_name = REPLACE(REPLACE(@database_name, '[', ''), ']', '')

DECLARE @databases AS TABLE (db VARCHAR(100), position INT)

INSERT INTO @databases
SELECT [name] db, ROW_NUMBER() OVER (ORDER BY [name]) position FROM [Reports].[sys].[databases] WHERE [name] NOT IN ('master', 'model', 'msdb', 'tempdb', 'SSISDB')

DECLARE @position AS INT = 1
DECLARE @max_position AS INT = (SELECT MAX(position) FROM @databases)
DECLARE @results AS TABLE ([database_name] VARCHAR(MAX), object_type VARCHAR(MAX), [schema_name] VARCHAR(MAX), [name] VARCHAR(MAX), definition VARCHAR(MAX))

WHILE @position <= @max_position
BEGIN

DECLARE @database AS NVARCHAR(MAX) = (SELECT db FROM @databases WHERE position = @position)

DECLARE @sql AS NVARCHAR(MAX) = '
SELECT ''' + @database + ''' database_name, ''View'' object_type, [TABLE_SCHEMA] schema_name , [table_name] name, [VIEW_DEFINITION] definition
FROM ' + @database + '.[INFORMATION_SCHEMA].[VIEWS]
WHERE
REPLACE(REPLACE(VIEW_DEFINITION, ''['',''''), '']'', '''') LIKE ''%' + @database_name + '%''
UNION
SELECT ''' + @database + ''' database_name, ''Stored Procedure'' type, [ROUTINE_SCHEMA], [ROUTINE_NAME], [ROUTINE_DEFINITION] definition
FROM ' + @database + '.[INFORMATION_SCHEMA].[ROUTINES]
WHERE
REPLACE(REPLACE(ROUTINE_DEFINITION, ''['',''''), '']'', '''') LIKE ''%' + @database_name + '%'''

INSERT INTO @results
EXEC [sys].[sp_sqlexec] @sql

SET @position = @position + 1

END

SELECT * FROM @results
```

## Find Object References on Server

Source: https://sites.google.com/view/bideveloperwiki/home/find-object-references-on-server

Find references to objects in SP or View code through Looping.

```sql
ALTER PROC [dbo].[find_object_references] (@schema AS NVARCHAR(MAX), @table_name AS NVARCHAR(MAX)) AS

SET @schema = REPLACE(REPLACE(@schema, '[', ''), ']', '')
SET @table_name = REPLACE(REPLACE(@table_name, '[', ''), ']', '')

DECLARE @databases AS TABLE (db VARCHAR(100), position INT)

INSERT INTO @databases
SELECT [name] db, ROW_NUMBER() OVER (ORDER BY [name]) position FROM [Reports].[sys].[databases] WHERE [name] NOT IN ('master', 'model', 'msdb', 'tempdb', 'SSISDB')

DECLARE @position AS INT = 1
DECLARE @max_position AS INT = (SELECT MAX(position) FROM @databases)
DECLARE @results AS TABLE ([database_name] VARCHAR(MAX), object_type VARCHAR(MAX), [schema_name] VARCHAR(MAX), [name] VARCHAR(MAX), definition VARCHAR(MAX))

WHILE @position <= @max_position
BEGIN

DECLARE @database AS NVARCHAR(MAX) = (SELECT db FROM @databases WHERE position = @position)

DECLARE @sql AS NVARCHAR(MAX) = '
SELECT ''' + @database + ''' database_name, ''View'' object_type, [TABLE_SCHEMA] schema_name , [table_name] name, [VIEW_DEFINITION] definition
FROM ' + @database + '.[INFORMATION_SCHEMA].[VIEWS]
WHERE
REPLACE(REPLACE(VIEW_DEFINITION, ''['',''''), '']'', '''') LIKE ''%' + @schema + '.' + @table_name + '%''
UNION
SELECT ''' + @database + ''' database_name, ''Stored Procedure'' type, [ROUTINE_SCHEMA], [ROUTINE_NAME], [ROUTINE_DEFINITION] definition
FROM ' + @database + '.[INFORMATION_SCHEMA].[ROUTINES]
WHERE
REPLACE(REPLACE(ROUTINE_DEFINITION, ''['',''''), '']'', '''') LIKE ''%' + @schema + '.' + @table_name + '%''
UNION
SELECT [TABLE_CATALOG] database_name, ''Table'' type, [TABLE_SCHEMA] schema_name, [TABLE_NAME] name, NULL definition
FROM ' + @database + '.[INFORMATION_SCHEMA].[TABLES]
WHERE TABLE_TYPE = ''BASE TABLE'' AND [TABLE_SCHEMA] LIKE ''%' + @schema + '%'' AND [TABLE_NAME] LIKE ''%' + @table_name + '%''
'

INSERT INTO @results
EXEC [sys].[sp_sqlexec] @sql

SET @position = @position + 1

END

SELECT @schema + '.' + @table_name table_name, * FROM @results;
```

## Import XML

Source: https://sites.google.com/view/bideveloperwiki/home/import-xml

Importing an XML file into SQL Server.

```sql
DECLARE @X1 AS INT, @X AS XML, @RowSet AS NVARCHAR(MAX)

SET @RowSet = 'SELECT @x2 = p FROM OPENROWSET(BULK ''' + @FileLoc + ''', SINGLE_BLOB) as T(P)'

EXEC sp_executesql @RowSet, N'@x2 xml OUTPUT', @x2=@x OUTPUT

EXEC sp_xml_preparedocument @x1 OUTPUT, @x;

-- Populate fxl tables

INSERT INTO fxl.Fund (FundCode, MasterCitiCode, CitiCode, FundName, FundClassName, FundObjective, OfficialSector, FESector, IsFromCustomTable, AsAtArea, AsAtSector, AsAtHolding)
SELECT FundCode, MasterCitiCode, CitiCode, FundName, FundClassName, FundObjective, OfficialSector, FESector, IsFromCustomTable, AsAtArea, AsAtSector, AsAtHolding
FROM OPENXML(@x1,'/DataFields/Fund', 1)
WITH (
    FundCode varchar(12) 'FundCode/text()',
    MasterCitiCode varchar(4) 'PrimaryCitiCode/text()',
    CitiCode varchar(4) 'CitiCode/text()',
    FundName varchar(250) 'FundNameLong/text()',
    FundClassName varchar(250) 'UnitNameLong/text()',
    FundObjective nvarchar(max) 'FundObjective/text()',
    OfficialSector varchar(250) 'OfficialSector/text()',
    FESector varchar(250) 'FESector/text()',
    IsFromCustomTable int 'IsFromCustomTable/text()',
    AsAtArea varchar(50) 'AreaBreakdown/RankingDate/text()',
    AsAtSector varchar(50) 'SectorBreakdown/RankingDate/text()',
    AsAtHolding varchar(50) 'TopTenHolding/RankingDate/text()'
)

INSERT INTO fxl.EO_Area
SELECT * FROM OPENXML (@x1,'/DataFields/Fund/AreaBreakdown/Items/Item', 1)
WITH (
    FundCode varchar(12) '../../../FundCode/text()',
    AreaName varchar(250) 'Name/text()',
    AreaWeight decimal(9,5) 'Weight/text()'
)

INSERT INTO fxl.EO_Sector
SELECT * FROM OPENXML (@x1,'/DataFields/Fund/SectorBreakdown/Items/Item', 1)
WITH (
    FundCode varchar(12) '../../../FundCode/text()',
    AreaName varchar(250) 'Name/text()',
    AreaWeight decimal(9,5) 'Weight/text()'
)

INSERT INTO fxl.EO_Holding
SELECT * FROM OPENXML (@x1,'/DataFields/Fund/TopTenHolding/Items/Item', 1)
WITH (
    FundCode varchar(12) '../../../FundCode/text()',
    AreaName varchar(250) 'Name/text()',
    AreaWeight decimal(9,5) 'Weight/text()'
)
```

## LDAP

Source: https://sites.google.com/view/bideveloperwiki/home/ldap

Working with Active Directory via LDAP.

### Get LDAP User Groups for user

```sql
ALTER PROCEDURE [dbo].[GetLdapUserGroups]
(
    @LDAPEmail NVARCHAR(max)
)
AS
BEGIN

DECLARE @Query NVARCHAR(max), @Path NVARCHAR(max)

SET @Query = '
SELECT @Path = distinguishedName
FROM OPENQUERY(ADSI, ''
SELECT distinguishedName
FROM ''''LDAP://{location of LDAP server}''''
WHERE
objectClass = ''''user'''' AND
mail = ''''' + @LDAPEmail + '''''
'')
'

--print @path

EXEC SP_EXECUTESQL @Query, N'@Path NVARCHAR(max) OUTPUT', @Path = @Path OUTPUT

SET @Query = '
SELECT cn AS [LdapGroup]
FROM OPENQUERY (ADSI, ''<LDAP://{location of LDAP server}>;
(&(objectClass=group)(member:1.2.840.113556.1.4.1941:= ' + @Path + '));
cn, adspath;subtree'')
ORDER BY cn;
'

EXEC SP_EXECUTESQL @Query

END
```

## MERGE

Source: https://sites.google.com/view/bideveloperwiki/home/merge

### Update values, add new ones and delete

In 2016 SQL introduced the MERGE function allowing you to update values, add new ones and delete. This is a powerful all in one function which minimises and simplifies your code.

I frequently use this for performing mapping exercises between two systems and keeping them in sync with each other.

#### Set up code

```sql
DECLARE @source AS TABLE (country VARCHAR(50), region_code VARCHAR(2))

INSERT INTO @source VALUES ('United Kingdom', 'GB')
INSERT INTO @source VALUES ('France', 'FR')
```

#### Solution

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

## PIVOT

Source: https://sites.google.com/view/bideveloperwiki/home/pivot

Transpose rows into columns.

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

## Query Active Directory

Source: https://sites.google.com/view/bideveloperwiki/home/query-active-directory

### List users in an AD security group

There are 2 types of AD group:

- **Security groups** have credentials with a username and password. They can be configured to have permisson to servers and reports in the same way a user does.
- **Distribution groups** are used solely for emailing and have an email address which can be used for mass mailers.

#### OU

In the script below, the OU is the location within Active Directory where the AD group is stored. The path is seperated by dots, so for example Region.CompanyName.local. As a result the DC value appears 3 times.

```sql
CREATE PROC [dbo].[get_ad_group_users] (@Group VARCHAR(100)) AS
BEGIN

DECLARE @Query NVARCHAR(1000), @Path NVARCHAR(1000)

-- Identify memberof attribute value

SET @Query = '
SELECT @Path =
DistinguishedName
FROM OPENQUERY(ADSI, ''
SELECT  distinguishedName, name, objectCategory
FROM    ''''LDAP://DC={OU},DC={OU},DC={OU}''''
WHERE   objectCategory=''''group'''' AND name = ''''' + @Group + ''''''')
'

EXEC SP_EXECUTESQL @Query, N'@Path NVARCHAR(1000) OUTPUT', @Path = @Path OUTPUT

-- Extract users of AD group

SET @Query = '
SELECT
sAMAccountName WindowsLogin,
Name,
Department,
physicalDeliveryOfficeName Office,
Title,
Mail,
HomePhone,
Mobile
FROM OPENQUERY(ADSI, ''
SELECT physicalDeliveryOfficeName, sAMAccountName, mail, name, title, department, homePhone, Mobile
FROM ''''LDAP://DC={OU},DC={OU},DC={OU}''''
WHERE ObjectClass=''''User'''' AND memberof=''''' + @Path + '''''
ORDER BY sAMAccountName'')
'

EXEC (@Query)

END
```

### Find who belongs to an AD security group

The member id used below is used for recursive querying: [Recursive Querying](https://confluence.atlassian.com/crowdkb/active-directory-user-filter-does-not-search-nested-groups-715130424.html)

```sql
CREATE PROC [dbo].[get_ad_groups_for_user] (@Username NVARCHAR(256)) AS
BEGIN

    DECLARE @Query NVARCHAR(1024), @Path NVARCHAR(1024)

    SET @Query = '
        SELECT @Path = distinguishedName
        FROM OPENQUERY(ADSI, ''
            SELECT distinguishedName
            FROM ''''LDAP://DC={OU},DC={OU},DC={OU}''''
            WHERE
                objectClass = ''''user'''' AND
                sAMAccountName = ''''' + @Username + '''''
        '')
    '

    EXEC SP_EXECUTESQL @Query, N'@Path NVARCHAR(1024) OUTPUT', @Path = @Path OUTPUT

    SET @Query = '
        SELECT cn,AdsPath
        FROM OPENQUERY (ADSI, ''<LDAP://DC={OU},DC={OU},DC={OU}>;(&(objectClass=group)(member:1.2.840.113556.1.4.1941:=' + @Path +'));cn, adspath;subtree'')
ORDER BY cn'

    EXEC SP_EXECUTESQL @Query

END
```

## Query Linked Servers

Source: https://sites.google.com/view/bideveloperwiki/home/query-linked-servers

```sql
SELECT * FROM OPENQUERY({linked server name}, '{SQL Query')
```

## Query Size of Databases

Source: https://sites.google.com/view/bideveloperwiki/home/query-size-of-databases

```sql
SELECT d.NAME
    ,ROUND(SUM(CAST(mf.size AS bigint)) * 8 / 1024, 0) Size_MBs
    ,(SUM(CAST(mf.size AS bigint)) * 8 / 1024) / 1024 AS Size_GBs
FROM sys.master_files mf
INNER JOIN sys.databases d ON d.database_id = mf.database_id
WHERE d.database_id > 4 -- Skip system databases
GROUP BY d.NAME
ORDER BY d.NAME
```

## Restore Database

Source: https://sites.google.com/view/bideveloperwiki/home/restore-database

Restore databases in code.

```sql
declare @path varchar(255) = N'E:{bak file location}.bak'
declare @file int = 1

RESTORE DATABASE {
FILE = N'{DB Name}' FROM DISK = @path
WITH FILE = @file,
MOVE N'{DB Name}' TO N'D:{mdf file location}.mdf',
MOVE N'{DB Name}_log' TO N'E:{ldf file location}.ldf',
NOUNLOAD, REPLACE, STATS = 10
```

## Row Counts for All Tables

Source: https://sites.google.com/view/bideveloperwiki/home/row-counts-for-all-tables

```sql
DECLARE @entities AS TABLE ([schema] VARCHAR(100), [table_name] VARCHAR(100), position INT)
DECLARE @count AS INT
DECLARE @position AS INT = 1 -- Set the intial default position
DECLARE @schema AS VARCHAR(100)
DECLARE @table_name AS VARCHAR(100)
DECLARE @sql AS VARCHAR(MAX)

TRUNCATE TABLE dbo.RowCounts ;

-- Populate dimensional data

DELETE FROM @entities

INSERT INTO @entities
SELECT
    [TABLE_SCHEMA], [TABLE_NAME], ROW_NUMBER() OVER (ORDER BY [TABLE_NAME]) position
FROM
    [EDW2].[INFORMATION_SCHEMA].[TABLES]
WHERE
    TABLE_TYPE = 'BASE TABLE'

SET @position = 1
SET @schema = (SELECT [schema] FROM @entities WHERE position = @position);
SET @table_name = (SELECT [table_name] FROM @entities WHERE position = @position);
SET @count = (SELECT COUNT(*) FROM @entities)

WHILE @position <= @count
BEGIN

    SET @schema = (SELECT [schema] FROM @entities WHERE position = @position);
    SET @table_name = (SELECT [table_name] FROM @entities WHERE position = @position);

    SET @sql = '
    INSERT INTO dbo.RowCounts
    SELECT ''' + @schema + '.' + @table_name + ''' Table_Name, COUNT(*) Number FROM EDW2.' + @schema + '.' + @table_name + ';'

    EXEC sp_sqlexec @sql

    SET @position = @position + 1

END

SELECT * FROM dbo.RowCounts
```

## STUFF

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

## STRING_SPLIT

Source: https://sites.google.com/view/bideveloperwiki/home/stringsplit

Transform rows to columns. STRING_SPLIT allows you to transform repeating cell patterns within a cell to rows. For example you can split commas in an address to entries in their individual columns.

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

## Temporal Tables

Source: https://sites.google.com/view/bideveloperwiki/home/temporal-tables

### Turn a table into a Temporal Table

```sql
ALTER TABLE [schema].[table_name]
ADD
    sys_start_time DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL DEFAULT GETUTCDATE(),
    sys_end_time DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL DEFAULT CONVERT(DATETIME2, '9999-12-31 23:59:59.9999999'),
    PERIOD FOR SYSTEM_TIME (sys_start_time, sys_end_time);

ALTER TABLE [schema].[table_name] SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = [schema].[table_name_history]));
```

### Remove System Versioning

Do this first if wishing to delete the table or if you wish to edit the history.

```sql
ALTER TABLE [schema].[table_name] SET (SYSTEM_VERSIONING = OFF);
```

## UNPIVOT

Source: https://sites.google.com/view/bideveloperwiki/home/unpivot

Transpose columns to rows.

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
