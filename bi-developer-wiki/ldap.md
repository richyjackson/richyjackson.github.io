# SQL LDAP

Source: https://sites.google.com/view/bideveloperwiki/home/ldap

Working with Active Directory via LDAP

## Get LDAP User Groups for user

```sql
ALTER PROCEDURE [dbo].[GetLdapUserGroups]
(
    @LDAPEmail NVARCHAR(max)
)
AS
BEGIN

DECLARE @Query NVARCHAR(max), @Path NVARCHAR(max)

SET @Query = '
SELECT @Path = distinguishedName
FROM OPENQUERY(ADSI, ''
SELECT distinguishedName
FROM ''''LDAP://{location of LDAP server}''''
WHERE
objectClass = ''''user'''' AND
mail = ''''' + @LDAPEmail + '''''
'')
'

--print @path

EXEC SP_EXECUTESQL @Query, N'@Path NVARCHAR(max) OUTPUT', @Path = @Path OUTPUT

SET @Query = '
SELECT cn AS [LdapGroup]
FROM OPENQUERY (ADSI, ''<LDAP://{location of LDAP server}>;
(&(objectClass=group)(member:1.2.840.113556.1.4.1941:= ' + @Path + '));
cn, adspath;subtree'')
ORDER BY cn;
'

EXEC SP_EXECUTESQL @Query

END
```
