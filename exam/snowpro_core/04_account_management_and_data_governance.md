# 4 Account Management and Data Governance
## Table of Contents
- [4 Account Management and Data Governance](#4-account-management-and-data-governance)
  - [Managing Snowflake Accounts](#managing-snowflake-accounts)
    - [The Snowflake Database](#the-snowflake-database)
    - [Access History](#access-history)
    - [Account Identifiers](#account-identifiers)
    - [Organization](#organization)
    - [Managing Costs](#managing-costs)
  - [Access Control](#access-control)
    - [Access Control Framework](#access-control-framework)
    - [Objects](#objects)
    - [Roles](#roles)
    - [Access Control Privileges](#access-control-privileges)
      - [Warehouse Privileges](#warehouse-privileges)
      - [Schema Privileges](#schema-privileges)
      - [Granting Privileges](#granting-privileges)
      - [Future Grants](#future-grants)
      - [Grant Roles to Users](#grant-roles-to-users)
      - [Revoking Grants](#revoking-grants)
      - [Show Grants](#show-grants)
      - [Snowsight Admin](#snowsight-admin)
      - [Role-based acces to Admin functions](#role-based-acces-to-admin-functions)
  - [Security Features](#security-features)
    - [User Types](#user-types)
    - [Data Encryption](#data-encryption)
    - [Network-level Security](#network-level-security)
  - [Data Security and Management Capabilities](#data-security-and-management-capabilities)
    - [Row-level Security](#row-level-security)
    - [Column-level Security](#column-level-security)
      - [Dynamic data masking](#dynamic-data-masking)
    - [Object Tagging](#object-tagging)
    - [Secure Views](#secure-views)
    - [Snowflake Horizon](#snowflake-horizon)
  - [Sharing Queries or Folders](#sharing-queries-or-folders)
## Managing Snowflake Accounts
#### The Snowflake Database
- The Snowflake database is a central hub for metadata and usage analytics
- It is automatically imported from a share named ``ACCOUNT_USAGE`` when the account is provisioned

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
- Privileges are granted to roles, roles to users, to operations a user can perform on an object
#### Warehouse Privileges
- **MODIFY** change the size and configuration settings of the virtual warehouse
- **OPERATE** allows the role to start, stop or suspend a virtual warehouse
- **USAGE** use the available compute resources in the warehouse
- **OWNERSHIP** grants full control of the warehouse (only 1 role can hold this privilege at a time)
- **MONITOR** allows viewing current and past queries on the warehouse
#### Schema Privileges
- **MODIFY** alter any settings of a schema
- **USAGE** enables using a schema
- **CREATE TABLE** create a new table in a schema, including cloning
#### Granting Privileges
- A role hierarchy is created where roles inherit the abilities of other roles
```sql
USE ROLE SECURITYADMIN;

CREATE ROLE DBA;

CREATE ROLE Analyst;

CREATE ROLE Developer;

GRANT ROLE Analyst TO ROLE Developer; -- Developer has privileges of Analyst

GRANT ROLE Developer TO ROLE DBA; -- DBA has privileges of Developer
```
Privileges are then assigned to the roles:
```sql
GRANT USAGE ON WAREHOUSE main_wh TO role analyst;

GRANT USAGE ON DATABASE sales TO role analyst;

GRANT USAGE ON SCHEMA sales.staging TO role analyst;

GRANT CREATE TABLE, CREATE VIEW ON SCHEMA sales.staging TO role developer

GRANT OPERATE ON WAREHOUSE main_wh TO ROLE DBA;

GRANT CREATE STAGE ON SCHEMA sales.staging TO ROLE DBA;
```
#### Future Grants
- Grants only apply to existing objects not future ones, if SYSADMIN created a table, it would not have privileges to it
- To ensure grants are provided for future objects use: ```GRANT INSERT ON FUTURE TABLES IN SCHEMA sales.staging TO role```
#### Grant Roles to Users
```sql
USE ROLE USERADMIN;
CREATE USER user_1;
CREATE USER user_2;
CREATE USER user_3;

GRANT ROLE DBA TO USER user_1;
GRANT ROLE developer TO USER user_2;
GRANT ROLE analyst TO USER user_3;
```
#### Revoking Grants
- Following RBAC principles, priviliges are granted and revoked at role level
```sql
REVOKE CREATE TABLE, CREATE VIEW ON SCHEMA sales.staging FROM role
```
- When a role creates an object it automatically gets OWNERSHIP privilege, it cannot be revoked but transferred using ```GRANT OWNERSHIP```
#### Show Grants
Show grants commands list all privileges explicitly granted to roles, users and shares
- **SHOW GRANTS** the same as SHOW GRANTS TO USER <current-user>
- **SHOW GRANTS ON ACCOUNT / object-type / object-name**
- **SHOW GRANTS TO ROLE / USER / SHARE**
- **SHOW GRANTS OF ROLE / SHARE** role lists all users and roles to which the role has been granted
- **SHOW FUTURE GRANTS IN SCHEMA / DATABASE** for new objects or databases granted to a role
#### Snowsight Admin
- An interface for management tasks, useage monitoring, warehouse admin, user management and account configuration
#### Role-based acces to Admin functions
- Content within the Admin section is controlled by your role
- **SECURITYADMIN** roles can see and manage users & roles
- **SYSADMIN** can also access Trust Center, manage virtual warehouses, budgets, and resource monitors
- **ACCOUNTADMIN / ORGADMIN** can also view cost and consumption metrics and view query history
## Security Features
- MFA is available across all editions by default
- A human user must authenticate via two methods, a log in and a notification sent to a mobile
- Snowflake supports authentication via a passkey, authenticator app or with Duo
- MFA is also supported by SnowCLI, SnowSQL, JDBC, ODBC & Python
### User Types
```sql
CREATE OR REPLACE USER <<USER_NAME>> TYPE = <<USER_TYPE>>
```
- **Human users** (TYPE = PERSON or NULL) for interactive logins and subject to MFA
- **Service users** (TYPE = SERVICE) for access by systems or automated processes. Cannot use passwords and are MFA exempt. Connection is via OAuth or key pair authentication using public-private key cryptography eliminating the need to store passwords
### Data Encryption
- Data encrypted at rest and in transit by default including data held in internal stages
- Data held in external stages can be optionally encrypted but data is then encrypted during transit to Snowflake
### Network-level Security
- By default any device can access the log in screen
- Security can be added at the network level
- **Network Rules** are schema level objects that are the building blocks of **Network Policies**. They include network identifiers, IP addresses, end points (locations) and can be used by multiple policies
- **Network Policies** control who can connect to Snowflake using a network rule
- **Federated Authentication and Single Sign On** authorisation is managed by an external service (identity provider) rather than Snowflake such as Azure Active Directory or Okta. This allows for Single Sign On
## Data Security and Management Capabilities
### Row-level Security
- For Enterprise Edition and above
- Implemented using row-access policies allowing you to secure data at an individual row level
- You define a policy (and optionally define a mapping table), apply the  policy to one of more tables and query the data

**First create the policy**
```sql
CREATE OR REPLACE ROW ACCESS POLICY SALES_TERRITORY AS
(TERRITORY STRING) RETURNS BOOLEAN ->
  CASE
    WHEN 'SALES_MANAGER' = CURRENT_ROLE() THEN TRUE
    WHEN 'SALES_EMEA' = CURRENT_ROLE() AND TERRITORY = 'EMEA' THEN TRUE
    WHEN 'SALES_APAC' = CURRENT_ROLE() AND TERRITORY = 'APAC' THEN TRUE
    ELSE FALSE END;
```
**Next apply the policy to the table**
```sql
ALTER TABLE SALES ADD ROW ACCESS POLICY SALES_TERRITORY ON (TERRITORY);
```
- If you need to update a row access policy you must use GET_DDL or DESCRIBE ROW ACCESS POLICY

**List objects with policies***
```sql
select * from table (mydb.information_schema.policy_references (policy_name=>'<policy_name>'));
```
***Check if there is a policy attached to a specific object***
```sql
select * from table (mydb.information_schema.policy_references (ref_entity_name => '<name>', ref_entity_domain => '<domain>'));
```
### Column-level Security
Allows you to create a masking policy within a table or view and comes as:
1) **Dynamic data masking** obfuscating contents of data
2) **External tokenization** allows data exchange  for a token outside of Snowflake
#### Dynamic data masking
- A masking policy is a schema level database object applied at query execution time

**Create the masking policy**
```sql
CREATE OR REPLACE MASKING POLICY EMAIL_MASK AS
  (VAL STRING) RETURNS STRING ->
    CASE
      WHEN CURRENT_ROLE() <> ('SENSITIVE_ALLOWED_ROLE') THEN 'XXX-XX-XXXX' ELSE VAL
    END;
```
**Apply the policy to a column**
```sql
ALTER VIEW PRESENTATION.CUSTOMER_LAST_ORDER_DATE
  MODIFY COLUMN CUSTOMER_EMAIL SET MASKING POLICY EMAIL_MASK;
```
**Tag-based masking Policies**
- A masking policy is applied to a TAG, each column is then attached to the tag which applies the policy
- A single tag can support multiple masking policies eg. PII_DATA
#### External tokenization
- The masking policy makes a call to the external function so that it can operation outside of Snowflake
- Example could include exposing medical data externally but hiding a patient id. The patient remains anonyumous but analysis can be continued
- Does not work with data sharing, however Dynamic Data Masking does
### Object Tagging
- Tags allow you to track sensitive data across your environment
- They can be applies to warehouses, schemas, tables, streams & views etc.. allowing you to categories your artifacts
- Available on enterprise edition
- Tags allow tag inheritance
### Secure Views
- Prevents unauthroised access to underlying table structures
- Has performance trade offs
- Use where there is a business need, not for convenience
### Snowflake Horizon
- Provides a unified interface for many security, governance and data management capabilities
- It provides interfaces for access history, data quality monitoring, data lineage & object tagging
- It centralises the trust centre for security posture against industry benchmmarks
## Sharing Queries or Folders
- Queries can be shared in Snowsight through Worksheets and selecting Share in the top right corner
