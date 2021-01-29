# Strings

In Julia, as in other programming languages, a string is a sequence of one or more characters and can be created using quotes

```jldoctest strings
julia> str = "Hello, world."
"Hello, world."
```

The strings are immutable and, therefore, cannot be changed after creation. However, it is very easy to create a new string from parts of existing strings. Individual characters of a string can be accessed via square brackets and indices (the same syntax as for [arrays](@ref Vectors))

```jldoctest strings
julia> str[1] # returns the first character
'H': ASCII/Unicode U+0048 (category Lu: Letter, uppercase)
```

The return type, in this case, is a `Char`

```jldoctest strings
julia> typeof(str[1])
Char
```

A `Char` value represents a single character. It is just a 32-bit primitive type with a special literal representation and appropriate arithmetic behaviors. Chars can be created using an apostrophe

```jldoctest
julia> 'x'
'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)
```

It is also possible to convert characters to a numeric value representing a Unicode and vice versa

```jldoctest
julia> Int('x')
120

julia> Char(120)
'x': ASCII/Unicode U+0078 (category Ll: Letter, lowercase)
```

Substrings from the existing string can be extracted via square brackets and indexing syntax which is similar to the one for [arrays](@ref Vectors)

```jldoctest strings
julia> str[1:5] # returns the first five characters
"Hello"

julia> str[[1,2,5,6]]
"Heo,"
```

Note that we use a range `1:5` to access the first five elements of the string (further details on ranges are given in the section on [arrays](@ref Vectors)). Be aware that the expressions `str[k]` and `str[k:k]` do not give the same result

```jldoctest strings
julia> str[1] # returns the first character as Char
'H': ASCII/Unicode U+0048 (category Lu: Letter, uppercase)

julia> str[1:1] # returns the first character as String
"H"
```

When using strings, we have to pay attention to some special characters, specifically to the following three characters: `\`, `"` and `$`. If we want to use any of these three characters, we have to use a backslash before them. The reason is that these characters have a special meaning. For example, if we use a quote inside a string, then the rest of the string will be interpreted as a Julia code and not a string.

```jldoctest strings
julia> str1 = "This is how a string is created: \"string\"."
"This is how a string is created: \"string\"."
```

Similarly, the dollar sign is reserved for string interpolation, and if we want to use it as a character, we have to use a backslash too

```jldoctest strings
julia> str2 = "\$\$\$ dollars everywhere \$\$\$"
"\$\$\$ dollars everywhere \$\$\$"
```

The print of the strings can be done using the `print` function or the `println` function that also add a new line at the end fo the string

```jldoctest strings
julia> println(str1)
This is how a string is created: "string".

julia> println(str2)
$$$ dollars everywhere $$$
```

There is one exception to using quotes inside a string: quotes without backslashes can be used in multiline strings. Multiline strings can be created using triple quotes syntax as follows

```jldoctest strings
julia> mstr = """
       This is how a string is created: "string".
       """
"This is how a string is created: \"string\".\n"

julia> print(mstr)
This is how a string is created: "string".
```

This syntax is usually used for docstring for functions. It is possible to write a string in the same way as it will appear after printing in REPL

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
and print the string into the REPL. The printed string should look the same as the text above, i.e., each sentence should be on a separate line. Also, use an indent of length 4 for each sentence.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

There are two basic ways to get the right result. The first is to use a multiline string and write the message in the correct form

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

Note that we do not have to use backslashes to escape quotation marks in the text in this case. The second way is to use a regular string and new line symbol `\n`. In this case, it is necessary to use backslashes to escape quotation marks. Also, we have to add four spaces before each sentence to get a proper indentation

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

Note that it is possible to concatenate strings with numbers and other types that can be converted to a string

```jldoctest
julia> a = 1.123
1.123

julia> string("The variable a is of type ", typeof(a), " and its value is ", a)
"The variable a is of type Float64 and its value is 1.123"
```

In general, it is not possible to perform mathematical operations on strings, even if the strings look like numbers. However, there are two exceptions. The `*` operator performs string concatenation

```jldoctest
julia> "Hello," * " world"
"Hello, world"
```

This approach can only be applied to `String`s, unlike the `string` function, which also works for other types. The second exception is the `^` operator, which performs repetition

```jldoctest
julia> "Hello"^3
"HelloHelloHello"
```

The example above is equivalent to calling the `repeat` function

```jldoctest
julia> repeat("Hello", 3)
"HelloHelloHello"
```

Using the `string` function to concatenate strings can lead to too long expressions and be cumbersome. To simplify the construction of strings, Julia allows interpolation into string literals using the `$` symbol

```jldoctest interpolation
julia> a = 1.123
1.123

julia> string("The variable a is of type ", typeof(a), " and its value is ", a)
"The variable a is of type Float64 and its value is 1.123"

julia> "The variable a is of type $(typeof(a)), and its value is $(a)"
"The variable a is of type Float64, and its value is 1.123"
```

Note that we use parentheses to separate expressions that should be interpolated into a string. It is not mandatory, but it can prevent mistakes. In the example below, we can see different results with and without parentheses

```jldoctest interpolation
julia> "$typeof(a)"
       "$(typeof(a))"
ERROR: cannot document the following expression:

"$(typeof(a))"
```

In the case without parentheses, only the function name is interpolated into the string. In the second case, the result of the expression `typeof(a)` is interpolated into the string literal. It is more apparent when we declare a variable `myfunc` that refers to `typeof` function

```jldoctest interpolation
julia> myfunc = typeof
typeof (built-in function)

julia> "$myfunc(a)"
       "$(myfunc(a))"
ERROR: cannot document the following expression:

"$(myfunc(a))"
```

Both concatenation and string interpolation call `string` to convert objects into string form. Most non-`AbstractString` objects are converted to strings closely corresponding to how they are entered as literal expressions

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
where `<vec>` is the string representation of the given vector, `<len>` is the actual length of the given vector, and `<type>` is the type of its elements. Use the following two vectors

```julia
a = [1,2,3]
b = [:a, :b, :c, :d]
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

We will show two ways how to solve this exercise. The first way is to use the `string` function in combination with the `length` function to get the length of the vector and the `eltype` function to get the type of its elements

```jldoctest
julia> a = [1,2,3];

julia> str = string(a, " is a vector of length ",  length(a), " with elements of type ", eltype(a));

julia> println(str)
[1, 2, 3] is a vector of length 3 with elements of type Int64
```

The second way is to use string interpolation

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

A handy function is the `join` function that performs string concatenation. Additionally, it supports defining a custom separator and a different separator for the last element

```jldoctest
julia> join(["apples", "bananas", "pineapples"], ", ", " and ")
"apples, bananas and pineapples"
```

In many cases, it is necessary to split the given string according to some conditions. In such cases, the `split` function can be used

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

By default, the function splits the given string based on spaces. But it can be changed by defining a custom delimiter

```jldoctest joins
julia> split(str, " a ")
2-element Array{SubString{String},1}:
 "JuliaLang is"
 "pretty cool language!"
```

Julia also provides multiple functions that can be used to find specific characters or substring in the given string. The `contains` function checks if the string contains a specific substring or character. Similarly, the `occursin` function determines if the specified string or character occurs in the given string. These two functions differ only in the order of arguments.

```jldoctest
julia> contains("JuliaLang is pretty cool!", "Julia")
true

julia> occursin("Julia", "JuliaLang is pretty cool!")
true
```

A very useful function is the `endswith` function, which checks if the given string ends with the given substring or character. It can be used, for example, to check that the file has a proper suffix

```jldoctest
julia> endswith("figure.png", "png")
true
```

Sometimes, it is necessary to find indexes of characters in the string based on some conditions. For such cases, Julia provides several find functions

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

Note that `isequal('a')` creates a function that checks if its argument is equal to the character `a`.

As we said before, strings are immutable and cannot be changed. However, we can easily create new strings. The `replace` function returns a new string with a substring of characters replaced with something else

```jldoctest
julia> replace("Sherlock Holmes", "e" => "ee")
"Sheerlock Holmees"
```

It is also possible to apply a function to a specific substring using the `replace` function. The following example shows how to change all `e` letters in the given string to uppercase

```jldoctest
julia> replace("Sherlock Holmes", "e" => uppercase)
"ShErlock HolmEs"
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use the `split` function to split the following string
> "Julia!"
into a vector of single-character strings and convert all these strings to uppercase.

**Hint:** we can say that an empty string separates the characters in the string `""`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

To separate a string into separate single-character strings, we can use the `split` function and an empty string (`""`) as a delimiter. Then, we can use the `uppercase` function to convert strings to uppercase

```jldoctest
julia> uppercase.(split("Julia!", ""))
6-element Array{String,1}:
 "J"
 "U"
 "L"
 "I"
 "A"
 "!"
```

```@raw html
</p></details>
```