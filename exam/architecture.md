## Architecture
Storage, compute and services are independantly configurable resources allowing for scalability

- **Storage**
  - Data is stored in a scalable cloud storage service
  - It can be used to work on top of Amazon S3, Google Cloud or Azure
  - Data loaded to compressed columnar format into micro-partitions 250MB and encrypted
  - Supports Structured, Semi-Structured and Unstructured data
- **Compute**
  - For data loading, queries, pipelines & ML models using virtual warehouses
- **Cortex AI**
  - AI services using LLMs to query unstructure data, answer questions and provide intelligent assistance
  - allows uses to buold models using low code, sql and python interfaces
- **Cloud Services** (brain layer)
  - Coordinate & execute activities across platform using virtual warehouses such as authentication, infrastructure management, metadata management, query parsing and optimisation & access control
  - Access to Snowflake is via:
    - Snowsight
    - SnowSQL
    - Snowflake CLI
    - Language Drivers (ODBC, JDBC)
    - SQL API (REST)
- **Snowgrid**
  - Allows users to collaborate and use data regardless of what cloud & region each team member is using
