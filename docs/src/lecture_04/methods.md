# Methods

So far, we defined all functions (with some exceptions) without annotating the types of input arguments. When the type annotation is omitted, the default behaviour in Julia is to allow values to be of any type. One can write many useful functions without stating the types. When additional expressiveness is needed, it is easy to introduce type annotations into previously *untyped* code.

In Julia, one function consists of multiple methods. A prime example is the `convert` function. When a user calls a function, the process of choosing which method to execute is called dispatch. The dispatch system in Julia decides which method to execute based on:

- the number of function arguments;
- the types of function arguments.

Using all function arguments to choose which method should be invoked is known as **multiple dispatch**.

As an example of multiple dispatch, we define the `product` function that computes the product of two numbers.

```jldoctest methods
julia> product(x, y) = x * y
product (generic function with 1 method)
```

In the REPL, we can see that the `product` function has only one method. In this case, we defined the method for any two input arguments without type specification.

```jldoctest methods
julia> product(1, 4.5)
4.5

julia> product(2.4, 3.1)
7.4399999999999995
```

The `methods` function lists all methods for a function.

```jldoctest methods
julia> methods(product)
# 1 method for generic function "product":
[1] product(x, y) in Main at none:1
```

Because we did not specify types of input arguments, the `product` function accepts arguments of all types. For some inputs, such as symbols, the `*` operator will not work.

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

The second line redefined the original definition of the `product` function. It now throws an error if `product` is called with non-numeric inputs.

```jldoctest methods
julia> methods(product)
# 2 methods for generic function "product":
[1] product(x::Number, y::Number) in Main at none:1
[2] product(x, y) in Main at none:1
```

Now, we have a function with two methods, that returns a product if the input arguments are numbers, and throws an error otherwise.

```jldoctest methods
julia> product(1, 4.5)
4.5

julia> product(:a, :b)
ERROR: ArgumentError: product is defined for numbers only.

julia> product("a", "b")
ERROR: ArgumentError: product is defined for numbers only.
```

## Type hierarchy

It is always better to use abstract types like `Number` or `Real` instead of concrete types like `Float64`, `Float32`, or `Int64`. The reason is that if we use an abstract type, the function will work for all its subtypes. To find a supertype for a specific type, we can use the `supertype` function from the `InteractiveUtils` package.

```jldoctest methods
julia> using InteractiveUtils: supertype

julia> supertype(Float64)
AbstractFloat
```

The problem with the `supertype` function is that it does not return the whole supertype hierarchy, but only the closest *larger* supertype. For `Float64` the closest larger supertype is `AbstractFloat`. However, as in the example above, we do not want to use this supertype, since then the function will only work for floating point numbers.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body">
```

Create a function `supertypes_tree` which prints the whole tree of all supertypes. If the input type `T` satisfies the following condition `T === Any`, then the function should do nothing. Use the following function declaration:

```julia
function supertypes_tree(T::Type, level::Int = 0)
    # code
end
```

The optional argument `level` sets the printing indentation level.

**Hints:**
- Use the `supertype` function in combination with recursion.
- Use the `repeat` function and string with white space `"    "` to create a proper indentation.

```@raw html
</div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The `supertypes_tree` function can be defined by:

```jldoctest methods; output = false
function supertypes_tree(T::Type, level::Int = 0)
    isequal(T, Any) && return
    println(repeat("   ", level), T)
    supertypes_tree(supertype(T), level + 1)
    return
end

# output
supertypes_tree (generic function with 2 methods)
```

The first line checks if the given input type is `Any`. If yes, then the function returns nothing. Otherwise, the function prints the type with a proper indentation provided by `repeat("   ", level)`, i.e., four white-spaces repeated `level`-times. The third line calls the `supertypes_tree` function recursively for the supertype of the input type `T` and the level of indentation `level + 1`.

```@raw html
</p></details>
```

Now we can use the `supertypes_tree` function to get the whole supertype hierarchy for `Float64`.

```julia
julia> supertypes_tree(Float64)
Float64
   AbstractFloat
      Real
         Number
```

We can check the type hierarchy by the `<:` operator for comparing types: If `T1 <: T2` is true, then `T1` is a subtype (or the same type) of `T2`.

```jldoctest methods
julia> Float64 <: AbstractFloat <: Real <: Number
true
```

Similarly to the `supertype` function, there is the `subtypes` function that returns all subtypes for the given type.

```julia
julia> using InteractiveUtils: subtypes

julia> subtypes(Number)
2-element Vector{Any}:
 Complex
 Real
```

This function suffers from a similar disadvantage as the `supertype` function: It is impossible to get the whole hierarchy of all subtypes using only this function.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body">
```

Create a function `subtypes_tree` which prints the whole tree of all subtypes for the given type. Use the following function declaration:

```@meta
DocTestSetup = quote
   using InteractiveUtils: subtypes
end
```

```julia
function subtypes_tree(T::Type, level::Int = 0)
    # code
end
```

The optional argument `level` sets the printing indentation level.

**Hints:**
- Use the `subtypes` function in combination with recursion.
- Use the `repeat` function and string with white space `"    "` to create a proper indentation.

```@raw html
</div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The `subtypes_tree` function is similar to `supertypes_tree`. The only differences are that we do not need to check for the top level of `Any`, and that we need to call the vectorized version `subtypes_tree.` because `subtypes(T)` returns an array.

```jldoctest methods; output = false
function subtypes_tree(T::Type, level::Int = 0)
    println(repeat("   ", level), T)
    subtypes_tree.(subtypes(T), level + 1)
    return
end

# output
subtypes_tree (generic function with 2 methods)
```

```@raw html
</p></details>
```

Now we can use the `subtypes_tree` function to get the whole subtypes hierarchy for the `Number` type.

```julia
julia> subtypes_tree(Number)
Number
   Complex
   Real
      AbstractFloat
         BigFloat
         Float16
         Float32
         Float64
      AbstractIrrational
         Irrational
      Integer
         Bool
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
```

This tree shows the whole structure of Julia numerical types. If we want to define a function that accepts all numeric types, we should use inputs of type `Number`. However, many operations are restricted to only real numbers. In such a case, we want to use the `Real` type instead of `Number`.


## Multiple dispatch

Now we can go back to our example with the `product` function. The problem with this function is that it is too restrictive because the product of two strings is a legitimate operation that should return their concatenation. We should define a method for strings. To use the proper type, we can use the `supertypes_tree` function for the `String` type.

```jldoctest methods
julia> supertypes_tree(String)
String
   AbstractString
```

We see that the *largest* supertype for `String` is `AbstractString`. This leads to

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

Sometimes, it may be complicated to guess which method is used for concrete inputs. In such a case, there is a useful macro `@which` that returns the method that is called for given arguments.

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

For example, the `g` function returns `x + 1` if the input `x` is a real number or repeats four times the input argument if it is a string. Otherwise, it will throw a method error.

```jldoctest methods
julia> g(1.2)
2.2

julia> g("a")
"aaaa"

julia> g(:a)
ERROR: MethodError: no method matching g(::Symbol)
Closest candidates are:
  g(!Matched::Real) at none:1
  g(!Matched::String) at none:1
```



```@raw html
<div class="admonition is-info">
<header class="admonition-header">Do not overuse type annotation:</header>
<div class="admonition-body">
```

The `product` function should be defined without the type annotation. It is a good practice not to restrict input argument types unless necessary. The reason is that, in this case, there is no benefit of using the type annotation. It is better to define the function `product_new` by:

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

Here we get a different error. However, the error returned by the `product_new` function is more useful because it tells us what the real problem is. We can see that it is impossible to use the `*` operator to multiply a `String` and a `Symbol`. We can decide if this is the desired behaviour, and if not, we can define a method for the `*` operator that will fix it.

```@raw html
</div></div>
```

We show a simple example when the multiple dispatch is useful.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body">
```

We define the abstract type `Student` and specific types `Master` and `Doctoral`. The latter two are defined as structures containing one and three fields, respectively.

```@example methods
abstract type Student end

struct Master <: Student
    salary
end

struct Doctoral <: Student
    salary
    exam_mid::Bool
    exam_english::Bool
end

nothing # hide
```

We can check that the `subtypes_tree` works correctly on any type, including the type `Student` which we defined.

```julia
julia> subtypes_tree(Student)
Student
   Doctoral
   Master
```

We create instances of two students by providing values for the struct fields.

```@example methods
s1 = Master(5000)
s2 = Doctoral(30000, 1, 0)

nothing # hide
```

Write the `salary_yearly` function which computes the yearly salary for both student types. The monthly salary is computed from the base salary (which can be accessed via `s1.salary`). Monthly bonus for doctoral students is 2000 for the mid exam and 1000 for the English exam.

```@raw html
</div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Julia prefers to write many simple functions. We write `salary_yearly` based on the not-yet-defined `salary_monthly` function.

```@example methods
salary_yearly(s::Student) = 12*salary_monthly(s)

nothing # hide
```

We specified that the input to `salary_yearly` is any `Student`. Since `Student` is an abstract type, we can call `salary_yearly` with both `Master` and `Doctoral` student. Now we need to define the `salary_monthly` function. Since the salary is computed in different ways for both students, we write two methods.

```@example methods
salary_monthly(s::Master) = s.salary
salary_monthly(s::Doctoral) = s.salary + s.exam_mid*2000 + s.exam_english*1000

nothing # hide
```

Both methods have the same name (they are the same function) but have different inputs. While the first one is used for `Master` students, the second one for `Doctoral` students. Now we print the salary.

```@example methods
println("The yearly salary is $(salary_yearly(s1)).")
println("The yearly salary is $(salary_yearly(s2)).")

nothing # hide
```

```@raw html
</p></details>
```

## Method ambiguities

It is possible to define a set of function methods with no most specific method applicable to some combinations of arguments.

```jldoctest methods_amb; output = false
f(x::Float64, y) = x * y
f(x, y::Float64) = x + y

# output
f (generic function with 2 methods)
```

Here, `f` has two methods. The first method applies if the first argument is of type `Float64`, and the second method applies if the second argument is of type `Float64`.

```jldoctest methods_amb
julia> f(2.0, 3)
6.0

julia> f(2, 3.0)
5.0
```

Both methods can be used if both arguments are of type `Float64`. The problem is that neither method is more specific than the other. This results in `MethodError`.

```jldoctest methods_amb
julia> f(2.0, 3.0)
ERROR: MethodError: f(::Float64, ::Float64) is ambiguous. Candidates:
  f(x::Float64, y) in Main at none:1
  f(x, y::Float64) in Main at none:1
Possible fix, define
  f(::Float64, ::Float64)
```

We can avoid method ambiguities by specifying an appropriate method for the intersection case.

```jldoctest methods_amb
julia> f(x::Float64, y::Float64) = x - y
f (generic function with 3 methods)
```

Now `f` has three methods.

```jldoctest methods_amb
julia> f(2.0, 3.0)
-1.0
```
