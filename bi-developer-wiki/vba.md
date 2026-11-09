# VBA

## General VBA Tips

### Extract value from multivalued combo box / drop down

```vba
Private Sub cboProcessControl_Change()
    Me.SourceSystem = Me.cboProcessControl.Column(2)
End Sub
```

### Lookup table or query value

```vba
DLookup ("OrderDate", "Orders", "OrderID = 10248")
```

### Add a search box to a form

```vba
If Len(Me.txtSearch) > 0 Then
    Me.Form.RecordSource = "SELECT * FROM {datasource} WHERE [entity_name] Like '*'+[Forms]![frmFormName]!txtSearch +'*'"
Else
    Me.Form.RecordSource = "SELECT * FROM {datasource}"
End If
```

## IE Automation

Source: https://sites.google.com/view/bideveloperwiki/home/ie-automation

Automating Websites through MS Access or Excel in VBA

### Add Error Handling

```vba
Sub cmdAutomate()

On Error GoTo AutomateError:

MSGBOX "No errors"

ValuationError:

MSGBOX "An error occured"

End Sub
```

### Launch a web page

```vba
Dim IE As Object

Set IE = New SHDocVw.InternetExplorer

IE.Navigate2 "https://www.google.com"

IE.Visible = True
```

### Delay actions

```vba
Sub cmdAutomate()

Dim t As Long
Dim Timer As Long

While IE.Busy
    DoEvents
Wend

Do
    DoEvents
Loop Until IE.readystate = 4

Do Until t = Timer
    t = t + 1
Loop

t = 1

End Sub
```

### Press a button

```vba
IE.Document.getelementbyid("{html field name}").Click
```

### Give a field a value

```vba
IE.Document.getelementbyid("{html field name}").Value = ""
```
