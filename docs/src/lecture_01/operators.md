# Operators and basic functions

# Arithmetic operators
The following arithmetic operators are supported on all primitive numeric types:

| Expression | Name           | Description                              |
| :--        | :--            | :--                                      |
| `+x`       | unary plus     | the identity operation                   |
| `-x`       | unary minus    | maps values to their additive inverses   |
| `x + y`    | binary plus    | performs addition                        |
| `x - y`    | binary minus   | performs subtraction                     |
| `x * y`    | times          | performs multiplication                  |
| `x / y`    | divide         | performs division                        |
| `x ÷ y`    | integer divide | `x / y`, truncated to an integer         |
| `x \ y`    | inverse divide | equivalent to `y / x`                    |
| `x ^ y`    | power          | raises `x` to the `y`th power            |
| `x % y`    | remainder      | equivalent to `rem(x,y)`                 |
| `!x`       | negation       | changes `true` to `false` and vice versa |

Here are some simple examples using arithmetic operators:

```@repl
1 + 2 + 3
1 - 2
3*2/12
```

A numeric literal placed directly before an identifier or parentheses is treated as a multiplication (except with higher precedence than other binary operations):

```@repl
x = 1
2x
```

Julia's promotion system makes arithmetic operations on mixtures of argument types "just work" naturally and automatically:

```@repl
x = 1f0 # Float32
y = 2.0 # Float64

2(x + y) # Float64
```

## Updating operators

Every binary arithmetic operator also has an updating version that assigns the result of the operation back into its left operand. The updating version of the binary operator is formed by placing a `=` immediately after the operator. For example, writing `x += 3` is equivalent to writing `x = x + 3`:

```@repl
x = 1
x += 3
x *= 4
x /= 2
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

```@repl
1 == 1
1 == 2
1 == 1.0
-1 <= 1
-1 ≥ 1
```

The last point is potentially surprising and thus worth noting.

```@repl
NaN == NaN
NaN != NaN
NaN < NaN
NaN > NaN
```

Julia provides additional functions to test numbers for special values, which can be useful in situations like hash key comparisons:

| Function        | Tests if                 |
| :--             | :--                      |
| `isequal(x, y)` | `x` and `y` are identical|
| `isfinite(x)`   | `x` is a finite number   |
| `isinf(x)`      | `x` is infinite          |
| `isnan(x)`      | `x` is not a number      |

Function `isequal` considers `NaN`s equal to each other:

```@repl
isequal(NaN, NaN)
isequal(NaN, NaN32)
```

It can also be used to distinguish signed zeros:

```@repl
-0.0 == 0.0
isequal(-0.0, 0.0)
```

Unlike most languages, with the notable exception of Python, comparisons can be arbitrarily chained:

```@repl
1 < 2 <= 2 < 3 == 3 > 2 >= 1 == 1 < 3 != 5
```




!!! tip "Exercise 2: Momentum optimiser"
    Momentum [5] is a method that helps accelerate SGD in the relevant direction and dampens oscillations.
    It does this by adding a fraction ``\gamma`` of the update vector of the past time step to the current update vector:
    ```math
    \begin{aligned}
        v_t    & = \gamma v_{t-1} + \eta \nabla_{\theta}J(\theta) \\
        \theta & = \theta - v_t
    \end{aligned}
    ```
    Write a function that accepts gradient of the objective function and return `v_t`.
    [Solution](@ref solution_ex_2)
