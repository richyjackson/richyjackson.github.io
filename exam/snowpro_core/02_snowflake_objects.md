# 2 Snowflake Objects
## Table Types
There are 9 table types in Snowflake

- **Permanent** - Provides configurable time travel and fail safe
- **Temporary** - Exists only in the current session with no recovery or alternative user access
- **Transient** - Like permanent tables with configurable time travel but without fail-safe
- **Iceberg** - For Apache Iceberg data stored in external cloud storage in a multi-cloud environment. Maintains acide transactions and schema evolution
- **External** - Provides a window to your data stored outside Snowflake. Suitable for ad-hoc analysis
- **Hybrid** - For analytical & transactional capabilities & complex analytics with support for primary / foreign keys & indexes
- **Dynamic Tables** - Represents a materialised pre-defined query set to a target refresh, eliminates complex pipelines
- **Directory Tables** - Catalog files in your stages when working with unstructured data
- **Event Tables** - For capturing & storing event data from Snowflakes event logging framework for insights into account activity, security events & system operations
- **Interactive Tables** - For simple fast queries requiring low latency that must process within 5 seconds. For use with an interactive warehouse
## Different ways to create tables
- ```CREATE TABLE``` - Creates a table from scratch
- ```CREATE OR ALTER TABLE``` - Creates table if it doesnt exist or modifies the structure without affecting contents
- ```CREATE TABLE AS SELECT``` (CTAS) - Creates a table based on a query
- ```CREATE TABLE USING TEMPLATE``` - Creates a table based on external staged files automatically inferring the schema
```sql 
CREATE TABLE Sales_Import
USING TEMPLATE (SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
FROM TABLE(INFER_SCHEMA(
LOCATION=>'@my_stage/sales_data/', FILE_FORMAT=>'my_csv_format')));
```
- ```CREATE TABLE LIKE``` - Copies an existing table without its data
```sql
CREATE TABLE Sales_Backup LIKE Sales;
```
- ```CREATE TABLE CLONE``` - Copies an existing table and its data. The clone has no storage cost until data is altered
```sql
CREATE TABLE Sales_Backup CLONE Sales;
```
## Types of Views


## Stage types


## User Defined Functions (UDFs)



## External Functions


## Stored Procedures



## Data Types


