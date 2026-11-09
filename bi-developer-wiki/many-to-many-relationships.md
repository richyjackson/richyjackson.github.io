# Many to Many relationships with Power BI

Source: https://sites.google.com/view/bideveloperwiki/home/many-to-many-relationships-in-power-bi

POWER BI DOES NOT SUPPORT MANY TO MANY RELATIONSHIPS

You can however create a bridging table with unique keys between the two sources, allowing you to join the two dataset together.

- Go to the Modelling Tab and Select "New Table"
- Use the function **SUMMARIZECOLUMNS** to extract unique values
- This is useful for allowing Many to Many relationships work in Power BI.

![](https://sites.google.com/sitesv-images-rt/APXyLQdcDRRAv1B-f2BRe2-83djWwgWM8treQUDyFqW1jcuz0xLTORaOR-OtFruPV-JG7TyulvSYBQ_yo8oRspDZ4nMT6CxqVfYRazBh3e1zz3K3t1PxhkPZmqgbTJ2CUCNoyHhlbwIWlMTcykuGGoQkae7RfXKzPVRpuD0JyLethfvFnh41hnSmpJ2sGHRG7eh9qUQyLdzUJoIPSJ2yNJK2XEJYU1Aq5efx_3hXwEPs=w1280)
