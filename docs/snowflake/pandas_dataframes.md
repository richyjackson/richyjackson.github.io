## Pandas Dataframes

https://www.youtube.com/watch?v=DkjCaAMBGWM&t=623s

### Reading and Writing Data

```python
-- Reading data

pd.read_csv() -- configure the options to match the csv style

-- Writing data

df.to_csv('flights.csv') -- set index=False to hide the row number being output
```

### Data Frame Meta Data

```python
df.head()               # See the first 5 rows of data

pd.set_option('display.max_columns', 500) # If you do not see all cols then use before calling the statement

df.tail()               # See the last 5 rows

df.sample(5)            # See a random sample

df.sample(frac=0.1, random_state_529)   # See a random sample as a fraction

df.columns              # See a list of all columns in your data frame

df.index                # See index values

df.info()               # See info about the data frame such as columns, indexes and data types

df.describe()           # See descriptive statitistics such as count, mean, min of all columns

df.[['Airline']].describe() # Show info against a set column

df.shape                # Provides the total rows and columns

len(df)                 # To specifically see the number of rows
```

### Querying the Data Frame

```python
df[['FlightDate', 'Airline', 'Origin']] # Supplies data for columns required. Double square brackets create the dataset as a new data frame

df[df.columns[:5]]          # Provides a slice of the first 5 columns

df[df.columns[:-5]]         # Provides the last 5 columns

df.select_dtypes('int')     # Provide all coilumns of type integer

df[['Airline']]             # If you do not add double square brackets the index number is supplied in the data frame
```

### Filtering Rows by row or column information

Uses iloc (filtering by index) and loc (filtering by name)

```python
df.iloc[1, 3]               # Retrieves the cell for row 1 and column 3

df.iloc[:5, :5]             # A slice retrieving the first 5 rows and columns

df.iloc[5]                  # Supply all data for row 5

df.iloc[:, 5]               # Supply all rows for column 5

df.loc[:, ['Airline', 'Origin']]    # Provides the named columns and all rows
```

### Filtering Rows by Values

```python
df['Airline'] == 'Spirit Air Lines' # Provides a boolean true or false for all rows whether the criteria is met

df.loc[df['Airline'] == 'Spirit Air Lines'] # Filters data to when this expression is true

df.loc[(df['Airline'] == 'Spirit Air Lines']
    & (df['FlightDate'] == '2021-09-09'])]      # Multiple filters using AND

df.loc[(df['Airline'] == 'Spirit Air Lines']
    || (df['FlightDate'] == '2021-09-09'])]     # Multiple filters using OR

df.loc[~((df['Airline'] == 'Spirit Air Lines']  # Multiple filters the INVERSE of the condition
    & (df['FlightDate'] == '2021-09-09']))] 

df.query('(DepTime > 1130) AND (Origin == "DRO")')  # Uses the query method in a string literal

df.query('(DepTime > @min_time) AND (Origin == "DRO")')  # Query method parsing a variable

# Filtering by a calculated column

df['POPULATION_ABOVE_1M'] = df['POPULATION'] > 10000000
df.loc[df['POPULATION_ABOVE_1M'] == True]
df = df[df['POPULATION_ABOVE_1M'] == True]
```

### Summarising Data

```python
df['DepTime'].mean()
df['DepTime'].min()
df['DepTime'].max()
df['DepTime'].std()
df['DepTime'].var()
df['DepTime'].count()
df['DepTime'].sum()
df['DepTime'].quantile(0.5)
df['DepTime'].quantile([0.25, 0.75])

df[['DepTime', 'DepDelay', 'ArrTime']].mean()   # Queries can be run against multiple columns

df[['DepTime', 'DepDelay', 'ArrTime']].agg(['mean', 'min', 'max'])  # Allows you to query against multiple aggregations

df['Airline'].unique()          # Supplies all unique values in the columns

df['Airline'].nunique()         # Returns the number of unique values

df['Airline'].value_counts()    # Aggregates and counts the number of all individual values in the column

df[[]'Airline', 'Origin']].value_counts()   # Provides count of column combinations

df[[]'Airline', 'Origin']].value_counts().reset_index   # Provides data frame with an index number for each combinations
```

### Ranking, Rolling and Cumulative Summing

### Snowflake Integration

```python
from snowflake.snowpark.context import get_active_session
session = get_active_session()

# Grab data from table in snowflake

df = session.table("{table_name}")
df.show()

# Convert snowpark table to a pandas datframe

pdf = df.to_pandas()
pdf.head()

# Run SQL commands in Python

query_result = session.sql("SELECT * FROM your_table")
query_result.show()

# Other fun

cd = DeathData.to_pandas()
cddf = pd.DataFrame(cd)

cv = VaccinationData.to_pandas()
cvdf = pd.DataFrame(cv)

p = PopulationData.to_pandas()
pdf = pd.DataFrame(p)

df = pd.merge(cddf, cvdf, on='COUNTRY', how='inner')
df = pd.merge(df, pdf, on='COUNTRY', how='inner')

df = df.dropna()

df['DEATHS'] = df['DEATHS'].astype('int')
df['VACCINATIONS'] = df['VACCINATIONS'].astype('int')
df['POPULATION'] = df['POPULATION'].astype('int')
df['PERCENT_VACCINATED'] = (df['VACCINATIONS'] / df['POPULATION']) * 100
df['PERCENT_DIED'] = (df['DEATHS'] / df['POPULATION']) * 100

df['POPULATION_ABOVE_1M'] = df['POPULATION'] > 10000000 -- Adding a column

df.loc[df['POPULATION_ABOVE_1M'] == True]

# Sorting Values

df.sort_values(by=["PERCENT_VACCINATED"], inplace=True)

df
```
