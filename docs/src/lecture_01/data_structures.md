# Data structures

## Tuples

A tuple is an immutable, ordered, fixed-sized group of elements, i.e. it is not possible to add new elements or change the value of any element in a tuple. Tuples are created using the following syntax

```@repl tuples
t = (1, 2.0, "3")
```

It is even possible to omit the brackets

```@repl tuples
t = 1, 2.0, "3"
```

This syntax is used in a [function definition](@ref Functions) to return multiple values at once. The type of a tuple is given by the types of all its elements

```@repl tuples
typeof(t)
```

In this case, we can see, that we have a tuple that contains three elements, where the first one is of type `Int64`, the second one of type `Float64`, and the last one of type `String`.

To access elements of a tuple, we can use the same syntax as for arrays

```@repl tuples
t[1] # the first element
t[end] # the last element
t[1:2] # the first two elements
```

A very useful feature is that it is possible to unpack a tuple over many values

```@repl tuples
a, b, c = t
println("The values stored in the tuple are: $a, $b and $c")
```
Note that this is also possible to do with arrays. Tuples are usually used for storing a small number of values and then this feature may be useful. On the other hand, arrays are usually large, so such a feature is not useful for arrays most of the time.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Create a tuple that contains the first four letters of the alphabet (these letters should be of type `String`). Then unpack this tuple into four variables `a`, `b`, `c` and `d`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
Such a tuple can be created easily using standard syntax
```@repl tuples_ex
t = ("a", "b", "c", "d")
```
To unpack the tuple, we can simply use the four variables and the `=` sign

```@repl tuples_ex
a, b, c, d = t
```
```@raw html
</p></details>
```

## Named Tuples

Named tuples are similar to tuples, i.e. named tuple is an immutable, ordered, fixed-sized group of elements. The only difference is, that each element consists of a name (identifier) and value. Named tuples are created using the following syntax

```@repl named_tuples
t = (a = 1, b = 2.0, c = "3")
```

or it is possible to create a named tuple directly from variables

```@repl named_tuples
a = 1;
b = 2.0;
c = "3";
t = (; a, b, c)
```

Here the semicolon is mandatory, because without the semicolon the result will be a tuple instead of a named tuple. Similarly to tuples, the elements of a named tuple can be accessed via square brackets. However, in opposed to tuples, it is not possible to access multiple elements at once

```@repl named_tuples
t[1] # the first element
t[end] # the last element
t[1:2] # error
```

Moreover, it is possible to get elements of a named tuple via their names or unpack elements directly to variables

```@repl named_tuples
t.a
t.c
a, b, c = t
println("The values stored in the tuple are: a = $a, b = $b")
```

## Dictionaries

Dictionaries are mutable, unordered (random order) collections of pairs of keys and values. The syntax for creating a dictionary is as follows

```@repl dicts
d = Dict("a" => [1, 2, 3], "b" => 1)
```

or using symbols instead of strings as keys

```@repl dicts
d = Dict(:a => [1, 2, 3], :b => 1)
```
In fact, it is possible to use almost any type as a key in a dictionary. The elements of a dictionary can be accessed via square brackets and a key

```@repl dicts
d[:a]
```

If the key does not exist in the dictionary and we try to get it using the square brackets syntax, an error will occur

```@repl dicts
d[:c]
haskey(d, :c)
```
Note, that we use the `haskey` function to check if the given dictionary has the `:c` key. To avoid such errors, we can use `get` function. This function accepts three arguments: a dictionary, key, and a default value for this key, which is returned if the key does not exist in the given dictionary

```@repl dicts
get(d, :c, 42)
```

There is also an in-place version of the `get` function, which also add the default value to the dictionary if the key does not exist

```@repl dicts
get!(d, :c, 42)
get!(d, :d, ["hello", "world"])
d
```
Unwanted keys from the dictionary can be removed using the `delete!` function

```@repl dicts
delete!(d, :d)
haskey(d, :d)
```

An alternative is the `pop!` function, which removes the key from the dictionary and returns the value corresponding to this key

```@repl dicts
pop!(d, :c)
haskey(d, :c)
```

Optionally it is possible to add a default value for a given key to the `pop!` function, which is returned if the key does not exist in the given dictionary

```@repl dicts
haskey(d, :c)
pop!(d, :c, 444)
```
