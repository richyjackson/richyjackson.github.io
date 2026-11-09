# Revision notes

**Time Travel**
- Standard edition: 0 to 1 day (default 1)
- Enterprise and above: 0 to 90 days (default 1)
- Temporary and transient tables: max 1 day, whatever the edition
- Permanent tables: up to 90 days (Enterprise+)
- Set via `DATA_RETENTION_TIME_IN_DAYS`, at account, database, schema, or table level

**Fail-safe**
- 7 days, permanent tables only, non-configurable
- Starts after Time Travel ends
- Transient and temporary tables: 0 days
- Only Snowflake support can recover from it, not users

**Caching**
- Result cache: 24 hours, and each reuse resets the clock, up to a max of 31 days
- Result cache needs identical query text and unchanged underlying data
- Warehouse (local disk) cache: lasts until the warehouse suspends
- Metadata cache: lives in the cloud services layer

**Warehouses**
- Minimum billing: 60 seconds each time a warehouse starts or resumes, then per-second after that
- Default `AUTO_SUSPEND`: 600 seconds (10 minutes) when created via SQL
- `AUTO_RESUME` is on by default
- Query queue timeout: `STATEMENT_QUEUED_TIMEOUT_IN_SECONDS` (default 0 = no timeout)
- Statement timeout: `STATEMENT_TIMEOUT_IN_SECONDS` (default 172800 = 2 days)

**Data loading and files**
- COPY INTO load metadata: 64 days (files already loaded won't reload within this window unless forced)
- Snowpipe load history: 14 days
- Internal stage files and URLs:
  - Scoped URL: expires after 24 hours (or when the query result cache period ends)
  - File URL: doesn't expire
  - Pre-signed URL: configurable expiry
- Query history in UI: 14 days
- `ACCOUNT_USAGE` views: up to 365 days of history, with latency of 45 minutes to 3 hours
- `INFORMATION_SCHEMA` views: 7 days to 6 months depending on the view

**Security and access**
- Default session idle timeout: 4 hours (Snowflake web UI)

**Data sharing and cloning**
- Zero-copy clone: shares Time Travel limits of the source object at the time of cloning
- Dropped objects: recoverable with `UNDROP` within the Time Travel period

**Materialized views / streams**
- Stream staleness: stream offset becomes stale if not consumed within the table's data retention period (extended up to 14 days when the retention is shorter)
- Tasks: max 1 week (7 days) for a single task run limit is not a standard figure, so rely on `USER_TASK_TIMEOUT_MS` for task runs (default 1 hour)

**Exam tips**
- The most commonly tested numbers: **Time Travel 1/90, Fail-safe 7, result cache 24h/31 days, 60-second minimum billing, COPY history 64 days, Snowpipe 14 days**
- Remember the pattern: transient/temporary = 0 Fail-safe and max 1 day Time Travel

**The three caches**

| Cache | Where | Lifespan | Needs a running warehouse? |
|---|---|---|---|
| Result cache | Cloud services layer | 24 hours, renewed on each reuse (max 31 days) | No |
| Warehouse (local disk) cache | SSD/memory in the virtual warehouse | Until the warehouse suspends | Yes |
| Metadata cache | Cloud services layer | Maintained continuously | No |

**Result cache conditions (heavily tested)**
- Query text must match exactly
- Underlying data must be unchanged
- No non-deterministic functions (`CURRENT_TIMESTAMP`, `RANDOM`, `UUID_STRING`)
- The role must have privileges on the objects
- Results are shared across users, not just the original runner
- Disable with `USE_CACHED_RESULT = FALSE`
- `RESULT_SCAN(query_id)` re-queries a previous result

**Warehouse cache**
- Stores raw micro-partition data, not results
- Larger warehouses have more cache
- Trade-off: a short `AUTO_SUSPEND` saves credits but throws away the cache

**Metadata cache**
- Holds row counts, min/max values, and distinct counts per micro-partition
- `COUNT(*)`, `MIN`, `MAX`, and `SHOW`/`DESCRIBE` can often be answered without a warehouse

**Query planning and optimization**
- Compilation (parse, optimize, plan) happens in the cloud services layer
- `EXPLAIN` shows the plan without executing it, so it uses no warehouse compute
- **Pruning**: Snowflake skips micro-partitions using min/max metadata. Compare "partitions scanned" with "partitions total" in the Query Profile
- **Clustering keys** improve pruning on large tables. Check with `SYSTEM$CLUSTERING_INFORMATION`
- **Search optimization service**: speeds up point lookups and selective filters
- **Query acceleration service**: offloads parts of large scans to serverless compute
- **Materialized views**: precomputed results that Snowflake keeps up to date (Enterprise+)

**Query Profile red flags**
- Spilling to local or remote storage means the warehouse is too small or the query is too heavy
- High "bytes scanned" with low cache percentage points to poor pruning or a cold cache
- Exploding joins (output rows far above input rows) are usually a missing or bad join condition
- Queuing means concurrency is too high; consider a multi-cluster warehouse

**Scaling rules of thumb**
- Scale **up** (bigger warehouse) for complex or slow single queries
- Scale **out** (multi-cluster) for concurrency
- Multi-cluster warehouses need Enterprise+








