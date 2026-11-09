# Sharepoint as a Data Source

Source: https://sites.google.com/view/bideveloperwiki/home/sharepoint-as-a-data-source

## Setting the data source in SSRS

In SSRS data source settings, change the drop down to "Microsoft Sharepoint List".

In the connection string select the site root / main page, e.g. `http://{server name}/sites/intranet/{main site name}`

In the SSRS report itself, add the HTML for the data set as follows:

```xml
<ListName>{name of list in site}</ListName>
<ViewFields>
<FieldRef Name="{field name 1}" />
<FieldRef Name="{field name 2}" />
<FieldRef Name="{field name 3}" />
<FieldRef Name="{field name 4}" />
<FieldRef Name="{field name 5}" />
</ViewFields>
```
