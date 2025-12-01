# Snowflake Tasks: Comprehensive Guide

## Table of Contents

- [Overview](#overview)
- [Task Fundamentals](#task-fundamentals)
- [Creating Tasks](#creating-tasks)
- [Task Scheduling](#task-scheduling)
- [Task Dependencies (Task Trees)](#task-dependencies-task-trees)
- [Conditional Task Execution](#conditional-task-execution)
- [Monitoring and Managing Tasks](#monitoring-and-managing-tasks)
- [Best Practices](#best-practices)
- [Common Use Cases](#common-use-cases)
- [Troubleshooting](#troubleshooting)

-----

## Overview

Snowflake Tasks are objects that enable scheduled execution of SQL statements, stored procedures, or procedural logic. They’re essential for building automated data pipelines, ETL processes, and scheduled maintenance operations.

### Key Capabilities

- Schedule SQL statements or stored procedures
- Create task dependencies (DAGs - Directed Acyclic Graphs)
- Execute tasks conditionally based on data or previous task results
- Monitor execution history and manage task lifecycle
- Integrate with streams for CDC (Change Data Capture) workflows

### Required Privileges

```sql
-- Grant privileges to create and manage tasks
GRANT EXECUTE TASK ON ACCOUNT TO ROLE my_role;
GRANT CREATE TASK ON SCHEMA my_schema TO ROLE my_role;

-- Grant privileges to execute tasks
USE ROLE ACCOUNTADMIN;
GRANT EXECUTE MANAGED TASK ON ACCOUNT TO ROLE my_role;
```

-----

## Task Fundamentals

### Basic Task Anatomy

```sql
CREATE TASK my_task
  WAREHOUSE = my_warehouse
  SCHEDULE = 'USING CRON 0 9 * * * America/New_York'
AS
  INSERT INTO target_table
  SELECT * FROM source_table WHERE processed = FALSE;
```

### Task States

- **Started**: Task is active and will run according to schedule
- **Suspended**: Task is paused and won’t execute
- **Executing**: Task is currently running

### Task Components

|Component    |Description                    |Required               |
|-------------|-------------------------------|-----------------------|
|`WAREHOUSE`  |Compute resources for execution|Yes (unless serverless)|
|`SCHEDULE`   |When/how often the task runs   |Yes (for root tasks)   |
|`WHEN`       |Conditional execution logic    |No                     |
|`AFTER`      |Task dependency specification  |No                     |
|SQL/Procedure|The work to be performed       |Yes                    |

-----

## Creating Tasks

### Simple Scheduled Task

```sql
CREATE OR REPLACE TASK daily_aggregation
  WAREHOUSE = compute_wh
  SCHEDULE = '1440 MINUTE'  -- Every 24 hours
AS
  CREATE OR REPLACE TABLE daily_summary AS
  SELECT 
    date_trunc('day', order_date) as order_day,
    count(*) as order_count,
    sum(amount) as total_amount
  FROM orders
  WHERE order_date >= current_date - 1
  GROUP BY 1;
```

### Task with CRON Expression

```sql
CREATE TASK weekly_report
  WAREHOUSE = reporting_wh
  SCHEDULE = 'USING CRON 0 8 * * MON America/Los_Angeles'  -- Every Monday at 8 AM PT
  COMMENT = 'Generate weekly sales report'
AS
  CALL generate_weekly_report();
```

#### CRON Expression Format

```
 ┌───────────── minute (0 - 59)
 │ ┌───────────── hour (0 - 23)
 │ │ ┌───────────── day of month (1 - 31)
 │ │ │ ┌───────────── month (1 - 12)
 │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
 │ │ │ │ │
 * * * * *
```

**Common CRON Examples:**

```sql
-- Every hour
'USING CRON 0 * * * * UTC'

-- Every day at 2:30 AM
'USING CRON 30 2 * * * UTC'

-- Every 15 minutes
'USING CRON 0,15,30,45 * * * * UTC'

-- First day of every month at midnight
'USING CRON 0 0 1 * * UTC'

-- Weekdays at 9 AM
'USING CRON 0 9 * * 1-5 UTC'
```

### Serverless Task

Snowflake-managed compute (no warehouse needed):

```sql
CREATE TASK serverless_task
  USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = 'XSMALL'
  SCHEDULE = '60 MINUTE'
AS
  MERGE INTO customers_clean c
  USING customers_staging s
  ON c.customer_id = s.customer_id
  WHEN MATCHED THEN UPDATE SET
    c.email = s.email,
    c.updated_at = current_timestamp()
  WHEN NOT MATCHED THEN INSERT
    (customer_id, email, created_at)
    VALUES (s.customer_id, s.email, current_timestamp());
```

### Task Executing a Stored Procedure

```sql
CREATE TASK run_data_quality_checks
  WAREHOUSE = data_quality_wh
  SCHEDULE = '120 MINUTE'
AS
  CALL run_all_quality_checks('production', 'critical');
```

-----

## Task Scheduling

### Time-Based Scheduling

```sql
-- Run every 5 minutes
CREATE TASK frequent_sync
  WAREHOUSE = sync_wh
  SCHEDULE = '5 MINUTE'
AS
  CALL sync_external_data();

-- Run every 12 hours
CREATE TASK twice_daily
  WAREHOUSE = batch_wh
  SCHEDULE = '720 MINUTE'
AS
  INSERT INTO archive_table SELECT * FROM active_table WHERE age > 90;
```

### Starting and Stopping Tasks

```sql
-- Start a task (must be done for root tasks)
ALTER TASK my_task RESUME;

-- Stop a task
ALTER TASK my_task SUSPEND;

-- Check task status
SHOW TASKS LIKE 'my_task';

-- Resume all tasks in a tree (start from root)
EXECUTE TASK my_root_task;
```

-----

## Task Dependencies (Task Trees)

Create dependent tasks that execute in sequence or in parallel.

### Simple Task Chain

```sql
-- Root task (scheduled)
CREATE TASK extract_data
  WAREHOUSE = etl_wh
  SCHEDULE = '60 MINUTE'
AS
  CREATE OR REPLACE TABLE staging_raw AS
  SELECT * FROM external_source;

-- Child task (runs after extract_data completes successfully)
CREATE TASK transform_data
  WAREHOUSE = etl_wh
  AFTER extract_data
AS
  CREATE OR REPLACE TABLE staging_transformed AS
  SELECT 
    id,
    upper(name) as name,
    cast(amount as decimal(10,2)) as amount
  FROM staging_raw;

-- Grandchild task
CREATE TASK load_data
  WAREHOUSE = etl_wh
  AFTER transform_data
AS
  INSERT INTO production_table
  SELECT * FROM staging_transformed;
```

### Starting a Task Tree

```sql
-- Resume tasks in order (child tasks first, then parent)
ALTER TASK load_data RESUME;
ALTER TASK transform_data RESUME;
ALTER TASK extract_data RESUME;  -- Start root task last
```

### Parallel Task Execution

```sql
-- Root task
CREATE TASK root_task
  WAREHOUSE = etl_wh
  SCHEDULE = '120 MINUTE'
AS
  CREATE OR REPLACE TABLE source_data AS
  SELECT * FROM main_source WHERE updated_at > :last_run;

-- Multiple child tasks that run in parallel
CREATE TASK process_customers
  WAREHOUSE = etl_wh
  AFTER root_task
AS
  CALL process_customer_data();

CREATE TASK process_orders
  WAREHOUSE = etl_wh
  AFTER root_task
AS
  CALL process_order_data();

CREATE TASK process_products
  WAREHOUSE = etl_wh
  AFTER root_task
AS
  CALL process_product_data();

-- Final task that runs after all parallel tasks complete
CREATE TASK finalize
  WAREHOUSE = etl_wh
  AFTER process_customers, process_orders, process_products
AS
  CALL generate_summary_report();
```

-----

## Conditional Task Execution

### Using WHEN Clause

```sql
CREATE TASK conditional_task
  WAREHOUSE = compute_wh
  SCHEDULE = '30 MINUTE'
  WHEN
    SYSTEM$STREAM_HAS_DATA('my_stream')
AS
  INSERT INTO target_table
  SELECT * FROM my_stream;
```

### Trigger Stored Procedure When Data Becomes Available in a View

This is a common pattern for event-driven processing:

```sql
-- Step 1: Create a view that identifies when new data is available
CREATE OR REPLACE VIEW new_data_available AS
SELECT 
  count(*) as pending_count,
  max(created_at) as latest_record
FROM staging_table
WHERE processed = FALSE;

-- Step 2: Create the stored procedure to process the data
CREATE OR REPLACE PROCEDURE process_pending_data()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Process the pending records
  INSERT INTO processed_table
  SELECT * FROM staging_table WHERE processed = FALSE;
  
  -- Mark records as processed
  UPDATE staging_table 
  SET processed = TRUE 
  WHERE processed = FALSE;
  
  RETURN 'Processing completed';
END;
$$;

-- Step 3: Create task that checks the view and triggers the procedure
CREATE OR REPLACE TASK check_and_process_data
  WAREHOUSE = processing_wh
  SCHEDULE = '10 MINUTE'
  WHEN
    -- Only run if there are pending records
    (SELECT pending_count FROM new_data_available) > 0
AS
  CALL process_pending_data();

-- Start the task
ALTER TASK check_and_process_data RESUME;
```

### Advanced Conditional Logic with Multiple Conditions

```sql
CREATE TASK smart_processing
  WAREHOUSE = compute_wh
  SCHEDULE = '15 MINUTE'
  WHEN
    -- Multiple conditions
    (SELECT count(*) FROM staging_table WHERE processed = FALSE) > 100
    AND
    (SELECT current_time()::TIME BETWEEN '06:00'::TIME AND '22:00'::TIME)
AS
  CALL batch_process_records(100);
```

### Stream-Based Conditional Execution

```sql
-- Create a stream to track changes
CREATE STREAM customer_changes ON TABLE customers;

-- Task only runs when stream has data
CREATE TASK sync_customer_changes
  WAREHOUSE = sync_wh
  SCHEDULE = '5 MINUTE'
  WHEN
    SYSTEM$STREAM_HAS_DATA('customer_changes')
AS
  MERGE INTO customers_warehouse w
  USING customer_changes c
  ON w.customer_id = c.customer_id
  WHEN MATCHED AND c.METADATA$ACTION = 'DELETE' THEN DELETE
  WHEN MATCHED AND c.METADATA$ACTION = 'INSERT' THEN UPDATE SET
    w.name = c.name,
    w.email = c.email,
    w.updated_at = current_timestamp()
  WHEN NOT MATCHED THEN INSERT
    (customer_id, name, email, created_at)
    VALUES (c.customer_id, c.name, c.email, current_timestamp());

ALTER TASK sync_customer_changes RESUME;
```

-----

## Monitoring and Managing Tasks

### View Task History

```sql
-- Show all tasks
SHOW TASKS;

-- Show tasks in specific schema
SHOW TASKS IN SCHEMA my_schema;

-- View task execution history
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
  TASK_NAME => 'my_task',
  SCHEDULED_TIME_RANGE_START => DATEADD(day, -7, CURRENT_TIMESTAMP())
))
ORDER BY scheduled_time DESC;
```

### Task Execution Details

```sql
-- Get detailed task run information
SELECT
  name,
  database_name,
  schema_name,
  state,
  scheduled_time,
  completed_time,
  return_value,
  error_code,
  error_message
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE name = 'my_task'
  AND scheduled_time >= DATEADD(day, -1, CURRENT_TIMESTAMP())
ORDER BY scheduled_time DESC;
```

### Monitor Task Dependencies

```sql
-- View task graph/dependencies
SHOW TASKS;

-- Query task dependency information
SELECT
  name,
  predecessors,
  state,
  schedule,
  warehouse
FROM TABLE(INFORMATION_SCHEMA.TASKS)
WHERE database_name = CURRENT_DATABASE()
  AND schema_name = CURRENT_SCHEMA()
ORDER BY name;
```

### Manually Execute a Task

```sql
-- Execute a task immediately (doesn't affect schedule)
EXECUTE TASK my_task;
```

### Modify Existing Tasks

```sql
-- Change schedule
ALTER TASK my_task SET SCHEDULE = '30 MINUTE';

-- Change warehouse
ALTER TASK my_task SET WAREHOUSE = larger_wh;

-- Add or modify WHEN condition
ALTER TASK my_task MODIFY WHEN SYSTEM$STREAM_HAS_DATA('my_stream');

-- Update the SQL/procedure being executed
CREATE OR REPLACE TASK my_task
  WAREHOUSE = compute_wh
  SCHEDULE = '60 MINUTE'
AS
  -- New SQL statement
  INSERT INTO new_target SELECT * FROM new_source;
```

-----

## Best Practices

### 1. Use Appropriate Warehouse Sizes

```sql
-- Small tasks: use XSMALL or SMALL
CREATE TASK quick_task
  WAREHOUSE = xsmall_wh
  SCHEDULE = '5 MINUTE'
AS
  UPDATE metadata_table SET last_run = current_timestamp();

-- Large batch jobs: use MEDIUM or LARGE
CREATE TASK heavy_processing
  WAREHOUSE = large_wh
  SCHEDULE = '1440 MINUTE'
AS
  CALL process_millions_of_records();
```

### 2. Implement Error Handling in Stored Procedures

```sql
CREATE OR REPLACE PROCEDURE safe_data_load()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Start transaction
  BEGIN TRANSACTION;
  
  -- Your data operations
  INSERT INTO target_table SELECT * FROM source_table;
  
  -- Validate results
  LET row_count NUMBER := (SELECT count(*) FROM target_table);
  
  IF (row_count = 0) THEN
    ROLLBACK;
    RETURN 'ERROR: No rows loaded';
  END IF;
  
  COMMIT;
  RETURN 'SUCCESS: Loaded ' || row_count || ' rows';
  
EXCEPTION
  WHEN OTHER THEN
    ROLLBACK;
    RETURN 'ERROR: ' || SQLERRM;
END;
$$;
```

### 3. Use Task Comments for Documentation

```sql
CREATE TASK documented_task
  WAREHOUSE = etl_wh
  SCHEDULE = '120 MINUTE'
  COMMENT = '{
    "purpose": "Daily customer aggregation",
    "owner": "data-team@company.com",
    "sla": "Must complete within 30 minutes",
    "dependencies": ["customer_stream", "orders_table"]
  }'
AS
  CALL aggregate_customer_metrics();
```

### 4. Monitor Task Performance

```sql
-- Create a monitoring view
CREATE OR REPLACE VIEW task_performance AS
SELECT
  name,
  state,
  scheduled_time,
  completed_time,
  DATEDIFF(second, scheduled_time, completed_time) as duration_seconds,
  return_value,
  error_code,
  error_message
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
  SCHEDULED_TIME_RANGE_START => DATEADD(day, -7, CURRENT_TIMESTAMP())
))
WHERE state = 'FAILED' OR duration_seconds > 300;
```

### 5. Use Streams with Tasks for CDC

```sql
-- Create stream
CREATE STREAM order_stream ON TABLE orders;

-- Create task that processes stream
CREATE TASK process_orders
  WAREHOUSE = stream_wh
  SCHEDULE = '5 MINUTE'
  WHEN SYSTEM$STREAM_HAS_DATA('order_stream')
AS
  INSERT INTO order_analytics
  SELECT 
    order_id,
    customer_id,
    order_date,
    amount,
    METADATA$ACTION as change_type,
    current_timestamp() as processed_at
  FROM order_stream;
```

### 6. Implement Alerting

```sql
-- Create task to monitor for failures
CREATE TASK task_failure_monitor
  WAREHOUSE = monitoring_wh
  SCHEDULE = '15 MINUTE'
AS
BEGIN
  LET failure_count NUMBER := (
    SELECT count(*)
    FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
      SCHEDULED_TIME_RANGE_START => DATEADD(minute, -15, CURRENT_TIMESTAMP())
    ))
    WHERE state = 'FAILED'
  );
  
  IF (failure_count > 0) THEN
    CALL send_alert('Task Failures Detected', :failure_count);
  END IF;
END;
```

-----

## Common Use Cases

### 1. Incremental Data Loading

```sql
CREATE TASK incremental_load
  WAREHOUSE = load_wh
  SCHEDULE = '30 MINUTE'
AS
  INSERT INTO target_table
  SELECT *
  FROM source_table
  WHERE updated_at > (
    SELECT COALESCE(MAX(updated_at), '1970-01-01'::TIMESTAMP)
    FROM target_table
  );
```

### 2. Data Retention/Archiving

```sql
CREATE TASK archive_old_data
  WAREHOUSE = maintenance_wh
  SCHEDULE = 'USING CRON 0 2 * * * UTC'  -- 2 AM daily
AS
BEGIN
  -- Archive data older than 90 days
  INSERT INTO archive_table
  SELECT * FROM active_table
  WHERE created_at < DATEADD(day, -90, CURRENT_DATE());
  
  -- Delete archived data from active table
  DELETE FROM active_table
  WHERE created_at < DATEADD(day, -90, CURRENT_DATE());
END;
```

### 3. Data Quality Checks

```sql
CREATE TASK data_quality_checks
  WAREHOUSE = quality_wh
  SCHEDULE = '60 MINUTE'
AS
  CALL run_data_quality_suite();

-- Supporting procedure
CREATE OR REPLACE PROCEDURE run_data_quality_suite()
RETURNS STRING
LANGUAGE SQL
AS
$$
BEGIN
  -- Check for nulls in critical columns
  INSERT INTO quality_issues
  SELECT 'null_customer_id', count(*)
  FROM orders WHERE customer_id IS NULL;
  
  -- Check for duplicates
  INSERT INTO quality_issues
  SELECT 'duplicate_orders', count(*)
  FROM (
    SELECT order_id, count(*) as cnt
    FROM orders
    GROUP BY order_id
    HAVING cnt > 1
  );
  
  RETURN 'Quality checks completed';
END;
$$;
```

### 4. Materialized View Refresh

```sql
-- Refresh materialized views on schedule
CREATE TASK refresh_mv_daily
  WAREHOUSE = refresh_wh
  SCHEDULE = 'USING CRON 0 3 * * * UTC'
AS
BEGIN
  -- Refresh multiple materialized views
  ALTER MATERIALIZED VIEW customer_summary REFRESH;
  ALTER MATERIALIZED VIEW product_metrics REFRESH;
  ALTER MATERIALIZED VIEW sales_aggregates REFRESH;
END;
```

### 5. Multi-Stage ETL Pipeline

```sql
-- Stage 1: Extract
CREATE TASK extract
  WAREHOUSE = etl_wh
  SCHEDULE = '60 MINUTE'
AS
  CREATE OR REPLACE TABLE staging.raw_data AS
  SELECT * FROM production.source_table
  WHERE updated_at > (SELECT MAX(extracted_at) FROM staging.raw_data);

-- Stage 2: Transform
CREATE TASK transform
  WAREHOUSE = etl_wh
  AFTER extract
  WHEN (SELECT count(*) FROM staging.raw_data) > 0
AS
  CREATE OR REPLACE TABLE staging.transformed_data AS
  SELECT 
    id,
    clean_text(name) as name,
    parse_json(metadata) as metadata_json,
    current_timestamp() as transformed_at
  FROM staging.raw_data;

-- Stage 3: Load
CREATE TASK load
  WAREHOUSE = etl_wh
  AFTER transform
AS
  MERGE INTO production.target_table t
  USING staging.transformed_data s
  ON t.id = s.id
  WHEN MATCHED THEN UPDATE SET
    t.name = s.name,
    t.metadata_json = s.metadata_json,
    t.updated_at = current_timestamp()
  WHEN NOT MATCHED THEN INSERT
    (id, name, metadata_json, created_at)
    VALUES (s.id, s.name, s.metadata_json, current_timestamp());

-- Stage 4: Cleanup
CREATE TASK cleanup
  WAREHOUSE = etl_wh
  AFTER load
AS
  TRUNCATE TABLE staging.raw_data;
```

-----

## Troubleshooting

### Common Issues and Solutions

#### 1. Task Not Running

```sql
-- Check if task is resumed
SHOW TASKS LIKE 'my_task';
-- Look at 'state' column - should be 'started'

-- Resume if suspended
ALTER TASK my_task RESUME;

-- Check privileges
SHOW GRANTS ON TASK my_task;
```

#### 2. Task Failing

```sql
-- View error details
SELECT
  scheduled_time,
  error_code,
  error_message,
  query_id
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE name = 'my_task'
  AND state = 'FAILED'
ORDER BY scheduled_time DESC
LIMIT 10;

-- Get full query text that failed
SELECT query_text
FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY())
WHERE query_id = '<query_id_from_above>';
```

#### 3. Task Running Too Long

```sql
-- Identify long-running tasks
SELECT
  name,
  scheduled_time,
  DATEDIFF(minute, scheduled_time, COALESCE(completed_time, CURRENT_TIMESTAMP())) as duration_minutes
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE scheduled_time >= DATEADD(day, -1, CURRENT_TIMESTAMP())
ORDER BY duration_minutes DESC;

-- Consider increasing warehouse size or optimizing query
ALTER TASK slow_task SET WAREHOUSE = larger_warehouse;
```

#### 4. Child Tasks Not Running

```sql
-- Ensure parent task completed successfully
SELECT name, state, return_value, error_message
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY())
WHERE name = 'parent_task'
ORDER BY scheduled_time DESC
LIMIT 5;

-- Verify child tasks are resumed
SHOW TASKS LIKE 'child_task';

-- Check task dependencies
SELECT name, predecessors, state
FROM TABLE(INFORMATION_SCHEMA.TASKS)
WHERE name IN ('parent_task', 'child_task');
```

#### 5. WHEN Condition Never True

```sql
-- Test your WHEN condition manually
SELECT 
  SYSTEM$STREAM_HAS_DATA('my_stream') as has_data,
  (SELECT count(*) FROM staging_table WHERE processed = FALSE) as pending_count;

-- Temporarily remove WHEN clause to debug
ALTER TASK my_task MODIFY WHEN TRUE;
```

### Debugging Queries

```sql
-- Show all task runs in the last 24 hours
SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
  SCHEDULED_TIME_RANGE_START => DATEADD(day, -1, CURRENT_TIMESTAMP())
))
ORDER BY scheduled_time DESC;

-- Task execution statistics
SELECT
  name,
  COUNT(*) as total_runs,
  SUM(CASE WHEN state = 'SUCCEEDED' THEN 1 ELSE 0 END) as successful,
  SUM(CASE WHEN state = 'FAILED' THEN 1 ELSE 0 END) as failed,
  AVG(DATEDIFF(second, scheduled_time, completed_time)) as avg_duration_seconds
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
  SCHEDULED_TIME_RANGE_START => DATEADD(day, -7, CURRENT_TIMESTAMP())
))
GROUP BY name
ORDER BY failed DESC, name;
```

-----

## Additional Resources

- [Snowflake Documentation: Tasks](https://docs.snowflake.com/en/user-guide/tasks-intro)
- [Task Best Practices](https://docs.snowflake.com/en/user-guide/tasks-best-practices)
- [Serverless Tasks](https://docs.snowflake.com/en/user-guide/tasks-serverless)
- [Task Graphs](https://docs.snowflake.com/en/user-guide/tasks-graphs)

-----

## Quick Reference

### Essential Commands

```sql
-- Create task
CREATE TASK task_name WAREHOUSE = wh SCHEDULE = '60 MINUTE' AS <sql>;

-- Start task
ALTER TASK task_name RESUME;

-- Stop task
ALTER TASK task_name SUSPEND;

-- Execute immediately
EXECUTE TASK task_name;

-- View history
SELECT * FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY()) WHERE name = 'task_name';

-- Show all tasks
SHOW TASKS;

-- Drop task
DROP TASK task_name;
```

### Required Privileges

```sql
GRANT CREATE TASK ON SCHEMA schema_name TO ROLE role_name;
GRANT EXECUTE TASK ON ACCOUNT TO ROLE role_name;
GRANT EXECUTE MANAGED TASK ON ACCOUNT TO ROLE role_name;
GRANT USAGE ON WAREHOUSE wh_name TO ROLE role_name;
```
