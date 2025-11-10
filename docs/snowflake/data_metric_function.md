---
layout: default
title: Snowflake
---

[Home](./index.md)<br><br>
Data Metric Functions (DMFs) perform data quality checks against tables or views at regular intervals.
To automate data quality checks you must firstly:
- Choose between a pre-built system DMF or create a custom one
- Configure a schedule to applied to all DMFs associated with a table / view
- Assocate the DMF with the table or view
### System DMFs
Snowflake provide a large number of pre-built DMFs as follows:
- [BLANK_COUNT](https://docs.snowflake.com/en/sql-reference/functions/dmf_blank_count)
- [BLANK_PERCENT](https://docs.snowflake.com/en/sql-reference/functions/dmf_blank_percent)
- [NULL_COUNT](https://docs.snowflake.com/en/sql-reference/functions/dmf_null_count)
- [NULL_PERCENT](https://docs.snowflake.com/en/sql-reference/functions/dmf_null_percent) |
- [FRESHNESS](https://docs.snowflake.com/en/sql-reference/functions/dmf_freshness) (Freshness according to a timestamp column or the most recent DML operation)
- [DATA_METRIC_SCHEDULE_TIME](https://docs.snowflake.com/en/sql-reference/functions/dmf_data_metric_schedule_time)
- [AVG](https://docs.snowflake.com/en/sql-reference/functions/dmf_avg)
- [MAX](https://docs.snowflake.com/en/sql-reference/functions/dmf_max)
- [MIN](https://docs.snowflake.com/en/sql-reference/functions/dmf_min)
- [STDDEV](https://docs.snowflake.com/en/sql-reference/functions/dmf_stddev)
- [ACCEPTED_VALUES](https://docs.snowflake.com/en/sql-reference/functions/dmf_accepted_values) (ensure values match agreed list)
- [ROW_COUNT](https://docs.snowflake.com/en/sql-reference/functions/dmf_row_count)
- [UNIQUE_COUNT](https://docs.snowflake.com/en/sql-reference/functions/dmf_unique_count)
- [DUPLICATE_COUNT](https://docs.snowflake.com/en/sql-reference/functions/dmf_duplicate_count)
### Schedule the DMF to run
A schedule is set against a table which is to apply to all functions
For processing via the medallion architecture, TRIGGER ON CHANGES is preferred
#### Setting the schedule
```SQL
ALTER TABLE <table_or_view_name> SET
  -- Examples of cron expressions
  DATA_METRIC_SCHEDULE = '5 MINUTE';
  DATA_METRIC_SCHEDULE = 'USING CRON 0 8 * * * UTC';
  DATA_METRIC_SCHEDULE = 'USING CRON 0 8 * * MON,TUE,WED,THU,FRI UTC';
  DATA_METRIC_SCHEDULE = 'USING CRON 0 6,12,18 * * * UTC';
  DATA_METRIC_SCHEDULE = 'TRIGGER_ON_CHANGES';
```
[INFO] When changing a schedule there is a 10 minute delay
#### Viewing the schedule
The table keyword applies to both tables and views
```SQL
SHOW PARAMETERS LIKE 'DATA_METRIC_SCHEDULE' IN TABLE <table_or_view_name>;
```
### Associate the DMF with a table
```SQL
ALTER TABLE t
  ADD DATA METRIC FUNCTION SNOWFLAKE.CORE.NULL_COUNT
    ON (c1);
```
### Create a custom DMF
Email addresses that dont match the regular pattern:
```SQL
CREATE DATA METRIC FUNCTION IF NOT EXISTS
  invalid_email_count (ARG_T table(ARG_C1 STRING))
RETURNS NUMBER AS
  'SELECT COUNT_IF(FALSE = (
    ARG_C1 REGEXP ''^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$''))
    FROM ARG_T';
```
Fields have positive values:
```SQL
CREATE OR REPLACE DATA METRIC FUNCTION governance.dmfs.count_positive_numbers
  (arg_t TABLE(arg_c1 NUMBER, arg_c2 NUMBER, arg_c3 NUMBER))
RETURNS NUMBER
AS
$$
  SELECT COUNT(*)
  FROM arg_t
  WHERE arg_c1 > 0 AND arg_c2 > 0 AND arg_c3 > 0
$$;
```
Check that referential integrity exists between two tables:
```SQL
CREATE OR REPLACE DATA METRIC FUNCTION governance.dmfs.referential_check(
  arg_t1 TABLE (arg_c1 INT), arg_t2 TABLE (arg_c2 INT))
RETURNS NUMBER AS
 'SELECT COUNT(*) FROM arg_t1
  WHERE arg_c1 NOT IN (SELECT arg_c2 FROM arg_t2)';
ALTER TABLE salesorders
  ADD DATA METRIC FUNCTION governance.dmfs.referential_check
    ON (sp_id, TABLE (my_db.sch1.salespeople(sp_id)));
```
### Query DMF Results
#### Call a DMF directly
```SQL
SELECT SNOWFLAKE.CORE.NULL_COUNT(SELECT <field> FROM <table_or_view_name>);
SELECT SNOWFLAKE.CORE.MAX(SELECT <field> FROM <table_or_view_name>);
```
#### Return the bad rows
This only applies to the supported system DMFs:
- ACCEPTED_VALUES
- BLANK_COUNT
- BLANK_PERCENT
- DUPLICATE_COUNT
- NULL_COUNT
- NULL_PERCENT
```SQL
SHOW DATA METRIC FUNCTIONS IN ACCOUNT;
```
#### DATA_METRIC_SCAN
```SQL
SELECT *
  FROM TABLE(SYSTEM$DATA_METRIC_SCAN(
    REF_ENTITY_NAME  => 'dq_tutorial_db.sch.employeesTable',
    METRIC_NAME  => 'snowflake.core.blank_count',
    ARGUMENT_NAME => 'name'
   ));
```
```SQL
SELECT *
  FROM TABLE(SYSTEM$DATA_METRIC_SCAN(
    REF_ENTITY_NAME  => 'governance.sch.employeesTable',
    METRIC_NAME  => 'snowflake.core.accepted_values',
    ARGUMENT_NAME => 'age',
    ARGUMENT_EXPRESSION => 'age > 5'
  ));
```
#### DATA_METRIC_FUNCTION_REFERENCES
See available DMFs and their current status
```SQL
SELECT * FROM 
  TABLE(INFORMATION_SCHEMA.DATA_METRIC_FUNCTION_REFERENCES(
    METRIC_NAME => 'SNOWFLAKE.CORE.DUPLICATE_COUNT'));

SELECT * FROM TABLE(INFORMATION_SCHEMA.DATA_METRIC_FUNCTION_REFERENCES(
  REF_ENTITY_NAME => '<database>.<schema>.<table>',
  REF_ENTITY_DOMAIN => 'TABLE'));
```
#### DATA_QUALITY_MONITORING_RESULTS
See when checks have been run and the number of exceptions
```SQL
SELECT *
FROM SNOWFLAKE.LOCAL.DATA_QUALITY_MONITORING_RESULTS
WHERE TRUE
LIMIT 100;
```
#### View the DMF code
```SQL
SELECT * FROM DEV_DM.INFORMATION_SCHEMA.FUNCTIONS WHERE IS_DATA_METRIC = 'YES'
```
##### Drop A DMF
```SQL
ALTER TABLE customers DROP DATA METRIC FUNCTION
  invalid_email_count ON (email);
```
#### Permissions
- View / Select DMF = USAGE of DMF
- Create / Alter DMF = USAGE on DB, CREATE DATA METRIC FUNCTION on Schema, OWNERSHIP of DMF
- Associate DMF with Object = USAGE of DMF, OWNERSHIP of Object, Role for Object has EXECUTE DATA METRIC FUNCTION privaledge
- Query metric results = DATA_QUALITY_ADMIN_PRIVILEDGE

| Feature | Code |
| --- | --- |
| Create Role | CREATE ROLE IF NOT EXISTS dq_demo_role; |
| Associate Role to sysadmin & current user | GRANT ROLE dq_demo_role TO USER sysadmin; GRANT ROLE dq_demo_role TO USER identifier($me); |
| Grant Execute a DMF | GRANT EXECUTE DATA METRIC FUNCTION ON ACCOUNT TO ROLE dq_demo_role; |
| Associate Application Role with created Role | GRANT APPLICATION ROLE SNOWFLAKE.DATA_QUALITY_MONITORING_VIEWER TO ROLE dq_demo_role; |
| Grant Database Roles to created Role to view reports | GRANT DATABASE ROLE SNOWFLAKE.USAGE_VIEWER TO ROLE dq_demo_role; GRANT DATABASE ROLE SNOWFLAKE.DATA_METRIC_USER TO ROLE dq_demo_role; |
