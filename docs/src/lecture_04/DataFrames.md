# DataFrames.jl

```@setup tables
using RDatasets
using StatsPlots
```

[DataFrames](https://dataframes.juliadata.org/stable/) is a package that provides a set of tools for working with tabular data in Julia. Its design and functionality are similar to those of [pandas](https://pandas.pydata.org/) (in Python) and `data.frame`, `data.table` and dplyr (in R), making it a great general purpose data science tool, especially for those coming to Julia from R or Python.

## Creating DataFrame

The core of the package is the `DataFrame` that represents a data table. The simplest way of constructing a `DataFrame` is to pass column vectors using keyword arguments or pairs
```@repl tables
using DataFrames
df = DataFrame(A = 1:4, B = ["M", "F", "F", "M"], C = rand(4))
```

Since each column is stored in a `DataFrame` as a separate vector, it is possible to combine columns of a different element types. Column can be accesed directly without copying as follows
```@repl tables
df.A
df[!, :B]
df[!, 3]
```
Since vectors are mutable structures and accessing a column of `DataFrame` via syntax above does not make a copy, it is possible to change elements of the `DataFrame` as follows
```@repl tables
df.A[1] = 5;
df
```
However, sometimes it is useful to get a copy of a column instead. To do that, we can use the following syntax
```@repl tables
col = df[:, :A];
col[1] = 4;
df
```

## Adding columns and rows

`DataFrame`s can be also extended by new columns. It can be done directly by as follows
```@repl tables
df.D = [:a, :b, :c, :d];
df
```
or using the `insertcols!` function that allows more options like inserting columns to a specific location

```@repl tables
insertcols!(df, 3, :B => rand(4), :B => 11:14; makeunique = true)
```

It is also possible to add new rows to the existing `DataFrame` using the `push!` function. New rows can be in the form of a vector or tuple of the correct length or in the form of a dictionary with keys the same as the column names of the target table

```@repl tables
push!(df, [10, "F", 0.1, 15, 0.235, :f]);
push!(df, (10, "F", 0.1, 15, 0.235, :f));
push!(df, Dict(:B_1 => 0.1, :B_2 => 15, :A => 10, :D => :f, :B => "F", :C => 0.235));
df
```

Column names can be obtained as `String`s using the `names` function or as a `Symbol`s using `propertynames` function
```@repl tables
names(df)
propertynames(df)
```

```@repl tables
rename!(df, [:A, :B, :C, :D, :E, :F])
```

```@raw html
<div class = "info-body">
<header class = "info-header">Savin and loading <code>csv</code> files</header><p>
```

The standard format for storing table data is `csv` file format. The [CSV](https://github.com/JuliaData/CSV.jl) package provides an interface for saving and loading `csv` files.

```@repl tables
using CSV
CSV.write("dataframe.csv", df)
table = CSV.read("dataframe.csv", DataFrame; header = true)
```
See the package documentation for more information.
```@raw html
</p></div>
```

## StatsPlots

In the next part of the lecture, we will use the [RDatasets](https://github.com/JuliaStats/RDatasets.jl). That package provides an easy way for Julia users to use most of the standard data sets that are available in the core of R programming language.

```@repl tables
using RDatasets
iris = dataset("datasets", "iris")
```


```@example tables
using StatsPlots
@df iris scatter(
    :SepalLength,
    :SepalWidth,
    group = :Species,
    marker = ([:d :h :star7], 8),
)
savefig("tables_1.svg") # hide
```

![](tables_1.svg)

```@example tables
@df iris marginalhist(:PetalLength, :PetalWidth)
savefig("tables_2.svg") # hide
```

![](tables_2.svg)

```@example tables
@df iris corrplot([:SepalLength :SepalWidth :PetalLength :PetalWidth], grid = false, size = (600, 500))
savefig("tables_3.svg") # hide
```

![](tables_3.svg)
