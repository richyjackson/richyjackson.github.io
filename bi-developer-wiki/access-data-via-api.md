# Access Data Via API in SQL

Source: https://sites.google.com/view/bideveloperwiki/home/access-data-via-api-in-sql

## JSON GET

Example includes where an API Key is granted only. It does not include a secret however I suspect this is available as a parameter in the path.

The JSON_VALUE function can extract any value in the tree as seen in ResponseText.

```sql
DECLARE @object INT;
DECLARE @responsetext VARCHAR(8000);
DECLARE @latitude VARCHAR(10) = '50'
DECLARE @longitude VARCHAR(10) = '0.11'
DECLARE @apikey VARCHAR(100) = '{your OpenWeatherMap API key}'
DECLARE @path VARCHAR(1000) =
'https://api.openweathermap.org/data/2.5/weather?' +
'lat=' + @latitude +
'&lon=' + @longitude +
'&appid=' + @apikey

EXEC sp_OACreate 'MSXML2.XMLHTTP', @object OUT;
EXEC sp_OAMethod @object, 'open', NULL, 'get',
                 @path,
                 'false'
EXEC sp_OAMethod @object, 'send'
EXEC sp_OAMethod @object, 'responseText', @responsetext OUTPUT

PRINT @responsetext

SELECT json_value(@responsetext, '$.main.temp')

EXEC sp_OADestroy @Object
```
