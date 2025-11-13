Querying JSON

```json
Formatted JSON Data

{
   "identifierType":"FactSet Entity",
   "instrumentMetadata":{
      "name":"My Firm plc",
      "entityId":"05H7JB-E",
      "ticker":"CBG-GB",
      "sedol":"0766807",
      "cusip":"G22120102",
      "isin":"GB0007668071"
   },
   "customSymbolDetails":null,
   "query":"CBG-GB"
}
```
```sql
SELECT 
    f.value:query::VARCHAR AS id, 
    f.value:instrumentMetadata.cusip::VARCHAR AS cusip,
    f.value:instrumentMetadata.entityId::VARCHAR AS entity_Id,
    f.value:instrumentMetadata.isin::VARCHAR AS isin,
    f.value:instrumentMetadata.name::VARCHAR AS name,
    f.value:instrumentMetadata.sedol::VARCHAR AS sedol,
    f.value:instrumentMetadata.ticker::VARCHAR AS ticker,
    ''BATCH_LOAD'' AS update_user
FROM IRN_RAW.IDENTIFIERS_STREAM IDENTIFIER, 
    LATERAL FLATTEN(INPUT => IDENTIFIER.data) f
```
