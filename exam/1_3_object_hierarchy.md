## Object hierarchy

**Containers** (e.g. databases) logically group objects (e.g. tables, views). **Hierarchy** refers to how these containers and objects are structured. Permissions can be set at the database, schema or object level.

- **Organisation:** The highest level in Snowflake's hierarchy comprised of one or more Snowflake accounts
- **Account:** A single Snowflake deployment including all data, users, roles, and settings. Each account is deployed to a single cloud platform provider (AWS, Azure, GCP), to a single geographic region with a single Snowflake Edition
- **Database:** A logical object within an account to organize data. It can hold multiple schemas
- **Schema:** An object within a database that holds tables, views, stages, file formats, sequences, stored procedures, user-defined functions, and other objects. Schemas can be replicated to other accounts or databases
- **Table:** An object for storing structured and semi-structured data
- **View:** A view allows the result of a query to be accessed as if it were a table
- **Stage:** A storage location used for loading or unloading data files. Stages can be internal (within Snowflake) or external (such as on AWS S3, Azure Blob Storage, or Google Cloud Storage)

### Object Types

- **Tables**
  - Permanet - for long-term storage
  - Transient - for short-lived data
  - Temporary - for data tied to a single session
- **Views**
  - Non-materialized - don’t store data 
  - Materialized - store the result-set
  - Secure - Designated for privacy, limiting access to sensitive data with hidden DDL
- **Streams**
  - Streams track changes to data in tables making it easier to process updates
- **Stages**
  - Internal - created by users and points to a cloud repository within the Snowflake's ecosystem
  - External - created by users and points to a cloud repository outside the Snowflake's ecosystem
  - User - created internally by Snowflake for each user for personal data storage
  - Table - created internally by Snowflake for each table and used for data loads
