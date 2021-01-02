# Strings

In Julia as in other programming languages, a string a sequence of one or more characters. Strings can be created using quotes

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

Characters can be converted to a numeric value representing a Unicode code point and vice versa

```@repl
Int('x')
Char(120)
```

It is also possible to extract a substring from an existing string. It is done using square brackets and multiple indexes

```@repl strings
str[1:5] # returns the first five characters
str[[1,2,5,6]]
```

Notice that the expressions `str[k]` and `str[k:k]` do not give the same result:

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

## Splitting and joining strings

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
"Hello,"*" world"
```

This approach is applicable only to string as opposed to `string` function that also works for other types. The second exeption is `^` operator, which performs repetition

```@repl
"Hello"^3
```

This is equivalent to calling `repeat` function

```@repl
repeat("Hello", 3)
```

Another very useful function is the `join` function. This function also performs string concatenation, however, it supports defining custom separator and also it supports different separator for the last element

```@repl
join(["apples", "bananas", "pineapples"], ", ", " and ")
```

Similarly as `string` function,  the `join` function can be used also for other types than strings

```@repl
join([1,2,3,4,5], ", ", " or ")
```

To split a string, the function `split` function can be used

```@repl joins
str = "JuliaLang is a pretty cool language!"
split(str)
```

By default, the `split` function splits the given string based on spaces. But it can be changed by defining custom delimiter

```@repl joins
split(str, " a ")
```

If you want to split a string into separate single-character strings, use the empty string (`""`) which splits the string between the characters

```@repl joins
split(str, "")
```

## String interpolation

Using `string` function to concatenate strings can lead to extremely long expressions and can be cumbersome. To simplify the construction of strings, Julia allows interpolation into string literals using `$`

```@repl interpolation
a = 1.123
string("The variable a is of type ", typeof(a), " and its value is ", a)
"The variable a is of type $(typeof(a)), and its value is $(a)"
```

Note that we use parentheses to separate expressions that should be interpolated into a string literal. It is not mandatory, but it can prevent mistakes. In the example below, we can see different results with and without parentheses

```@repl interpolation
"$typeof(a) = $(typeof(a))"
```

The reason is, that in the case without parentheses only the function name is interpolated into the string literal. In the second case, the result of the expression `typeof(a)` is interpolated into the string literal. It is more obvious when we declare a variable `myfunc` that refers to `typeof` function

```@repl interpolation
myfunc = typeof
"$myfunc(a) = $(myfunc(a))"
```
Both concatenation and string interpolation call `string` to convert objects into string form. However, string actually just returns the output of `print`, so new types should add methods to `print` or `show` instead of `string`. Most non-`AbstractString` objects are converted to strings closely corresponding to how they are entered as literal expressions

```@repl
v = [1,2,3]
"vector: $v"

t = (1,2,3)
"tuple: $(t)"
```

## Useful functions

There are multiple functions that can be used to find specific characters or substring in the given string. To check if the string contains a specific substring or character, the functions `contains` or `occursin` can be used

```@repl
contains("JuliaLang is pretty cool!", "Julia")
contains("Julia", "JuliaLang is pretty cool!")
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

It is also possible to apply a function to a specific substring using `replace` function. The following example shows how to change all `e`  in the given string to uppercase

```@repl
replace("Sherlock Holmes", "e" => uppercase)
```
