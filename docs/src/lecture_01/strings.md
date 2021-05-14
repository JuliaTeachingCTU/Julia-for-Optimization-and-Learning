# Strings

In Julia, as in other programming languages, a string is a sequence of one or more characters and can be created using quotes.

```jldoctest strings
julia> str = "Hello, world."
"Hello, world."
```

The strings are immutable and, therefore, cannot be changed after creation. However, it is simple to create a new string from parts of existing strings. Individual characters of a string can be accessed via square brackets and indices (the same syntax as for [arrays](@ref Vectors)).

```jldoctest strings
julia> str[1] # returns the first character
'H': ASCII/Unicode U+0048 (category Lu: Letter, uppercase)
```

The return type, in this case, is a `Char`.

```jldoctest strings
julia> typeof(str[1])
Char
```

A `Char` value represents a single character. It is just a 32-bit primitive type with a special literal representation and appropriate arithmetic behaviour. Chars can be created using an apostrophe.

```jldoctest
julia> 'x'
'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)
```

It is also possible to convert characters to a numeric value representing a Unicode and vice versa.

```jldoctest
julia> Int('x')
120

julia> Char(120)
'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)
```

Substrings from the existing string can be extracted via square brackets. The indexing syntax is similar to the one for [arrays](@ref Vectors).

```jldoctest strings
julia> str[1:5] # returns the first five characters
"Hello"

julia> str[[1,2,5,6]]
"Heo,"
```

We used the range `1:5` to access the first five elements of the string (further details on ranges are given in the section on [arrays](@ref Vectors)). Be aware that the expressions `str[k]` and `str[k:k]` do not give the same results.

```jldoctest strings
julia> str[1] # returns the first character as Char
'H': ASCII/Unicode U+0048 (category Lu: Letter, uppercase)

julia> str[1:1] # returns the first character as String
"H"
```

When using strings, we have to pay attention to following characters with special meaning: `\`, `"` and `$`. In order to use them as regular characters, they need to be escaped with a backslash (`\`). For example, unescaped double quote (`"`) would end the string prematurely, forcing the rest being interpreted as Julia code. This is a common malicious attack vector called [code injection](https://en.wikipedia.org/wiki/Code_injection).

```jldoctest strings
julia> str1 = "This is how a string is created: \"string\"."
"This is how a string is created: \"string\"."
```

Similarly, the dollar sign is reserved for string interpolation (it will be explained soon). If we want to use it as a character, we have to use a backslash too.

```jldoctest strings
julia> str2 = "\$\$\$ dollars everywhere \$\$\$"
"\$\$\$ dollars everywhere \$\$\$"
```

```jldoctest strings
julia> "The $ will be fine."
ERROR: syntax: invalid interpolation syntax: "$ "
```

No, they won't. Not escaping characters will result in an error.
Printing of strings can be done by the `print` function or the `println` function that also add a new line at the end of the string.

```jldoctest strings
julia> println(str1)
This is how a string is created: "string".

julia> println(str2)
$$$ dollars everywhere $$$
```

There is one exception to using quotes inside a string: quotes without backslashes can be used in multi-line strings. Multi-line strings can be created using triple quotes syntax as follows:

```jldoctest strings
julia> mstr = """
       This is how a string is created: "string".
       """
"This is how a string is created: \"string\".\n"

julia> print(mstr)
This is how a string is created: "string".
```

This syntax is usually used for docstring for functions. It will have the same form after printing it in the REPL.

```jldoctest
julia> str = """
             Hello,
             world.
           """
"  Hello,\n  world.\n"

julia> print(str)
  Hello,
  world.
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Create a string with the following text
> Quotation is the repetition or copy of someone else's statement or thoughts. \
> Quotation marks are punctuation marks used in text to indicate a quotation. \
> Both of these words are sometimes abbreviated as "quote(s)".
and print it into the REPL. The printed string should look the same as the text above, i.e., each sentence should be on a separate line. Use an indent of length 4 for each sentence.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

There are two basic ways to get the right result. The first is to use a multi-line string and write the message in the correct form.

```jldoctest
julia> str = """
           Quotation is the repetition or copy of someone else's statement or thoughts.
           Quotation marks are punctuation marks used in text to indicate a quotation.
           Both of these words are sometimes abbreviated as "quote(s)".
       """;

julia> println(str)
    Quotation is the repetition or copy of someone else's statement or thoughts.
    Quotation marks are punctuation marks used in text to indicate a quotation.
    Both of these words are sometimes abbreviated as "quote(s)".
```

We do not have to add backslashes to escape quotation marks in the text. The second way is to use a regular string and the new line symbol `\n`. In this case, it is necessary to use backslashes to escape quotation marks. Also, we have to add four spaces before each sentence to get a proper indentation.

```jldoctest
julia> str = "    Quotation is the repetition or copy of someone else's statement or thoughts.\n    Quotation marks are punctuation marks used in text to indicate a quotation.\n    Both of these words are sometimes abbreviated as \"quote(s)\".";

julia> println(str)
    Quotation is the repetition or copy of someone else's statement or thoughts.
    Quotation marks are punctuation marks used in text to indicate a quotation.
    Both of these words are sometimes abbreviated as "quote(s)".
```

```@raw html
</p></details>
```

## String concatenation and interpolation

One of the most common operations on strings is their concatenation. It can be done using the `string` function that accepts any number of input arguments and converts them to a single string.

```jldoctest
julia> string("Hello,", " world")
"Hello, world"
```

Note that it is possible to concatenate strings with numbers and other types that can be converted to strings.

```jldoctest
julia> a = 1.123
1.123

julia> string("The variable a is of type ", typeof(a), " and its value is ", a)
"The variable a is of type Float64 and its value is 1.123"
```

In general, it is not possible to perform mathematical operations on strings, even if the strings look like numbers. However, there are two exceptions. The `*` operator performs string concatenation.

```jldoctest
julia> "Hello," * " world"
"Hello, world"
```

Unlike the `string` function, which works for other types, this approach can only be applied to `String`s. The second exception is the `^` operator, which performs repetition.

```jldoctest
julia> "Hello"^3
"HelloHelloHello"
```

The example above is equivalent to calling the `repeat` function.

```jldoctest
julia> repeat("Hello", 3)
"HelloHelloHello"
```

Using the `string` function to concatenate strings can be cumbersome due to long expressions. To simplify the strings' construction, Julia allows interpolation into string literals with the `$` symbol.

```jldoctest interpolation
julia> a = 1.123
1.123

julia> string("The variable a is of type ", typeof(a), " and its value is ", a)
"The variable a is of type Float64 and its value is 1.123"

julia> "The variable a is of type $(typeof(a)), and its value is $(a)"
"The variable a is of type Float64, and its value is 1.123"
```

We use parentheses to separate expressions that should be interpolated into a string. It is not mandatory, but it can prevent mistakes. In the example below, we can see different results with and without parentheses.

```jldoctest interpolation
julia> "$typeof(a)"
"typeof(a)"

julia> "$(typeof(a))"
"Float64"
```

In the case without parentheses, only the function name is interpolated into the string. In the second case, the expression `typeof(a)` is interpolated into the string literal. It is more apparent when we declare a variable `myfunc` that refers to `typeof` function

```jldoctest interpolation
julia> myfunc = typeof
typeof (built-in function)

julia> "$myfunc(a)"
"typeof(a)"

julia> "$(myfunc(a))"
"Float64"
```

Both concatenation and string interpolation call `string` to convert objects into string form. Most non-`AbstractString` objects are converted to strings closely corresponding to how they are entered as literal expressions.

```jldoctest
julia> v = [1,2,3]
3-element Array{Int64,1}:
 1
 2
 3

julia> "vector: $v"
"vector: [1, 2, 3]"

julia> t = (1,2,3)
(1, 2, 3)

julia> "tuple: $(t)"
"tuple: (1, 2, 3)"
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Print the following message for a given vector
> "<vec> is a vector of length <len> with elements of type <type>"
where `<vec>` is the string representation of the given vector, `<len>` is the actual length of the given vector, and `<type>` is the type of its elements. Use the following two vectors.

```julia
a = [1,2,3]
b = [:a, :b, :c, :d]
```

**Hint:** use the `length` and` eltype` functions.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

We will show two ways how to solve this exercise. The first way is to use the `string` function in combination with the `length` function to get the length of the vector, and the `eltype` function to get the type of its elements.

```jldoctest
julia> a = [1,2,3];

julia> str = string(a, " is a vector of length ",  length(a), " with elements of type ", eltype(a));

julia> println(str)
[1, 2, 3] is a vector of length 3 with elements of type Int64
```

The second way is to use string interpolation.

```jldoctest
julia> b = [:a, :b, :c, :d];

julia> str = "$(b) is a vector of length $(length(b)) with elements of type $(eltype(b))";

julia> println(str)
[:a, :b, :c, :d] is a vector of length 4 with elements of type Symbol
```

```@raw html
</p></details>
```

## Useful functions

A handy function is the `join` function that performs string concatenation. Additionally, it supports defining a custom separator and a different separator for the last element.

```jldoctest
julia> join(["apples", "bananas", "pineapples"], ", ", " and ")
"apples, bananas and pineapples"
```

In many cases, it is necessary to split a given string according to some conditions. In such cases, the `split` function can be used.

```jldoctest joins
julia> str = "JuliaLang is a pretty cool language!"
"JuliaLang is a pretty cool language!"

julia> split(str)
6-element Array{SubString{String},1}:
 "JuliaLang"
 "is"
 "a"
 "pretty"
 "cool"
 "language!"
```

By default, the function splits the given string based on whitespace characters. This can be changed by defining a delimiter.

```jldoctest joins
julia> split(str, " a ")
2-element Array{SubString{String},1}:
 "JuliaLang is"
 "pretty cool language!"
```

Julia also provides multiple functions that can be used to find specific characters or substring in a given string. The `contains` function checks if the string contains a specific substring or character. Similarly, the `occursin` function determines if the specified string or character occurs in the given string. These two functions differ only in the order of arguments.

```jldoctest
julia> contains("JuliaLang is pretty cool!", "Julia")
true

julia> occursin("Julia", "JuliaLang is pretty cool!")
true
```

Another useful function is `endswith`, which checks if the given string ends with the given substring or character. It can be used, for example, to check that the file has a proper suffix.

```jldoctest
julia> endswith("figure.png", "png")
true
```

Sometimes, it is necessary to find indices of characters in the string based on some conditions. For such cases, Julia provides several find functions.

```jldoctest
julia> str = "JuliaLang is a pretty cool language!"
"JuliaLang is a pretty cool language!"

julia> findall(isequal('a'), str)
5-element Array{Int64,1}:
  5
  7
 14
 29
 33

julia> findfirst(isequal('a'), str)
5

julia> findlast(isequal('a'), str)
33
```

The first argument `isequal('a')` creates a function that checks if its argument equals the character `a`.

As we said before, strings are immutable and cannot be changed. However, we can easily create new strings. The `replace` function returns a new string with a substring of characters replaced with something else:

```jldoctest
julia> replace("Sherlock Holmes", "e" => "ee")
"Sheerlock Holmees"
```

It is also possible to apply a function to a specific substring using the `replace` function. The following example shows how to change all `e` letters in the given string to uppercase.

```jldoctest
julia> replace("Sherlock Holmes", "e" => uppercase)
"ShErlock HolmEs"
```

It is even possible to replace a whole substring:

```jldoctest
julia> replace("Sherlock Holmes", "Holmes" => "Homeless")
"Sherlock Homeless"
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use the `split` function to split the following string
> "Julia!"
into a vector of single-character strings.

**Hint:** we can say that an empty string `""` separates the characters in the string.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

To separate a string into separate single-character strings, we can use the `split` function and an empty string (`""`) as a delimiter.
```jldoctest
julia> split("Julia!", "")
6-element Array{SubString{String},1}:
 "J"
 "u"
 "l"
 "i"
 "a"
 "!"
```

```@raw html
</p></details>
```
