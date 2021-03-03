## Arithmetic operators

Basic arithmetic operations are defined in Julia standard libraries, and all these operators are supported on all primitive [numeric types](@ref Primitive-numeric-types)

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

```jldoctest
julia> 1 + 2
3

julia> 2*3
6

julia> 4/3
1.3333333333333333
```

All of these operators can also be applied directly to any variable that represents a numeric value

```jldoctest
julia> x = 1;

julia> y = 3;

julia> (x + 2)/(y - 1) - 4*(x - 2)^2
-2.5
```

Note that we use a semicolon after some expressions. In the REPL, if we evaluate any expression, its result is printed. If we use the semicolon, the output is omitted. It is similar behaviour as in Matlab, but in Julia, the printing is automatic only in the REPL.

A numeric literal placed directly before an identifier or parentheses is treated as multiplication

```jldoctest
julia> 2(3 + 4) # equivalent to 2*(3 + 4)
14
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Determine the value and type of `y` given by the following expression

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

```jldoctest ex1
julia> x = 4
4

julia> p = 5
5
```

then we can use the combination of basic arithmetic operators to compute the value of `y`

```jldoctest ex1
julia> y = ((x + 2)^2 - 4)/(x - 2)^(p - 2)
4.0
```

The type of `y` can be determined using the `typeof` function

```jldoctest ex1
julia> typeof(y)
Float64
```

Note that the resulting type of `y` is `Float64` even though the result can be represented as an integer. The reason is that we divide two integers

```jldoctest ex1
julia> typeof((x + 2)^2 - 4)
Int64

julia> typeof((x - 2)^(p - 2))
Int64
```

Because this operation generally does not result in an integer, dividing two integers always returns a floating-point number. If we want to get an integer, we can use the integer division operator `÷` (can be typed as `\div<tab>`)

```jldoctest ex1
julia> y_int = ((x + 2)^2 - 4)÷(x - 2)^(p - 2)
4

julia> typeof(y_int)
Int64
```

```@raw html
</p></details>
```

## Promotion system

The section about [variables](@ref Primitive-numeric-types) showed that there are many numeric types in Julia. To ensure that the correct type is always used, Julia has a promotion system that converts input values of mixed types to a type that can correctly represent all values. The promotion of mixed type variables can be done manually using the `promote` function. As an example, we can mention the promotion of multiple numeric types

```jldoctest promotion
julia> x = 1.0 # Float64
1.0

julia> y = 2 # Int64
2

julia> xp, yp = promote(x, y)
(1.0, 2.0)
```

In this case, the resulting type of variables `xp` and `yp` is `Float64` as can be checked using the `typeof` function

```jldoctest promotion
julia> typeof(xp)
Float64

julia> typeof(yp)
Float64
```

Strictly speaking, not all `Int64` values can be represented exactly as `Float64` values. The promotion system generally tries to return a type that approximates well most values of either input type.

The `promote` function accepts any number of input arguments

```jldoctest
julia> promote(1, 2f0, true, 4.5, Int32(1))
(1.0, 2.0, 1.0, 4.5, 1.0)
```

The resulting type of promotion can be determined by the `promotion_type` function. This function is similar to the `promote` function and will accept any number of input arguments, but the inputs have to be types and not values

```jldoctest
julia> promote_type(Float64, Int64, Bool, Int32)
Float64
```

Although this may seem complicated, type promotion is done automatically in most cases, and the user does not have to worry about it. To demonstrate the promotion system in practice, consider the following example: we sum the value of type `Int64` with the value of type `Float32`

```jldoctest promotion2
julia> x = 1 # Int64
1

julia> y = 2f0 # Float32
2.0f0
```

Since the "smallest" type that can represent both values correctly is `Float32`, the result is of type `Float32`

```jldoctest promotion2
julia> z = x + y
3.0f0

julia> typeof(z)
Float32
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

All of these values represent number ``1``. Determine the smallest type which can represent them.

```jldoctest promotion3; output = false
x = 1
y = 1f0
z = true
w = Int32(1)

# output
1
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

To get the correct promotion type, we can use a combination of the `promote` and `typeof` functions

```jldoctest promotion3
julia> xp, yp, zp, wp = promote(x, y, z, w)
(1.0f0, 1.0f0, 1.0f0, 1.0f0)

julia> typeof(xp)
Float32
```

or the `promote_type` and `typeof` functions

```jldoctest promotion3
julia> promote_type(typeof(x), typeof(y), typeof(z), typeof(w))
Float32
```

```@raw html
</p></details>
```

## Updating operators

Every binary arithmetic operator also has an updating version that assigns the operation's result back into its left operand. The updating version of the binary operator is formed by placing a `=` symbol immediately after the operator. For example, writing `x += 3` is equivalent to writing `x = x + 3`

```jldoctest
julia> x = 1
1

julia> x += 3 # x = x + 3
4

julia> x *= 4 # x = x * 4
16

julia> x /= 2 # x = x / 2
8.0

julia> x \= 16 # x = x \ 16 = 16 / x
2.0
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

```jldoctest ex2
julia> x = 5;

julia> p = 3;

julia> y = (x + 4)^(3/2)/(x + 1)^(p - 1)
0.75
```

Then we can use the update operators to get all the intermediate results as well as the final result

```jldoctest ex2
julia> y *= 8
6.0

julia> y += 3
9.0

julia> y /= 3
3.0

julia> y -= 1
2.0
```

```@raw html
</p></details>
```

## Numeric comparison

In addition to arithmetic and updating operators, basic comparison operators are also defined in Julia's standard libraries.

| Operator  | Name                     |
| :--       | :--                      |
| `==`      | equality                 |
| `!=`, `≠` | inequality               |
| `<`       | less than                |
| `<=`, `≤` | less than or equal to    |
| `>`       | greater than             |
| `>=`, `≥` | greater than or equal to |
| `&`       | bitwise and              |
| `\|`      | bitwise or               |

All these operators always return a boolean value (`true` or `false`) as the following example shows

```jldoctest
julia> 1 == 1
true

julia> 1 == 1.0
true

julia> -1 <= 1
true

julia> -1 ≥ 1
false
```

In most programming languages, comparison operators are strictly binary, i.e., they can be used to compare only two values at a time. As an example, we can use a comparison of three numbers in Matlab

```matlab
>> 3 > 2 > 1

ans =

  logical

   0
```

Even though the condition holds, the result is `false` (logical `0`). The correct way to write such a condition in Matlab is as follows

```matlab
>> 3 > 2 & 2 > 1

ans =

  logical

   1
```

In Julia (and Python, for example), both ways of writing conditions are correct and lead to the same result

```jldoctest
julia> 3 > 2 > 1
true

julia> 3 > 2 & 2 > 1
true
```

In fact, comparison operators can be arbitrarily chained as in the following example

```jldoctest
julia> 1 < 2 <= 2 < 3 == 3 > 2 >= 1 == 1 < 3 != 5
true
```

In general, the user should always try to write code that is easy to read. Even though writing expressions as in the example above is possible, the user should always consider if it is necessary.

Comparison of special values such as `NaN` can lead to unexpected behaviour

```jldoctest
julia> NaN == NaN
false

julia> NaN != NaN
true

julia> NaN < NaN
false
```

To avoid unexpected result, Julia provides additional functions to compare numbers for special values

| Function        | Tests if                 |
| :--             | :--                      |
| `isequal(x, y)` | `x` and `y` are identical|
| `isfinite(x)`   | `x` is a finite number   |
| `isinf(x)`      | `x` is infinite          |
| `isnan(x)`      | `x` is not a number      |

Function `isequal` considers `NaN`s equal to each other

```jldoctest
julia> isequal(NaN, NaN)
true

julia> !isequal(NaN, NaN)
false
```

We used the operator `!` to negate the output of the `isequal` function in the example above. This operator is called boolean not and can be used to negate boolean values

```jldoctest
julia> !true
false

julia> !false
true
```

## Rounding functions

Julia provides several functions for rounding numbers, as can be seen in the following table

| Function   | Description                     |
| :--        | :--                             |
| `round(x)` | round `x` to the nearest integer|
| `floor(x)` | round `x` towards `-Inf`        |
| `ceil(x)`  | round `x` towards `+Inf`        |
| `trunc(x)` | round `x` towards `zero`        |

These functions can be used without specifying output types. In such a case, the output has the same type as the input variable

```jldoctest rounding
julia> x = 3141.5926
3141.5926

julia> round(x)
3142.0

julia> floor(x)
3141.0

julia> ceil(x)
3142.0
```

However, in many cases, it makes sense to convert the rounded value to a different type. For example, if the rounded value can be represented as an integer, it makes sense to convert the rounded value to an integer. The output type (only subtypes of `Integer` with the exception of `Bool`) can be passed as the first argument to all rounding functions from the table above

```jldoctest rounding
julia> round(Int64, x)
3142

julia> floor(Int32, x)
3141

julia> ceil(Int16, x)
3142
```

All rounding functions also support additional keyword arguments:
- If the `digits` keyword argument is provided, it rounds to the specified number of digits after the decimal place in the base specified by the `base` keyword argument.

```jldoctest rounding
julia> round(x; digits = 3)
3141.593
```
- If the `sigdigits` keyword argument is provided, it rounds to the specified number of significant digits in the base specified by the `base` keyword argument.

```jldoctest rounding
julia> round(x; sigdigits = 3)
3140.0
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use rounding functions to solve the following tasks:
- Round `1252.1518` to the nearest larger integer and convert the resulting value to `Int64`.
- Round `1252.1518` to the nearest smaller integer and convert the resulting value to `Int16`.
- Round `1252.1518` to `2` digits after the decimal point.
- Round `1252.1518` to `3` significant digits.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The `ceil` function rounds numbers to the nearest larger value, and since we want the result to be of type `Int64`, we have to pass this type as a first argument

```jldoctest rounding_ex
julia> x = 1252.1518
1252.1518

julia> ceil(Int64, x)
1253
```

Similarly, the floor function rounds numbers to the nearest smaller value

```jldoctest rounding_ex
julia> floor(Int16, x)
1252
```

The number of digits after the decimal point can be controlled using the `digits` keyword

```jldoctest rounding_ex
julia> round(x; digits = 2)
1252.15
```

and the number of significant digits using the `sigdigits` keyword

```jldoctest rounding_ex
julia> round(x; sigdigits = 3)
1250.0
```

```@raw html
</p></details>
```

## Numerical conversions

The previous section showed that numerical conversions could be done by using rounding functions with a specified type of output variable. This works only for converting floating-point numbers to integers. Julia also provides a more general way of how to perform conversions between different (not only numerical) types: notation `T(x)` or `convert(T,x)` converts `x` to a value of type `T`.
- If `T` is a floating-point type, the result is the nearest representable value, which could be positive or negative infinity

```jldoctest
julia> convert(Float32, 1.234)
1.234f0

julia> Float32(1.234)
1.234f0
```

- If `T` is an integer type, an `InexactError` is raised if `x` is not representable by `T`

```jldoctest
julia> convert(Int64, 1.0)
1

julia> Int64(1.0)
1

julia> convert(Int64, 1.234)
ERROR: InexactError: Int64(1.234)
[...]

julia> Int64(1.234)
ERROR: InexactError: Int64(1.234)
[...]
```

Conversion to other types works in a similar way.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use the proper numeric conversion to get the correct result (not approximate) of summing the following two numbers

```jldoctest conversion_ex; output = false
x = 1//3
y = 0.5

# output
0.5
```

**Hint:** rational numbers can be summed without approximation.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Firstly, we can try just to sum the given numbers

```jldoctest conversion_ex
julia> x + y
0.8333333333333333
```

The result of this operation is a floating-point number. However, in this specific case, we have a rational number and a floating-point number that can also be represented as a rational number. The exact result can be obtained by converting the variable `y` to a rational number

```jldoctest conversion_ex
julia> x + Rational(y)
5//6
```

```@raw html
</p></details>
```
