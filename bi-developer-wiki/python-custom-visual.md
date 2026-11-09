# Python Custom Visual

Source: https://sites.google.com/view/bideveloperwiki/home/python-custom-visual

```python
# Import necessary libraries

import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.patches as patches

# Set the environment

fig, ax = plt.subplots(figsize=(3,1.8), frameon=False)

df = pd.DataFrame(data=dataset, columns=dataset.columns)

# Define variables

value_1_name = "Income"
value_1 = round(sum(df.iloc[:,0]))

value_2_name = "Pr Qtr"
value_2 = round(sum(df.iloc[:,1]))

value_3_name = "PY Pr Qtr"
value_3 = round(sum(df.iloc[:,2]))

is_increase_positive = 1
header_colour = '#333333'
positive_colour = '#78BA5C'
negative_colour = '#E86463'

value_2_diff = value_1 - value_2

if value_2_diff > 0 and is_increase_positive == 1:
    value_2_colour = positive_colour
    value_2_diff_operator = '+'
    value_2_arrow = f'▲'
elif value_2_diff > 0 and is_increase_positive == 0:
    value_2_colour = negative_colour
    value_2_diff_operator = '+'
    value_2_arrow = f'▲'
elif value_2_diff < 0 and is_increase_positive == 1:
    value_2_colour = negative_colour
    value_2_diff_operator = '-'
    value_2_arrow = f'▼'
elif value_2_diff < 0 and is_increase_positive == 0:
    value_2_colour = positive_colour
    value_2_diff_operator = '-'
    value_2_arrow = f'▼'
else:
    value_2_colour = header_colour
    value_2_diff_operator = ''
    value_2_arrow = ''

value_3_diff = value_1 - value_3

if value_3_diff > 0 and is_increase_positive == 1:
    value_3_colour = positive_colour
    value_3_diff_operator = '+'
    value_3_arrow = f'▲'
elif value_3_diff > 0 and is_increase_positive == 0:
    value_3_colour = negative_colour
    value_3_diff_operator = '+'
    value_3_arrow = f'▲'
elif value_3_diff < 0 and is_increase_positive == 1:
    value_3_colour = negative_colour
    value_3_diff_operator = '-'
    value_3_arrow = f'▼'
elif value_3_diff < 0 and is_increase_positive == 0:
    value_3_colour = positive_colour
    value_3_diff_operator = '-'
    value_3_arrow = f'▼'
else:
    value_3_colour = header_colour
    value_3_diff_operator = ''
    value_3_arrow = ''

try:
    value_2_perc = round(((value_1 - value_2) / value_2) * 100)
except:
    value_2_perc = 0

try:
    value_3_perc = round(((value_1 - value_3) / value_3) * 100)
except:
    value_3_perc = 0

# Add any thousands seperators after calculations are made

value_1 = f"{value_1:,}".format(1000)
value_2_diff = f"{value_2_diff:,}".format(1000)
value_3_diff = f"{value_3_diff:,}".format(1000)

# Populate values (Width, Height, Value)

ax.text(0.95, 0.87, value_1_name, ha='right', va='center', fontsize=14, color=header_colour, font='Arial')                     # Value 1 Name
ax.text(0.95, 0.65, value_1, ha='right', va='center', fontsize=24, color=header_colour, font='Arial')                          # Value 1

ax.text(0.2, 0.4, value_2_name, ha='left', va='center', fontsize=10, color=header_colour, font='Arial')                        # Value 2 Name
ax.text(0.7, 0.4, value_2_diff_operator + str(value_2_diff), ha='right', va='center', fontsize=10, color=value_2_colour, font='Arial') # Value 2 Number
ax.text(0.75, 0.4, "|", ha='right', va='center', fontsize=10, color=header_colour, font='Arial')                               # Value 2 Seperator
ax.text(0.95, 0.4, value_2_diff_operator + str(value_2_perc) + "%", ha='right', va='center', fontsize=10, color=value_2_colour, font='Arial') # Value 2 Percent
ax.text(0.055, 0.395, value_2_arrow, ha='left', va='center', fontsize=14, color=value_2_colour, font='Arial')                  # Value 2 Arrow

ax.text(0.2, 0.2, value_3_name, ha='left', va='center', fontsize=10, color=header_colour, font='Arial')                        # Value 3 Name
ax.text(0.7, 0.2, value_3_diff_operator + str(value_3_diff), ha='right', va='center', fontsize=10, color=value_3_colour, font='Arial') # Value 3 Number
ax.text(0.75, 0.2, "|", ha='right', va='center', fontsize=10, color=header_colour, font='Arial')                               # Value 3 Seperator
ax.text(0.95, 0.2, value_3_diff_operator + str(value_3_perc) + "%", ha='right', va='center', fontsize=10, color=value_3_colour, font='Arial') # Value 3 Percent
ax.text(0.055, 0.195, value_3_arrow, ha='left', va='center', fontsize=14, color=value_3_colour, font='Arial')                  # Value 3 Arrow

# Remove x and y axis labels

ax.set_xticks([])
ax.set_yticks([])

# Display the plot

plt.show()
```
