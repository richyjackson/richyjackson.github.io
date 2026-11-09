# Find Object References on Server

Source: https://sites.google.com/view/bideveloperwiki/home/find-object-references-on-server

Find references to objects in SP or View code through Looping

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
