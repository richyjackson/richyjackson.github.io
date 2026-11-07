# 4 Account Management and Data Governance
## Managing Snowflake Accounts
#### The Snowflake Database
- The Snowflake database is a central hub for metadata and usage analytics
- It is automatically imported from a share named ACCOUNT_USAGE when the account is provisioned

There are several schemas:
- **ACCOUNT_USAGE** for object metadata and historical data for 1 year across the entire Snowflake account. There is a latency of 35 mins to 3 hours
- **ALERT** containing functions used for alerts
- **CORE** for data relared to Snowflake features such as system tags, data classification and DMFs
- **DATA_PRIVACY** for  functions and procedures related to data privacy including data classification
- **DATA_SHARING_USAGE** for data related to sharing, data marketplace or data exchange
- **INFORMATION_SCHEMA** a data dictionary for all objects in your account across the database with a latency of 7 days to 6 months
- **LOCAL** for data quality monitoring results
- **ML** contains the analytics functions including time-series, forecasting and anomaly detection
- **MONITORING** shows historical information about your account
- **NOTIFICATION** contains object for sending notifications
- **ORGANIZATION_USAGE** for historical usage meta across your accounts
- **READ_ACCOUNT_USAGE** for reader accounts if created
- **TELEMETRY** for logs, trace events and metrics data
> Explicit permission is granted by ACCOUNTADMIN for ACCOUNT_USAGE, READER_ACCOUNT_USAGE, ORGANIZATION_USAGE and DATA_SHARING_USAGE
#### Access History
- Available in Enterprise edition and above, it shows data related to user queries, source, projected and filter columns
- It shows the query accessed directly and indirectly for regulatory compliance auditing
- It now includes detail about masking policies references, tracks DDL operations, query relationships and stored procedures and column lineage
- It will show access control privilege detail about grants to a role and grants to a user 
#### Account Identifiers



## Access Control


## Security Features


## Data Security and Management Capabilities


## Sharing Queries or Folders


