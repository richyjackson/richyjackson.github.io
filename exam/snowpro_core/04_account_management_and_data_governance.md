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
- Distinguishes between Snowflake instances
- Available via Classic Web UI, Snowsight, SnowSQL and data sharing / database replication
- It is available in the Snowflake URL: <account_identifier>.snowflakecomputing.com
#### Organization
- An organisation links all your Snowflake accounts
- If you have an organization, the org name is prefixed to your account identifier
#### Managing Costs
- Snowflake has three main categories for costs, compute, data storage and data transfer
- In Snowsight go to Admin > Cost Management > Account overview where costs and cost insights are displayed
- For more detailed information use information_schema or account_usage views
- If an organisation is set up, the organisatoiomn view shows detail across all accounts
- Object tagging can be used to identify and group costs associated with a particular process or department
- Resource monitors restrict credit useage to avoid overspend
- Costs are mostly attributed to the running of virtual warehouses which charge acfcording to size and the length of time the warehouse was up and running
```sql
USE ROLE ACCOUNTADMIN;

CREATE RESOURCE MONITOR MONTHLY_ACCOUNT_BUDGET WITH
  CREDIT_QUOTA  = 1000
  FREQUENCY   = MONTHLY
  START_TIMESTAMP = IMMEDIATELY
TRIGGERS
  ON 90 PERCENT DO NOTIFY
  ON 95 PERCENT DO SUSPEND
  ON 99 PERCENT DO SUSPEND_IMMEDIATE;

ALTER ACCOUNT SET RESOURCE_MONITOR = MONTHLY_ACCOUNT_BUDGET;
```
## Access Control
### Access Control Framework
Snowflake uses three established models for access control:
- **Discretionary Access Control (DAC)** each database object has a designated owner who possesses authority to grant access privileges to that object
- **Role-based Access Control (RBAC)** access privileges are assigned to roles, which are assigned to users creating a security hierarchy
- **User-based Access Control (UBAC)** is more flexible than RBAC and is for specific, temporary or limited scope access
### Objects
- Privileges exist on objects that can be granted to roles, users are assigned to roles
### Roles
- Snowflake controls who can access objects, what operations can be performaed and who can create or alter access control policies

There are 5 pre-defined system roles, custom roles can be created as required:
- **ORGADMIN** for organisation level tasks such as managing Snowflake accounts and organisation level useage information
- **ACCOUNTADMIN** the most powerful role; allowing you to administer your account & view credit & billing. Access should be limited. It is a parent of SYSADMIN & SECURITYADMIN
- **SYSADMIN** can create warehouses, databases and all objects within the database
- **SECURITYADMIN** for management of granting or revoking privileges to roles, it is a parent of USERADMIN
- **USERADMIN** for creating roles, users and managing privileges assigned to them
- **PUBLIC** the default role for users allowing them to log in and view basic information
- **CUSTOM** for custom roles, the recommendation is the highest role in the hierarchy can manage all warehouses, databases and objects whilst maintaining the existing SECURITYADMIN & ACCOUNTADMIN roles
### Access Control Privileges

## Security Features


## Data Security and Management Capabilities


## Sharing Queries or Folders


