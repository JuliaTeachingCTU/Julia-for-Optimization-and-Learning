# Methods

So far, we have defined all functions (with some exceptions) without annotating types of their input arguments. The default behavior in Julia when types are omitted is to allow values to be of any type. Thus, one can write many useful Julia functions without ever explicitly using types. When additional expressiveness is needed, however, it is easy to gradually introduce explicit type annotations into previously "untyped" code.

In Julia, functions consist of multiple methods. The choice of which method to execute when a function is applied is called dispatch. Julia allows the dispatch process to choose which of a function's methods to call based on

- the number of arguments given
- types of all of the function's arguments.

Using all of a function's arguments to choose which method should be invoked is known as **multiple dispatch**.

As an example of usage of multiple-dispatch, we will define a `product` function, that will computes the product of the given numbers
```@repl methods
product(x, y) = x * y
```

In the REPL, we can see the line, that tells us, that the function product has only one method. In this case,  we defined only the method for two input arguments without type specification
```@repl methods
product(1, 4.5)
product(2.4, 3.1)
```

A list of all methods for a given function can be obtained using the `methods` function
```@repl methods
methods(product)
```

Because we did not specify any types of input arguments, the `product` function accepts arguments of all types. However, the `*` operator will not work for example for symbols
```@repl methods
product(:a, :b)
```

We can avoid such errors by specifying types of input arguments. Since we want to create a function that computes the product of two numbers, it makes sense to allow input arguments to be only numbers.
```@example methods
product(x::Number, y::Number) = x * y
product(x, y) = throw(ArgumentError("product is defined for numbers only."))
nothing # hide
```

Note that we also redefined the original definition of the `product` function to throw an error if we call the function with non-numeric input arguments.
```@repl methods
methods(product)
```

Now, we have a function with two methods, that returns a product if the input arguments are numbers and throw an error otherwise.
```@repl methods
product(1, 4.5)
product(:a, :b)
product("a", "b")
```

As in the previous example, it is always better to use abstract types like `Number` or `Real` instead of concrete types like `Float64`,` Float32`, `Int64` ... . This is because if we use an abstract type, the function will work for all its subtypes. To find an super type for a specific type, we can use  `supertype` function from `InteractiveUtils` package
```@repl methods
using InteractiveUtils: supertype
supertype(Float64)
```

The problem with the `supertype` function is, that it will not return the whole supertype hierarchy, but only the closest *larger* supertype for the given type. For `Float64` the closest large supertype is `AbstractFloat`. However, as in the example before, we do not want to use this supertype, since then the function will only work for floating-point numbers. Solve the following exercise to get the tool, which allows you to print the whole supertypes hierarchy.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Create a function `supertypes_tree` that prints the whole tree of all supertypes for the given type. If the given type `T` satisfies the following condition `T === Any`, then the function should do nothing. Use the following function declaration
```julia
function supertypes_tree(T::Type, level::Int = 0)
    # code
end
```

The optional argument `level` sets the level of indentation

**Hints:**
- use the `supertype` function in combination with recursion.
- use function `repeat` and string with white space `"    "` to create a proper indentation.
- look at the example placed after the solution, how the output of the function should look like.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The `supertypes_tree` function can be defined as follows
```@example methods
function supertypes_tree(T::Type, level::Int = 0)
    T === Any && return
    println(repeat("   ", level), T)
    supertypes_tree(supertype(T), level + 1)
    return
end
nothing # hide
```

On the first line, we check if the given input type is `Any`, and if yes, then the function returns nothing. If the input type is not `Any`, then the function prints the type with a proper indentation which is given by `repeat("   ", level)`, i.e. four white-spaces are repeated `level`-times. On the third-line, we call the `supertypes_tree` function recursively for the supertype of the type `T` and level of indentation `level + 1`.

```@raw html
</p></details>
```

Now we can use the `supertypes_tree` function to get the whole supertypes hierarchy for `Float64`.
```@repl methods
supertypes_tree(Float64)
```
We can check the type hierarchy using `<:` operator for comparing type, i.e. is `T1 <: T2` is true, then `T1` is a subtype (or the same type) of `T2`.

```@repl methods
Float64 <: AbstractFloat <: Real <: Number
```

Similarly to the `supertype` function, there is a function `subtypes`, that return all subtypes for the given type
```@repl methods
using InteractiveUtils: subtypes
subtypes(Number)
```

But there is the same problem as for the `supertype` function: It is not possible to get the whole hierarchy of all subtypes using only this function. Solve the following exercise to get the tool, which allows you to print the whole subtypes hierarchy.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Create a function `subtypes_tree` that prints the whole tree of all subtypes for the given type. Use the following function declaration
```julia
function subtypes_tree(T::Type, level::Int = 0)
    # code
end
```

The optional argument `level` sets the level of indentation

**Hints:**
- use the `subtypes` function in combination with recursion.
- use function `repeat` and string with white space `"    "` to create a proper indentation.
- look at the example placed after the solution, how the output of the function should look like.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The `subtypes_tree` function can be defined as follows
```@example methods
function subtypes_tree(T::Type, level::Int = 0)
    println(repeat("   ", level), T)
    subtypes_tree.(subtypes(T), level + 1)
    return
end
nothing # hide
```

The function prints the type with a proper indentation which is given by `repeat("   ", level)`, i.e. four white-spaces are repeated `level`-times. On the second-line, we call the `subtypes_tree` function recursively for all subtypes of the type `T` and level of indentation `level + 1`. Note, that we use dot syntax to apply the `subtypes_tree` function to all elements of the tuple, that is returned by `subtypes(T)`.

```@raw html
</p></details>
```

Now we can use the `subtypes_tree` function to get the whole subtypes hierarchy for `Number`
```@repl methods
subtypes_tree(Number)
```

From the tree of all subtypes of the abstract type `Number`, we see the whole structure of numerical types in Julia. So if we want to define a function that accepts all numeric types, we should use inputs of type `Number`. However, many operations are restricted to only real numbers, in such a case, we want to use the `Real` type instead of `Number`.

Now we can go back to our example with the `product` function. The problem with this function is, that it is too restrictive since the product of two strings is a legitimate operation that should return their concatenation. So we should define a method for strings. To use the proper type, we can use the `supertypes_tree` function for the `String` type

```@repl methods
supertypes_tree(String)
```
We see, that the *largest* supertype for `String` is the `AbstractString` and that is the type we should use
```@example methods
product(x::AbstractString, y::AbstractString) = x * y
product(x, y) = throw(ArgumentError("product is defined for numbers and strings only."))
nothing # hide
```

We also redefined the original definition of the `product` function to throw an appropriate error.
```@repl methods
product(1, 4.5)
product("a", "b")
product(:a, :b)
```

Sometimes, it can be very complicated to guess, which method will be used for concrete inputs. In such a case, there is a useful macro `@which` that returns the method that would be called for given arguments
```@repl methods
using InteractiveUtils: @which

@which product(1, 4.5)
@which product("a", :a)
@which product("a", "b")
```

The previous example with the `product` function shows, how methods in Julia works. However, it is a good practice to use type annotation only if we really want to have a specialized function or if we want to define a function, which does different things for different types of input arguments.

```@example methods
g(x::Real) = x + 1
g(x::String) = repeat(x, 4)
nothing # hide
```
For example, the `g` function returns `x + 1` if the input `x` is a real number or repeats four times the input argument if it is a string. Otherwise, it will throw a method error, since we define only these two specific methods.

```@repl methods
g(1.2)
g("a")
g(:a)
```

```@raw html
<div class = "info-body">
<header class = "info-header">Do not overuse type annotation!!!</header><p>
```

The `product` function should be defined without the type annotation. It is a good practice to not restrict input argument types if it is not necessary. The reason is, that in this case, there is no benefit to using the type annotation. If we define a function `product_new` in the following way

```@example methods
product_new(x, y) = x * y
nothing # hide
```

Then we can apply this function to the same inputs as the original `product` function and we will get the same results

```@repl methods
product(1, 4.5)
product_new(1, 4.5)
product("a", "b")
product_new("a", "b")
```
with only one exception
```@repl methods
product("a", :a)
product_new("a", :a)
```
Here we get a different error, but the error given by the `product_new` function is more useful since it tells us what is the real problem. We can see, that it is not possible to use the `*` operator to multiply `String` and `Symbol`. Now we can decide if it is the desired behavior and if not, we can define a method for the `*` operator that will fix it.

```@raw html
</p></div>
```

## Method Ambiguities

It is possible to define a set of function methods such that there is no unique most specific method applicable to some combinations of arguments:

```@example methods_amb
f(x::Float64, y) = x * y
f(x, y::Float64) = x + y
nothing # hide
```

Here, the `f` function has two methods. The first method applies if the first argument is of type `Float64`.

```@repl methods_amb
f(2.0, 3)
```

The second method applies if the second argument is of type `Float64`.

```@repl methods_amb
f(2, 3.0)
```

The case, where both arguments are of type `Float64` can be handled by both methods. The problem is that neither method is more specific than the other. In such cases, Julia raises a `MethodError` rather than arbitrarily picking a method.

```@repl methods_amb
f(2.0, 3.0)
```

We can avoid method ambiguities by specifying an appropriate method for the intersection case:

```@repl methods_amb
f(x::Float64, y::Float64) = x - y
nothing # hide
```

If we can check again how many methods are defined for `f`, there will be three methods

```@repl methods_amb
methods(f)
f(2, 3.0)
f(2.0, 3)
f(2.0, 3.0)
```
