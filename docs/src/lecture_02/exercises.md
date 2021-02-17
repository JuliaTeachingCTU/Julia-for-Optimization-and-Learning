# Julia set

So far, we used only the standard library shipped with Julia. However, the standard library provides only basic functionality. If we want to get additional functions, we have to use extra packages. For example, there is a [Plots.jl](https://github.com/JuliaPlots/Plots.jl) package for creating plots. Packages can be installed via Pkg REPL. To enter the Pkg REPL from the Julia REPL, press `]` and install the package by

```julia
(@v1.5) pkg> add Plots
```

We need to use the `using` keyword to load the package. For example, we can use the Plots package to visualize the `sin` and `cos` functions.

```@example plots
using Plots
x = 0:0.01π:2π

plot(x, sin.(x); label = "sinus", linewidth = 2)
plot!(x, cos.(x); label = "cosinus", linewidth = 2)

savefig("sin.svg") # hide
```

![](sin.svg)

There will be a whole [section](@ref Plots.jl) dedicatd to the Plots package. However, we need some basic functionality to visualize the outputs of the following exercises.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 1: </header><p>
```

Every programmer should be able to rewrite pseudocode to actual code. The goal of this exercise is to rewrite the following pseudocode

![](juliasetalg.png)

This pseudocode describes how to compute the [Julia set](https://en.wikipedia.org/wiki/Julia_set) for the following function

```math
f_c(z) = z^2 + c,
```

where ``c \in \mathbb{C}`` is a complex parameter. To test the resulting code, try the following settings of input parameters
- ``x`` is a vector of 1500 evenly spaced numbers from ``-1.5`` to ``1.5``.
- ``y`` is a vector of 1000 evenly spaced numbers from ``-1`` to ``1``.
- ``c = - 0.4 + 0.61 \cdot i``
- ``R = 2``
- ``N = 1000``

Use this code given below to plot the heatmap of the matrix ``A``.

```julia
using Plots
heatmap(A;
    c = :viridis,
    clims = (0, 0.15),
    cbar = :none,
    axis = :none,
    ticks = :none
)
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Firstly, we have to define all input parameters.

```julia
c = - 0.4 + 0.61im
R = 2
N = 1000
L = 1500
K = 1000
```

The second step is to define vectors `x` and `y`. Since we know that these vectors contain evenly spaced numbers, and we also know the starting point, the stopping point, and the length of the vectors, we the `range` function.

```julia
x = range(-1.5, 1.5; length = L)
y = range(-1.0, 1.0; length = K)
```

The next step is to define the `A` matrix of zeros by the `zeros` function.

```julia
A = zeros(K, L)
```

Now, we rewrite the for loops from the pseudocode. It is possible to rewrite the pseudocode in an almost identical way. However, in many cases, the code can be simplified. For example, we can use the shorter syntax for writing nested `for` loops.

```julia
for k in 1:K, l in 1:L
    z = x[l] + y[k]*im
    for n in 0:N
        if abs(z) > R^2 - R
            A[k, l] = n/N
            break
        end
        z = z^2 + c
    end
end
```

Finally, we use the code provided to visualize the heatmap of the matrix `A`.

```julia
using Plots
heatmap(A;
    c = :viridis,
    clims = (0, 0.15),
    cbar = :none,
    axis = :none,
    ticks = :none,
)
```

```@raw html
</p></details>
```

![](juliaset.svg)


```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 2:</header><p>
```

In the previous exercise, we rewrote pseudocode to actual Julia code. However, the resulting code is not written in the best possible way. This exercise will improve the central part of the code: the inner loop. Write a function which replaces the inner loop in the code from the exercise above. Use the following function definition

```julia
function juliaset(z, c, R, N)
    ???
    return ???
end
```

where ``z, c \in \mathbb{C}``, ``R \in \mathbb{R}`` and ``N \in \mathbb{N}``. Try to use the `while` loop to replace the `for` loop in the original pseudocode. Visualize the resulting matrix using the same code as in the previous exercise.


**Hint:** do not forget, that the function should return `0` if `n > N` and `n/N` otherwise.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

As suggested in the exercise description, we will use the `while` loop because it is more suitable in this case. When using the `while` loop, we have to define the stopping condition. In this case, we have two conditions:
1. maximal number of iterations is `N + 1`,
2. the absolute value of variable `z` has to be smaller or equal to `R^2 - R`.
These two conditions can be merged together as follows `n > N && abs(z) <= R^2 - R`. Inside the `while` loop, we onlye have to update variables `n` and `z`. Altogether the function can be defined in the following way

```julia
function juliaset(z, c, R, N)
    n = 0
    while n <= N && abs(z) <= R^2 - R
        n += 1
        z = z^2 + c
    end
    return n > N ? 0 : n/N
end
```

Note that we use the ternary operator to decide which value is returned. With a defined function, we have to define all input parameters as in the previous exercise

```julia
c = - 0.4 + 0.61im
R = 2
N = 1000
x = range(-1.5, 1.5; length = 1500)
y = range(-1.0, 1.0; length = 1000)
```

Now we can use nested `for` loops to create the `A` matrix. However, it is not the easiest way. It is simpler to use the list comprehension or broadcasting to vectorize the `juliaset` function

```julia
A1 = [juliaset(xl + yk*im, c, R, N) for yk in y, xl in x]
A2 = juliaset.(x' .+ y .* im, c, R, N)
```

In the second case, we have to pay attention to use the correct form of the input. Note that we use transposition of the vector `x`. Finally, we can call the same code as before to create the same plot

```julia
using Plots
heatmap(A1;
    c = :viridis,
    clims = (0, 0.15),
    cbar = :none,
    axis = :none,
    ticks = :none,
    size = (800, 600),
)
```

```@raw html
</p></details>
```

![](juliaset_ex2.svg)

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 3: </header><p>
```

Try different values of variable `c` to create different plots. For inspiration, check the Wikipedia page about [Julia set](https://en.wikipedia.org/wiki/Julia_set).

```@raw html
</p></div>
```
- ``c = 0.285 + 0.01 \cdot i``
![](juliaset_ex3_1.svg)

- ``c = - 0.835 - 0.2321 \cdot i``
![](juliaset_ex3_2.svg)

- ``c = -0.8 + 0.156 \cdot i``
![](juliaset_ex3_3.svg)

- ``c = -0.70176 + 0.3842 \cdot i``
![](juliaset_ex3_4.svg)

## Animation

!!! warning "Warning"
    It takes a lot of time to create the animation described below, especially when using the default [GR](https://github.com/jheinen/GR.jl) backend for the Plots package. The plotting time can be reduced by using a different backend. For example, the [PyPlot](https://github.com/JuliaPy/PyPlot.jl) backend can be used as follows

    ```julia
    using Plots, PyPlot
    pyplot()
    ```
    Note that the PyPlot package must be installed first. An alternative way is to use the [Makie](https://github.com/JuliaPlots/Makie.jl) package instead of the Plots package.

It is also possible to create animations using the Plots package. Just for illustration, we will create an animation of Julia sets for `c` values defined as follows

```math
c_k = 0.7885 \exp \{ k \cdot i \}, \qquad k \in \left [\frac{\pi}{2}, \frac{3\pi}{2} \right ]
```

The vector of all values `c` can be created using the combination of the `range` function and broadcasting in the following way

```julia
cs = 0.7885 .* exp.(range(π/2, 3π/2; length = 500) .* im)
```

We use the `length` keyword to specify the length of the resulting vector. The only thing that we have to do to create an animation is to use the `for` loop in combination with the `@animate` macro as follows

```julia
anim = @animate for c in cs
    A = juliaset.(x' .+ y .* im, c, R, N)
    heatmap(A;
        c = :viridis,
        clims = (0, 0.15),
        cbar = :none,
        axis = :none,
        ticks = :none,
        size = (800, 600),
    )
end
gif(anim, "juliaset.gif", fps = 20) # save animation as a gif
```

Note that the code inside the loop is the same as we used in the previous exercises. The result is the following animation

![](juliaset.gif)
