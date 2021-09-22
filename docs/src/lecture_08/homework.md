# Homework

```@raw html
<div class="admonition is-category-homework">
<header class="admonition-header">Homework: Newton's method</header>
<div class="admonition-body">
```

Newton's method for solving equation ``g(x)=0`` is an iterative procedure which at every iteration ``x^k`` approximates the function ``g(x)`` by its first-order (linear) expansion ``g(x) \approx g(x^k) + \nabla g(x^k)(x-x^k)`` and finds the zero point of this approximation.

Newton's method for unconstrained optimization replaces the optimization problem by its optimality condition and solves the resulting equation.

Implement Newton's method to minimize

```math
f(x) = e^{x_1^2 + x_2^2 - 1} + (x_1-1)^2
```

with the starting point ``x^0=(0,0)``.

```@raw html
</div></div>
```