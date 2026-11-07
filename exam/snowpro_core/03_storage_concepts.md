# 3 Storage Concepts
## Row-Orientated Databases
- Use OLTP which read and write complete records and handle dml operations efficiently
- Less efficient for analytical workloads, querying just one column requires a read of the entire rows data
## Column-Orientated Databases
- Data partitioned vertically by column for significant improvement in analytical workloads x10 -> x100
- Significantly less data is read in analysis as only the dcolumns required are referenced
- Snowflake uses this approach compressing data efficiently
## Micro-partitions
Snowflake organises data in Micro-partitons
- Data organised in small blocks of 50 -> 500MB
- Data is compressed in columnar format for maximum storage efficiency and query performance
- Each partiton contains metadata such as min / max, distinct values for query pruining
- Data organised based on its natural order of data insertion
- All partitons are encrypted automatically at rest and in transit

Snowflake elimiates unnecessary data during queries
- **Stage 1 - Partiton-level Pruning** - Partitons which do not match WHERE criteria automatically get eliminated
- **Stage 2 - Column-level Pruning** - Only the required columns are read

** Scale and flexibility**
- **Parallel Processing** - Multiple partitions can be processed simultaneously across different nodes for parallelization
- **Incremental Updates** - For data changes, Snowflake only rewrites the affected micro-partition rather than entire table segments
- **Scaling** - The consistent size of partions ensures predicatbale performance characteristics
- **Automatic Optimisation** - Partitions are automatically ordered through background maintenance processes
## Data Clustering
- Clustering determins how data is organised within your micro-partitions
- A clustering key consisting of one or more columns guide Snowflake for locating related data within the same micro-partition
- By default data is clustered in order of arrival
- Data can be manually clustered using ```CREATE OR ALTER TABLE Sales CLUSTER BY (Order_Id);```
- Manual clustering should only be considered for very large tables which show poor performance, query patterns which consistently filter by set columns, join operatons using a set key or range queries across predicatable column ranges
- To automatically ask Snowflake to recluster your data use ``ALTER TABLE Sales RESUME RECLUSTER``
- Introducing too many columns in a cluster key can reduce performance
## Storage Layer
- Your data in Snowflake resides on your chosen cloud providers storage infrastructue (Amazon S3, Azure Blob Storage, Google Cloud Storage)
- To work with data you consume Snowflake credits via Virtual Warehouses
- It is not possible to work externally with data held in Snowflake
- You pay for the compressed data you store, calculated as a monthly average
- The underlying cloud storage cost is passed on with minimal markup
- Time travel, fail safe & internally staged data are also included within the costs
- Costs vary by geographic region typically 23$ -> $40 per TB per month
- Snowflake compresses your data from 3:1 to 10:1 reducing costs
### Storage Lifecycle Policies
- Like your cloud service provider, Snowflake supports storage lifecycle polices of Hot, Warm & Cold
First you create the table
```sql
CREATE STORAGE LIFECYCLE POLICY my_storage_policy AS
  (event_ts TIMESTAMP, account_id NUMBER)
RETURNS BOOLEAN ->
  event_ts < DATEADD(DAY, -60, CURRENT_TIMESTAMP()) AND
  EXISTS ( SELECT 1 FROM closed_accounts WHERE id = account_id )
ARCHIVE_TIER = COOL
ARCHIVE_FOR_DAYS = 90;
```
Then reference the policy when you create your table
```sql
CREATE TABLE my_table ... WITH STORAGE LIFECYCLE POLICY my_storage_policy ON (col1);
ALTER TABLE my_table ADD STORAGE LIFECYCLE POLICY my_storage_policy ON (col1);
```
- For archiving data use Cool fast retrieval with a 90 day minimum, Cold for a minimum of 180 days with a 48 hour retrieval
- Both tiers charge the same one time cost, but Cold is cheaper than Cool
### Monitoring Storage Useage
- Database level storage ```SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE;```
- Table-level storage ```SELECT * FROM SNOWFLAKE.ACCOUNT_USAGE.TABLE_STORAGE_METRICS WHERE TABLE_NAME = '<table-name>';```
