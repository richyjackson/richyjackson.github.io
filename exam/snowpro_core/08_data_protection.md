# 8 Data Protection

## Table of Contents
- [How Snowflake keeps data safe](#how-snowflake-keeps-data-safe)
  - [Infrastructure Protection](#infrastructure-protection)
  - [High Availability](#high-availability)
  - [Data Encryption](#data-encryption)
  - [Data Protection](#data-protection)
- [Zero-Copy Cloning](#zero-copy-cloning)
- [Time Travel](#time-travel)
  - [Querying table data at a specific point in time](#querying-table-data-at-a-specific-point-in-time)
- [Fail Safe](#fail-safe)
- [Underlying Storage Concepts](#underlying-storage-concepts)

## How Snowflake keeps data safe
### Infrastructure Protection
- Snowflake seperates architecture through compute, storage and service layers
- It takes care of these node failures seemlessly without need for user intervention
### High Availability
- Snowflake provides **failover** replicating your data acorss three availability zones without additional cost
- You can instruct Snowflake to replicate changes automatically between databases withyout the need to develop or configure ETL jobs
- If Google had a major outage you could failover to another service
### Data Encryption
- Data at rest within Snowflake (including internal stages) is always encrypted by default
- Data in extrernal stages sits outside of Snowflake and must be encrypted at source "client-side encryption"
### Data Protection
- **Time Travel** allows you to recover data for up to 90 days from any point in time
## Zero-Copy Cloning
- Quickly create a copy of any database or its objects and data at zero cost across environments
- There is no physical movement of data, it is a metadata operation
- It helps facilitate the creation of dev or test enrinoments are part of the development lifecycle
- Internal Pipes & Views cannot be cloned
## Time Travel
- Allows you to query data at any point in time within the data retention window
- Cloning and time travel can be used in tandem which means for example you could compare a table at two different points in time
- Temporary & Transient tables provide 1 days time travel
- Permananet objects have 1 day time travel & 90 days on Enterprise Edition
- Changes to data retention is set via ACCOUNTADMIN using `DATA_RETENTION_TIME_IN_DAYS`
- Increasing the data retention period also increases storage costs
```sql
CREATE TABLE ORDERS (ORDER_ID INT, PRODUCT_ID INT, ORDER_QUANTITY INT)
DATA_RETENTION_TIME_IN_DAYS = 60;

ALTER TABLE ORDERS SET DATA_RETENTION_TIME_IN_DAYS=30;
```
### Querying table data at a specific point in time
```sql
SELECT * FROM ORDERS AT(TIMESTAMP => '2022-07-07 15:22:11.00 -0700'::timestamp_tz);

SELECT * FROM ORDERS AT(OFFSET => -60*30);

SELECT * FROM ORDERS BEFORE(STATEMENT => '019db306-3200-7542-0000-00005db6d821');
```
- Dropping a table does not drop the data retention period, the object will stay available and can be returned using the `UNDROP` comand
- This `HISTORY` command allows you to view dropped objects
```sql
SHOW TABLES HISTORY LIKE '%TABLE_NAME';

SHOW SCHEMAS HISTORY IN SALES_DB;

SHOW DATABASES HISTORY;

UNDROP DATABASE SALES_DB;
```
## Fail Safe
- When an object falls outside of the data retention period it lands in a fail safe position for 7 days where Snowflake employees can recover the data on a best endevaour basis
- This is not available for Transient or Temporary tables
## Underlying Storage Concepts
- Dropping and truncating tables results in entire copies of data being held in time-travel or fail safe
- In other cases Snowflake works out which data it needs to store & recover data
- Sotrage useage = Overall table size vs the number of records modified
- See storage used by fail safe by using ACCOUNTADMIN then navigating to Admin - Cost Management -> Consumption
