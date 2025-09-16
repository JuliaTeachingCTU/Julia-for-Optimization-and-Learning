# Conditional evaluations

This lecture handles control flow. The first part focuses on `if` conditions and the second one of loops.

## `if-elseif-else` statement

In many cases, we have to decide what to do for different conditions. Julia supports the standard `if-elseif-else` syntax, which determines which part of the code will be evaluated. This depends on the logical expression value. For example, the following function compares two numerical values.

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

If the expression `x < y` is true, the function prints *"x is less than y"*, otherwise, the expression `x > y` is evaluated, and if it is true, the function prints *"x is greater than y"*. If neither expression is true, the function prints the remaining option *"x is equal to y"*.

```jldoctest conditions
julia> compare(1, 2.3)
x is less than y

julia> compare(4.7, 2.3)
x is greater than y

julia> compare(2.3, 2.3)
x is equal to y
```

The `elseif` and `else` keywords are optional. Moreover, it is possible to use as many `elseif` blocks as needed.

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

The conditions in the `if-elseif-else` construction are evaluated until the first one is `true`. The associated block is then evaluated, and no other condition expressions or blocks are evaluated.

In contrast to languages like Python or Matlab, the logical expression in the `if-elseif-else` statement must always return a boolean value. Otherwise, an error will occur.

```jldoctest
julia> if 1
           println("Hello")
       end
ERROR: TypeError: non-boolean (Int64) used in boolean context
[...]
```

The `if` blocks do not introduce a [local scope](https://docs.julialang.org/en/v1/manual/variables-and-scoping/), i.e., it is possible to introduce a new variable inside the `if` block and use this variable outside the block.

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

However, it is necessary to ensure that the variable is always declared in all cases.

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

The function defined above works only for numbers which are not equal.

```jldoctest conditions
julia> compare(1, 2.3)
2.3

julia> compare(4.7, 2.3)
4.7

julia> compare(2.3, 2.3)
ERROR: UndefVarError: `z` not defined
[...]
```

The `if` blocks always return a value equal to the last expression evaluated in the `if` block. In other words, it is possible to assign the value returned by the `if` block to a new variable.

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

In the example above, the variable `z` equals `y` if the expression` x < y` evaluates as `true`. Otherwise, the variable `z` equals` x`.

```jldoctest conditions
julia> compare(1, 2.3)
2.3

julia> compare(4.7, 2.3)
4.7

julia> compare(2.3, 2.3)
2.3
```

!!! warning "Exercise:"
    Write the `fact(n)` function that computes the factorial of `n`. Use the following function declaration:

    ```julia
    function fact(n)
        # some code
    end
    ```

    Make sure that the input argument is a non-negative integer. For negative input arguments and for arguments that can not be represented as an integer, the function should throw an error.

    **Hint:** use recursion, the `isinteger` function and the `error` function. The or operator is written as `|`.

!!! details "Solution:"
    We split the solution into three cases:
    1. If `n` is smaller than zero or not an integer, we throw an error.
    2. If `n` is equal to zero, the function returns `1`.
    3. If `n` is a positive integer, we use recursion.

    ```jldoctest conditions_ex; output = false
    function fact(n)
        return if n < 0 | !isinteger(n)
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

    Since the `if` block returns a value from the latest evaluated expression, it is possible to use it after the `return` keyword to define the function output. However, it is also possible to omit the `return` keyword since functions return the last evaluated expression if the `return` keyword is not used.

    ```jldoctest conditions_ex
    julia> fact(4)
    24

    julia> fact(0)
    1

    julia> fact(-5)
    ERROR: argument must be non-negative integer
    [...]

    julia> fact(1.4)
    ERROR: argument must be non-negative integer
    [...]
    ```

## Ternary operator

The [ternary operator](https://en.wikipedia.org/wiki/%3F:) `?` is closely related to the `if-else` statement. It can instead be used to decide between two simple options. The syntax is the following:

```julia
a ? b : c
```

which can be read as *"if `a` is true, then evaluate `b`; otherwise, evaluate `c`"*. The white spaces around `?` and `:` are mandatory.

```jldoctest
julia> x, y = 2, 1;

julia> println(x < y ? "x is less than y" : "x is greater than or equal to y")
x is greater than or equal to y
```

In this case, there are two possibilities:
- if `x < y` is true, then the string `"x is less than y"` is returned,
- if `x < y` is false, then the string `"x is greater than or equal to y"` is returned.
Since we wrapped the whole expression into the `println` function, the ternary operator output is printed.

## Short-circuit evaluation

Julia provides the so-called short-circuit evaluation which is similar to the conditional evaluation. The behaviour exists in most imperative programming languages, which have the `&&` and `||` boolean operators. In a series of boolean expressions connected by these operators, only the minimal number of expressions is evaluated  to determine the final boolean value of the entire chain:
- In the expression `a && b`, the subexpression `b` is only evaluated if `a` evaluates true.
- In the expression `a || b`, the subexpression `b` is only evaluated if `a` evaluates to false.

To investigate this behavior, let's define the following two functions:

```jldoctest shortcirc; output = false
t(x) = (println(x); true)
f(x) = (println(x); false)

# output
f (generic function with 1 method)
```

The `t` function prints `x` and returns true. Similarly, the `f` function prints `x` and returns false. Using these two functions, we can easily determine which expressions are evaluated when using short-circuit evaluation.

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

!!! info "Short-circuit evaluation vs. bitwise boolean operators:"
    Boolean operations without short-circuit evaluation can be done with the bitwise boolean operators `&` and `|` introduced in [previous lecture](@ref Numeric-comparison). These are normal functions, which happen to support infix operator syntax, but always evaluate their arguments.

    ```jldoctest shortcirc
    julia> f(1) & t(2)
    1
    2
    false

    julia> f(1) && t(2)
    1
    false
    ```

When multiple `&&` and `||` are chained together, `&&` has a higher precedence than `||`. For example, `a || b && c && d || e` is equivalent to `a || (b && c && d) || e`.

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

!!! warning "Exercise:"
    Rewrite the factorial function from the exercises above. Use the short-circuit evaluation to check if the given number is a non-negative integer and the ternary operator for recursion.

!!! details "Solution:"
    Since we want to check if the input number is a non-negative integer, we need to check two conditions. It can be done separately by the short-circuit evaluation.

    ```julia
    function fact(n)
        isinteger(n) || error("argument must be non-negative integer")
        n >= 0 || error("argument must be non-negative integer")
        return n == 0 ? 1 : n * fact(n - 1)
    end
    ```

    This can be further simplified by combining the `&&` and `||` operators.

    ```jldoctest shortcirc_ex; output = false
    function fact(n)
        isinteger(n) && n >= 0 || error("argument must be non-negative integer")
        return n == 0 ? 1 : n * fact(n - 1)
    end

    # output
    fact (generic function with 1 method)
    ```

    Since `&&` has higher precedence than `||`, the error function is evaluated only if `isinteger(n) && n >= 0` is violated. We can then check that this function works the same as the `fact` function from above.

    ```jldoctest shortcirc_ex
    julia> fact(4)
    24

    julia> fact(0)
    1

    julia> fact(-5)
    ERROR: argument must be non-negative integer
    [...]

    julia> fact(1.4)
    ERROR: argument must be non-negative integer
    [...]
    ```