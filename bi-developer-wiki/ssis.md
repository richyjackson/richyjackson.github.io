# SSIS
## Extract SharePoint data in SSIS
### Basic OData Source Configuration
Service Document Location: `http://SITENAME/sites/SUBSITENAME/_vti_bin/listdata.svc`

Unfortunately the expand option to uncover linked data within your SharePoint site is not supported in SSIS.

## Extract SSIS Environment Variables
```sql
CREATE VIEW migrate_ssis_environment_variables AS

-- [internal].[check_data_type_value] does not have all data types coded so fails on Strings! You need to add the code manually for this check or return all as 0 to import

SELECT
    f.[name] AS folder_name,
    e.environment_name,
    v.[name] variable_name,
    v.[type] data_type,
    v.sensitive,
    v.[value],
    v.[description],
    'EXEC [catalog].[create_environment_variable] ''' +
        f.[name] + ''', ''' +
        e.environment_name + ''', ''' +
        v.[name] + ''', ''' +
        v.[type] + ''', ' +
        CAST(v.sensitive AS VARCHAR(1)) + ', ''' +
        ISNULL(CAST(v.[value] AS VARCHAR(100)), '') + ''', ''' +
        v.[description] + ''''
    AS create_variable_script
FROM
    [SSISDB].[internal].[environments] e
    LEFT JOIN [SSISDB].[internal].[folders] f ON f.folder_id = e.folder_id
    LEFT JOIN [SSISDB].[internal].[environment_variables] v ON v.environment_id = e.environment_id
```
