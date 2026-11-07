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
