# Visualization of gradients

For the numerical experiments, we will consider the following function
```math
f(x) = \sin(x_1 + x_2) + \cos(x_1)^2
```
on domain ``[-3,1]\times [-2,1]``.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Contour plot</header><p>
```
Write a function ```g(x)``` which computes the derivative of ``f`` at a point  ``x``.

Plot the contours of ``f`` on the given domain. Use the optional argument ```color = :jet``` for better visualization.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
Function ```f(x)``` takes as an input a vector of two dimensions and returns a scalar. Therefore, the gradient is a two-dimensional vector, which we create by ```[?; ?]```. Its components are computed from the chain rule. To plot, we need to use the ```Plots``` package, create the discretization ```xs``` and ```ys``` of both axis and then call the ```contourf``` function. Since the third argument of ```contourf``` requires a function of two variables, we need to modify ```f``` into ```f_mod```.
```@example optim
using Plots

f(x) = sin(x[1] + x[2]) + cos(x[1])^2
g(x) = [cos(x[1] + x[2]) - 2*cos(x[1])*sin(x[1]); cos(x[1] + x[2])]

xs = range(-3, 1, length = 40)
ys = range(-2, 1, length = 40)
f_mod = (x, y) -> f([x; y])

contourf(xs, ys, f_mod, color = :jet)

savefig("grad1.svg") # hide
```
```@raw html
</p></details>
```

![](grad1.svg)

## Computation of gradients

The simplest way to compute the gradients is to use a finite difference approximation. It replaces the limit in
```math
f'(x) = \lim_{h\to 0}\frac{f(x+h)-f(x)}{h}
```
by fixing some ``h`` and approximates the gradient by
```math
f'(x) \approx \frac{f(x+h)-f(x)}{h}.
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Finite difference approximation</header><p>
```
Write a function ```finite_difference``` which computes the approximation of ``f'(x)`` by finite differences. The inputs are a function ``f:\mathbb R\to\mathbb R`` and a point ``x\in\mathbb{R}``. It should have an optional input ``h\in\mathbb{R}``, for which you need to choose a reasonable value. 

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
We just need to rewrite the formula above. Since the argument ```h``` should be optional, it needs to be after ```;```. Its good default value is anything between ``10^{-10}`` and ``10^{-5}``. We specify ```x::Real``` as a sanity check for the case when a function of more variables is passed as input.
```@example optim
finite_difference(f, x::Real; h=1e-8) = (f(x+h) - f(x)) / h
nothing # hide
```
```@raw html
</p></details>
```

This way of computing the gradient has two diadvantages:
1. It is slow. For a function of ``n`` variables, we need to evaluate the function at least ``n+1`` times to get the whole gradient.
2. It is not precise. We will show this in the next example.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Finite difference approximation</header><p>
```
Fix a point ``x=(-2,-1)`` and compute the finite difference approximation of the partial derivative of ``f`` with respect to the second variable. Do this for ``h=10^k`` with ``k=-15,\dots,-1``. Plot the dependence of the approximation on the choice of ``h``. Add the true derivative computed from ```g```.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
To compute the partial derivative with respect to the second argument, we need to fix the first argument and vary only the second one. The resulting function is ```f_y```.

It is possible to use a ```for``` loop but there is a more efficient way. We first store all the values of ``h`` in ```hs```. Then ```[? for h in hs]``` runs the function ```?``` for all ```h in hs``` and stores the results in an array with the same size as ```hs```. Since we need to get finite differences, the function ```?``` will be replaced by ```finite_difference(f_y, -1; h=h)```.

The true gradient is computed by ```g([-2;1])``` and returns an array of length two. Since we need only the partial derivative with respect to the second component, we need to select it by adding  ```[2]```.

It is possible to call ```plot``` twice. However, we concatenate the true gradient ```true_grad``` and its finite difference approximation ```fin_diff``` by ```hcat```. It is also possible to use ```[? ?]``` (but not ```[?, ?]``` or ```[?; ?]``` -> try it). To get the same shape of the arrays, we need to repeat ```true_grad``` from a scalar to a vector of the same dimension as ```fin_diff```. Since ```repeat``` requires the input to be an array, we need to create it by ```[true_grad]```.
```@example optim    
f_y = x -> f([-2; x])
hs = 10. .^(-15:-1)
fin_diff = [finite_difference(f_y, -1; h=h) for h in hs]
true_grad = g([-2,-1])[2]

plot(hs, hcat(fin_diff, repeat([true_grad], length(fin_diff))),
    xlabel = "h",
    ylabel = "Partial gradient wrt y",
    label = ["Approximation" "True gradient"],
    xscale = :log10,
)

savefig("grad2.svg") # hide
```
```@raw html
</p></details>
```

![](grad2.svg)

We see that the approximation is good if the value ``h`` is not too small or too large. It cannot be too large because the definition of the gradient considers the limit to zero. It cannot be too small because then the numerical errors kick in. This is connected with machine precision, which is most vulnerable to the subtraction of two numbers of almost the same value. A simple example shows
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
gives an error already on the third decimal point.


Finally, we show how the gradients look like.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Direction of gradients</header><p>
```
Plot the contours of ``f`` and its gradient at ``(-2,-1)``.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
We use the same functions as before. Since we want to add a line, we use ```plot!``` instead of ```plot```. We specify the parameters of the line in an optional argument ```line = (:arrow, 4, :black)```. These parameters specify the pointed arrow, the thickness and the color of the line. Since we do not want any legend, we add ```label = ""```.
```@example optim
x = [-2; -1]
x_grad = g(x)

contourf(xs, ys, (x, y) -> f([x; y]), color = :jet)

plot!([x[1]; x[1]+0.25*x_grad[1]], [x[2]; x[2]+0.25*x_grad[2]],
    line = (:arrow, 4, :black),
    label = "",
)

savefig("grad3.svg") # hide
```
```@raw html
</p></details>
```

![](grad3.svg)

The gradient is perpendicular to the contour lines. This makes perfect sense. Since the gradient is the direction of the steepest ascent and the contours have constant values, it needs to be like this. Try this with different values of ``x``.
