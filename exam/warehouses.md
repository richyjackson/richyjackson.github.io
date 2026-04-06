## Contents
- [Types](#types)
## Warehouses
> Warehouses are compute resources. They can be switched on or off, scaled up or out and clustered at any time <br><br>
> They are best organised according to workload

## Types

### 1. Standard Warehouse (default)
- For general purpose query execution, DML & Loading
- Billed per second, 60-second minimum on resume
- Supports auto-suspend and auto-resume
- Supports multi-cluster & auto-scale on Enterprise+
   - Scaling up (increasing size) solves slow queries
   - Scaling out (adding more clusters) solves queuing

### 2. Snowpark-Optimised Warehouse
- Designed specifically for Snowpark workloads (Python, Java, or Scala)
- Use for memory intensive workloads or when Snowpark jobs are splling to disk

|Property   |Detail                                            |
|-----------|--------------------------------------------------|
|Memory     |~16x more memory per node than standard           |
|Use case   |ML model training, large Snowpark DataFrames, UDFs|
|Size       |Recommended M or larger                           |
|Credit cost|Higher than standard at equivalent size           |

## Warehouse Size
- Credit useage doubles as you increase warehouse size
- The default size is XS when created using CREATE WAREHOUSE, XL when using Snowsight UI
- Warehouses charge per second with a minimum of 60 seconds
- Cost is multiplied per cluster

| Size | Credits per Hour | Credits per Second |
|---|---|---|
| XS | 1 | 0.000278 |
| S | 2 | 0.000556 |
| M | 4 | 0.001111 |
| L | 8 | 0.002222 |
| XL | 16 | 0.004444 |
| 2XL | 32 | 0.008889 |
| 3XL | 64 | 0.017778 |
| 4XL | 128 | 0.035556 |
| 5XL | 256 | 0.071111 |
| 6XL | 512 | 0.142222 |

> Data loading speed does not increase with size as files are loaded consecutively and are influenced by the number and size of files
