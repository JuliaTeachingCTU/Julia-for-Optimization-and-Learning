# DataFrames.jl

[DataFrames](https://dataframes.juliadata.org/stable/) is a package that provides a set of tools for working with tabular data. Its design and functionality are similar to  [pandas](https://pandas.pydata.org/) (in Python) and `data.frame`, `data.table` and dplyr (in R) or `table` (in Matlab). This makes it a great general-purpose data science tool, especially for people coming to Julia from other languages.

```@setup dfbasics
using CSV
using DataFrames
```

The core of the package is the `DataFrame` structure that represents a data table. The simplest way of constructing a `DataFrame` is to pass column vectors using keyword arguments or pairs.

```@example dfbasics
using DataFrames
df = DataFrame(A = 1:4, B = ["M", "F", "F", "M"], C = rand(4))
```

Since each column is stored in a `DataFrame` as a separate vector, it is possible to combine columns of different element types. Columns can be accessed directly without copying.

```@repl dfbasics
df.A
```

Another way is to use the indexing syntax similar to the one for arrays.

```@repl dfbasics
df[!, :A]
```

We use `!` to select all rows. This creates a pointer to the column. If we use `:`,  then we get a copy of a column. Since vectors are mutable structures and accessing a column of `DataFrame` via `!` does not make a copy, it is possible to change elements of the `DataFrame`.

```@example dfbasics
df.A[1] = 5
df
```

On the other hand, the `:` creates a copy, which will not change the original `DataFrame`.

```@example dfbasics
col = df[:, :A]
col[1] = 4
df
```

```@raw html
<div class = "info-body">
<header class = "info-header">Column names</header><p>
```

DataFrames allow using symbols (like `:A`) and strings (like `"A"`) for all column indexing operations. Using symbols is slightly faster and should be preferred. One exception is when the column names are generated using string manipulation.

```@raw html
</p></div>
```

The standard format for storing table data is the `csv` file format. The [CSV](https://github.com/JuliaData/CSV.jl) package provides an interface for saving and loading `csv` files.

```@example dfbasics
using CSV
CSV.write("dataframe.csv", df)
table = CSV.read("dataframe.csv", DataFrame; header = true)
```

See the package [documentation](https://csv.juliadata.org/stable/) for more information.

## Adding columns and rows

It is common for tables to be created column by column or row by row. `DataFrame`s provides an easy way to extend existing tables. To can add new columns to a `DataFrame` in a direct way.

```@example dfbasics
df.D = [:a, :b, :c, :d]
df
```

Alternatively, we can use the `insertcols!` function. This function can insert multiple columns at once and also provides advanced options for column manipulation. For example, we can specify the column index into which the columns are to be inserted.

```@example dfbasics
insertcols!(df, 3, :B => rand(4), :B => 11:14; makeunique = true)
```

New rows can be added to an existing `DataFrame` by the `push!` function. It is possible to append a new row in the form of a vector or a tuple of the correct length or in the form of a dictionary or `DataFrame` with the correct keys.

```@example dfbasics
push!(df, [10, "F", 0.1, 15, 0.235, :f])
push!(df, (10, "F", 0.1, 15, 0.235, :f))
push!(df, Dict(:B_1 => 0.1, :B_2 => 15, :A => 10, :D => :f, :B => "F", :C => 0.235))
df
```

It is also possible to start with an empty `DataFrame` and build the table incrementally.

```@example dfbasics_empty
using DataFrames
df_empty = DataFrame()
df_empty.A = 1:3
df_empty.B = [:a, :b, :c]
df_empty
```

However, this approach will not work if the `DataFrame` is created row by row. In this case, the `DataFrame` must be initialized with empty columns of appropriate element types.

```@example dfbasics_empty
df_empty = DataFrame(A = Int[], B = Symbol[])
push!(df_empty, [1, :a])
push!(df_empty, (2, :b))
push!(df_empty, Dict(:A => 3, :B => :c))
df_empty
```

## Renaming

Two functions can be used to rename columns. The `names` function returns column names as a vector of strings, while the `propertynames` function returns a vector of symbols.

```@repl dfbasics
names(df)
propertynames(df)
```

We use the `rename!` function to change column names. This function can be used to rename all columns at once.

```@example dfbasics
rename!(df, [:a, :b, :c, :d, :e, :f])
df
```

Another option is to rename only some of the columns specified by their names.

```@example dfbasics
rename!(df, :a => :A, :f => :F)
df
```

It is also possible to use a function to generate column names.

```@example dfbasics
myname(x) = string("column_", uppercase(x))
rename!(myname, df)
df
```

## Working with `DataFrame`s

```@setup dfwork
using DataFrames
using RDatasets
```

In the next part of the lecture, we will use the [RDatasets](https://github.com/JuliaStats/RDatasets.jl) package. The package provides an easy way for Julia users to use many standard datasets available in the core of the R programming language. We will use the [Iris dataset](https://en.wikipedia.org/wiki/Iris_flower_data_set).

```@example dfwork
using RDatasets, DataFrames
iris = dataset("datasets", "iris")
first(iris, 6)
```

We use the `first` function to print the first `n = 6` rows of a table. Similarly, the `last` function shows the last `n` rows. When working with a new dataset, it is helpful to get a basic description. DataFrames provides the `describe` function that returns descriptive statistics for each column.

```@example dfwork
describe(iris)
```

We can use the indexing syntax to get a specific subset of a `DataFrame`.

```@example dfwork
iris[2:4, [:SepalLength, :Species]]
```

Additionally, DataFrames provides `Not`, `Between`, `Cols` and `All` selectors for more complex column selection scenarios.

```@example dfwork
iris[2:4, Not([:SepalLength, :Species])]
```

The [Query](https://github.com/queryverse/Query.jl) package allows for advanced manipulation with `DataFrame`. The code below selects only rows with `SepalLength >= 6` and `SepalWidth >= 3.4`. Then we create a new DataFrame, where for each of the selected rows, we add the Species, the sum of sepal length and width, and the sum of petal length and width.

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

There are many topics related to DataFrames. However, there is not enough time to cover them all. We refer the reader to the excellent [documentation](https://dataframes.juliadata.org/stable/) with lots of examples.


## Visualizing using StatsPlots

```@setup dfplots
using DataFrames
using RDatasets
using StatsPlots
using Query

iris = dataset("datasets", "iris")
Core.eval(Main, :(using StatsPlots))
```

The [StatsPlots](https://github.com/JuliaPlots/StatsPlots.jl) package provides recipes for plotting histograms, boxplots, and many other plots related to statistics. This package also provides the `@df` macro, which allows simple plotting of tabular data. As a simple example, we create a scatter plot of `SepalLength` and `SepalWidth` grouped by `Species`. Keyword arguments can be used in the same way as before.

```@example dfplots
using StatsPlots
@df iris scatter(
    :SepalLength,
    :SepalWidth;
    group = :Species,
    xlabel = "SepalLength",
    ylabel = "SepalWidth",
    marker = ([:d :h :star7], 8),
)
```

As another example, we mention the `marginalkde` function for plotting marginal kernel density estimations. In statistics, [kernel density estimation (KDE)](https://en.wikipedia.org/wiki/Kernel_density_estimation) is a non-parametric way to estimate the probability density function of a random variable. The `marginalkde` function can be used together with `@df` macro.

```@example dfplots
using StatsPlots: marginalkde # hide
@df iris marginalkde(
    :SepalLength,
    :SepalWidth;
    xlabel = "SepalLength",
    ylabel = "SepalWidth",
)
```

Another example is the `corrplot` function, which shows the correlation between all variables.

```@example dfplots
@df iris corrplot(
    cols(1:4);
    grid = false,
    nbins = 15,
    fillcolor = :viridis,
    markercolor = :viridis,
)
```

Because it is shorter, we use `cols(1:4)` instead of the column names.
