## Time Travel
- Access historical, changed or deleted data within a retention period
- Applies to a database, schema or table
- For undoing mistakes, recovering objects, auditing changes or point in time analysis

### Retention Period
```
. Configured via DATA_RETENTION_TIME_IN_DAYS for individual objects
. MIN_DATA_RETENTION_IN_DAYS for account level settings
. Default: 1 day
. Standard Edition: 0 –> 1 day
. Enterprise Edition and above: 0 –> 90 days configurable
. Setting to 0 disables Time Travel for that object
. Child objects inherit parent settings
. Temp & transient tables: max 1 day regardless of edition
. Can be set at the account, database, schema, or table level
. Historical data counts towards storage billing
. Clones inherit the sources clone history at billing
```
### Querying Historical Data
Use the AT or BEFORE clause
```sql
-- By timestamp
SELECT * FROM my_table AT (TIMESTAMP => '2024-01-15 10:00:00'::TIMESTAMP);

-- By offset (seconds ago)
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
```

## Fail Safe
- Activates only after time travel has expired
- Recoverable by Snowflake only, no user access
