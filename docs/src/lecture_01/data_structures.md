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

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
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

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@raw html
</p></details>
```

## Dictionaries

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@raw html
</p></details>
```
