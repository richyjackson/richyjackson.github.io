---
layout: default
title: Snowflake
---


## Dynamic Tables

- Dynamic tables automatic check for data changes to underlying tables, populating data as required
- They can be a compositon of multiple tables
- They wont work against Shared View Objects as you require permission to the underlying tables
- If the underlying tables is dropped and recreated, the refresh will fail and you will need to recreate the dynamic  tables

```sql
CREATE OR REPLACE DYNAMIC TABLE ANALYSIS_DTBL
    TARGET_LAG = '1 minute'
    REFRESH_MODE = INCREMENTAL
    INITIALIZE = ON_CREATE
    WAREHOUSE = DEV_BI_WH_XS
    AS
    SELECT * FROM STAGING_TBL;
```

##### Refresh Mode

- Incremental Mode - This only makes changes to values which have changed in the underlying data
- Full Refresh - The entire dataset is truncated and replaced

Compute is only used when there has been a change to the underlying tables. Snowflake can identify this without having to query the data

# Snowflake Dynamic Tables: Suspend and Resume Refresh Schedules

## Suspending a Dynamic Table

To suspend the automatic refresh schedule of a dynamic table:

```sql
ALTER DYNAMIC TABLE my_database.my_schema.my_dynamic_table SUSPEND;
```

## Resuming a Dynamic Table

To resume the automatic refresh schedule of a dynamic table:

```sql
ALTER DYNAMIC TABLE my_database.my_schema.my_dynamic_table RESUME;
```

## Force Refresh a Dynamic Table

To manually trigger an immediate refresh of a dynamic table:

```sql
ALTER DYNAMIC TABLE my_database.my_schema.my_dynamic_table REFRESH;
```

## Reports and Monitoring

### Show All Dynamic Tables

To view all dynamic tables in your account:

```sql
SHOW DYNAMIC TABLES;
```

To view dynamic tables in a specific database or schema:

```sql
SHOW DYNAMIC TABLES IN DATABASE my_database;
SHOW DYNAMIC TABLES IN SCHEMA my_database.my_schema;
```

To search for a specific dynamic table by name:

```sql
SHOW DYNAMIC TABLES LIKE 'my_dynamic_table';
```

### Check Dynamic Table Status and Last Refresh

Use the `DYNAMIC_TABLE_REFRESH_HISTORY` function to get detailed refresh information:

```sql
SELECT *
FROM TABLE(INFORMATION_SCHEMA.DYNAMIC_TABLE_REFRESH_HISTORY(
    NAME => 'my_database.my_schema.my_dynamic_table'
))
ORDER BY REFRESH_START_TIME DESC
LIMIT 10;
```

This returns information including:

- `REFRESH_START_TIME` - When the refresh started
- `REFRESH_END_TIME` - When the refresh completed
- `STATE` - Status of the refresh (SUCCEEDED, FAILED, etc.)
- `REFRESH_ACTION` - Type of refresh (FULL, INCREMENTAL)

### Query Account Usage for Historical Data

For longer-term historical analysis:

```sql
SELECT 
    name,
    database_name,
    schema_name,
    scheduling_state,
    target_lag,
    data_timestamp,
    refresh_start_time,
    refresh_end_time,
    state as refresh_state
FROM SNOWFLAKE.ACCOUNT_USAGE.DYNAMIC_TABLE_REFRESH_HISTORY
WHERE name = 'MY_DYNAMIC_TABLE'
ORDER BY refresh_start_time DESC
LIMIT 100;
```

### Get Current State of All Dynamic Tables

```sql
SELECT 
    "name",
    "database_name",
    "schema_name",
    "scheduling_state",
    "target_lag",
    "warehouse",
    "created_on",
    "owner"
FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()))
WHERE QUERY_ID IN (
    SELECT QUERY_ID 
    FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
    WHERE QUERY_TEXT = 'SHOW DYNAMIC TABLES'
    ORDER BY START_TIME DESC
    LIMIT 1
);
```

Or simply use `SHOW DYNAMIC TABLES` and check the `scheduling_state` column which will display either `SUSPENDED` or `STARTED`.



