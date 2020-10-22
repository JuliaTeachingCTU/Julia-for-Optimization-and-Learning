# Variables

A variable, in Julia, is a name associated (or bound) to a value. It's useful when you want to store a value (that you obtained after some math, for example) for later use

```jldoctest var_declaration
julia> x = 10
10
```

Here `x` contains an integer. Type of the variable can be checked using `typeof` function

```jldoctest var_declaration
julia> typeof(x)
Int64
```

Contrary to other programming languages like C++ and similarly to Python, Julia can infer the type of the object on the right side of the equal sign, so there is no need to specify the type of the variable as you would do in C++.

Julia provides an extremely flexible system for naming variables. Variable names are case-sensitive, and have no semantic meaning (that is, the language will not treat variables differently based on their names).

```jldoctest
julia> I_am_float = 3.1415
3.1415

julia> typeof(I_am_float)
Float64

julia> CALL_ME_RATIONAL = 1//3
1//3

julia> typeof(CALL_ME_RATIONAL)
Rational{Int64}

julia> MyString = "MyVariable"
"MyVariable"

julia> typeof(MyString)
String
```

Here `I_am_float` contains a floating point number, `CALL_ME_RATIONAL` is a rational number (can be used, if the exact accuracy is needed) and `MyString` contains a string (a piece of text).

Moreover, in the Julia REPL and several other Julia editing environments, you can type many Unicode (UTF-8 encoding) math symbols by typing the backslashed $\LaTeX$ symbol name followed by tab. You can also type many other non-math symbols. For example, the variable name `δ` can be entered by typing `\delta<tab>`

```jldoctest
julia> δ = 1
1
```

or pizza symbol `🍕` can be entered by typing `\:pizza:<tab>`

```jldoctest
julia> 🍕 = "It's time for pizza!!!"
"It's time for pizza!!!"
```

If you find a symbol somewhere, e.g. in someone else's code, that you don't know how to type, the REPL help will tell you: just type `?` and then paste the symbol (works only for basic $\LaTeX$ symbols)

```julia
help?> α
"α" can be typed by \alpha<tab>
[...]
```

[Here](https://docs.julialang.org/en/v1/manual/unicode-input/) is the list of all Unicode characters that can be entered via tab completion of $\LaTeX$-like abbreviations in the Julia REPL

If necessary, it is also possible to reassign the value of a variable

```jldoctest
julia> x = 10
10

julia> typeof(x)
Int64

julia> x = "1.0"
"1.0"

julia> typeof(x)
String
```

Julia will even let you redefine built-in constants and functions if needed (although this is not recommended to avoid potential confusions)

```jldoctest
julia> π = 2
2

julia> π
2
```

However, if you try to redefine a built-in constant or function already in use, Julia will give you an error (`ℯ` can be typed as `\euler<tab>`)

```jldoctest
julia> ℯ
ℯ = 2.7182818284590...

julia> ℯ = 3
ERROR: cannot assign a value to variable MathConstants.ℯ from module Main
[...]
```

The only explicitly disallowed names for variables are the names of built-in statements:

```jldoctest
julia> end = 4
ERROR: syntax: unexpected "end"
[...]
```

While there are almost no restrictions on valid names in Julia, it is useful to adopt the following conventions:
- Names of variables are in lower case.
- Word separation can be indicated by underscores ('_'), but use of underscores is discouraged unless the name would be hard to read otherwise.
For more information about stylistic conventions, see the [Style Guide](https://docs.julialang.org/en/v1/manual/style-guide/#Style-Guide-1) or [Blue Style](https://github.com/invenia/BlueStyle).

!!! tip "Exercise:"


!!! compat "Solution:"
