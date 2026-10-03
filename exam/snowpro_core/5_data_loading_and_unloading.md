# 5 Data Loading and Unloading
## Stages
### External Stage
- Point to 3rd party storage locations
- Supports Amazon S3, Google Cloud, Microsoft Azure
- It does not matter which platform Snowflake is installed against
### External Tables
- Exist within an External Stage
- Provides read only access to files in tabular format
- Performance is impacted as files are not organised within Snowflakes efficient architecture (micro-partitions, query pruning)
- Metadata is kept up to date automatically using a notification service such as Amazons Simple Queue Service (SQS) or Azure Event Grid at cost
### Internal Stage
**User Stage**
- Used as a file loading area for the current user only
- Use the prefix `@~` to access
```sql
copy into mytable from @~/staged file_format = (format_name = 'my_csv_format');
```
**Table Stage**
- Each table is automatically given a table stage for file loading directly into a given table
- Multiple users can access the stage
- Use the prefix ``@%`` to access
```sql
LIST @%my_table
```


**Named Stage**
- An area where all data files exist efficient with multi user access
- Files target multiple tables
- Refer to the internal stage with the @ prefix
```sql
create or replace stage my_stage file_format = 
my_csv_format;
```
Removing internal stages will also remove the files. For external stages the files remain in place
## File Formats
- Used to tell Snowflake how to load or unload data across various file types
- Structured format is CSV supporting unloading
- Unstructured formats are: JSON, Parquet, AVRO, ORC, XML
- Only JSON / Parquet support unloading
```sql
CREATE [ OR REPLACE ] FILE FORMAT [ IF NOT EXISTS ] <name>
  TYPE = { CSV | JSON | AVRO | ORC | PARQUET | XML } [ formatTypeOptions ]
  [ COMMENT = '<string_literal>' ]
```
## Storage Integration
- Stores connection and credential information for external stages
- The storage integration object can then be referenced in the COPY INTO command


**Without integration**
```sql
COPY INTO mytable
  FROM s3://mybucket/data/files
  CREDENTIALS = (AWS_KEY_ID='$AWS_ACCESS_KEY_ID' AWS_SECRET_KEY='$AWS_SECRET_ACCESS_KEY')
  ENCRYPTION = (MASTER_KEY = 'eSx...')
  FILE_FORMAT = (FORMAT_NAME = my_csv_format);
```
**With integration**
```sql
CREATE STORAGE INTEGRATION s3_int
  TYPE = EXTERNAL_STAGE
  STORAGE_PROVIDER = 'S3'
  STORAGE_AWS_ROLE_ARN = 'arn:aws:iam::001234567890:role/myrole'
  ENABLED = TRUE
  STORAGE_ALLOWED_LOCATIONS = ('s3://mybucket1/path1/', 's3://mybucket2/path2/');

COPY INTO mytable FROM s3://mybucket/data/files
  STORAGE_INTEGRATION = myint
  ENCRYPTION=(MASTER_KEY = 'eSx...')
  FILE_FORMAT = (FORMAT_NAME = my_csv_format);
```
## Commands
- `PUT` Moves files to an INTERNAL stage
```sql
put file://c:\temp\data\mydata.csv @~ auto_compress=true;
```
- `COPY INTO` Loads data from any stage to a table
```sql
copy into mytable from s3://mybucket/data/files
  storage_integration = myint
  file_format = (format_name = my_csv_format);
```
- `INSERT` Moves data from one table to another
```sql
insert overwrite into sf_employees
  select * from employees where city = 'San Francisco';
```
- The `OVERWRITE` command will issue an additional truncate

- `GET` is Used to move files from an INTERNAL stage to your local machine
```sql
get @~/myfiles file:///tmp/data/;
```
## Snowpipe
- Snowpipe allows you to continuously move data from a stage to a table
- It is a fully managed service working serverless without need for a virtual warehouse
- You pay using snowflake credits under a warehouse called Snowpipe
- Or essentially runs the copy into commands continuously
```sql
create pipe mypipe as copy into mytable from @mystage; create pipe mypipe2 as copy into mytable(c1, c2) from (select $5, $4 from @mystage); create pipe mypipe_s3 auto_ingest = true aws_sns_topic = 'arn:aws:sns:us-west-2:001234567890:s3_mybucket' as copy into snowpipe_db.public.mytable from @snowpipe_db.public.mystage file_format = (type = 'JSON');
```
- Metadata / History is held for 64 days via `COPY INTO` commands, with Snowpipe it is 14
- Account Admin or MONITOR USEAGE users can access history via Snowsight or the `PIPE_USEAGE_HISTORY` table function


## Snowpipe Streaming
- For direct connections to streaming services such as Apache Kafka topics, application event streams, or IoT sensor data that arrives row by row
- Works serverless and is more cost effective than Snowpipe
- Use Snowpipe over Snowpipe Streaming when you have file based loads
## Dynamic Tables
- A table which automatically refreshes based on a query embedded within it
- Snowflake identifies which data has changed and automatically refreshes it on schedule
- Refresh is controlled via a lag
```sql
CREATE OR REPLACE DYNAMIC TABLE customer_metrics TARGET_LAG = '5 minutes' WAREHOUSE = compute_wh AS SELECT customer_id, COUNT(*) as transaction_count, SUM(amount) as total_spent, AVG(amount) as avg_transaction, MAX(transaction_timestamp) as last_transaction FROM transactions GROUP BY customer_id;
```
- Dynamic Tables avoid the need for complex pipelines
- They allow transformation across multiple tables
- Are powerful when used with Snowpipe Streaming
- They simplify architecture
## Data Loading Best Practice
- File sizes between 100 - 250 MB
- Break large files into smaller files for efficiency
- Smaller files can be aggregated for efficiency
- Folders are best organised in a path structure by theme
### Load Options
**Validation Mode**
- Provides error information before data load, useful for newly loaded data
```sql
copy into mytable validation_mode = 'RETURN_ERRORS';
```
**Error on Column Count Mismatch**
- Notify error if column counts mismatch
```sql
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE;
```
**ON_ERROR**
- `CONTINUE` - Ignores errors and skips over them
- `SKIP_FILE` - Ignores bad files only (Snowpipe default)
- `ABORT_STATEMENT` - Terminate the whole load process (COPY INTO default)
## Unloading Data
- Data is loaded from a table to a CSV, Parquet or Avro file using a COPY INTO command to an internal or external stage
- A SQL statement can be used to transform the data from multiple sources
- The default option is to create a single file, for multiple files use option SINGLE = FALSE
- Use MAX_FILE_SIZE to specify file sizes. The max file size Google Cloud, Amazon S3 & Azure support is 5GB
```sql
copy into @my_stage/result/data_
  from (
    select * from DIM_ACCOUNT_ITEMS dim
    inner join FCT_LMI_ACCOUNT_ITEMS fct on dim.acc_id = fct.acc_id
    limit 100);

-- View the newly created file

List @my_stage;
```
- In the file format you can control how to handles empty strings and nulls using `EMPTY_FIELD_AS_NULL`
- `FIELD_OPTIONALLY_ENCLOSED_BY` controls how strings are encapsulated (eg. double quotes)
## Streams and Tasks
### Streams
- Allow for Change Data Capture CDC identifying deltas during data load via a change table
- Hidden metadata columns are added to allow CDC
    - `METADATA$ACTION1 the DML performed as INSERT or DELETE. Updates are an insert and delete
    - `METADATA$ISUPDATE` lets you know if the record was part of an update operation
    - `METADATA$ROW_ID` provides a unique ID for the row to assist with auditability. It can be used through your solution to track flow of data
### Tasks
- Tasks execute a single line of SQL on schedule or on demand
- For multiple SQL statements multiple tasks must be used
- A virtual warehouse can be assigned or managed compute
- Tasks can be chained together executing one after the other
- Using option `SYSTEM$STREAM_HAS_DATA('<stream_name>')` executes the task based on whether data exists within the stream
```sql
CREATE TASK mytask_minute WAREHOUSE = mywh SCHEDULE = '5 MINUTE' AS INSERT INTO mytable(ts) VALUES(CURRENT_TIMESTAMP);

-- Task chaining
create task task5 after task2 as insert into t1(ts) values(current_timestamp);
```
## Openflow
- Uses Apache's NiFi service to extend the ETL offering to all data sources, batch and streaming services
- All configuration sits outside Snowflake
- Primarily focused around ingestion
## dbt Projects
- Extends the dbt Core offering which carried external overhead, configuration, pipeline debugging and CI/CD
- dbt Projects natively works with Workspaces provides CI/CD via GitHub Actions & Snowflake CLI
