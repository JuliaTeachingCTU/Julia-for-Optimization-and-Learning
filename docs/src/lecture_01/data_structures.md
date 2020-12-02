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

In this case, we can see, that we have a tuple that contains three elements, where the first one I of type `Int64`, the second one of type `Float64`, and the last one of type `String`.

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

Tuples can be very handy for passing arguments to functions. Imagine the situation, that we have function arguments stored in a tuple and we want to call some function with them. The standard way how to do that is manually passed each element of the tuple to the function. As an example, we can use a tuple with two numbers and modulo function

```@repl tuples
args = (9, 5)
mod(args[1], args[2])
```

or we can unpack the tuple to two variables and then pass these two variables to the function

```@repl tuples
a, b = args
mod(a, b)
```

In Julia, however, there is an even simpler way. It is possible to unpack a tuple and pass its arguments to a function directly with the triple dot (`...`) syntax

```@repl tuples
mod(args...)
```
This is very useful, but also very addictive and it should be used carefully.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Create a tuple that contains odd numbers smaller than `10`. Try to do that using `range` function, `tuple` function and triple-dot syntax `...`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Such a tuple can be created easily with the following syntax

```@repl
t = tuple(1:2:9...)
```

or even in a simpler way without `tuple` function

```@repl
t = (1:2:9..., )
```

The comma after three dots is crucial because it says that we want to create a tuple. Without the comma, an error will occur.

```@repl
t = (1:2:9...)
```

Note, that the same syntax can be also used to create a vector

```@repl
v = [1:2:9..., ]
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

Moreover, it is possible to get elements of a named tuple via their names

```@repl named_tuples
t.a
t.c
```
Also unpacking and passing named tuple as argumnts into the function works in the same way as for tuples

```@repl
args = (a = 9, b = 5)
a, b = args
println("The values stored in the tuple are: a = $a, b = $b")
mod(args...)
```

Moreover, it is possible to use named tuples to store and reuse keyword arguments. It can be demonstrated on a `range` function

```@repl
kwargs = (stop = 10, step = 2)
range(1; kwargs...)
```
Also here the semicolon is mandatory because without the semicolon the named tuple will be unpacked as positional arguments.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Define a matrix using the following code
```julia
m = hcat(-2:2, -5:-1)
```
Use `sort` function to sort each column of the matrix in descending order based on the absolute value of each element. Use help to learn how the `sort` function works and what arguments accepts. Use named tuple with appropriate keys to pass keyword arguments to `sort` function.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
From the help, we can see that we need to set up the following three keyword arguments
- `dims`: Index of dimension along which we want to sort given matrix. Since we want to sort columns, we have to set `dims = 1`.
- `rev`: Boolean that says if we want to use reverse ordering. By default values are sorted in ascending order, so we need to set `rev = true`.
- `by`: A function that is applied to each element before comparing. Since we want to sort elements based on their absolute values, we have to set `by = abs`.

Now we know what keyword arguments we have to use to get a correct result and we can create a named tuple

```@repl named_tuples_ex
kwargs = (dims = 1, rev = true, by = abs)
```

and then call sort function on the given matrix `m`

```@repl named_tuples_ex
m = hcat(-2:2, -5:-1)
sort(m; kwargs...)
```

In this particular case, there is no benefit to use a named tuple to store keyword arguments and it is simpler to pass arguments directly to the `sort` function

```@repl named_tuples_ex
sort(m; dims = 1, rev = true, by = abs)
```

However, this approach can be very useful as we will see later.

```@raw html
</p></details>
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
```

To avoid such errors, we can use `get` function. This function accepts three arguments: a dictionary, key, and a default value for this key, which is returned if the key does not exist in the given dictionary

```@repl dicts
get(d, :c, 42)
```

There is also an in-place version of `get` function, which also add the default value to the dictionary if the key does not exist

```@repl dicts
get!(d, :c, 42)
get!(d, :d, ["hello", "world"])
d
```

Sometimes it is useful to check if a dictionary has a specific key. For this purpose, there is a function  `haskey`

```@repl dicts
haskey(d, :d)
haskey(d, :e)
```

It is also possible to remove unwanted keys from the dictionary. It can be done using `delete!` function, which removes the key from the dictionary

```@repl dicts
delete!(d, :d)
haskey(d, :d)
```

or using `pop!` function, which removes the key from the dictionary and returns the value corresponding to this key

```@repl dicts
pop!(d, :c)
haskey(d, :c)
```

Optionally it is possible to add a default value for a given key to the `pop!` function, which is returned if the key does not exist in the given dictionary

```@repl dicts
haskey(d, :c)
pop!(d, :c, 444)
```
