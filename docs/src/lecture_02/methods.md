# Types, methods and multiple-dispatch

So far we did not mention any types. The default behavior in Julia when types are omitted is to allow values to be of any type. Thus, one can write many useful Julia functions without ever explicitly using types. When additional expressiveness is needed, however, it is easy to gradually introduce explicit type annotations into previously "untyped" code.

In Julia, functions consist of multiple methods. The choice of which method to execute when a function is applied is called dispatch. Julia allows the dispatch process to choose which of a function's methods to call based on
- the number of arguments given
- types of all of the function's arguments.

Using all of a function's arguments to choose which method should be invoked is known as **multiple dispatch**. Until now, we have defined only functions with a single method having unconstrained argument types.

```@repl f_func
f(x, y) = x * y
```

We can easily check which methods are defined for this function using the `methods` function

```@repl f_func
methods(f)
```

Each function can be easily extended by new methods

```@repl f_func
f(x, y, z) = x * y * z
f(x, y, z, q) = x * y * z * q
f(x...) = reduce(*, x)
methods(f)
```

Since we did not specify what types of arguments are allowed, function `f` will work for all types

```@repl f_func
[
    f(2, 3),
    f(2.0, 3),
    f(2, 3.0),
    f("a", "b")
]
```

However, some combinations of arguments will result in an error

```@repl f_func
f(:a, :b)
```

When using types we can be extremely conservative and we can set a specific type for each function argument

```@repl foo_func
foo(x::Int64, y::Int64) = x * y
```

This function definition applies only to calls where `x` and `y` are both values of type Int64:

```@repl foo_func
foo(2,3)
```

Applying it to any other types of arguments will result in a `MethodError`:

```@repl foo_func
foo(2.0,3)
```

It is better to use abstract types like `Number` or` Real` instead of concrete types like `Float64`,` Float32`, `Int64` ... .  To find an super type for a specific type, we can use  `supertype` function

```@repl
supertype(Int64)
```

or we can create a simple recursive function that prints the entire tree of supertypes for a given type

```@repl
function supertypes_tree(::Type{T}, k::Int = 0) where {T <: Any}
    T === Any && return
    col = isabstracttype(T) ? :blue : :green
    printstyled(repeat("   ", k)..., T, "\n"; bold = true, color = col)
    supertypes_tree(supertype(T), k + 1)
    return
end

```

All abstract types are printed in blue and all concrete types are printed in green. There is also `subtypes` function, which returns all subtypes for a given type.

```@repl
subtypes(Number)
```

As with supertypes, we can create a simple recursive function that prints the entire tree of subtypes for a given type.

```@repl
function subtypes_tree(::Type{T}, k::Int = 0) where {T <: Any}
    col = isabstracttype(T) ? :blue : :green
    printstyled(repeat("   ", k)..., T; bold = true, color = col)
    println()
    subtypes_tree.(subtypes(T), k + 1)
    return
end

```

From the tree of all subtypes of the abstract type "Number," we see the whole structure of numerical types in Julia. So if we really want to specify the argument types of a function, we should use some abstract type, such as `Real`

```@repl foo_func
foo(x::Real, y::Real) = x * y
```

This function definition applies to calls where `x` and `y` are both values of any subtype of `Real`.

```@repl foo_func
Real[
    foo(2.0, 3)
    foo(2.0, 3.0)
    foo(Int32(2), Int16(3.0))
    foo(Int32(2), Float32(3.0))
]
```

Now we can check again how many methods are defined for `foo`

```@repl foo_func
methods(foo)
```

## Method Ambiguities

It is possible to define a set of function methods such that there is no unique most specific method applicable to some combinations of arguments:

```@repl goo_func
goo(x::Float64, y) = x * y

goo(x, y::Float64) = x + y
```

Here, the `goo` function has two methods. The first method applies if the first argument is of type `Float64`.

```@repl goo_func
goo(2.0, 3)
```

The second method applies if the second argument is of type `Float64`.

```@repl goo_func
goo(2, 3.0)
```

The case, where both arguments are of type `Float64` can be handled by both methods. The problem is that neither method is more specific than the other. In such cases, Julia raises a `MethodError` rather than arbitrarily picking a method.

```@repl goo_func
goo(2.0, 3.0)
```

We can avoid method ambiguities by specifying an appropriate method for the intersection case:

```@repl goo_func
goo(x::Float64, y::Float64) = x - y
```

If we can check again how many methods are defined for `goo`, there will be three methods

```@repl goo_func
methods(goo)
```
