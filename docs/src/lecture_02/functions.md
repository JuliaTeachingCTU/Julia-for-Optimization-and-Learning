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

We use a lot of things that will be discussed later in the course. So for now, just enjoy a nice picture of the Gaussian probability density functions

![](gauss.svg)

```@raw html
</p></details>
```

## Variable number of arguments

Sometimes, it is very convenient to be able to define a function, that can accept any number of arguments. Such functions are traditionally known as "varargs" functions, which is short for "variable number of arguments". In Julia, varargs functions can be defined using triple-dot syntax after the last positional argument as follows

```@example varargs
foo(x...) = x
nothing # hide
```

The `foo` function defined above, accepts any number of input arguments, wraps them in a tuple a returns them

```@repl varargs
foo()
foo(1, 2, "a", :b, [1,2,3])
```
The following example is more useful. In that example, we define `basicinfo` function, that accepts any number of input arguments and then prints basic information like the number of given arguments, their sum, mean and standard deviation.

```@example varargs
using Statistics

function basicinfo(x...)
    println("""
      - number of arguments: $(length(x))
      - sum: $(round(sum(x); digits = 2))
      - mean: $(round(mean(x); digits = 2))
      - std: $(round(std(x); digits = 2))
    """)
    return
end
nothing # hide
```
Note, that we have to use package `Statistics`, since functions `mean` and `std` are not part of standard packages, that are loaded in every Julia session.

```@repl varargs
basicinfo(0.158, 1.889, 1.246, 4.569)
basicinfo(0.158, 1.889, 1.246, 4.569, 5.189, -4.123)
```

A similar syntax for a variable number of positional arguments can be used for keyword arguments as well. Functions that accept any number of keyword arguments can be very useful. Such functions can be used for example
```@example varargs
shiftedsum(x; a = 1, kwargs...) = sum(x .- a; kwargs...)
nothing # hide
```

Here we define a function, that subtracts `a` from each element of the given input array `x` and then sums this array. This function also pass all given keyword arguments to the `sum` function.

```@repl varargs
A = [1 2 3; 4 5 6]
shiftedsum(A)
shiftedsum(A; dims = 1)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Write a function `wrapper`, that accepts a number and applies the `round`, `ceil` or `floor` function based on the keyword argument `type`. Make sure that all optional and keyword arguments can be passed to these three functions.

Use the function to solve the following tasks
- Round `1252.1518` to the nearest larger integer and convert the resulting value to `Int64`.
- Round `1252.1518` to the nearest smaller integer and convert the resulting value to `Int16`.
- Round `1252.1518` to `2` digits after the decimal point.
- Round `1252.1518` to `3` significant digits.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The one way how to define such a function is to use `if` conditions as follows

```@example varargs_ex
function wrapper(x...; type = :round, kwargs...)
    if type == :ceil
        return ceil(x...; kwargs...)
    elseif type == :floor
        return floor(x...; kwargs...)
    else
        return round(x...; kwargs...)
    end
end
nothing # hide
```
In this case, the `type` keyword argument is used to determine which function should be used. Note, that we use an optional number of arguments as well as an optional number of keyword arguments. The reason is, that we want to pass all given arguments to the appropriate function and this is the easiest way how to do it.

```@repl varargs_ex
x = 1252.1518
wrapper(Int64, x; type = :ceil)
wrapper(Int16, x; type = :floor)
wrapper(x; digits = 2)
wrapper(x; sigdigits = 3)
```
The second way how to solve this exercise is to use the fact, that it is possible to pass functions as arguments. Using this fact, we can omit the if condition, and we can pass the appropriate function directly

```@example varargs_ex
wrapper_new(x...; type = round, kwargs...) = type(x...; kwargs...)
nothing # hide
```

Note, that in the function definition, we use the `type` keyword argument as a function. It can be done since we assume that a function is assigned to the keyword argument type

```@repl varargs_ex
wrapper_new(1.123; type = ceil)
```

If we use for example `Symbol` instead of a function, the error will occur

```@repl varargs_ex
wrapper_new(1.123; type = :ceil)
```
Finally, we can test `wrapper_new` function on the same arguments as we tested `wrapper` function

```@repl varargs_ex
x = 1252.1518
wrapper_new(Int64, x; type = ceil)
wrapper_new(Int16, x; type = floor)
wrapper_new(x; digits = 2)
wrapper_new(x; sigdigits = 3)
```

```@raw html
</p></details>
```


## Anonymous functions

It is also common to use anonymous functions, i.e. functions without specified name. Such a function can be defined in almost the same way as a normal function:

```@example
h1 = function (x)
    x^2 + 2x - 1
end
h2 = x ->  x^2 + 2x - 1
nothing # hide
```

Those two function declarations create functions with automatically generated names. Then variables `h1` and `h2` only refers to these functions. The primary use for anonymous functions is passing them to functions which take other functions as arguments. A classic example is `map` function, which applies a function to each value of an array and returns a new array containing the resulting values:

```@repl
map(x -> x^2 + 2x - 1, [1,3,-1])
```

Julia also provides a reserved word do, that allows creating more complicated functions easily. In the following example, we apply `map` function to two arrays.  Using do block, we create an anonymous function, that prints the given values a return their sum

```@repl
map([1,3,-1], [2,4,-2]) do x, y
    println("x = $(x), y = $(y)")
    return x + y
end
```
Note, that the body of such a function is written in the same way as in the case of a normal function definition. The arguments of such function are defined after the `do` keyword. Usually, it is better to create an actual function and then use it in `map` function. The previous example can be rewritten as

```@example anonym
function f(x, y)
    println("x = $(x), y = $(y)")
    return x + y
end
nothing # hide
```

```@repl anonym
map(f, [1,3,-1], [2,4,-2])
```

There are many possible uses quite different from map, such as managing system state. For example, there is a version of open that runs code ensuring that the opened file is eventually closed

```julia
open("outfile", "w") do io
    write(io, data)
end
```

## Dot Syntax for Vectorizing Functions

In technical-computing languages, it is common to have *vectorized* versions of functions. Imagine, that we have a function `f(x)`, then its vectorized version is a function, that applies function `f` to each element of an array `A` and returns a new array `f(A)`. Such functions are especially useful in languages, where loops are slow and vectorized versions of functions are written in a low-level language (C, Fortran,...) and are much faster. As an example, we can mention Matlab.

In Julia, vectorized functions are not required for performance, and indeed it is often beneficial to write your own loops, but they can still be convenient. As an example, consider the sine function and imagine, that we want to compute its value for all following values `[0, π/2, 3π/4]`. Using the loops we can do it as follows

```@repl dot
x = [0, π/2, 3π/4];
A = zeros(length(x));

for (i, xi) in enumerate(x)
    A[i] = sin(xi)
end
A
```
or using list compherension

```@repl dot
A = [sin(xi) for xi in x]
```
However, in this case, the most onvenient way is to use dot syntax for vectorizing functions as follows
```@repl dot
A = sin.(x)
```
In Julia, it is possible to use this syntax for any function to apply it to each element of the given array. It is extremely useful since it allows us to write simple functions that accept for example only numbers as arguments and then we can easily apply them to whole arrays

```@example dot
plus(x::Real, y::Real) = x + y
nothing # hide
```
Here, we define a function, that accepts two real numbers and returns their sum. This function will work perfectly for two numbers

```@repl dot
plus(1,3)
plus(1.4,2.7)
```
But, if we try to apply this function to arrays, an error will occur

```@repl dot
x = [1,2,3,4]; # column vector
plus(x, x)
```
However, we can use dot syntax for vectorizing functions, to any function in Julia. Then the plus function will be applied to arrays `x` and `y` element-wise
```@repl dot
plus.(x, x)
```
More generally, if we have a function `f` and we use dot syntax `f.(args...)`, then it is equivalent to calling the `broadcast` function  in the following way `broadcast(f, args...)`
```@repl dot
broadcast(plus, x, x)
```
This allows us to operate on multiple arrays (even of different shapes), or a mix of arrays and scalars. For more information see the section about [broadcasting](https://docs.julialang.org/en/v1/manual/arrays/#Broadcasting) in the official documentation. In the following example, the `plus` function adds one to each element of the `x` array
```@repl dot
plus.(x, 1)
```
Or we can apply the `plus` function to the column vector `x` and the row vector `y`. The result will be a matrix

```@repl dot
y = [1 2 3 4]; # row vector
plus.(x, y)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Some text that describes the exercise

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Solution

```@raw html
</p></details>
```

## Function composition and piping

As in mathematics, functions in Julia can be composed. If we have two functions ``f: \mathcal{X}  \rightarrow \mathcal{Y}`` and ``g: \mathcal{Y}  \rightarrow \mathcal{Z}``, then their [composition](https://en.wikipedia.org/wiki/Function_composition) can be mathematically written as
```math
(g \circ f)(x) = g(f(x)), \quad \forall x \in \mathcal{X}.
```
In Julia, we can compose functions in a similar way using the function composition operator `∘` (can be typed as `\circ<tab>`)
```@repl
(sqrt ∘ +)(3, 6) # equivalent to sqrt(3 + 6)
```
It is even possible to compose multiple functions at once
```@repl
(sqrt ∘ abs ∘ sum)([-3, -6, -7])  # equivalent to sqrt(abs(sum([-3, -6, -7])))
```

There is also another concept, that allows to chain functions, which is sometimes called *piping* or *using a pipe* to send data to a subsequent function. This concept can be used to simply pass the output of one function as an input to another one. In Julia, it can be one by pipe operator `|>`

```@repl
[-3, -6, -7] |> sum |> abs |> sqrt
```
The pipe operator can be combined with broadcasting. In the following example, firstly we apply the `abs` function element-wise and then we apply the `sqrt` function element-wise.
```@repl
[-4, 9, -16] .|> abs .|> sqrt
```
Or as in the next example, we can use broadcasting in combination with the pipe operator to apply a different function to each element of the given vector
```@repl
["a", "list", "of", "strings"] .|> [uppercase, reverse, titlecase, length]
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Some text that describes the exercise

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Solution

```@raw html
</p></details>
```
