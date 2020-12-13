# Exercises

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 1:</header><p>
```

The goal of this exercise is to solve the following quadratic equation

```math
ax^2 + bx + c = 0
```
where ``a, b, c, \in \mathbb{R}. `` Write a function `quadratic` that computes the value of the left hand side of the given equation. Then write a function `findroots` that computes roots of the quadratic equation based on the given coefficients ``a``, ``b`` and ``c``. Finally, test that the roots given by the `findroots` function are correct. Use the following four parameter settings
1. ``a = 2``, ``b = 9`` and ``c = 4``
2. ``a = 0``, ``b = 2`` and ``c = 4``
3. ``a = 1``, ``b = 2`` and ``c = 1``
4. ``a = 1``, ``b = 2`` and ``c = 2``

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
To define the `quadratic` function, we can use the one-line syntax as follows

```@repl functions_ex
quadratic(x, a, b, c) = a*x^2 + b*x + c
```

The `findroots` function is a little bit more complicated. We know, that for ``a = 0`` the equation is reduced to a linear equation with the following root
```math
x = - \frac{b}{c}.
```
If ``a \neq 0`` the roots can be computed using discriminant that is defined as  ``\Delta = b^2 - 4ac``. Then there are three cases:

- If the discriminant is zero, then there is exactly one real root
```math
x = -\frac{b}{2a}
```
- If the discriminant is positive, then there are two unique real roots
```math
x_1 = \frac{-b + \sqrt{\Delta}}{2a}, \quad
x_2 = \frac{-b - \sqrt{\Delta}}{2a}
```
- If the discriminant is negative, then there are two unique complex roots
```math
x_1 = \frac{-b + i\sqrt{-\Delta}}{2a}, \quad
x_2 = \frac{-b - i\sqrt{-\Delta}}{2a}
```

Now, we can simply use `if` conditions to define the `findroots` function

```@repl functions_ex
function findroots(a, b, c)
    a == 0 && return -c/b

    Δ = b^2 - 4*a*c
    if Δ == 0
        return -b/(2*a)
    elseif Δ > 0
        return (-b + sqrt(Δ))/(2*a), (-b - sqrt(Δ))/(2*a)
    else
        return (-b + im*sqrt(-Δ))/(2*a), (-b - im*sqrt(-Δ))/(2*a)
    end
end
```

Finally, we can test our functions

```@repl functions_ex
args = (2, 9, 4);
quadratic.(findroots(args...), args...)
args = (0, 2, 4);
quadratic.(findroots(args...), args...)
args = (1, 2, 1);
quadratic.(findroots(args...), args...)
args = (1, 2, 2);
quadratic.(findroots(args...), args...)
```

```@raw html
</p></details>
```
