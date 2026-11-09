# Import XML

Source: https://sites.google.com/view/bideveloperwiki/home/import-xml

Importing an XML file into SQL Server

```sql
DECLARE @X1 AS INT, @X AS XML, @RowSet AS NVARCHAR(MAX)

SET @RowSet = 'SELECT @x2 = p FROM OPENROWSET(BULK ''' + @FileLoc + ''', SINGLE_BLOB) as T(P)'

EXEC sp_executesql @RowSet, N'@x2 xml OUTPUT', @x2=@x OUTPUT

EXEC sp_xml_preparedocument @x1 OUTPUT, @x;

-- Populate fxl tables

INSERT INTO fxl.Fund (FundCode, MasterCitiCode, CitiCode, FundName, FundClassName, FundObjective, OfficialSector, FESector, IsFromCustomTable, AsAtArea, AsAtSector, AsAtHolding)
SELECT FundCode, MasterCitiCode, CitiCode, FundName, FundClassName, FundObjective, OfficialSector, FESector, IsFromCustomTable, AsAtArea, AsAtSector, AsAtHolding
FROM OPENXML(@x1,'/DataFields/Fund', 1)
WITH (
    FundCode varchar(12) 'FundCode/text()',
    MasterCitiCode varchar(4) 'PrimaryCitiCode/text()',
    CitiCode varchar(4) 'CitiCode/text()',
    FundName varchar(250) 'FundNameLong/text()',
    FundClassName varchar(250) 'UnitNameLong/text()',
    FundObjective nvarchar(max) 'FundObjective/text()',
    OfficialSector varchar(250) 'OfficialSector/text()',
    FESector varchar(250) 'FESector/text()',
    IsFromCustomTable int 'IsFromCustomTable/text()',
    AsAtArea varchar(50) 'AreaBreakdown/RankingDate/text()',
    AsAtSector varchar(50) 'SectorBreakdown/RankingDate/text()',
    AsAtHolding varchar(50) 'TopTenHolding/RankingDate/text()'
)

INSERT INTO fxl.EO_Area
SELECT * FROM OPENXML (@x1,'/DataFields/Fund/AreaBreakdown/Items/Item', 1)
WITH (
    FundCode varchar(12) '../../../FundCode/text()',
    AreaName varchar(250) 'Name/text()',
    AreaWeight decimal(9,5) 'Weight/text()'
)

INSERT INTO fxl.EO_Sector
SELECT * FROM OPENXML (@x1,'/DataFields/Fund/SectorBreakdown/Items/Item', 1)
WITH (
    FundCode varchar(12) '../../../FundCode/text()',
    AreaName varchar(250) 'Name/text()',
    AreaWeight decimal(9,5) 'Weight/text()'
)

INSERT INTO fxl.EO_Holding
SELECT * FROM OPENXML (@x1,'/DataFields/Fund/TopTenHolding/Items/Item', 1)
WITH (
    FundCode varchar(12) '../../../FundCode/text()',
    AreaName varchar(250) 'Name/text()',
    AreaWeight decimal(9,5) 'Weight/text()'
)
```
