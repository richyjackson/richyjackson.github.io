# Query Active Directory

Source: https://sites.google.com/view/bideveloperwiki/home/query-active-directory

## List users in an AD security group

There are 2 types of AD group:

- **Security groups** have credentials with a username and password. They can be configured to have permisson to servers and reports in the same way a user does.
- **Distribution groups** are used solely for emailing and have an email address which can be used for mass mailers.

### OU

In the script below, the OU is the location within Active Directory where the AD group is stored. The path is seperated by dots, so for example Region.CompanyName.local. As a result the DC value appears 3 times.

```sql
CREATE PROC [dbo].[get_ad_group_users] (@Group VARCHAR(100)) AS
BEGIN

DECLARE @Query NVARCHAR(1000), @Path NVARCHAR(1000)

-- Identify memberof attribute value

SET @Query = '
SELECT @Path =
DistinguishedName
FROM OPENQUERY(ADSI, ''
SELECT  distinguishedName, name, objectCategory
FROM    ''''LDAP://DC={OU},DC={OU},DC={OU}''''
WHERE   objectCategory=''''group'''' AND name = ''''' + @Group + ''''''')
'

EXEC SP_EXECUTESQL @Query, N'@Path NVARCHAR(1000) OUTPUT', @Path = @Path OUTPUT

-- Extract users of AD group

SET @Query = '
SELECT
sAMAccountName WindowsLogin,
Name,
Department,
physicalDeliveryOfficeName Office,
Title,
Mail,
HomePhone,
Mobile
FROM OPENQUERY(ADSI, ''
SELECT physicalDeliveryOfficeName, sAMAccountName, mail, name, title, department, homePhone, Mobile
FROM ''''LDAP://DC={OU},DC={OU},DC={OU}''''
WHERE ObjectClass=''''User'''' AND memberof=''''' + @Path + '''''
ORDER BY sAMAccountName'')
'

EXEC (@Query)

END
```

## Find who belongs to an AD security group

The member id used below is used for recursive querying: [Recursive Querying](https://confluence.atlassian.com/crowdkb/active-directory-user-filter-does-not-search-nested-groups-715130424.html)

```sql
CREATE PROC [dbo].[get_ad_groups_for_user] (@Username NVARCHAR(256)) AS
BEGIN

    DECLARE @Query NVARCHAR(1024), @Path NVARCHAR(1024)

    SET @Query = '
        SELECT @Path = distinguishedName
        FROM OPENQUERY(ADSI, ''
            SELECT distinguishedName
            FROM ''''LDAP://DC={OU},DC={OU},DC={OU}''''
            WHERE
                objectClass = ''''user'''' AND
                sAMAccountName = ''''' + @Username + '''''
        '')
    '

    EXEC SP_EXECUTESQL @Query, N'@Path NVARCHAR(1024) OUTPUT', @Path = @Path OUTPUT

    SET @Query = '
        SELECT cn,AdsPath
        FROM OPENQUERY (ADSI, ''<LDAP://DC={OU},DC={OU},DC={OU}>;(&(objectClass=group)(member:1.2.840.113556.1.4.1941:=' + @Path +'));cn, adspath;subtree'')
ORDER BY cn'

    EXEC SP_EXECUTESQL @Query

END
```
