## Contents
- [Types](#types)
- [Warehouse size](#warehouse-size)
- [Multi-cluster warehouses](#multi-cluster-warehouses)
- [Warehouse modes](#warehouse-modes)
   - [Maximised](#1-maximised)
   - [Auto-scale](#2-auto-scale-recommended)
- [Auto-suspend](#auto-suspend)
- [Create](#create)
- [Recommended settings](#recommended-settings)

## Warehouses
Warehouses are compute resources. They can be switched on or off, scaled up or out and clustered at any time. They are best organised according to workload

## Types

### 1. Standard Warehouse (default)
- For general purpose query execution, DML & Loading
- Supports auto-suspend and auto-resume
- Supports multi-cluster & auto-scale on Enterprise+
   - Scaling up (increasing size) solves slow queries
   - Scaling out (adding more clusters) solves queuing
- Gen 2 warehouses are optimised for DML operations and loading
   - 2.1x faster for core analytics workloads and complex queries
   - Improved concurrency and cost efficiency<br>

### 2. Snowpark-Optimised Warehouse
- Designed specifically for Snowpark workloads (Python, Java, or Scala)
- Good for ML model training, large Snowpark DataFrames, UDFs
- Use for memory intensive workloads or when Snowpark jobs are splling to disk
- Has 16x more memory per node than standard
- Costs 1.5x times of Standard (Gen 1)

## Warehouse Size
Warehouse size is primarily intended for improving query performance
- Credit useage doubles as you increase warehouse size
- The default size is XS when created using CREATE WAREHOUSE, XL when using Snowsight UI
- Warehouses charge per second with a minimum of 60 seconds
- Cost is multiplied per cluster<br>

### Larger Warehouses
- ✅ Complex workloads
- ❌ Basic queries
- ❌ Data loading (Performance influenced by number & size of files. Split to 250MB to improve performance)

### Multi-Cluster Warehouses
Multi-cluster warehouses are Standard Warehouses with multiple instances. Each query is assigned compute resource. Once this has been exhausted items are then queued. By adding clusters you avoid queueing<br><br>
Each warehouse has a default of 10 clusters which can be overridden to the maxium allowable for the warehouse size<br>

| Size | Standard Credits / Hour | Standard Credits / Second | Standard (Gen1)| Standard (Gen2) | Snowpark-Optimised | Standard Max Clusters |
|---|---|---|---|---|---|---|
| XS  | 1   | 0.000278 |✅ Yes|❌ No |❌ No |300|
| S   | 2   | 0.000556 |✅ Yes|❌ No |❌ No |300|
| M   | 4   | 0.001111 |✅ Yes|✅ Yes|✅ Yes|300|
| L   | 8   | 0.002222 |✅ Yes|✅ Yes|✅ Yes|160|
| XL  | 16  | 0.004444 |✅ Yes|✅ Yes|✅ Yes|80 |
| 2XL | 32  | 0.008889 |✅ Yes|✅ Yes|✅ Yes|40 |
| 3XL | 64  | 0.017778 |✅ Yes|✅ Yes|✅ Yes|20 |
| 4XL | 128 | 0.035556 |✅ Yes|✅ Yes|✅ Yes|10 |
| 5XL | 256 | 0.071111 |✅ Yes|❌ No |✅ Yes|10 |
| 6XL | 512 | 0.142222 |✅ Yes|❌ No |✅ Yes|10 |

### Warehouse modes
There are two warehouse modes:
#### 1. Maximised
The warehouse is always on within the configured parameters (> 1)
#### 2. Auto-scale (recommended)
The warehouse increases and decreases automatically according to workload for which there are two **policies**
   - **Standard (default)** - Minimise queuing, favour performance over cost<br>
      - A new cluster starts as soon as a query is queued or Snowflake detects existing clusters can’t handle incoming queries
      - An idle cluster shuts down after a sustained period of low load
      - Reacts quickly — spins up clusters aggressively
   - **Economy**<br> - Favour cost over performance<br>
      - A new cluster only starts if Snowflake estimates there is at least 6 minutes of work to justify it
      - An idle cluster shuts down if Snowflake estimates it has less than 6 minutes of work remaining
      - More tolerant of short queuing — won’t spin up a cluster for a brief spike
> Warehouses with a policy assigned have no affect if they are on maximised mode
## Auto-suspend
Warehouses charge while active and not in use with a minimum billing policy of 60 seconds
- Initially set auto-suspend after inactivity to a minimum of 5–10 minutes. Setting it lower risks the warehouse repeatedly suspending and resuming, which can be more expensive given the minimum billing period
- Queries are cached all the time a warehouse is available. This is cleared when the warehouse suspends
- Disabling auto-suspend may be beneficial for continual heavy workloads or where responsiveness is required
## Auto-resume
- When set the warehouse automatically resumes as soon as the query comes in
## Create
```sql
CREATE WAREHOUSE IF NOT EXISTS my_warehouse
   WAREHOUSE_SIZE = Small
   AUTO_SUSPEND = 10
   AUTO_RESUME = TRUE;
```
## Recommended settings

|Use Case|Warehouse Type|Warehouse Size|Multi-Cluster|Scaling Policy|Auto-Suspend|Auto-Resume|Key Rationale|
|---|---|---|---|---|---|---|---|
|**Ad-hoc Queries**  |Standard|XS – M|Optional|Economy |1–5 mins|✅ Yes|Unpredictable, sporadic load. Economy policy avoids premature scale-out. Auto-suspend is critical for cost control|
|**Data Loading**    |Standard|XS – S|❌ No   |N/A     |Immediately after job|✅ Yes|Parallelism comes from number of files, not warehouse size. Optimise file sizing (100–250 MB compressed) instead|
|**BI & Reporting**  |Standard|M – L |✅ Yes  |Economy or Standard|5–10 mins|✅ Yes|Concurrent users drive load. Multi-cluster handles concurrency queuing. Larger size supports complex report queries|
|**Individual Teams**|Standard|XS – S|❌ No   |N/A     |1–5 mins |✅ Yes|Dedicated warehouse per team isolates resource contention and simplifies cost attribution. Small size sufficient for team-level workloads|
|**High Concurrency**|Standard|M     |✅ Yes  |Standard|5–10 mins|✅ Yes|Multi-cluster is the primary lever — scale out over scale up. Standard policy adds clusters quickly to avoid query queuing under sudden load spikes|
|**Complex Queries** |Standard|L – XL|❌ No   |N/A     |5–10 mins|✅ Yes|Large single queries benefit from more compute per node. Scale up (larger warehouse) rather than scale out. Consider query result caching and clustering keys to reduce repeated full scans|
<br>
-----
<br>
|Concept|Detail|
|---|---|
|**Standard vs Snowpark-Optimised**|Standard suits all three use cases. Snowpark-Optimised is for ML/Python workloads needing high memory|
|**Economy scaling policy**        |Waits longer before spinning up additional clusters — better for cost-sensitive workloads|
|**Standard scaling policy**       |Adds clusters faster — better when low latency matters more than cost|
|**Data loading**|Larger warehouse does **not** meaningfully improve load speed. File count and size (100–250 MB) is the primary tuning lever|
|**Multi-cluster**                 |Only available on Enterprise edition and above|
|**Auto-suspend default**          |Snowflake default is 10 minutes — always tune down to control credit consumption|
