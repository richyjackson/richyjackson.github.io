# 4 Performance and Cost Optimization Concepts
## Virtual Warehouse
- Is a bundle of compute resource of CPU and RAM
- Sized from extra-small to large etc..
- Large warehouses come with increased performance and cost
- Storage is kept separate to compute as part of Snowflake architecture


> Snowpipe, automatic clustering and some Cortex AI functions use the Snowflake managed service instead and do not require a warehouse

- Compute services are charged via the consumption based model (pay as you go) with 3 pricing models
    - *On-Demand* full flexibility, higher cost
    - *Pre-Purchased Capacity* with commitment to an agreed volume at reduce cost
    - *Annual Upfront* annual commitments with significant savings
- The rate you pay depends on your chosen pricing model, snowflake edition, cloud provider and geographical region
- Each increase in size doubles the credit cost
- The minimum charge is 60 seconds, then per second
- Suspended warehouses do not accrue a credit cost
- For multi-cluster billing you are charged for each active cluster
