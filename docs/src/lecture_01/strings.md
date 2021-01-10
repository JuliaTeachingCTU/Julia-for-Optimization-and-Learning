# Strings

In Julia as in other programming languages, a string is a sequence of one or more characters and can be created using quotes

```@repl strings
str = "Hello, world."
```

The strings are immutable and therefore cannot be changed after creation. However, it is very easy to create a new string from parts of existing strings. Individual characters of a string can be accessed via square brackets and indices (the same syntax as for [arrays](@ref Vectors))

```@repl strings
str[1] # returns the first character
```

The return type, in this case, is a `Char`

```@repl strings
typeof(str[1])
```

A `Char` value represents a single character. It is just a 32-bit primitive type with a special literal representation and appropriate arithmetic behaviors. Chars can be created using apostrophe

```@repl
'x'
```

Characters can be converted to a numeric value representing a Unicode and vice versa

```@repl
Int('x')
Char(120)
```

Square brackets can be also used to extract a substring from an existing string

```@repl strings
str[1:5] # returns the first five characters
str[[1,2,5,6]]
```
Note, that we use a range `1:5` to access the first five elements of the string (further details on ranges are given in the section on [arrays](@ref Vectors)). Be aware, that the expressions `str[k]` and `str[k:k]` do not give the same result:

```@repl strings
str[1] # returns the first character as Char
str[1:1] # returns the first character as String
```

When using strings, we have to pay attention to some special characters, specifically to the following three characters: `\`, `"` and `$`. If we want to use any of these three characters, we have to use a backslash before them. The reason is that these characters have a special meaning. For example, if we use quote inside a string, then the rest of the string will be interpreted as a Julia code and not a string.

```@repl strings
str1 = "This is how a string is created: \"string\"."
```

Similarly, the dollar sign is reserved for string interpolation and if we want to use it as a character we have to use a backslash too

```@repl strings
str2 = "\$\$\$ dollars everywhere \$\$\$"
```

If we want to see how the string will be printed, we can use `print` or `println` function

```@repl strings
println(str1)
println(str2)
```

There is one exception to using quotes inside a string: quotes without a backslashes can be used in multiline strings. Multiline strings are created using triple quotes syntax

```@repl strings
mstr = """
This is how a string is created: "string".
"""
print(mstr)
```

This syntax is usually used for docstring for functions. It is possible to write a string in the same way as it will appear after printing in REPL

```@repl
str = """
      Hello,
      world.
    """
print(str)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Create a string with the following text
> Quotation is the repetition or copy of someone else's statement or thoughts. \
> Quotation marks are punctuation marks used in text to indicate a quotation. \
> Both of these words are sometimes abbreviated as "quote(s)".
and use the `println` function to print this string. The printed string should look exactly the same as the text above, i.e. each sentence should be on a separate line. Also, use an indent of length 4 for each sentence.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
There are two basic ways to get the right result. The first is to use a multiline string and write the message in the correct form

``` @example
str = """
    Quotation is the repetition or copy of someone else's statement or thoughts.
    Quotation marks are punctuation marks used in text to indicate a quotation.
    Both of these words are sometimes abbreviated as "quote(s)".
"""
println(str)
```

Note that in this case, we do not have to use backslashes to escape quotation marks in the text. The second way is to use a normal string and new line symbol `\n`. In this case, it is also necessary to use backslashes to escape. quotation marks. Also, we have to add four spaces before each sentence to get a proper indentation

``` @example
str = "    Quotation is the repetition or copy of someone else's statement or thoughts.\n    Quotation marks are punctuation marks used in text to indicate a quotation.\n    Both of these words are sometimes abbreviated as \"quote(s)\"."
println(str)
```

```@raw html
</p></details>
```


## String concatenation and interpolation

One of the most common operations on strings is their concatenation. It can be done using `string` function that accepts any number of input arguments and returns a string.

```@repl
string("Hello,", " world")
```

Note, that it is possible to concatenate strings with numbers and other types, that can be converted to a string

```@repl
a = 1.123
string("The variable a is of type ", typeof(a), " and its value is ", a)
```

In general, it is not possible to perform mathematical operations on strings, even if the strings look like numbers. But there are two exceptions. The `*` operator performs string concatenation

```@repl
"Hello," * " world"
```

This approach is applicable only to `String`s as opposed to the `string` function that also works for other types. The second exeption is `^` operator, which performs repetition

```@repl
"Hello"^3
```

This is equivalent to calling `repeat` function

```@repl
repeat("Hello", 3)
```

Using `string` function to concatenate strings can lead to extremely long expressions and can be cumbersome. To simplify the construction of strings, Julia allows interpolation into string literals using `$` symbol

```@repl interpolation
a = 1.123
string("The variable a is of type ", typeof(a), " and its value is ", a)
"The variable a is of type $(typeof(a)), and its value is $(a)"
```

Note that we use parentheses to separate expressions that should be interpolated into a string literal. It is not mandatory, but it can prevent mistakes. In the example below, we can see different results with and without parentheses

```@repl interpolation
"$typeof(a)"
"$(typeof(a))"
```

The reason is, that in the case without parentheses only the function name is interpolated into the string literal. In the second case, the result of the expression `typeof(a)` is interpolated into the string literal. It is more obvious when we declare a variable `myfunc` that refers to `typeof` function

```@repl interpolation
myfunc = typeof
"$myfunc(a)"
"$(myfunc(a))"
```
Both concatenation and string interpolation call `string` to convert objects into string form. Most non-`AbstractString` objects are converted to strings closely corresponding to how they are entered as literal expressions

```@repl
v = [1,2,3]
"vector: $v"

t = (1,2,3)
"tuple: $(t)"
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Print the following message for a given vector

> "<vec> is a vector of length <len> with elements of type <type>"

where `<vec>` is the string representation of the given vector, `<len>` is the actual length of the given vector and `<type>` is the type of its elements. Use the following two vectors

```julia
a = [1,2,3]
b = [:a, :b, :c, :d]
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

We will show two ways how to solve this exercise. The first way is to use the `string` function in combination with the `length` function to get the length of the vector and the `eltype` function to get its elements type:

```@example
a = [1,2,3]
string(a, " is a vector of length ",  length(a), " with elements of type ", eltype(a))
```
The second way is to use string interpolation

```@example
b = [:a, :b, :c, :d]
"$(b) is a vector of length $(length(b)) with elements of type $(eltype(b))"
```

```@raw html
</p></details>
```

## Useful functions

Very useful function is the `join` function that performs string concatenation. However, it supports defining custom separator and also it supports different separator for the last element

```@repl
join(["apples", "bananas", "pineapples"], ", ", " and ")
```

To split a string, the `split` function can be used

```@repl joins
str = "JuliaLang is a pretty cool language!"
split(str)
```

By default, the function splits the given string based on spaces. But it can be changed by defining custom delimiter

```@repl joins
split(str, " a ")
```

There are multiple functions that can be used to find specific characters or substring in the given string. To check if the string contains a specific substring or character, the functions `contains` or `occursin` can be used

```@repl
contains("JuliaLang is pretty cool!", "Julia")
occursin("Julia", "JuliaLang is pretty cool!")
```

These two function differ only in the order of arguments. A very useful function is the `endswith` function, which cheks if the given string ends with the given substring or character. It can be used for example to check, that the file has a proper suffix

```@repl
endswith("figure.png", "png")
```

Index of a specific character in a string can be found using find functions

```@repl
str = "JuliaLang is a pretty cool language!"
findall(isequal('a'), str)
findfirst(isequal('a'), str)
findlast(isequal('a'), str)
```

As we said before, strings are immutable and cannot be changed. However, we can easily create new strings. The `replace` function returns a new string with a substring of characters replaced with something else

```@repl
replace("Sherlock Holmes", "e" => "ee")
```

It is also possible to apply a function to a specific substring using `replace` function. The following example shows how to change all `e` letters in the given string to uppercase

```@repl
replace("Sherlock Holmes", "e" => uppercase)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Use the `split` function to split the following string

```@example joins_ex
str = "JuliaLang is a pretty cool language!"
nothing # hide
```
into a vector of single-character strings and convert all these strings to upper case.

**Hint:** we can say that the characters in the string are separated by an empty string `""`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
If you want to split a string into separate single-character strings, use the empty string (`""`) which splits the string between the characters. To convert strings to uppercase, we can use the `uppercase` function and dot syntax to apply this function to each string separately

```@repl joins_ex
str = "JuliaLang is a pretty cool language!"
uppercase.(split(str, ""))
```
```@raw html
</p></details>
```
