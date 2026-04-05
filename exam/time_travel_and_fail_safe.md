## Time Travel
- Access historical, changed or deleted data within a retention period
- Applies to a database, schema or table
- For undoing mistakes, recovering objects, auditing changes or point in time analysis

### Retention Period
> Default: 1 Day<br>
> Disable: 0 Days

|Table Type|Standard Edition Max|Enterprise Edition Max|
|---|---|---|
|Permanent|1 Day|90 Days|
|Temporary|1 Day|1 Day|
|Transient|1 Day|1 Day|
- Use DATA_RETENTION_TIME_IN_DAYS for individual objects
- Use MIN_DATA_RETENTION_IN_DAYS for account, database, schema or table level settings
- Child objects inherit parent settings
- Historical data counts towards storage billing
- Clones inherit the sources clone history at billing
### Querying Historical Data
**Use the AT or BEFORE clause**
```sql
-- By timestamp
SELECT * FROM my_table AT (TIMESTAMP => '2024-01-15 10:00:00'::TIMESTAMP);

-- By offset
SELECT * FROM my_table AT (OFFSET => -60*5);  -- 5 minutes ago

-- By query ID
SELECT * FROM my_table BEFORE (STATEMENT => '<query_id>');

-- Restore a dropped object:
UNDROP TABLE my_table;
UNDROP SCHEMA my schema;
UNDROP DATABASE my_database;

-- Recreate from a historical snapshot or restore table
CREATE OR REPLACE TABLE my_table AS
  SELECT * FROM my_table BEFORE (STATEMENT => '<query_id>');

-- See the time travel policy
SHOW TABLES;
SHOW SCHEMAS;
SHOW DATABASES;
SHOW STREAMS;
```
### Limitations
- External tables
- Hybrid tables
- Internal stages
- Tasks
### Effect on Streams
> Streams go stale if data has not been consumed within the underlying tables time travel policy or 14 days whichever is longest <br><br>
> Data within the stream cannot be recovered if it becomes stale and must be recreated
## Fail Safe
- Activates only after time travel has expired
- Recoverable by Snowflake only, no user access
