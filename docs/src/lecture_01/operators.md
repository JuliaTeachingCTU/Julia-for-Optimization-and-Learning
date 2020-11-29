# Mathematical operations and Elementary functions

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

In addition to arithmetic and updating operators, basic comparison operators are also defined in Julie's standard libraries.

| Operator  | Name                     |
| :--       | :--                      |
| `==`      | equality                 |
| `!=`, `≠` | inequality               |
| `<`       | less than                |
| `<=`, `≤` | less than or equal to    |
| `>`       | greater than             |
| `>=`, `≥` | greater than or equal to |

All these operators always return boolean value (`true` or `false`) as can be seen in the following example

```@repl
1 == 1
1 == 1.0
-1 <= 1
-1 ≥ 1
```

In most programming languages, comparison operators are strictly binary, i.e. they can be used to compare with only two values at a time. As an example, we can use a comparison of three numbers in Matlab

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

```@repl
3 > 2 > 1
3 > 2 & 2 > 1
```

In fact, comparison operators can be arbitrarily chained as in the following example

```@repl
1 < 2 <= 2 < 3 == 3 > 2 >= 1 == 1 < 3 != 5
```

It may be quite convenient in numerical code, however, it can also easily decrease code readability. So if you want to use such syntax, always take code readability in your consideration.


Comparison of special values such as `NaN` can lead to unexpected behavior

```@repl
NaN == NaN
NaN != NaN
NaN < NaN
```

To avoid unexpected result, Julia provides additional functions to compare numbers for special values

| Function        | Tests if                 |
| :--             | :--                      |
| `isequal(x, y)` | `x` and `y` are identical|
| `isfinite(x)`   | `x` is a finite number   |
| `isinf(x)`      | `x` is infinite          |
| `isnan(x)`      | `x` is not a number      |

Function `isequal` considers `NaN`s equal to each other

```@repl
isequal(NaN, NaN)
!isequal(NaN, NaN)
```

## Rounding functions

| Function   | Description                     |
| :--        | :--                             |
| `round(x)` | round `x` to the nearest integer|
| `floor(x)` | round `x` towards `-Inf`        |
| `ceil(x)`  | round `x` towards `+Inf`        |
| `trunc(x)` | round `x` towards `zero`        |

All these functions can be used without a specified output type. In such a case, the output will have the same type as the input variable

```@repl rounding
x = 3.1415
round(x)
floor(x)
ceil(x)
```
However, in many cases, it makes sense to convert the rounded value to an integer. To do this, we can simply pass the appropriate integer type as the first argument

```@repl rounding
round(Int64, x)
floor(Int32, x)
ceil(Int16, x)
```

All rounding functions also support additional keyword arguments:
- If the `digits` keyword argument is provided, it rounds to the specified number of digits after the decimal place (or before if negative), in base specifide by `base` keyword argument.
- If the `sigdigits` keyword argument is provided, it rounds to the specified number of significant digits, in base specifide by `base` keyword argument.

```@repl rounding
round(x; digits = 3)
round(x; sigdigits = 3)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Use rounding operators to solve the following tasks
- Round `1252.1518` to the nearest larger integer and convert the resulting value to `Int64`.
- Round `1252.1518` to the nearest smaller integer and convert the resulting value to `Int16`.
- Round `1252.1518` to `2` digits after the decimal place.
- Round `1252.1518` to `3` significant digits.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@repl
x = 1252.1518
ceil(Int64, x)
floor(Int16, x)
round(x; digits = 2)
round(x; sigdigits = 3)
```

```@raw html
</p></details>
```

## Numerical Conversions

As was shown in the previous section, the numerical conversion can be done using rounding functions with a specified type of output variable. However, it only works for converting floating-point numbers to integers. Julia also provides a more general way how to perform the numerical conversion: the notation `T(x)` or `convert(T,x)` converts `x` to a value of type `T`.
- If `T` is a floating-point type, the result is the nearest representable value, which could be positive or negative infinity.
- If `T` is an integer type, an `InexactError` is raised if `x` is not representable by `T`.

```@repl
convert(Float32, 1.234)
Float32(1.234)
convert(Float64, 1)
Float64(1)
convert(Int64, 1.234)
Int64(1.234)
```
