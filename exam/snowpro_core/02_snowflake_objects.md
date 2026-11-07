# 2 Snowflake Objects
## Table Types
There are 9 table types in Snowflake

- **Permanent** - Provides configurable time travel and fail safe
- **Temporary** - Exists only in the current session with no recovery or alternative user access
- **Transient** - Like permanent tables with configurable time travel but without fail-safe
- **Iceberg** - For Apache Iceberg data stored in external cloud storage in a multi-cloud environment. Maintains acide transactions and schema evolution
- **External** - Provides a window to your data stored outside Snowflake. Suitable for ad-hoc analysis
- **Hybrid** - For analytical & transactional capabilities & complex analytics with support for primary / foreign keys & indexes
- **Dynamic Tables** - Represents a materialised pre-defined query set to a target refresh, eliminates complex pipelines
- **Directory Tables** - Catalog files in your stages when working with unstructured data
- **Event Tables** - For capturing & storing event data from Snowflakes event logging framework for insights into account activity, security events & system operations
- **Interactive Tables** - For simple fast queries requiring low latency that must process within 5 seconds. For use with an interactive warehouse
## Different ways to create tables
- ```CREATE TABLE``` - Creates a table from scratch
- ```CREATE OR ALTER TABLE``` - Creates table if it doesnt exist or modifies the structure without affecting contents
- ```CREATE TABLE AS SELECT``` (CTAS) - Creates a table based on a query
- ```CREATE TABLE USING TEMPLATE``` - Creates a table based on external staged files automatically inferring the schema
```sql 
CREATE TABLE Sales_Import
USING TEMPLATE (SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*))
FROM TABLE(INFER_SCHEMA(
LOCATION=>'@my_stage/sales_data/', FILE_FORMAT=>'my_csv_format')));
```
- ```CREATE TABLE LIKE``` - Copies an existing table without its data
```sql
CREATE TABLE Sales_Backup LIKE Sales;
```
- ```CREATE TABLE CLONE``` - Copies an existing table and its data. The clone has no storage cost until data is altered
```sql
CREATE TABLE Sales_Backup CLONE Sales;
```
## Types of Views
- **Non-materialised views** - Simplifies complex queries for users. Alows change to underlying table structures without breaking user queries. Allow embedded calculations and transformation
- **Secure views** - View definition hidden from users preventing underlying logic being uncovered. Query performance impacted
- **Materalized Views** - Data precalculated and stored improving performance. There are restrictions on joins, UDFs and window functions. For frequently accessed results that dont change often or signigicant aggregations
- **Semantic Views** - Allows you to securely describe your data in business terms, with business metrics, entities and their relationships. Previously only available via YAML files stored on external stages, they are no encorporated as a schema level object. They support auditing, time travel, replication, RBAC & dbt pipelines
## Stage types
- Used for loading and unloading your file data using internal stages (held withing Snowflake) or external stages (held in external storage locations such as Azure Blob Storage)
## User Defined Functions (UDFs)
Provide custom logic for reuse across applications and queries
- **Scalar** functions return one output value
- **Tabular** functions return a table


UDFs can be created using multiple languages:
- **SQL** for database operations, calculations,  data transformations and integration with your queries
- **Javascript** - for control flow including branching, looping and exception handling
- **Java** - providing access to the entire java ecosystem for complex operations and enterprise integration
- **Python** - for data science, mmachine learning and advanced analytics
- **Scala** - through Snowpark for functional programming capabilities and and integration with big data processing networks
## External Functions
- Allow your SQL queries tap into external cloud services, APIs and custom applications
Examples include:
- Integration with mapping services to convert addresses to coordinates
- Enhancing your data with additional information from external databases
- Pushing data to external systems
> Data is sent via HTTPS to your external service. Snowflake waits for the external services to process and return results so it can be incoporated within your data. This means a function can be added to your SQL code inline.
- External functions can impact performance; best to use when significant value is added
- The function must be able to handle potentially large data volumes
- Security happens over HTTPS and you control the authorisation and authentication
- You should plan for network issues, timeoluts or service failures
## Stored Procedures
Serve complex logic, encapsulating code in multi-step processes:
- They include Error handling, Dynamic SQL, Control Flow, Transaction Management & Variables
- Can orcestrate pipelines for data loading, transformation and validation. Automate administrative tasks and validations 


They support multiple languages including:
- **Snowflake Scription (SQL)** an extended library of SQL features
- **Javascript** for complex transformations and rich libraries
- **Python** (now available with Snowpark) for data science, advanced analytics and machine learning
- **Java** (via Snowpark) providing enterprise grade capabilities and integration with Java based systems and libraries
- **Scala** for functional programming and integration with big data processing frameworks


## Data Types


