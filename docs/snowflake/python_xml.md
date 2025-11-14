```python
from lxml import etree

tree = etree.parse("DLTINS_20250310_01of01.xml")

root = tree.getroot()

elements = root.findall(".//Fxd")

for elem in elements:
    print(elem.tag, elem.attrib)
    #print("Name:", elem.findtext("RlvntTradgVn"))\
```
