## Using Identifier

When using an object as a variable you must let Snowflake first:
<br>
```sql
REFRESH_CHECK := (SELECT COUNT(*) FROM IDENTIFIER(:MY_TABLE_VARIABLE) WHERE EVENT_DT = CURRENT_DATE());
```
<br>

When calling a procedure as a variable, you can also declare and return parameters
```sql
CALL IDENTIFIER(:PROCEDURE_NAME)(:RUN_ID, :FILE_ID) INTO :RETURN_OBJECT;
```
