```@setup plots
using Plots
using StatsPlots
```

# Plots.jl

![](julia_set.gif)

## Basics

The basic function for creating plots plotting is the `plot` function.

```@example plots
using Plots
x = range(-π, stop = π, length = 1000);

plot(x, sin.(x); label = "sin")
savefig("plots_1.svg") # hide
```

![](plots_1.svg)

```@example plots
plot!(x, cos.(x); label = "cos")

savefig("plots_2.svg") # hide
```

![](plots_2.svg)


```@example plots
plot(x, [sin.(x), cos.(x)]; label = ["sin" "cos"])

savefig("plots_3.svg") # hide
```

![](plots_3.svg)


## Plot attributes

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Create a plot of ``\sin`` and ``\cos`` function for ``x \in [0, 2 \pi]`` with following properties:
- Function ``\sin`` is plotted as a `red dashed` line of width `2` with label `sin`.
- Function ``\sin`` is plotted as a `blue dotted` line of width `4` with label `cos`.
- The title / x label /y label are `Trigonometric functions` / `x` / `y` respectively.
- The tick labels on the x-axis are `["0", "0.5π", "π", "1.5π", "2π"]`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@example plots
x = 0:0.01π:2π

plot(x, [sin, cos];
    label = ["sin" "cos"],
    color = [:red :blue],
    linestyle = [:dash :dot],
    linewidth = [2 4],
    title = "Trigonometric functions",
    xlabel = "x",
    ylabel = "y",
    xticks = (0:0.5π:2π, ["0", "0.5π", "π", "1.5π", "2π"]),
)

savefig("plots_sincos.svg") # hide
```
![](plots_sincos.svg)

```@raw html
</p></details>
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Create a plot given by the following two functions:
```math
\begin{aligned}
f_x(t) & = (a + b)\cos(t) - b \cdot \cos \left( \left(\frac{a}{b} + 1 \right)t \right) \\
f_y(t) & = (a + b)\sin(t) - b \cdot \sin \left( \left(\frac{a}{b} + 1 \right)t \right) \\
\end{aligned}
```
where ``a = 4.23``, ``b = 2.35`` and ``t \in [-15, 20]``. Try to set the attributes of the plot to get a beautiful picture.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
```@example plots
a = 4.23
b = 2.35

fx(t) = (a + b)*cos(t) - b*cos((a/b + 1)*t)
fy(t) = (a + b)*sin(t) - b*sin((a/b + 1)*t)

plot(fx, fy, -15, 20, 1000;
    legend = false,
    axis = false,
    ticks = false,
    linewidth = 2,
)

savefig("plots_parametric.svg") # hide
```

![](plots_parametric.svg)

or equivalently

```@example plots
t = range(-15; stop = 20, length = 1000)

plot(fx.(t), fy.(t);
    legend = false,
    axis = false,
    ticks = false,
    linewidth = 2,
)

savefig("plots_parametric2.svg") # hide
```

![](plots_parametric2.svg)

```@raw html
</p></details>
```

# Integration with other packages

Plots package provides a simple way of defining special plots for custom data types using so-called recipes (in fact, recipes are defined in a stand-alone package [RecipeBase](https://github.com/JuliaPlots/RecipesBase.jl)). By defining custom recipes it is possible to change the preprocessing of the data before they are plotted. There are many packages that provide specialized plot recipes. For example, [StatsPlots](https://github.com/JuliaPlots/StatsPlots.jl) provides recipes for plotting histograms, boxplots, violin plots, etc. This package also provides recipes to treat DataFrames and Distributions, which allows simple plotting of tabular data and distributions.


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
plot(D; linewidthd = 2, xlabel = "x", ylabel = "pdf(x)", legend = false)
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
histogram(x; normalize = :pdf, legend = false)
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
In a similar way, we can create a vector of labels for given distributions

```@example distr
labels = reshape(["Gamma$(params(D))" for D in D], 1, :)
nothing #hide
```
Note, that we reshape labels to be a row vector. The reason is, that we want to plot multiple distributions at once, and in such a case Plot package expects, that labels will be a row vector, where each column represents a label for one curve. Now, we can simply call the `plot` function to plot all distributions at once

```@example distr
plot(Ds;
    xlims = (0, 20),
    ylims = (0, 0.5),
    xlabel = "x",
    ylabel = "pdf(x)",
    labels = labels,
    linewidth = 2,
    legend = :topright,
)
savefig("distributions_ex.svg") # hide
```

![](distributions_ex.svg)


```@example distr
fs = [x -> cdf(D, x) for D in Ds]
plot(fs, 0, 20;
    xlabel = "x",
    ylabel = "cdf(x)",
    labels = labels,
    linewidth = 2,
    legend = :bottomright,
)
savefig("distributions_ex2.svg") # hide
```

![](distributions_ex2.svg)

```@raw html
</p></details>
```


## DataFrames


```@repl
using StatsPlots, RDatasets

iris = dataset("datasets", "iris")
@df iris scatter(
    :SepalLength,
    :SepalWidth,
    group = :Species,
    marker = ([:d :h :star7], 8),
)
```

## Images
