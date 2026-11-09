# Row Counts for All Tables

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
