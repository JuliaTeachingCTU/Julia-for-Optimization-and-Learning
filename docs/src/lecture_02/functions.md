# Functions

In Julia, a function is an object that maps a tuple of argument values to a return value. There are multiple ways how to create a function and each of them is useful in different situations. The first way is to use `function ... end` syntax

```@example functions
function plus(x,y)
    x + y
end
nothing # hide
```

In the previous example, we created a function `plus` that accepts two arguments `x`, `y` and returns their sum.

```@repl functions
plus(2, 3)
plus(2, -3)
```

By default, the function in Julia returns the last evaluated expression, which in our example is `x + y`. However, in many situations, it is useful to return something other than the last expression. For such a case there is an `return` keyword. The previous example can be equivalently rewritten as follows

```@example
function plus(x,y)
    return x + y
end
nothing # hide
```

Even though both function definitions do exactly the same, it is a good practice to always use `return` keyword. Using the `return` keyword usually improves the readability of the code and can prevent potential confusion.

```@example functions
function plus(x, y)
    return x + y
    println("I am a useless line of code!!")
end
nothing # hide
```
We can see, that there is println function used on the last line in the previous example. However, if the function is called, nothing is printed into the REPL

```@repl functions
plus(4, 5)
plus(3, -5)
```

The reason is, that the expressions after the `return` keyword are never evaluated

It is also possible to return multiple values at once. This can be done by simply writing multiple comma-separated values after the `return` keyword (or on the last line when `return` is not used)

```@example functions
function powers(x)
    return x, x^2, x^3, x^4
end
nothing # hide
```

In fact, this syntax creates a tuple of values and then this tuple is returned as a function output. It can be seen, if we call the `powers` function that returns the first four powers of the given `x`

```@repl functions
ps = powers(2)
typeof(ps)
```

Since the function returns a tuple, returned values can be directly unpacked into multiple variables. It can be done in the same way as unpacking [tuples](@ref Tuples)

```@repl functions
x1, x2, x3, x4 = powers(2)
x3
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Write a function that for a given real number ``x`` and integer ``p`` computes ``x^p`` without using the `^` operator. You can use only basic arithmetic operators `+`, `-`, `*`, `/` and `if` condition.

**Hint:** use recursion.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
To use recursion, we have to split the computation into three parts:
- ``p = 0``: the function should return `1`.
- ``p > 0``: the function should be called recursively with arguments ``x``, ``p - 1`` and the result should be multiplied by ``x``.
- ``p < 0``: then it is equivalent to call the power function with arguments ``1/x``, ``- p``.

These three cases can be defined simply using one `if` condition as follows

```@example functions_ex
function power(x::Real, p::Integer)
    if p == 0
        return 1
    elseif p > 0
        return x * power(x, p - 1)
    else
        return power(1/x, - p)
    end
end
nothing # hide
```
Note, that we use type annotation for function arguments. In this case, it will assure, that the first argument is always a real number and the second argument is always an integer.

```@repl functions_ex
power(2, 5)
power(2, -2)
power(2, 5) == 2^5
power(5, -3) == 5^(-3)
```

If we call the function with arguments of inappropriate types, an error will occur

```@repl functions_ex
power(2, 2.5)
```

We will discuss the type annotation later in the section about [multiple-dispatch](@ref Methods).

```@raw html
</p></details>
```

## One-line functions

Besides the traditional function declaration syntax above, it is possible to define a function in a compact one-line form

```@example functions
plus(x, y) = x + y
nothing # hide
```

that is equivalent to the previous definition of `plus` function

```@repl functions
plus(4, 5)
plus(3, -5)
```

This syntax is very similar to the mathematical notation especially in combination with the greek alphabet. For example the following function

```math
f(\varphi) = - 4 \cdot \sin\left(\varphi - \frac{\pi}{12}\right)
```

can be in Julia defined in almost identical form

```@example
f(φ) = -4sin(φ - π/12)
nothing # hide
```

Even with one-line syntax, it is possible to create more complex functions with some intermediate calculations. It can be done, using brackets and semicolons to separate expressions. The last expression in brackets is then returned  as a function output

```@example functions
g(x) = (x -= 1; x *= 2; x)
nothing # hide
```

In this example, the `g` function subtracts `1` from the given `x` and then multiply the result by `2`

```@repl functions
g(3)
```

However, for better code readability, the traditional multiline syntax should be used for more complex functions.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Write a one-line function, that returns true if the input argument is an odd number and false otherwise

**Hint:** use modulo function and [ternary operator](https://en.wikipedia.org/wiki/%3F:) `?` (for more info, use help for symbol `?`).

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
In help, we can find the syntax for the ternary operator
```julia
a ? b : c
```
This expression can be read as follows: *if `a` is true, evaluate `b` otherwise evaluate `c`*. We also know that even numbers are divisible by 2 and we can check it using the modulo, i.e. the given integer `x` is even if `mod(x, 2) == 0`.  Altogether, we get the following function definition

```@example functions
even(x::Integer) = mod(x, 2) == 0 ? true : false
nothing # hide
```

Note, that we use type annotation to assure, that the argument is always an integer.

```@repl functions
even(11)
even(14)
```

```@raw html
</p></details>
```

## Optional arguments

Another very useful thing is optional arguments. Similarly to python, optional arguments can be created by assigning a default value to the normal argument. The following function has only one argument, which is optional with a default value `world`

```@example opt_args
hello(x = "world") = println("Hello $(x).")
nothing # hide
```
Since the only argument is optional, we can call the function without any argument. In such a case, the function prints `"Hello $(x)."`, where `x` is replaced by the default value

```@repl opt_args
hello()
```

If we call the function with the argument, it will change the printed sentence

```@repl opt_args
hello("people")
```

In the same way, it is possible to define multiple optional arguments. It is even possible to define optional arguments, that depend on other arguments

```@example opt_args
powers(x, y = x*x, z = y*x, v = z*x) = x, y, z, v
nothing # hide
```

This function has one mandatory argument and three optional ones. If only the first argument `s` is provided, then the function returns the first four powers of the given `x`

```@repl opt_args
powers(2)
```

Otherwise, the function output depends on the given input arguments. For example, if two arguments `x` and `y` are provided, the function returns these two arguments unchanged, their product `x*y` and also `x^2*y`

```@repl opt_args
powers(2, 3)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Write a function, that computes the value of the following quadratic form

```math
q_{a,b,c}(x) = ax^2 + bxy + cy^2
```
where ``a, b, c, x \in \mathbb{R}``. Use optional arguments to set default values for parameters
```math
a = 1 \quad b = 2a \quad c = 3(a + b).
```
What is the function value at point ``(4, 2)`` for default parameters? What is the function value at the same point, if we use ``c = 3``?

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The quadratic form can be implemented as follows

```@example opt_args_ex
q(x, y, a = 1, b = 2*a, c = 3*(a + b)) = a*x^2 + b*x*y + c*y^2
nothing # hide
```

Since we want to evaluate the function `q` at point `(4, 2)` with default parameters, we can simply use only first two arguments

```@repl opt_args_ex
q(4, 2)
```

However, it is not possible to set only the last optional argument. We have to also set all previous optional arguments too. For the first two optional arguments, we use the default values, i.e. `a = 1` and `b = 2*a = 2`.

```@repl opt_args_ex
q(4, 2, 1, 2, 3)
```

```@raw html
</p></details>
```

## Keyword arguments

The exercise from the previous section shows the biggest disadvantage of using optional arguments, i.e. it is not possible to change only one optional argument unless it is the first one. Luckily there are also keyword arguments, that can be used instead of optional arguments. The syntax is exactly the same as for optional arguments with one exception: we have to use a semicolon before the first keyword argument

```@example key_args
linear(x; a = 1, b = 0) = a*x + b
nothing # hide
```
This function is a simple linear function, where `a` parameter is called slope and `b` parameter is called intercept. As with functions with optional arguments, we can call the function only with the mandatory arguments

```@repl key_args
linear(2)
```
or we can change the value of any keyword argument by assigning a new value to its name

```@repl key_args
linear(2; a = 2)
linear(2; b = 4)
linear(2; a = 2, b = 4)
```
Note that the semicolon, in this case, is not mandatory and can be omitted. Also, the order of keyword arguments can be arbitrary as can be seen i the following example

```@repl key_args
linear(2, b = 4, a = 2)
```
It is even possible to mix keyword arguments with positional arguments

```@repl key_args
linear(a = 2, 2, b = 4)
```
However, it's a good practice to always separate keyword arguments from optional arguments with a semicolon.

Julia also provides one very nice feature, that can be used to pass keyword arguments. Imagine, that we have two variable `a`, `b`, that represents the keyword arguments of the `linear` function. The standard way how to pass these arguments to the function is the following

```@repl key_args
a, b = 2, 4
linear(2; a = a, b = b)
```
However, in Julia, we can use the shorter version, that can be used if the variable name is the same as the name of the keyword argument we want to set

```@repl key_args
linear(2; a, b)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Write a probability density function for the Gaussian distribution, that is given by the following formula

```math
f_{\mu, \sigma}(x) = \frac{1}{\sigma \sqrt{ 2\pi }} \exp\left\{ -\frac{1}{2} \left( \frac{x - \mu}{\sigma} \right) ^2 \right\},
```

where ``\mu \in \mathbb{R}`` and ``\sigma^2 > 0``. Use keyword arguments to set the default values ``\mu = 0`` and ``\sigma = 1``.

**Bonus:** check that this function is really a probability density function

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The probability density function for the [Gaussian distribution](https://en.wikipedia.org/wiki/Normal_distribution#General_normal_distribution) can be simply written as follows

```@example key_args_ex
function f(x::Real; μ::Real = 0, σ::Real = 1)
    σ^2 == 0 && error("the variance `σ^2` must be nonzero")
    return exp(-1/2 * ((x - μ)/σ)^2)/(σ * sqrt(2*π))
end
nothing # hide
```

Note, that we use type annotation to  assure, that all input arguments will be real numbers and we also check whether the given arguments do not lead to a zero variance (the first line in the function body).

```@repl key_args_ex
f(0)
f(0.1; μ = 1, σ = 1)
```

We know, that the integral over all real numbers from the probability density function should be equal to one. We can check it numerically as follows

```@repl key_args_ex
x = -100:0.1:100;
sum(f, x) * 0.1

g(x) = f(x; μ = -1, σ = 1.4)
sum(g, x) * 0.1
```

We use the sum function, which can accept a function as a first argument a then this function is applied to each value before summation. The result is always multiplied by `0.1`. It is because we use a range with stepsize `0.1`  to approximate continuous interval `[-100, 100]`.

Finally, we can use the following code to visualize the probability density functions

```@example key_args_ex
using Plots

x = -15:0.1:15

plot(x, f.(x); label = "μ = 0, σ = 1", linewidth = 2, xlabel = "x", ylabel = "f(x)");
plot!(x, f.(x; μ = 4, σ = 2); label = "μ = 4, σ = 2", linewidth = 2);
plot!(x, f.(x; μ = -3, σ = 2); label = "μ = -3, σ = 2", linewidth = 2);
savefig("gauss.svg") # hide
```

We use a lot of things that will be discussed later in the course. So for now, enjoy a nice picture of the Gaussian probability density functions

![](gauss.svg)

```@raw html
</p></details>
```

## Variable number of arguments

## Anonymous functions

It is also common to use anonymous functions, ie functions without specified name. Such a function can be defined in almost the same way as a normal function:

```@repl
h1 = function (x)
    x^2 + 2x - 1
end
h2 = x ->  x^2 + 2x - 1
```

Those two function declarations create functions with automatically generated names. Then variables `h1` and `h2` only refers to these functions. The primary use for anonymous functions is passing them to functions which take other functions as arguments. A classic example is `map`, which applies a function to each value of an array and returns a new array containing the resulting values:

```@repl
map(x -> x^2 + 2x - 1, [1,3,-1])
```

For more complicated functions, the `do` blocks can be used

```@repl
map([1,3,-1]) do x
    x^2 + 2x - 1
end
```

## Function composition and piping

## Vectorized functions

## Docstrings
