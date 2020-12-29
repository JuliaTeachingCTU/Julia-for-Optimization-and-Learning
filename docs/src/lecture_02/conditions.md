# Conditional evaluation

In many cases, we have to decide what to do, based on some conditions. Julia supports the standard `if-elseif-else` syntax, which allows you to decide which part of the code will be evaluated depending on the value of the logical expression. For example, the following function compares two numerical values

```@example conditions
function compare(x, y)
    if x < y
        println("x is less than y")
    elseif x > y
        println("x is greater than y")
    else
        println("x is equal to y")
    end
    return
end
nothing # hide
```
If the expression `x < y` is true, the functions prints *"x is less than y"*, otherwise, the expression `x > y` is evaluated, and if it is true, the functions prints *"x is greater than y"*.  If neither expression is true, the function prints *"x is equal to y"*.

```@repl conditions
compare(1, 2.3)
compare(4.7, 2.3)
compare(2.3, 2.3)
```

```@raw html
<div class = "info-body">
<header class = "info-header">Function declaration:</header><p>
```
So far, we did not mention how to declare our own functions. However, the above example should suffice to show the basic syntax for defining functions. Note, that the `return` keyword is used to specify what is returned by a function. In this case, the function returns nothing, since we only want to compare numbers. If we want to define a function that returns one or more variables then the following syntax is used
```julia
return x, y, z
```
where `x`, `y`, `z` are the variables. See the [third lecture](@ref Functions) for more information about functions.
```@raw html
</p></div>
```

The `elseif` and `else` keywords are optional and it is possible to use as many `elseif` blocks as desired.
```@repl conditions
x, y = 2, 1;
if x < y
    println("x is less than y")
elseif x > y
    println("x is greater than y")
end
if x < y
    println("x is less than y")
end
```
The condition expressions in the `if-elseif-else` construct are evaluated until the first one evaluates to `true`, after which the associated block is evaluated, and no further condition expressions or blocks are evaluated.

In contrast to languages like Python or Matlab, the logical expression in the `if` statement must always return a boolean value, otherwise an error will occur
```@repl
if 1
    println("Hello")
end
```
The `if` blocks do not introduce a [local scope](https://docs.julialang.org/en/v1/manual/variables-and-scoping/), i.e. it is possible to introduce a new variable inside the `if` block and used this variable outside the block.
```@repl conditions
x, y = 2, 1;
if x < y
    z = y
else
    z = x
end
z
```
However, whenever you decide to declare a new variable inside the `if` block, make sure, that the variable will be always declared in all cases.
```@example conditions
function compare(x, y)
    if x < y
        z = y
    elseif x > y
        z = x
    end
    return z
end
nothing # hide
```
For example, the function defined above will work only for numbers, that are not equal
```@repl conditions
compare(1, 2.3)
compare(4.7, 2.3)
compare(2.3, 2.3)
```
Another a little bit unintuitive thing is that `if` blocks return values. This value is given by the last expression evaluated in the `if` block. It is possible to assign this value to a variable as follows
```@example conditions
function compare(x, y)
    z = if x < y
        y
    else
        x
    end
    return z
end
nothing # hide
```
In this case, the `z` variable is equal to `y` if `x < y` is true and to `x` otherwise
```@repl conditions
compare(1, 2.3)
compare(4.7, 2.3)
compare(2.3, 2.3)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Write a simple function `fact` that computes a factorial of the given number. Use the following function declaration
```julia
function fact(n)
    # some code
end
```
Make sure that the input argument is a non-negative integer. If the input argument is negative, the function should throw an error.

**Hint:** use recursion, the `isinteger` function and the `error` function.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
We will split the solution into three cases:
1. the given number `n` is smaller tan zero or is not an integer.
2. the given integer `n` is equal to zero, then the function returns `1`.
3. the given integer `n` is larger than zero, then we use recursion.
```@example conditions_ex
function fact(n)
    if n < 0 | !isinteger(n)
        error("`n` must be non-negative integer")
    elseif n == 0
        1
    else
        n * fact(n - 1)
    end
end
nothing # hide
```
Since the `if` block returns a value from the latest evaluated expression, it is possible to use it after the `return` keyword to define the output of a function.
```@repl conditions_ex
fact(4)
fact(0)
fact(-5)
fact(1.4)
```
```@raw html
</p></details>
```

## Ternary operator

The [ternary operator](https://en.wikipedia.org/wiki/%3F:) `?` is closely related to the `if-else` statement and can be used instead if we only want to decide between two options based on one condition. The syntax is following
```julia
a ? b : c
```
This expression can be read as follows: *if `a` is true, evaluate `b` otherwise evaluate `c`*. Note that white spaces around `?` and `:` are mandatory.
```@repl
x, y = 2, 1;
println(x < y ? "x is less than y" : "x is greater than or equal to y")
```
In this case, if the condition `x < y` holds, then the string `"x is less than y"` is returned, and otherwise `"x is greater than or equal to y"`. Since we wrapped the whole expression into the `println` function, the returned string from the ternary operator is printed in the REPL.

## Short-circuit evaluation

Julia provides a so-called Short-circuit evaluation that is similar to the conditional evaluation. The behavior is found in most imperative programming languages having the && and || boolean operators: in a series of boolean expressions connected by these operators, only the minimum number of expressions are evaluated as are necessary to determine the final boolean value of the entire chain:
- In the expression `a && b`, the subexpression `b` is only evaluated if `a` evaluates to true.
- In the expression `a || b`, the subexpression `b` is only evaluated if `a` evaluates to false.
Both `&&` and `||` associate to the right, but `&&` has higher precedence than `||` does.

To investigate this behavior, let's define the following two functions

```@example shortcirc
t(x) = (println(x); true)
f(x) = (println(x); false)
nothing # hide
```

The `t` function prints `x` and returns true. Similarly, the `f` function prints `x` and returns false. Using these two functions, we can easily find out which expressions are evaluated when using short-circuit evaluation.

```@repl shortcirc
t(1) && println(2) # both expressions are evaluated
f(1) && println(2) # only the first expression is evaluated
t(1) || println(2) # only the first expression is evaluated
f(1) || println(2) # both expressions are evaluated
```

In the same way, we can examine the behavior of various combinations of `&&` and `||` operators

```@repl shortcirc
t(1) && t(2) || println(3) # the first two expressions are evaluated
f(1) && t(2) || println(3) # the first and the last expressions are evaluated
f(1) && f(2) || println(3) # the first and the last expressions are evaluated
t(1) && f(2) || println(3) # all expressions are evaluated
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Rewrite the factorial function from the exercises from the first section. Use short-circuit evaluation to check if the given number is a non-negative integer and ternary operator for recursion.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Since we want to check if the input number is a non-negative integer, we need to check two conditions. It can be done separately using short-circuit evaluation in the following way
```julia
function fact(n)
    isinteger(n) || error("`n` must be non-negative integer")
    n >= 0 || error("`n` must be non-negative integer")
    return n == 0 ? 1 : n * fact(n - 1)
end
```

However, it can be even simplified, if we combine `&&` and `||` operators as follows

```@example shortcirc_ex
function fact(n)
    isinteger(n) && n >= 0 || error("`n` must be non-negative integer")
    return n == 0 ? 1 : n * fact(n - 1)
end
nothing # hide
```
Since `&&` has higher precedence than `||`, the first expression that is evaluated is `isinteger(n) && n >= 0`. The last expression is evaluated only if the first expression is evaluated to  `false`. We can easily check, that this function works exactly the same as the `fact` function from the first section

```@repl shortcirc_ex
fact(4)
fact(0)
fact(-5)
fact(1.4)
```
```@raw html
</p></details>
```
