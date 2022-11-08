# Gradients

To minimize a function, it is useful to use derivatives. For a function ``f:\mathbb{R}\to \mathbb{R}``, its gradient is defined by

```math
f'(x) = \lim_{h\to 0}\frac{f(x+h)-f(x)}{h}.
```

For a mapping  ``f:\mathbb{R}^n\to \mathbb{R}^m``, its Jacobian is a matrix ``\nabla f(x)`` of size ``m\times n`` of partial derivatives

```math
(\nabla f(x))_{i,j} = \frac{\partial f_i}{\partial x_j}(x) = \lim_{h\to 0}\frac{f_i(x_1,\dots,x_{j-1},x_j+h,x_{j+1},\dots,x_n)-f(x_1,\dots,x_n)}{h}.
```

The formal definition is more complicated, but this one is better for visualization.

!!! info "Confusion:"
    Gradient ``\nabla f(x)`` of a function ``f:\mathbb{R}^n\to\mathbb{R}`` should be of size  ``1\times n`` but it is commonly considered as ``n\times 1``.

Functions are usually complicated, and this definition cannot be used to compute the gradient. Instead, the objective function ``f`` is rewritten as a composition of simple functions, these simple functions are differentiated, and the chain rule is applied to get ``\nabla f``.

!!! theorem "Theorem: Chain"
    Consider two differentiable functions ``f:\mathbb{R}^m\to\mathbb{R}^s`` and ``g:\mathbb{R}^n\to\mathbb{R}^m``. Then its composition ``h(x) := f(g(x))`` is differentiable with Jacobian
    ```math
    \nabla h(x) = \nabla f(g(x))\nabla g(x).
    ```

The derivative is the direction of the steepest ascent. The following figure shows the vector field of derivatives, where each arrow shows the direction and size of derivatives at the points in the domain. Since a function has the same function values along its contour lines and since derivate is the direction of the steepest ascent, derivatives are perpendicular to contour lines. The figure also shows that local minima and local maxima have zero derivatives.


![](grad3.svg)





# Visualization of gradients

For the numerical experiments, we will consider the following function

```math
f(x) = \sin(x_1 + x_2) + \cos(x_1)^2
```

on domain ``[-3,1]\times [-2,1]``.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise: Contour plot</header>
<div class="admonition-body">
```

Write a function ```g(x)``` which computes the derivative of ``f`` at a point  ``x``. Plot the contours of ``f`` on the domain. 

**Hint**: Use the keyword argument ```color = :jet``` for better visualization.

```@raw html
</div></div>
<details class = "admonition is-category-solution">
<summary class = "admonition-header">Solution:</summary>
<div class = "admonition-body">
```

Function ```f(x)``` takes as an input a vector of two dimensions and returns a scalar. Therefore, the gradient is a two-dimensional vector, which we create by ```[?; ?]```. Its components are computed from the chain rule.

```@example optim
f(x) = sin(x[1] + x[2]) + cos(x[1])^2
g(x) = [cos(x[1] + x[2]) - 2*cos(x[1])*sin(x[1]); cos(x[1] + x[2])]

nothing # hide
```

Since sometimes it is better to use notation ``f(x)`` and sometimes ``f(x_1,x_2)``, we overload the function ```f```.

```@example optim
f(x1,x2) = f([x1;x2])

f([0; 0])
f(0, 0)

nothing # hide
```

```@example optim
println(f([0; 0])) # hide
println(f(0, 0)) # hide
```

We use the ```Plots``` package for plotting. We create the discretization ```xs``` and ```ys``` of both axis and then call the ```contourf``` function.

```@example optim
using Plots

xs = range(-3, 1, length = 40)
ys = range(-2, 1, length = 40)

contourf(xs, ys, f, color = :jet)

savefig("grad1.svg") # hide
```

```@raw html
</div></details>
```

![](grad1.svg)

## [Computation of gradients](@id comp-grad)

The simplest way to compute the gradients is to use a finite difference approximation. It replaces the limit in

```math
f'(x) = \lim_{h\to 0}\frac{f(x+h)-f(x)}{h}
```

by fixing some ``h`` and approximates the gradient by

```math
f'(x) \approx \frac{f(x+h)-f(x)}{h}.
```

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise: Finite difference approximation</header>
<div class="admonition-body">
```

Write a function ```finite_difference``` which computes the approximation of ``f'(x)`` by finite differences. The inputs are a function ``f:\mathbb R\to\mathbb R`` and a point ``x\in\mathbb{R}``. It should have an optional input ``h\in\mathbb{R}``, for which you need to choose a reasonable value.

```@raw html
</div></div>
<details class = "admonition is-category-solution">
<summary class = "admonition-header">Solution:</summary>
<div class = "admonition-body">
```

It is sufficient to rewrite the formula above. Since the argument ```h``` is optional, it should be after ```;```. Its good default value is anything between ``10^{-10}`` and ``10^{-5}``. We specify ```x::Real``` as a sanity check for the case when a function of more variables is passed as input.

```@example optim
finite_difference(f, x::Real; h=1e-8) = (f(x+h) - f(x)) / h
nothing # hide
```

```@raw html
</div></details>
```

This way of computing the gradient has two disadvantages:
1. It is slow. For a function of ``n`` variables, we need to evaluate the function at least ``n+1`` times to get the whole gradient.
2. It is not precise, as the following example shows.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise: Finite difference approximation</header>
<div class="admonition-body">
```

Fix a point ``x=(-2,-1)``. For a proper discretization of ``h\in [10^{-15}, 10^{-1}]`` compute the finite difference approximation of the partial derivative of ``f`` with respect to the second variable.

Plot the dependence of this approximation on ``h``. Add the true derivative computed from ```g```.

```@raw html
</div></div>
<details class = "admonition is-category-solution">
<summary class = "admonition-header">Solution:</summary>
<div class = "admonition-body">
```

To compute the partial derivative with respect to the second argument, we need to fix the first argument and vary only the second one. We create an anonymous function ```y -> f(-2, y)``` and another function ```fin_diff``` which for an input ```h``` computes the finite difference.

```@example optim
x = [-2; -1]
fin_diff(h) = finite_difference(y -> f(x[1], y), x[2]; h=h)

nothing # hide
```

The true gradient is computed by ```g(x)```. It returns a vector of length two. Since we need only the partial derivative with respect to the second component, we select it by adding  ```[2]```.

```@example optim
true_grad = g(x)[2]

nothing # hide
```

Now we create the discretization of ``h`` in ```hs```. When the orders of magnitude are so different, the logarithmic scale should be used. For this reason, we create a uniform discretization of the interval ``[-15,-1]`` and then use it as an exponent.

```@example optim
hs = 10. .^ (-15:0.01:-1)

nothing # hide
```

There are many possibilities of how to create the plot. Probably the simplest one is to plot the function ```fin_diff``` and then add the true gradient (which does not depend on ``h`` and is, therefore, a horizontal line) via ```hline!```.

```@example optim
plot(hs, fin_diff,
    xlabel = "h",
    ylabel = "Partial gradient wrt y",
    label = ["Approximation" "True gradient"],
    xscale = :log10,
)

hline!([true_grad]; label =  "True gradient")

savefig("grad2.svg") # hide
```

```@raw html
</div></details>
```

![](grad2.svg)

The approximation is good if ``h`` is not too small or too large. It cannot be too large because the definition of the gradient considers the limit to zero. It cannot be too small because the numerical errors kick in. This is connected with machine precision, which is most vulnerable to subtracting two numbers of almost the same value. A simple example shows

```math
(x + h)^2 - x^2 = 2xh + h^2
```

but the numerical implementation

```@repl
x = 1;
h = 1e-13;
(x+h)^2 - x^2
2*x*h + h^2
```

gives an error already at the fourth valid digit. It is important to realize how numbers are stored. Julia uses the [IEEE 754 standard](https://en.wikipedia.org/wiki/IEEE_754). For example, `Float64` uses 64 bits to store the number, from which 1 bit represents the sign, 11 bits the exponent and 52 bits the significand precision. As ``2^{52}\approx 10^{16}``, numbers are stored with a 16-digit precision. Since the exponent is stored separately, it is possible to represent numbers smaller than the machine precision, such as ``10^{-25}``. To prevent numerical errors, all computations are done in higher precision, and the resulting variable is rounded to the type precision.

Finally, we show how the gradients look like.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise: Direction of gradients</header>
<div class="admonition-body">
```

Reproduce the previous figure with the vector field of derivatives. Therefore, plot the contours of ``f`` and its gradients at a grid of its domain ``[-3,1]\times [-2,1]``.

**Hint**: when a plot is updated in a loop, it needs to be saved to a variable ```plt``` and then displayed via ```display(plt)```.
```@raw html
</div></div>
<details class = "admonition is-category-solution">
<summary class = "admonition-header">Solution:</summary>
<div class = "admonition-body">
```

First we reduce the number of grid elements and plot the contour plot.
```@example optim
xs = range(-3, 1, length = 20)
ys = range(-2, 1, length = 20)

plt = contourf(xs, ys, f;
    xlims = (minimum(xs), maximum(xs)),
    ylims = (minimum(ys), maximum(ys)),
    color = :jet
)
```

We use the same functions as before. Since we want to add a line, we use ```plot!``` instead of ```plot```. We specify its parameters in an optional argument ```line = (:arrow, 2, :black)```. These parameters add the pointed arrow, the thickness and the colour of the line. Since we do not want any legend, we use ```label = ""```. Finally, since we want to create a grid, we make a loop over ```xs``` and ```ys```.

```@example optim
α = 0.25
for x1 in xs, x2 in ys
    x = [x1; x2]
    x_grad = [x x.+α.*g(x)]

    plot!(x_grad[1, :], x_grad[2, :];
        line = (:arrow, 2, :black),
        label = "",
    )
end
display(plt)

savefig("grad3.svg") # hide
```

```@raw html
</div></details>
```

![](grad3.svg)



