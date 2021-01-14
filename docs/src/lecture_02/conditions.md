# Conditional evaluation

In many cases, we have to decide what to do, based on some conditions. Julia supports the standard `if-elseif-else` syntax, which allows you to decide which part of the code will be evaluated depending on the logical expression's value. For example, the following function compares two numerical values

```jldoctest conditions; output = false
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

# output
compare (generic function with 1 method)
```

If the expression `x < y` is true, the functions prints *"x is less than y"*, otherwise, the expression `x > y` is evaluated, and if it is true, the functions prints *"x is greater than y"*. If neither expression is true, the function prints *"x is equal to y"*.

```jldoctest conditions
julia> compare(1, 2.3)
x is less than y

julia> compare(4.7, 2.3)
x is greater than y

julia> compare(2.3, 2.3)
x is equal to y
```

```@raw html
<div class = "info-body">
<header class = "info-header">Function declaration:</header><p>
```

So far, we did not mention how to define functions. However, the above example should suffice to show the basic syntax for defining functions. Note that the `return` keyword is used to specify the output of the function. In this case, the function returns nothing since we only want to compare numbers. If we want to define a function that returns one or more variables, then the following syntax is used

```julia
return x, y, z
```

where `x`, `y`, and `z` are some variables. See the [third lecture](@ref Functions) for more information about functions.

```@raw html
</p></div>
```

The `elseif` and `else` keywords are optional, and it is possible to use as many `elseif` blocks as wanted

```jldoctest conditions
julia> x, y = 2, 1;

julia> if x < y
           println("x is less than y")
       elseif x > y
           println("x is greater than y")
       end
x is greater than y

julia> if x < y
           println("x is less than y")
       end
```

The condition expressions in the `if-elseif-else` construct are evaluated until the first one evaluates to `true`, after which the associated block is evaluated, and no further condition expressions or blocks are evaluated.

In contrast to languages like Python or Matlab, the logical expression in the `if-elseif-else` statement must always return a boolean value, otherwise, an error will occur

```jldoctest
julia> if 1
           println("Hello")
       end
ERROR: TypeError: non-boolean (Int64) used in boolean context
```

The `if` blocks do not introduce a [local scope](https://docs.julialang.org/en/v1/manual/variables-and-scoping/), i.e., it is possible to introduce a new variable inside the `if` block and used this variable outside the block

```jldoctest conditions
julia> x, y = 2, 1;

julia> if x < y
           z = y
       else
           z = x
       end
2

julia> z
2
```

However, it is necessary to ensure that the variable will always be declared in all cases in such cases.

```jldoctest conditions; output = false
function compare(x, y)
    if x < y
        z = y
    elseif x > y
        z = x
    end
    return z
end

# output
compare (generic function with 1 method)
```

For example, the function defined above will work only for numbers, that are not equal

```jldoctest conditions
julia> compare(1, 2.3)
2.3

julia> compare(4.7, 2.3)
4.7

julia> compare(2.3, 2.3)
ERROR: UndefVarError: z not defined
```

Another a little bit unintuitive thing is that `if` blocks return values. This value is given by the last expression evaluated in the `if` block. It is possible to assign this value to a variable as follows

```jldoctest conditions; output = false
function compare(x, y)
    z = if x < y
        y
    else
        x
    end
    return z
end

# output
compare (generic function with 1 method)
```

In this case, the `z` variable is equal to `y` if `x < y` is true and to `x` otherwise

```jldoctest conditions
julia> compare(1, 2.3)
2.3

julia> compare(4.7, 2.3)
4.7

julia> compare(2.3, 2.3)
2.3
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Write a simple `fact` function that computes the factorial of the given number. Use the following function declaration

```julia
function fact(n)
    # some code
end
```

Make sure that the input argument is a non-negative integer. For negative input arguments or arguments that can not be represented as an integer, the function should throw an error.

**Hint:** use recursion, the `isinteger` function and the `error` function.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

We will split the solution into three cases:
1. the given number `n` is smaller than zero or is not an integer.
2. the given integer `n` is equal to zero, then the function returns `1`.
3. the given integer `n` is larger than zero, then we use recursion.

```jldoctest conditions_ex; output = false
function fact(n)
    if n < 0 | !isinteger(n)
        error("argument must be non-negative integer")
    elseif n == 0
        1
    else
        n * fact(n - 1)
    end
end

# output
fact (generic function with 1 method)
```

Since the `if` block returns a value from the latest evaluated expression, it is possible to use it after the `return` keyword to define a function's output.

```jldoctest conditions_ex
julia> fact(4)
24

julia> fact(0)
1

julia> fact(-5)
ERROR: argument must be non-negative integer

julia> fact(1.4)
ERROR: argument must be non-negative integer
```

```@raw html
</p></details>
```

## Ternary operator

The [ternary operator](https://en.wikipedia.org/wiki/%3F:) `?` is closely related to the `if-else` statement and can instead be used to decide between two options based on a single condition. The syntax is following

```julia
a ? b : c
```

This expression can be read as follows: *if `a` is true, evaluate `b` otherwise evaluate `c`*. Note that white spaces around `?` and `:` are mandatory.

```jldoctest
julia> x, y = 2, 1;

julia> println(x < y ? "x is less than y" : "x is greater than or equal to y")
x is greater than or equal to y
```

In this case, there are two possibilities:
- if `x < y` is true, then the string `"x is less than y"` is returned,
- if `x < y` is false, then the string `"x is greater than or equal to y"` is returned.
Since we wrapped the whole expression into the `println` function, the ternary operator's output is printed in the REPL.

## Short-circuit evaluation

Julia provides a so-called Short-circuit evaluation that is similar to the conditional evaluation. The behavior is found in most imperative programming languages having the `&&` and `||` boolean operators. In a series of boolean expressions connected by these operators, only the minimum number of expressions are evaluated as are necessary to determine the final boolean value of the entire chain:
- In the expression `a && b`, the subexpression `b` is only evaluated if `a` evaluates to true.
- In the expression `a || b`, the subexpression `b` is only evaluated if `a` evaluates to false.
Both `&&` and `||` associate to the right, but `&&` has higher precedence than `||` does.

To investigate this behavior, let's define the following two functions

```jldoctest shortcirc; output = false
t(x) = (println(x); true)
f(x) = (println(x); false)

# output
f (generic function with 1 method)
```

The `t` function prints `x` and returns true. Similarly, the `f` function prints `x` and returns false. Using these two functions, we can easily find out which expressions are evaluated when using short-circuit evaluation.

```jldoctest shortcirc
julia> t(1) && println(2) # both expressions are evaluated
1
2

julia> f(1) && println(2) # only the first expression is evaluated
1
false

julia> t(1) || println(2) # only the first expression is evaluated
1
true

julia> f(1) || println(2) # both expressions are evaluated
1
2
```

In the same way, we can examine the behavior of various combinations of `&&` and `||` operators

```jldoctest shortcirc
julia> t(1) && t(2) || println(3) # the first two expressions are evaluated
1
2
true

julia> f(1) && t(2) || println(3) # the first and the last expressions are evaluated
1
3

julia> f(1) && f(2) || println(3) # the first and the last expressions are evaluated
1
3

julia> t(1) && f(2) || println(3) # all expressions are evaluated
1
2
3

julia> t(1) || t(2) && println(3) # the first expression is evaluated
1
true

julia> f(1) || t(2) && println(3) # all expressions are evaluated
1
2
3

julia> f(1) || f(2) && println(3) # the first two expressions are evaluated
1
2
false

julia> t(1) || f(2) && println(3) # the first expression is evaluated
1
true
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Rewrite the factorial function from the exercises in the first section. Use short-circuit evaluation to check if the given number is a non-negative integer and ternary operator for recursion.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Since we want to check if the input number is a non-negative integer, we need to check two conditions. It can be done separately using short-circuit evaluation

```julia
function fact(n)
    isinteger(n) || error("argument must be non-negative integer")
    n >= 0 || error("argument must be non-negative integer")
    return n == 0 ? 1 : n * fact(n - 1)
end
```

However, it can be even simplified, if we combine `&&` and `||` operators as follows

```jldoctest shortcirc_ex; output = false
function fact(n)
    isinteger(n) && n >= 0 || error("argument must be non-negative integer")
    return n == 0 ? 1 : n * fact(n - 1)
end

# output
fact (generic function with 1 method)
```

Since `&&` has higher precedence than `||`, the first expression that is evaluated is `isinteger(n) && n >= 0`. The error is thrown only if this condition does not hold. We can easily check that this function works the same as the `fact` function from the first section

```jldoctest shortcirc_ex
julia> fact(4)
24

julia> fact(0)
1

julia> fact(-5)
ERROR: argument must be non-negative integer

julia> fact(1.4)
ERROR: argument must be non-negative integer
```

```@raw html
</p></details>
```
