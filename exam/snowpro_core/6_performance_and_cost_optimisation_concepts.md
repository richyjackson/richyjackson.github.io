# 6 Performance and Cost Optimisation Concepts

## Table of Contents
- [Virtual Warehouse](#virtual-warehouse)
- [Additional Compute Services and Warehouse Types](#additional-compute-services-and-warehouse-types)
- [Cost optimisation strategies](#cost-optimisation-strategies)
- [Warehouse configuration](#warehouse-configuration)
- [Query Acceleration Service (QAS)](#query-acceleration-service-qas)
- [Caching](#caching)
- [Management and monitoring](#management-and-monitoring)
- [Resource monitors](#resource-monitors)
- [Query performance troubleshooting](#query-performance-troubleshooting)
- [Search optimisation service](#search-optimisation-service)

## Virtual Warehouse
- Is a bundle of compute resource of CPU and RAM
- Sized from extra-small to large etc..
- Large warehouses come with increased performance and cost
- Storage is kept separate to compute as part of Snowflake architecture


> Snowpipe, automatic clustering and some Cortex AI functions use the Snowflake managed service instead and do not require a warehouse

- Compute services are charged via the consumption based model (pay as you go) with 3 pricing models
    - **On-Demand** full flexibility, higher cost
    - **Pre-Purchased Capacity** with commitment to an agreed volume at reduce cost
    - **Annual Upfront** annual commitments with significant savings
- The rate you pay depends on your chosen pricing model, snowflake edition, cloud provider and geographical region
- Each increase in size doubles the credit cost
- The minimum charge is 60 seconds, then per second
- Suspended warehouses do not accrue a credit cost
- For multi-cluster billing you are charged for each active cluster

## Additional Compute Services and Warehouse Types
- **Snowpark Container Services** For running containerised applications with separate pricing
- **Cortex AI Functions** Machine learning and AI workloads with usage-based billing
- **Search Optimisation Service** Background compute for maintaining search indexes
- **Automatic Clustering** Managed service for maintaining optimal data clustering
- **Generation 2 Standard Warehouses (Gen2)** Improved analytics and data engineering workload performance
    - Enhanced delete, update, and merge operations
    - Optimised table scan operations
    - Improved query compilation and execution
    - Better resource utilisation and concurrency handling
- **Snowpark-Optimized Warehouses** provides additional memory and optimised resource allocation for Python, Scala and Java compute-intensive workloads in Snowpark such as:
    - Machine learning model training and Data science workloads
    - Complex data transformations and processing
    - Containerised applications running via Snowpark Container Services

```sql
-- Change from Generation 1 to Generation 2

ALTER WAREHOUSE my_warehouse SET RESOURCE_CONSTRAINT = 'GENERATION_2';

-- Change from Generation 2 back to Generation 1

ALTER WAREHOUSE my_warehouse SET RESOURCE_CONSTRAINT = 'GENERATION_1';

-- Switch to Snowpark-optimized warehouse

ALTER WAREHOUSE my_warehouse SET 
    WAREHOUSE_TYPE = 'SNOWPARK-OPTIMIZED'
    RESOURCE_CONSTRAINT = 'GENERATION_2';

-- Switch back to standard warehouse

ALTER WAREHOUSE my_warehouse SET
    WAREHOUSE_TYPE = 'STANDARD'
    RESOURCE_CONSTRAINT = 'GENERATION_2';
```
- Changes can occur at any time regardless of whether the warehouse is suspended
- Currently executing queries follow the existing warehouse


## Cost optimisation strategies
- Start with X-Small scaling up based on performance testing
- Configure auto-suspend to avoid paying for idle resources
- Use multi-cluster warehouses only where required
- Repeating queries can use caching to avoid compute
- Scale up where there are long running queues or blocked resources


## Warehouse configuration
- **Scale up** - Increase the size of your warehouse
- **Scaling out** - Set the minimum and maximum clusters between 1 and 10
- **Auto resume** - A suspended warehouse automatically restarts when a workload requires it
- **Auto suspend** - Suspend the warehouse after inactivity to a minimum of 1 minute
- **Scaling policy** - Change the behaviour of clusters
    - `STANDARD` - The default favouring performance over cost
    - `ECONOMY` - Waits a little longer favouring cost over performance
    - To keep clusters always on you configure the min and max clusters to be the same


```sql
CREATE OR REPLACE WAREHOUSE my_wh WITH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 600
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 2
    SCALING_POLICY = 'STANDARD';
```
## Query Acceleration Service (QAS)
Moves compute to the service to optimise queries, good for:
- Ad-hoc analysis or unpredictable workloads
- Workloads with variable data volumes per query
- Large table scans with filters
- Mixed workloads containing both quick queries and resource intensive operations


```sql
ALTER WAREHOUSE my_wh
    ENABLE_QUERY_ACCLERATION_SERVICE = TRUE
    QUERY_ACCLERATION_MAX_SCALE_FACTOR = 27;
```
- A factor of 27 increases performance 4 times of the warehouse
- It accelerates tables scans, filter operations and join-filter combinations for the following workloads:
    - `SELECT`
    - `INSERT`
    - `CREATE TABLE AS SELECT` (CTAS)
    - `COPY INTO`
- Queries which cannot be optimised are due to:
    - Insufficient partitions to scan
    - Non-selective filters
    - `LIMIT` clauses without `ORDER BY`
    - Functions with non-deterministic results
- Use the `QUERY_ACCELERATION_ELIGIBLE` view or the `SYSTEM$ESTIMATE_QUERY_ACCELERATION` function to identify eligibility
- Overall credit consumption will be increased, however there may be overall savings from warehouse consumption


## Caching
- Queries are pushed into the cache after running
- These are returned if queried again without the need to access the disk
- They are stored at environment level rather than belonging to a particular warehouse
- **Metadata cache** stores metadata about your objects, micro-partitions, usage and query history
- **Result cache** stores the result of each query run in a 24 period except:
    - When data has changed in the micro-partition
    - When using functions that recalculate at runtime (eg ``CURRENT_TIMESTAMP``)
    - When users do not have the correct privileges to underlying objects
- It does not need as running warehouse to return results
- **Local disk cache** stores data on the virtual warehouses SSD from storage to avoid having to retrieve this again
- This cache is flushed when the warehouse is suspended

## Management and monitoring
- Via ADMIN > COST MANAGEMENT in Snowsight using the ACCOUNTADMIN role
- Virtual warehouses can be started, stopped or re-sized here

## Resource monitors
- Limits cost consumption
- Configurable using the ACCOUNTADMIN role
- **Frequency** usually configured monthly inline with Snowflakes builling cycle however can go to daily
- **Trigger** when the threshold is met the following actions can be considered:
    - `NOTIFY` You are notified only (provided notifications are configured in the webUI)
    - `SUSPEND` New queries suspended, active remain which may result in the threshold being breached
    - `IMMEDIATE` All queries are terminated
 
## Query performance troubleshooting
**Query profile**
Provides a graphical representation of the execution plan and the steps taken to resolve
- The width of lines between nodes indicate volume of data, it also has a record counter
- Within each node the ORANGE bar indicates initialisation time
- The BLUE bar indicates processing time
- The box in the top right shows the most expensive nodes with links to show detail


**Query history**
Is found within the INFORMATION_SCHEMA views to show queries executed within 7 days
- ``QUERY_HISTORY`` queries executed within a specific timeframe
- ``QUERY_HISTORY_BY_SESSION`` queries executed within a specific timeframe within a given session
- ``QUERY_HISTORY_BY_USER`` executed within a specific timeframe within a given user
- ``QUERY_HISTORY_BY_WAREHOUSE`` executed within a specific timeframe within a given warehouse 


The following useful rows are returned:
- ``QUERY_ID`` the unique id for the query
- ``QUEUED_PROVISIONING_TIME`` time spent in the warehouse queue. Optimise wait times by increasing warehouse size
- ``COMPILATION_TYPE`` how long it takes to compile the query. Optimise run time by simplifying the query


**Data Spilling**
If your warehouse does not have enough memory (is not large enough) to service your workload, processing is spilled to disk
- ``Bytes spilled to local storage`` processing is spilled to the SDD cache
- ``Bytes spilled to remote storage`` processing is spilled to a remote drive (must always be avoided due to performance)


**Micro-partition pruning**
- Data is organised into micro-partitions via clustering keys which are preselected by Snowflake
- Metadata tells Snowflake what data resides in each micro-partition
- Via **Query pruning** micro-partitions are ignored in queries to increase performance
- The **Query profile** displays the number of partitions scanned versus the total
    - Aim for highly selective queries to improve performance
    - If a query is highly selective but there is a high percentage of partitions scanned the partitions may be poorly clustered


**Clustering information for micro-partitions**
- Clustering info is stored in the partitions metadata which includes:
    - Total partitions in table
    - Total partitions that overlap
    - Depth of overlapping partitions (average of partitions which overlap across their values)
- The lower the depth the better


**Search optimisation service**
- Stores the location of commonly searched values via a **search access path** to increase performance and query pruning
- Available in Enterprise edition or above
- Works well with the QAS where rows are filtered before QAS conducts the processing
- Carries ongoing cost to maintain the search access path
- Effective for:
    - Stable datasets
    - Selective point lookup queries
    - Substring and regular expression searches (eg ``ILIKE``, ``RLIKE``)
    - Semi-structured data queries
    - Text and IPv4 address searches (eg ``SEARCH``, ``SEARCH_IP``)
    - Geospatial queries
- It is configured on individual tables
- The search access path takers time to build in the background, progress is seen via ``SHOW TABLES`` and ``SEARCH_OPTIMISATION_PROGRESS``

```sql
alter table test_table add search optimization;
```
