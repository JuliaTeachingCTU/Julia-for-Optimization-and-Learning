# Operators and basic functions

# Arithmetic operators
The following arithmetic operators are supported on all primitive numeric types:

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

Here are some simple examples using arithmetic operators:

```jldoctest
julia> 1 + 2 + 3
6

julia> 1 - 2
-1


julia> 3*2/12
0.5
```

A numeric literal placed directly before an identifier or parentheses is treated as a multiplication (except with higher precedence than other binary operations):

```jldoctest
julia> x = 1
1

julia> 2x
2
```

Julia's promotion system makes arithmetic operations on mixtures of argument types "just work" naturally and automatically:

```jldoctest
julia> x = 1f0 # Float32
1.0f0

julia> y = 2.0 # Float64
2.0

julia> 2(x + y) # Float64
6.0
```

## Updating operators

Every binary arithmetic operator also has an updating version that assigns the result of the operation back into its left operand. The updating version of the binary operator is formed by placing a `=` immediately after the operator. For example, writing `x += 3` is equivalent to writing `x = x + 3`:

```jldoctest
julia> x = 1
1

julia> x += 3
4

julia> x *= 4
16

julia> x /= 2
8.0
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
