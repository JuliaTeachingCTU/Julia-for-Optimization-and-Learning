# Basic operators

## Arithmetic operators

Basic arithmetic operations are defined in Julia standard libraries and all these operators are supported on all primitive [numeric types](@ref Primitive-numeric-types)

| Expression | Name           | Description                              |
| :--        | :--            | :--                                      |
| `x + y`    | binary plus    | performs addition                        |
| `x - y`    | binary minus   | performs subtraction                     |
| `x * y`    | times          | performs multiplication                  |
| `x / y`    | divide         | performs division                        |
| `x ÷ y`    | integer divide | `x / y`, truncated to an integer         |
| `x \ y`    | inverse divide | equivalent to `y / x`                    |
| `x ^ y`    | power          | raises `x` to the `y`th power            |
| `x % y`    | remainder      | equivalent to `rem(x,y)`                 |

Here are some simple examples using arithmetic operators

```@repl
1 + 2
2*3
4/3
```

All of these operators can be also applied directly to any variable that represents numeric value

```@repl
x = 1;
y = 3;
(x + 2)/(y - 1) - 4*(x - 2)^2
```

A numeric literal placed directly before an identifier or parentheses is treated as a multiplication (except with higher precedence than other binary operations):

```@repl
2(3 + 4) # equivalent to 2*(3 + 4)
```



```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

What is the value and type of `y` given by the following expression
```math
y = \frac{(x + 2)^2 - 4}{(x - 2)^{p - 2}},
```
where `x = 4` and `p = 5`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

First, we define variables `x` and `p`
```@repl ex1
x = 4
p = 5
```
and then we can simply use the combination of basic arithmetic operators to compute the value of `y`
```@repl ex1
y = ((x + 2)^2 - 4)/(x - 2)^(p - 2)
```
The type of `y` can be determined using `typeof` function
```@repl ex1
typeof(y)
```
Note that the resulting type of `y` is `Float64` even though the result can be represented as an integer. The reason is, that we divide two integers

```@repl ex1
typeof((x + 2)^2 - 4)
typeof((x - 2)^(p - 2))
```
Because this operation generally does not result in an integer, dividing two integers always returns a floating-point number.

```@raw html
</p></details>
```

## Promotion system

As said in the section about [variables](@ref Primitive-numeric-types), there are many numeric types in Julia. To ensure that the correct type is always used, Julia has a promotion system that converts input values of mixed types to a type that can correctly represent all values. This can be done by `promote` function. As an example, we can mention the conversion of multiple numeric types

```@repl promotion
x = 1.0 # Float64
y = 2 # Int64
xp, yp = promote(x, y)
```

In this case, the resulting type of variables `xp` and `yp` is `Float64` as can be chcked using `typeof` function

```@repl promotion
typeof(xp)
typeof(yp)
```

even though strictly, not all `Int64` values can be represented exactly as `Float64` values. The promotion system generally tries to return a type that can at least approximate most values of either input type without excessively widening.

Note, that `promotion` function will accept any number of input arguments

```@repl
promote(1, 2f0, true, 4.5, Int32(1))
```

The resulting type of promotion can be determined by `promotion_type` function. This function is similar to `promote` function and will accept any number of input arguments, but the inputs have to be types and not values.

```@repl
promote_type(Float64, Int64, Bool, Int32)
```

Although this may seem complicated, type promotion is done automatically in most cases and the user does not have to worry about it. This can be demonstrated in the following example, where we sum two values. The first one is of type `Int64` and the second one of type `Float32`.

```@repl promotion2
x = 1 # Int64
y = 2f0 # Float32
```

Since the "smallest" type that can represent both values correctly is `Float32`, the result is of type `Float32`

```@repl promotion2
z = x + y
typeof(z)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

What is the smallest type, that can represent the following values
```@example promotion3
x = 1
y = 2f0
z = true
w = Int32(1)
nothing # hide
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
To get the smallest promotion type, we can use a combination of `promote` and `typeof` function

```@repl promotion3
xp, yp, zp, wp = promote(x, y, z, w)
typeof(xp)
```

or a combination of `promote_type` and `typeof` function

```@repl promotion3
promote_type(typeof(x), typeof(y), typeof(z), typeof(w))
```

```@raw html
</p></details>
```

## Updating operators

Every binary arithmetic operator also has an updating version that assigns the result of the operation back into its left operand. The updating version of the binary operator is formed by placing a `=` immediately after the operator. For example, writing `x += 3` is equivalent to writing `x = x + 3`:

```@repl
x = 1
x += 3 # x = x + 3
x *= 4 # x = x * 4
x /= 2 # x = x / 2
x \= 16 # x = x \ 16 = 16 / x
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Compute the value of `y` given by the following expression
```math
y = \frac{(x + 4)^{\frac{3}{2}}}{(x + 1)^{p - 1}},
```
where `x = 5` and `p = 3`. Then multiply the result by `8`, add `3`, divide by `3`, and subtract `1`. What are all the intermediate results and the final result?

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

First, we calculate the value of `y`

```@repl ex2
x = 5;
p = 3;
y = (x + 4)^(3/2)/(x + 1)^(p - 1)
```

Then we can use the update operators to get all the intermediate results as well as the final result

```@repl ex2
y *= 8
y += 3
y /= 3
y -= 1
```

```@raw html
</p></details>
```

## Numeric comparison

| Operator  | Name                     |
| :--       | :--                      |
| `==`      | equality                 |
| `!=`, `≠` | inequality               |
| `<`       | less than                |
| `<=`, `≤` | less than or equal to    |
| `>`       | greater than             |
| `>=`, `≥` | greater than or equal to |

Here are some simple examples:

```jldoctest
julia> 1 == 1
true

julia> 1 == 2
false

julia> 1 == 1.0
true

julia> -1 <= 1
true

julia> -1 ≥ 1
false
```

The last point is potentially surprising and thus worth noting.

```jldoctest
julia> NaN == NaN
false

julia> NaN != NaN
true

julia> NaN < NaN
false

julia> NaN > NaN
false
```

Julia provides additional functions to test numbers for special values, which can be useful in situations like hash key comparisons:

| Function        | Tests if                 |
| :--             | :--                      |
| `isequal(x, y)` | `x` and `y` are identical|
| `isfinite(x)`   | `x` is a finite number   |
| `isinf(x)`      | `x` is infinite          |
| `isnan(x)`      | `x` is not a number      |

Function `isequal` considers `NaN`s equal to each other:

```jldoctest
julia> isequal(NaN, NaN)
true

julia> isequal(NaN, NaN32)
true
```

It can also be used to distinguish signed zeros:

```jldoctest
julia> -0.0 == 0.0
true

julia> isequal(-0.0, 0.0)
false
```

Unlike most languages, with the notable exception of Python, comparisons can be arbitrarily chained:

```jldoctest
julia> 1 < 2 <= 2 < 3 == 3 > 2 >= 1 == 1 < 3 != 5
true
```
