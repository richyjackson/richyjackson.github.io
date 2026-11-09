# DAX Tips

Source: https://sites.google.com/view/bideveloperwiki/home/dax-tips

## Ranking for Top 10

```dax
_ Rank = RANKX(ALL({GROUP BY FIELD}, CALCULATE(SUM({VALUE FIELD})))
```

Once in place add to the filters to filter by numbers less than the top values you wish to show e.g. 10
