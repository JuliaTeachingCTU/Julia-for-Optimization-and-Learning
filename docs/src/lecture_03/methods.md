# Methods

So far, we have defined all functions (with some exceptions) without annotating the types of input arguments. When the type annotation is omitted, the default behavior in Julia is to allow values to be of any type. Thus, one can write many useful Julia functions without ever explicitly using types. However, when additional expressiveness is needed, it is easy to gradually introduce explicit type annotations into previously *untyped* code.

In Julia, functions consist of multiple methods. The choice of which method to execute when a function is applied is called dispatch. Julia allows the dispatch process to choose which of a function's methods to call based on

- the number of arguments given
- types of all of the function's arguments.

Using all of a function's arguments to choose which method should be invoked is known as **multiple dispatch**.

As an example of usage of multiple-dispatch, we will define a `product` function that will compute the product of the given numbers

```jldoctest methods
julia> product(x, y) = x * y
product (generic function with 1 method)
```

In the REPL, we can see the message that tells us that the `product` function has only one method. In this case,  we defined only the method for two input arguments without type specification

```jldoctest methods
julia> product(1, 4.5)
4.5

julia> product(2.4, 3.1)
7.4399999999999995
```

A list of all methods for a given function can be obtained using the `methods` function

```jldoctest methods
julia> methods(product)
# 1 method for generic function "product":
[1] product(x, y) in Main at none:1
```

Because we did not specify types of input arguments, the `product` function accepts arguments of all types. However, the `*` operator will not work, for example, for symbols

```jldoctest methods
julia> product(:a, :b)
ERROR: MethodError: no method matching *(::Symbol, ::Symbol)
[...]
```

We can avoid such errors by specifying types of input arguments. Since we want to create a function that computes the product of two numbers, it makes sense to allow input arguments to be only numbers.

```jldoctest methods; output = false
product(x::Number, y::Number) = x * y
product(x, y) = throw(ArgumentError("product is defined for numbers only."))

# output
product (generic function with 2 methods)
```

Note that we also redefined the original definition of the `product` function to throw an error if we call the function with non-numeric input arguments.

```jldoctest methods
julia> methods(product)
# 2 methods for generic function "product":
[1] product(x::Number, y::Number) in Main at none:1
[2] product(x, y) in Main at none:1
```

Now, we have a function with two methods, that returns a product if the input arguments are numbers and throw an error otherwise.

```jldoctest methods
julia> product(1, 4.5)
4.5

julia> product(:a, :b)
ERROR: ArgumentError: product is defined for numbers only.

julia> product("a", "b")
ERROR: ArgumentError: product is defined for numbers only.
```

As in the previous example, it is always better to use abstract types like Number or Real instead of concrete types like Float64, Float32, or Int64. The reason is that if we use an abstract type, the function will work for all its subtypes. To find a supertype for a specific type, we can use the `supertype` function from `InteractiveUtils` package

```jldoctest methods
julia> using InteractiveUtils: supertype

julia> supertype(Float64)
AbstractFloat
```

The problem with the `supertype` function is that it will not return the whole supertype hierarchy, but only the closest *larger* supertype for the given type. For `Float64` the closest large supertype is `AbstractFloat`. However, as in the example before, we do not want to use this supertype, since then the function will only work for floating-point numbers. Solve the following exercise to get the tool, which allows you to print the whole supertypes hierarchy.

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

The optional argument `level` sets the level of indentation for printing

**Hints:**
- Use the `supertype` function in combination with recursion.
- Use the `repeat` function and string with white space `"    "` to create a proper indentation.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The `supertypes_tree` function can be defined as follows

```jldoctest methods; output = false
function supertypes_tree(T::Type, level::Int = 0)
    T === Any && return
    println(repeat("   ", level), T)
    supertypes_tree(supertype(T), level + 1)
    return
end

# output
supertypes_tree (generic function with 2 methods)
```

On the first line, we check if the given input type is `Any`, and if yes, then the function returns nothing. Otherwise, the function prints the type with a proper indentation given by `repeat("   ", level)`, i.e., four white-spaces are repeated `level`-times. On the third-line, we call the `supertypes_tree` function recursively for the supertype of the type `T` and level of indentation `level + 1`.

```@raw html
</p></details>
```

Now we can use the `supertypes_tree` function to get the whole supertypes hierarchy for `Float64`.

```jldoctest methods
julia> supertypes_tree(Float64)
Float64
   AbstractFloat
      Real
         Number
```

We can check the type hierarchy using `<:` operator for comparing type, i.e., if `T1 <: T2` is true, then `T1` is a subtype (or the same type) of `T2`

```jldoctest methods
julia> Float64 <: AbstractFloat <: Real <: Number
true
```

Similarly to the `supertype` function, there is the `subtypes` function that returns all subtypes for the given type

```jldoctest methods
julia> using InteractiveUtils: subtypes

julia> subtypes(Number)
4-element Array{Any,1}:
 Complex
 Real
 SLEEFPirates.Double
 VectorizationBase.Static
```

But there is the same problem as for the `supertype` function: It is impossible to get the whole hierarchy of all subtypes using only this function. Solve the following exercise to get the tool, which allows you to print the whole subtypes hierarchy.

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

The optional argument `level` sets the level of indentation for printing

**Hints:**
- Use the `subtypes` function in combination with recursion.
- Use the `repeat` function and string with white space `"    "` to create a proper indentation.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The `subtypes_tree` function can be defined as follows

```jldoctest methods; output = false
function subtypes_tree(T::Type, level::Int = 0)
    println(repeat("   ", level), T)
    subtypes_tree.(subtypes(T), level + 1)
    return
end

# output
subtypes_tree (generic function with 2 methods)
```

The function prints the type with a proper indentation given by `repeat("   ", level)`, i.e., four white-spaces are repeated `level`-times. On the second-line, we call the `subtypes_tree` function recursively for all subtypes of the type `T` and level of indentation `level + 1`.

```@raw html
</p></details>
```

Now we can use the `subtypes_tree` function to get the whole subtypes hierarchy for the `Number` type

```jldoctest methods
julia> subtypes_tree(Number)
Number
   Complex
   Real
      AbstractFloat
         BFloat16s.BFloat16
         BigFloat
         Float16
         Float32
         Float64
      AbstractIrrational
         Irrational
      FixedPointNumbers.FixedPoint
         FixedPointNumbers.Fixed
         FixedPointNumbers.Normed
      ForwardDiff.Dual
      Integer
         Bool
         GeometryBasics.OffsetInteger
         Signed
            BigInt
            Int128
            Int16
            Int32
            Int64
            Int8
         Unsigned
            UInt128
            UInt16
            UInt32
            UInt64
            UInt8
      Rational
      Ratios.SimpleRatio
      StatsBase.TestStat
   SLEEFPirates.Double
   VectorizationBase.Static
```

From the tree of all subtypes of the abstract type `Number`, we see the whole structure of Julia's numerical types. So if we want to define a function that accepts all numeric types, we should use inputs of type `Number`. However, many operations are restricted to only real numbers. In such a case, we want to use the `Real` type instead of `Number`.

Now we can go back to our example with the `product` function. The problem with this function is that it is too restrictive since the product of two strings is a legitimate operation that should return their concatenation. So we should define a method for strings. To use the proper type, we can use the `supertypes_tree` function for the `String` type

```jldoctest methods
julia> supertypes_tree(String)
String
   AbstractString
```

We see that the *largest* supertype for `String` is the `AbstractString`, and that is the type we should use

```jldoctest methods; output = false
product(x::AbstractString, y::AbstractString) = x * y
product(x, y) = throw(ArgumentError("product is defined for numbers and strings only."))

# output
product (generic function with 3 methods)
```

We also redefined the original definition of the `product` function to throw an appropriate error.

```jldoctest methods
julia> product(1, 4.5)
4.5

julia> product("a", "b")
"ab"

julia> product(:a, :b)
ERROR: ArgumentError: product is defined for numbers and strings only.
```

Sometimes, it can be very complicated to guess which method will be used for concrete inputs. In such a case, there is a useful macro `@which` that returns the method that would be called for given arguments

```jldoctest methods
julia> using InteractiveUtils: @which

julia> @which product(1, 4.5)
product(x::Number, y::Number) in Main at none:1

julia> @which product("a", :a)
product(x, y) in Main at none:1

julia> @which product("a", "b")
product(x::AbstractString, y::AbstractString) in Main at none:1
```

The previous example with the `product` function shows how methods in Julia works. However, it is a good practice to use type annotation only if we want to have a specialized function or if we want to define a function, which does different things for different types of input arguments.

```jldoctest methods; output = false
g(x::Real) = x + 1
g(x::String) = repeat(x, 4)

# output
g (generic function with 2 methods)
```

For example, the `g` function returns `x + 1` if the input `x` is a real number or repeats four times the input argument if it is a string. Otherwise, it will throw a method error since we define only these two specific methods.

```jldoctest methods
julia> g(1.2)
2.2

julia> g("a")
"aaaa"

julia> g(:a)
ERROR: MethodError: no method matching g(::Symbol)
Closest candidates are:
  g(!Matched::String) at none:1
  g(!Matched::Real) at none:1
```

```@raw html
<div class = "info-body">
<header class = "info-header">Do not overuse type annotation!!!</header><p>
```

The `product` function should be defined without the type annotation. It is a good practice not to restrict input argument types if it is not necessary. The reason is that, in this case, there is no benefit of using the type annotation. If we define a function `product_new` in the following way

```jldoctest methods; output = false
product_new(x, y) = x * y

# output
product_new (generic function with 1 method)
```

Then we can apply this function to the same inputs as the original `product` function, and we will get the same results

```jldoctest methods
julia> product(1, 4.5)
4.5

julia> product_new(1, 4.5)
4.5

julia> product("a", "b")
"ab"

julia> product_new("a", "b")
"ab"
```

with only one exception

```jldoctest methods
julia> product("a", :a)
ERROR: ArgumentError: product is defined for numbers and strings only.

julia> product_new("a", :a)
ERROR: MethodError: no method matching *(::String, ::Symbol)
[...]
```

Here we get a different error, but the error given by the `product_new` function is more useful since it tells us what the real problem is. We can see that it is not possible to use the `*` operator to multiply `String` and `Symbol`. Now we can decide if it is the desired behavior, and if not, we can define a method for the `*` operator that will fix it.

```@raw html
</p></div>
```

## Method Ambiguities

It is possible to define a set of function methods such that there is no unique most specific method applicable to some combinations of arguments

```jldoctest methods_amb; output = false
f(x::Float64, y) = x * y
f(x, y::Float64) = x + y

# output
f (generic function with 2 methods)
```

Here, the `f` function has two methods. The first method applies if the first argument is of type `Float64`, and the second method applies if the second argument is of type `Float64`
```jldoctest methods_amb
julia> f(2.0, 3)
6.0

julia> f(2, 3.0)
5.0
```

The case where both arguments are of type `Float64` can be handled by both methods. The problem is that neither method is more specific than the other. In such cases, Julia raises a `MethodError` rather than arbitrarily picking a method

```jldoctest methods_amb
julia> f(2.0, 3.0)
ERROR: MethodError: f(::Float64, ::Float64) is ambiguous. Candidates:
  f(x::Float64, y) in Main at none:1
  f(x, y::Float64) in Main at none:1
Possible fix, define
  f(::Float64, ::Float64)
```

We can avoid method ambiguities by specifying an appropriate method for the intersection case

```jldoctest methods_amb
julia> f(x::Float64, y::Float64) = x - y
f (generic function with 3 methods)
```

Now we can see that the `f` function has three methods

```jldoctest methods_amb
julia> f(2.0, 3.0)
-1.0
```
