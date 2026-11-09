# General VBA Tips

Source: https://sites.google.com/view/bideveloperwiki/home/vba-tips

## Extract value from multivalued combo box / drop down

```vba
Private Sub cboProcessControl_Change()
    Me.SourceSystem = Me.cboProcessControl.Column(2)
End Sub
```

## Lookup table or query value

```vba
DLookup ("OrderDate", "Orders", "OrderID = 10248")
```

## Add a search box to a form

```vba
If Len(Me.txtSearch) > 0 Then
    Me.Form.RecordSource = "SELECT * FROM {datasource} WHERE [entity_name] Like '*'+[Forms]![frmFormName]!txtSearch +'*'"
Else
    Me.Form.RecordSource = "SELECT * FROM {datasource}"
End If
```
