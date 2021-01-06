# DataFrames.jl

[DataFrames](https://dataframes.juliadata.org/stable/) is a package that provides a set of tools for working with tabular data in Julia. Its design and functionality are similar to those of [pandas](https://pandas.pydata.org/) (in Python) and `data.frame`, `data.table` and dplyr (in R), making it a great general purpose data science tool, especially for those coming to Julia from R or Python.

## Creating `DataFrame`s

```@setup dfbasics
using CSV
using DataFrames
```

The core of the package is the `DataFrame` that represents a data table. The simplest way of constructing a `DataFrame` is to pass column vectors using keyword arguments or pairs
```@example dfbasics
using DataFrames
df = DataFrame(A = 1:4, B = ["M", "F", "F", "M"], C = rand(4))
```

Since each column is stored in a `DataFrame` as a separate vector, it is possible to combine columns of a different element types. Column can be accesed directly without copying as follows
```@example dfbasics
df.A
```
or using indexing syntax which is similar to indexing syntax
```@example dfbasics
df[!, :A]
```
Note, that we use `!` to select all rows. If we use `:`,  then we get a copy of a column. Since vectors are mutable structures and accessing a column of `DataFrame` via syntax above does not make a copy, it is possible to change elements of the `DataFrame` as follows
```@example dfbasics
df.A[1] = 5
df
```
However, sometimes it is useful to get a copy of a column instead. To do that, we can use the following syntax
```@example dfbasics
col = df[:, :A]
col[1] = 4
df
```

```@raw html
<div class = "info-body">
<header class = "info-header">Column names</header><p>
```
DataFrames allows to use `Symbol`s (like `:A`) and strings (like `"A"`) for all column indexing operations for convenience. However, using `Symbol`s is slightly faster and should generally be preferred, if not generating them via string manipulation.

```@raw html
</p></div>
```

### Saving and loading

The standard format for storing table data is `csv` file format. The [CSV](https://github.com/JuliaData/CSV.jl) package provides an interface for saving and loading `csv` files.

```@example dfbasics
using CSV
CSV.write("dataframe.csv", df)
table = CSV.read("dataframe.csv", DataFrame; header = true)
```
See the package [documentation](https://csv.juliadata.org/stable/) for more information.

### Adding columns and rows

It is common for tables to be created column by column or row by row. `DataFrame`s provides an easy way to extend existing tables. To add a new column to a `DataFrame`, we can use a direct way as follows

```@example dfbasics
df.D = [:a, :b, :c, :d]
df
```
Alternatively, we can use the `insertcols!` function. This feature allows you to insert multiple columns at once and also allows for other advanced options. For example, you can specify the column index into which the columns are to be inserted. For more information, see the `insertcols!` help

```@example dfbasics
insertcols!(df, 3, :B => rand(4), :B => 11:14; makeunique = true)
```

New rows can be added to the existing `DataFrame` using the `push!` function. New rows can be in the form of a vector or tuple of the correct length or in the form of a dictionary with keys the same as the column names of the target table

```@example dfbasics
push!(df, [10, "F", 0.1, 15, 0.235, :f])
push!(df, (10, "F", 0.1, 15, 0.235, :f))
push!(df, Dict(:B_1 => 0.1, :B_2 => 15, :A => 10, :D => :f, :B => "F", :C => 0.235))
df
```

It is possible to start with an empty `DataFrame`.  There is no problem when the `DataFrame` is constructed in a column by column manner
```@example dfbasics_empty
using DataFrames
df_empty = DataFrame()
df_empty.A = 1:3
df_empty.B = [:a, :b, :c]
df_empty
```
However, this approach will not work if the `DataFrame` is created row by row. In this case, the empty `DataFrame` must be initialized with empty columns with the correct element types

```@example dfbasics_empty
df_empty = DataFrame(A = Int[], B = Symbol[])
push!(df_empty, [1, :a])
push!(df_empty, (2, :b))
push!(df_empty, Dict(:A => 3, :B => :c))
df_empty
```

### Renaming

Sometimes it is useful to get the names of all the columns. Two functions can be used for such a task. The first is the `names` function, which returns column names as a vector of ` String`s. The `propertynames` function does the same thing but returns a vector of ` Symbol`s

```@repl dfbasics
names(df)
propertynames(df)
```
If we are not satisfied with the column names, we can simply change them using the `rename!` function. This function can be used to rename all columns at once
```@example dfbasics
rename!(df, [:a, :b, :c, :d, :e, :f])
df
```
or to change the name of specific columns
```@example dfbasics
rename!(df, :a => :a, :f => :F)
df
```
Moreover, it is possible to use a function to generate column names
```@example dfbasics
myname(x) = string("column_", uppercase(x))
rename!(myname, df)
df
```

### Working with `DataFrame`s

```@setup dfwork
using DataFrames
using RDatasets
using StatsPlots
```

In the next part of the lecture, we will use the [RDatasets](https://github.com/JuliaStats/RDatasets.jl). That package provides an easy way for Julia users to use most of the standard data sets that are available in the core of R programming language. For further examples, we will use [Iris dataset](https://en.wikipedia.org/wiki/Iris_flower_data_set)
```@example dfwork
using RDatasets, DataFrames
iris = dataset("datasets", "iris")
first(iris, 6)
```
Note, that we use the `first` function to print only the first `n = 6` rows of the given table. Similarly, the `last` function can be used to show the last `n` rows of the given table.

When we start to work with a new data table, that we are not familiar with, it is very useful to get some basic description of the dataset. DataFrames provides the `describe` function that returns descriptive statistics for each column of the given `DataFrame`
```@example dfwork
describe(iris)
```
It is also possible to get a specific subset of a `DataFrame`. To do that, we can use indexing syntax which is similar to indexing syntax for matrices
```@example dfwork
iris[2:4, [:SepalLength, :Species]]
```
Additionally, DataFrames provides `Not`, `Between`, `Cols` and `All` selectors that can be used in more complex column selection scenarios
```@example dfwork
iris[2:4, Not([:SepalLength, :Species])]
```

The last thing, that we will present in this section, is the [Query](https://github.com/queryverse/Query.jl) package, which allows simple advanced manipulation with `DataFrame`. For example, in the code below, we select only rows where `SepalLength >= 6` and at the same time `SepalWidth >= 3.4`. Then we create a new DataFrame, where for each of the selected rows we add corresponding Species, the sum of sepal length and width, and the sum of petal length and width
```@example dfwork
using Query

table = @from row in iris begin
    @where row.SepalLength >= 6 && row.SepalWidth >= 3.4
    @select {
        row.Species,
        SepalSum = row.SepalLength + row.SepalWidth,
        PetalSum = row.PetalLength + row.PetalWidth,
    }
    @collect DataFrame
end
```

There are tons of other topics related to DataFrames, however, there is no time to cover them all. Also, there is also no reason to do that, since DataFrames provides very good [documentation](https://dataframes.juliadata.org/stable/) with a lof of examples


### Visualizing using StatsPlots

```@setup dfplots
using DataFrames
using RDatasets
using StatsPlots
using Query

iris = dataset("datasets", "iris")
```

[StatsPlots](https://github.com/JuliaPlots/StatsPlots.jl) provides recipes for plotting histograms, boxplots, violin plots, etc. This package also provides `@df` macro, which allows simple plotting of tabular data. As a simple example, we can create a scatter plot of `SepalLength` and `SepalWidth` grouped based on the `Species`

```@example dfplots
using StatsPlots
@df iris scatter(
    :SepalLength,
    :SepalWidth;
    xlabel = "SepalLength",
    ylabel = "SepalWidth",
    group = :Species,
    marker = ([:d :h :star7], 8),
)
savefig("tables_1.svg") # hide
```
![](tables_1.svg)

Note that keyword arguments can be used in the same way as usual.

StatsPlots provides a large amount of statistic related plots. As one example, we can mention `marginalkde` function for plotting marginal kernel density estimations. In statistics, [kernel density estimation (KDE)](https://en.wikipedia.org/wiki/Kernel_density_estimation) is a non-parametric way to estimate the probability density function of a random variable. The `marginalkde` function can be used together with `@df` macro as follows

```@example dfplots
using StatsPlots: marginalkde # hide
@df iris marginalkde(
    :SepalLength,
    :SepalWidth;
    xlabel = "SepalLength",
    ylabel = "SepalWidth",
)
savefig("tables_2.svg") # hide
```

![](tables_2.svg)

Another example of a useful function for statistically related graphs is the `corrplot` function, which shows the correlation between input variables

```@example dfplots
@df iris corrplot(
    cols(1:4);
    grid = false,
    nbins = 15,
    fillcolor = :viridis,
    markercolor = :viridis,
)
savefig("tables_3.svg") # hide
```

![](tables_3.svg)

Note, that in this case, we use `cols(1:4)` instead of the names of columns. The reason for that is simple: it is shorter. Anyway, it is possible to use a vector of column names too.
