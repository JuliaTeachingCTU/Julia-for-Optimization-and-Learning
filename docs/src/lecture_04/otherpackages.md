# Other useful packages

## Distributions.jl

```@setup distr
using Distributions
using StatsPlots
```

The [Distributions](https://github.com/JuliaStats/Distributions.jl) package provides a large collection of probabilistic distributions and related functions. Each distribution is defined as a custom type, which allows creating distribution instances in a simple way as follows

```@repl distr
using Distributions
D = Normal(2, 0.5)
```

In the example abovew, we created [Normal distribution](https://en.wikipedia.org/wiki/Normal_distribution) with mean `μ = 2` and standard deviation `σ = 0.5`. Distributions package provides many useful functions to compute mean, variance, or quantiles of the given distribution

```@repl distr
mean(D)
var(D)
quantile(D, 0.9)
```

The package also provides functions to evaluate probability density function or cumulative probability at a given point

```@repl distr
pdf(D, 2)
cdf(D, 2)
```

In the combination with StatsPlots package, it impossible to plot probability density functions as follows

```@example distr
plot(D; linewidth = 2, xlabel = "x", ylabel = "pdf(x)", legend = false)
savefig("distributions_1.svg") # hide
```

![](distributions_1.svg)


The Distributions package also provides methods to fit a distribution to a given set of samples

```@example distr
x = rand(Normal(2, 0.5), 10000); # generate 10000 random numbers from Normal(2, 0.5)
D = fit(Normal, x)
```

The `fit` function will choose a reasonable way to fit the distribution, which, in most cases, is maximum likelihood estimation. Note, that this is not supported for all distributions. We can easily check, that the distribution fit the given data nicely using histogram

```@example distr
histogram(x; normalize = :pdf, legend = false, opacity = 0.5)
plot!(D; linewidth = 2, xlabel = "x", ylabel = "pdf(x)")
savefig("distributions_3.svg") # hide
```
![](distributions_3.svg)


```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Create a figure that will show Gamma distributions with the following parameters: `(2, 2)`, `(9, 0.5)`, `(7.5, 1)` and `(0.5, 1)`.

**Hint:** to plot cumulative probability functions, use the Plots ability to plot a function on a given interval.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The easiest way to create distributions with given parameters is to use Julia's broadcast system as follows

```@example distr
Ds = Gamma.([2, 9, 7.5, 0.5], [2, 0.5, 1, 1])
nothing #hide
```
In a similar way, we can use broadcasting to create a vector of labels for given distributions
```@example distr
labels = reshape(string.("Gamma", params.(Ds)), 1, :)
nothing #hide
```
Note, that we reshape labels to be a row vector. The reason is, that we want to plot multiple distributions at once, and in such a case Plot package expects, that labels will be a row vector, where each column represents a label for one curve. Now, we can simply call the `plot` function to plot all distributions at once

```@example distr
plot(Ds;
    xaxis = ("x", (0, 20)),
    yaxis = ("pdf(x)", (0, 0.5)),
    labels = labels,
    linewidth = 2,
    legend = :topright,
)
savefig("distributions_ex.svg") # hide
```

![](distributions_ex.svg)

A plot of cumulative probability functions cannot be done in the same way. However, StatsPlots provides keyword argument `func` that allows specifying which function should be plotted for a given distribution

```@example distr
plot(Ds;
    func = cdf,
    xaxis = ("x", (0, 20)),
    yaxis = ("cdf(x)", (0, 1.05)),
    labels = labels,
    linewidth = 2,
    legend = :bottomright,
)
savefig("distributions_ex2.svg") # hide
```

![](distributions_ex2.svg)

Another way how to plot cumulative probability functions is to use the Plots package capability to plot functions directly. To do this, we need to define a function with one argument, which at a given point `x` returns the value of the cumulative probability function. Such functions for all our distributions can be easily defined as anonymous functions

```@example distr
cdfs = [x -> cdf(D, x) for D in Ds]
nothing # hide
```
Note, that the previous expression returns a vector of functions. Now we can use the `plot` function that creates a curve for each element of the vector of cumulative probability functions. In the example below, we create these curves for `x` from` 0` to 20

```@example distr
plot(cdfs, 0, 20;
    func = cdf,
    xaxis = ("x", (0, 20)),
    yaxis = ("cdf(x)", (0, 1.05)),
    labels = labels,
    linewidth = 2,
    legend = :bottomright,
)
savefig("distributions_ex3.svg") # hide
```

![](distributions_ex3.svg)

```@raw html
</p></details>
```

## BSON.jl

[BSON](https://github.com/JuliaIO/BSON.jl) is a package for working with the Binary JSON serialisation format. It can be used as a general store for Julia data structures. To save the data, BSON provides the `bson` function.  The data can be passed to the function directly via keyword arguments

```@repl bson
using BSON
BSON.bson("test2.bson", a = [1+2im, 3+4im], b = "Hello, World!")
```
or as a dictionary
```@repl bson
data = Dict(:a => [1+2im, 3+4im], :b => "Hello, World!")
BSON.bson("test1.bson", data)
```
To load the data, BSON provides the `load` function, that accepts the path to the data
```@repl bson
BSON.load("test1.bson")
BSON.load("test2.bson")
```
The package also provides an alternative way to saving and loading data using `@save` and `@load` macros
```@repl bson
using BSON: @save, @load

a = [1+2im, 3+4im];
b = "Hello, World!";

@save "test.bson" a b # Same as above
@load "test.bson" a b # Loads `a` and `b` back into the workspace
```

## ProgressMeter.jl

The [ProgressMeter](https://github.com/timholy/ProgressMeter.jl) package provides excellent utilities for printing progress bars for long-running computation. The package provides `@showprogress` macro, that can be used for printing progress bar for `for` loops in the following way

```julia
julia> using ProgressMeter

julia> @showprogress 1 "Computing..." for i in 1:50
           sleep(0.1)
       end
Computing... 20%|███████▊                               |  ETA: 0:00:04
```

The same syntax can be used also with `map`/`pmap`/`reduce` function. Progress bars can be also created manually, which allows additional formatting of the output. For example, it is possible to print and update information related to the computation by using the `showvalues` keyword as follows

```julia
julia> x, n = 1 , 10;

julia> p = Progress(n);

julia> for iter in 1:10
           x *= 2
           sleep(0.5)
           ProgressMeter.next!(p; showvalues = [(:iter, iter), (:x, x)])
       end
Progress: 100%|█████████████████████████████████████████| Time: 0:00:10
  iter:  10
  x:     1024
```

## BenchmarkTools.jl

The [BenchmarkTools](https://github.com/JuliaCI/BenchmarkTools.jl) package provides a framework for writing and running groups of benchmarks as well as comparing benchmark results. The primary macro provided by BenchmarkTools is `@benchmark`.

```@repl benchmark
using BenchmarkTools
@benchmark sin(x) setup=(x=rand())
```

The `setup` expression in the example above,  is run once per sample, and is not included in the timing results. Another handy macro provided by the package is the `@btime` macro. The output of this macro is similar to the built-in `@time` macro

```@repl benchmark
A = rand(3,3);
@btime inv($A);
```
Note, that we use `$` to interpolate variable `A` into the benchmark expression. Any expression that is interpolated in such a way into the benchmark expression, is "pre-computed" before benchmarking begins.
