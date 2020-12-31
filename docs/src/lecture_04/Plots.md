# Plots.jl

![](julia_set.gif)

## Basics

```@setup plots
using Plots
using StatsPlots
gr()
```

```@example plots
using Plots
x = range(-π, stop = π, length = 1000);
y = sin.(x);

plot(x, y; label = "sin")
savefig("plots_1.svg") # hide
```

![](plots_1.svg)

```@example plots
y2 = cos.(x)
plot!(x, y2; label = "cos")

savefig("plots_2.svg") # hide
```

![](plots_2.svg)


```@example plots
plot(x, [y, y2]; label = ["sin", "cos"])

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
