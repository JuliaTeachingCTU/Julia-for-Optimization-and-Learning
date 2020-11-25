# Visualization of gradients

For the numerical experiments, we will consider function
```math
f(x) = \sin(x_1 + x_2) + \cos(x_1)^2
```
on domain ``[-3,1]\times [-2,1]``.

!!! tip "Contours"
    Write a function ```g(x)``` which computes the derivative of ``f`` at a point  ``x``.

    Plot the contours of ``f`` on the given domain. Use the optional argument ```color = :jet``` for better visualization.

```@example optim
using Plots

f(x) = sin(x[1] + x[2]) + cos(x[1])^2
g(x) = [cos(x[1] + x[2]) - 2*cos(x[1])*sin(x[1]); cos(x[1] + x[2])]

x_range = range(-3, 1, length = 40)
y_range = range(-2, 1, length = 40)

contourf(x_range, y_range, (x, y) -> f([x; y]), color = :jet)

savefig("grad1.svg") #hide
```

![](grad1.svg)

## Computation of gradients

The simplest way to compute the gradients is to use the finite differences. Thus to replace the limit in
```math
f'(x) = \lim_{h\to 0}\frac{f(x+h)-f(x)}{h}
```
by fixing some ``h`` and approximating the gradient by
```math
f'(x) \approx \frac{f(x+h)-f(x)}{h}.
```

!!! tip "Finite difference approximation"
    Write a function ```get_finite_difference``` which computes the approximation of ``\nabla f(x)`` by finite differences. The inputs are function ``f:\mathbb R\to\mathbb R`` and point ``x\in\mathbb{R}``. It should have an optional input (with a default value) ``h\in\mathbb{R}``. Note that the finite difference approximation is only for a function of one variable. 

```@example optim
get_finite_difference(f, x::Real; h=1e-8) = (f(x+h) - f(x)) / h
```

!!! tip "Finite difference approximation"
    Fix a point ``x=(-2,-1)`` and compute the finite difference approximation of the partial derivative of ``f`` with respect to the second variable. Do this for all ``h=10^k, k=-15,\dots,-1``. Plot the dependence on the choice of ``h`` and add the true derivative computed from ```g```.
    
```@example optim    
h_all = 10. .^(-15:-1)
fin_diff = [get_finite_difference(x -> f([-2; x]), -1; h=h) for h in h_all]
true_grad = g([-2,-1])[2]

plot(h_all, hcat(fin_diff, repeat([true_grad], length(fin_diff))),
    xlabel = "h",
    ylabel = "Partial gradient wrt x",
    label = ["Approximation"; "True gradient"],
    xscale = :log10,
)

savefig("grad2.svg") #hide
```

![](grad2.svg)

ZAVER

!!! tip "Finite difference approximation"
    Plot the contours of ``f`` its gradient at ``(-2,-1)``.


```@example optim
x = [-2; -1]
x_grad = g(x)

contourf(x_range, y_range, (x, y) -> f([x; y]), color = :jet)

plot!([x[1]; x[1]+0.25*x_grad[1]], [x[2]; x[2]+0.25*x_grad[2]],
    arrow = :arrow,
    linewidth = 4,
    linecolor = :black,
    label = "",
)

savefig("grad3.svg") #hide
```

![](grad3.svg)

WHAT IS THE GRADIENT?
