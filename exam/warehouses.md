## Contents
- [Types](#types)

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
