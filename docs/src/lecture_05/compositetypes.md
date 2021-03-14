# Abstract types

In Julia, abstract types cannot be instantiated and are used to create a logical hierarchy of types. This can be seen in the hierarchy of numeric types introduced in the first lecture.

![](types.svg)

All types depicted in blue are abstract types. Note that Julia provides a variety of concrete types of numeric values. Although they have different representation sizes, `Int8`, `Int16`, `Int32`, `Int64`, and `Int128` all have in common that they are signed integer types. Likewise, `UInt8`, `UInt16`, `UInt32`, `UInt64`, and `UInt128` are all unsigned integer types, while `Float16`, `Float32`, and `Float64` are distinct in being floating-point types rather than integers. It is common for a piece of code to make sense, for example, only if its arguments are some integer, but not depend on what particular kind of integer. For example, the greatest common denominator algorithm works for all kinds of integers but will not work for floating-point numbers. Abstract types allow the construction of a hierarchy of types, providing a context into which concrete types can fit.

Abstract types can be defined using the `abstract type` keyword followed by the type's name. Optionally, it is possible to specify that the type is a subtype of another existing abstract type. For example, the hierarchy of numeric types presented above can be defined as follows.

```julia
abstract type Number end
abstract type Real <: Number end
abstract type AbstractFloat <: Real end
abstract type AbstractIrrational <: Real end
abstract type Integer <: Real end
abstract type Signed <: Integer end
abstract type Unsigned <: Integer end
```

When no supertype is given, the default supertype is `Any`, i.e., in our example, the `Number` type is a subtype of `Any`. The `Any` type is sometimes called the *top* type since all types are its subtypes. In Julia, there is also the *bottom* type `Union{}`.  It is the exact opposite of the `Any` type since no object is an instance of `Union{}` and all types are supertypes of `Union{}`.

The `<:` operator can be used in expressions as a subtype operator that returns `true` when its left operand is a subtype of its right operand.

```jldoctest
julia> Signed <: Integer
true

julia> Signed <: Number
true

julia> Signed <: AbstractFloat
false
```

Julia also provides the `isa` function, which can be used to test if the given variable is an instance of some type or subtype of some abstract type.

```jldoctest
julia> isa(1, Int64) # equivalent to typeof(1) <: Int64
true

julia> isa(1, Integer) # equivalent to typeof(1) <: Integer
true

julia> isa(1, AbstractFloat) # equivalent to typeof(1) <: AbstractFloat
false
```

Another handy function is the `isabstracttype` function that checks whether the given type is abstract or not.

```jldoctest
julia> isabstracttype(Real)
true

julia> isabstracttype(Float64)
false
```

Similarly, the `isconcretetype` function checks whether the given type is concrete or not.

```jldoctest
julia> isconcretetype(Real)
false

julia> isconcretetype(Float64)
true
```

# Composite types

A composite type is a collection of pairs of keys and values, and its instance of which can be treated as a single value. In many languages, composite types are the only kind of user-definable type. In Julia, it is possible to define also other types (primitive types, for example). However, composite types are by far the most used.

In object-oriented languages, such as Python or Java, composite types also have named functions associated with them, and the combination is called an *object*.  In Julia, all values are objects, but functions are not bundled with the objects they operate on. This is necessary since Julia chooses which method of function to use by multiple-dispatch. It means that the types of all of a function's arguments are considered when selecting a method, rather than just the first one. Thus, it would be inappropriate for functions to "belong" to only their first argument. Organizing methods into function objects rather than having named bags of methods "inside" each object ends up being a highly beneficial language design aspect.

Composite types can be defined using the `struct` keyword followed by the type name and field names that can be optionally annotated with types.

```jldoctest structs; output = false
struct Foo
    a
    b::Int
end

# output

```

Note that if the type annotation of the field is omitted,  the `Any` type is used by default, i.e., such a field can contain any value. Also, note that there is a convention in Julia that the first letter of each word in custom type names is in uppercase. We can create a new instance of the above type by calling `Foo` as a function with input arguments representing fields of the `Foo` type.

```jldoctest structs
julia> foo = Foo([1,2,3], 4)
Foo([1, 2, 3], 4)

julia> isa(foo, Foo)
true
```

When a type is applied like a function, it is called a constructor. By default, two constructors are generated automatically. One accepts any arguments and calls convert to convert them to the fields' types, and the other accepts arguments that match the field's types exactly. If all fields are of type `Any` (or we do not specify their types), the later constructor is not generated.  We can list all constructors using the `methods` function.

```jldoctest structs
julia> methods(Foo)
# 2 methods for type constructor:
[1] Foo(a, b::Int64) in Main at none:2
[2] Foo(a, b) in Main at none:2
```

By default, Julia generates these two constructors because it makes it easier to add new definitions without inadvertently replacing a default constructor.

The fields of composite types can be accessed via dot notation similarly to named tuples.

```jldoctest structs
julia> foo.a
3-element Array{Int64,1}:
 1
 2
 3

julia> foo.b
4
```

Internally `foo.a` is just a shortcut for the `getproperty(foo, :a)`.

```jldoctest structs
julia> getproperty(foo, :a)
3-element Array{Int64,1}:
 1
 2
 3

julia> getproperty(foo, :b)
4
```

There is also a convenient function, `fieldnames`, that returns a tuple with names of all fields of a given composite type. Note that all field names are represented as symbols.

```jldoctest structs
julia> fieldnames(Foo)
(:a, :b)
```

Composite types declared with `struct` are immutable, i.e., they cannot be modified after construction.

```jldoctest structs
julia> foo.a = 1
ERROR: setfield! immutable struct of type Foo cannot be changed
```

Composite types declared with `struct` are immutable, i.e., they cannot be modified after construction.

However, immutability is not recursive. It means that if an immutable object contains a mutable object (such as an array), we can modify elements of the mutable object. We can observe this behavior in the following example. The `Foo` type is defined as immutable, but we instantiate the `foo` object with a vector as a first argument. Since a vector is mutable, we can modify its elements.

```jldoctest structs
julia> foo.a[1] = 5
5

julia> foo.a
3-element Array{Int64,1}:
 5
 2
 3
```

Mutable composite types can be declared in a similar way as immutable ones. The only difference is that we have to add the `mutable` keyword before the `struct` keyword.

```jldoctest structs; output = false
mutable struct MutableFoo
    a
    b::Int
end

# output

```

Instances of mutable types are created in the same way as in the case of immutable ones.

```jldoctest structs
julia> mfoo = MutableFoo([1,2,3], 4)
MutableFoo([1, 2, 3], 4)

julia> isa(mfoo, MutableFoo)
true
```

There are two ways how to change fields of mutable types. The first one is to use the `setproperty!` function. The second one is to use the shorthand dot syntax to access the field and the `=` operator to assign a new value.

```jldoctest structs
julia> mfoo.a = 2.345
2.345

julia> setproperty!(mfoo, :a, 2)
2

julia> mfoo
MutableFoo(2, 4)
```

Note that the syntax `mfoo.a = 2.345` is equivalent to `setproperty!(mfoo, :a, 2.345)`.

```@raw html
<div class = "info-body">
<header class = "info-header">Type unions</header><p>
```

A type union is a special abstract type that includes all instances of any of its argument types. Type unions can be constructed using the `Union` keyword.

```jldoctest structs
julia> AbstractFoo = Union{Foo, MutableFoo}
Union{Foo, MutableFoo}

julia> Foo <: AbstractFoo
true

julia> MutableFoo <: AbstractFoo
true
```

The `Union` type can be very useful in many cases. For example, if there is no supertype for multiple types, but we want to write a specialized function that can be used for all of them. In such a case, we can use the type `Union` and write one function with type annotation to all of them at once.

```jldoctest structs
julia> geta(foo::AbstractFoo) = foo.a
geta (generic function with 1 method)

julia> geta(foo) == foo.a
true

julia> geta(mfoo) == mfoo.a
true
```

```@raw html
</p></div>
```

## Parametric types

An important and powerful feature of Julia's type system is that it is parametric: types can take parameters. It means that type declaration actually introduces a whole family of new types (one for each possible combination of parameter values). Parametric abstract and composite types can be defined as follows.

```jldoctest structs; output = false
abstract type AbstractPoint{T} end

struct Point{T <: Real} <: AbstractPoint{T}
    x::T
    y::T
end

# output

```

In the example above, we defined one parametric abstract type, `AbstractPoint`, and its parametric subtype `Point`. The declaration of the concrete type `Point{T <: Real}` has two fields of type `T`, where `T` can be any subtype of `Real`. This definition ensures that both fields are always of the same type. Note that `Point{Float64}` is a concrete type equivalent to the type defined by replacing `T` in the definition of `Point` with `Float64`.

```jldoctest structs
julia> isconcretetype(Point{Float64})
true

julia> isconcretetype(Point{Int64})
true
```

Thus, this single declaration actually declares concrete type for each subtype `T` of `Real`.  The `Point` type itself is also a valid type object, containing all instances `Point{Float64}`, `Point{Int64}`, etc., as subtypes.

```jldoctest structs
julia> Point{Float64} <: Point <: AbstractPoint
true

julia> Point{Int64} <: Point <: AbstractPoint
true
```

However, concrete `Point{T}` types with different `T` values are never subtypes of each other. Even though `Float64` is a subtype of ` Real`, the `Point{Float64}` is not a subtype of  `Point{Real}`.

```jldoctest structs
julia> Point{Float64} <: Point{Real}
false

julia> Point{Float64} <: AbstractPoint{Float64}
true

julia> Point{Float64} <: AbstractPoint{Real}
false
```

This behavior is for practical reasons: while any instance of `Point{Float64}` may conceptually be like an instance of `Point{Real}` as well, the two types have different representations in memory:

- An instance of `Point{Float64}` can be represented compactly and efficiently as an immediate pair of 64-bit values.
- An instance of `Point{Real}` must be able to hold any pair of instances of `Real`. Since objects that are instances of `Real` can be of arbitrary size and structure, in practice, an instance of `Point{Real}` must be represented as a pair of pointers to individually allocated `Real` objects.

The efficiency gained by being able to store `Point{Float64}` objects with immediate values is magnified enormously in the case of arrays: an `Array{Float64}` can be stored as a contiguous memory block of 64-bit floating-point values, whereas an `Array{Real}` must be an array of pointers to individually allocated `Real` objects - which may well be boxed 64-bit floating-point values, but also might be arbitrarily large, complex objects, which are declared to be implementations of the `Real` abstract type.

Since `Point{Float64}` is not a subtype of `Point{Real}`, the following method can't be applied to arguments of type `Point{Float64}`.

```julia structs
julia> coordinates(p::Point{Real}) = (p.x, p.y)

julia> coordinates(Point(1,2))
ERROR: MethodError: no method matching coordinates(::Point{Int64})
[...]

julia> coordinates(Point(1.0,2.0))
ERROR: MethodError: no method matching coordinates(::Point{Float64})
[...]
```

A correct way to define a method that accepts all arguments of type `Point{T}` where `T` is a subtype of `Real` is as follows.

```jldoctest structs
julia> coordinates(p::Point{<:Real}) = (p.x, p.y)
coordinates (generic function with 1 method)

julia> coordinates(Point(1,2))
(1, 2)

julia> coordinates(Point(1.0,2.0))
(1.0, 2.0)
```

Or simply use the `Point` type without specified parameter. It is also possible to define a function for all subtypes of some abstract type.

```jldoctest structs
julia> Base.show(io::IO, p::AbstractPoint) = print(io, coordinates(p))

julia> Point(4, 2)
(4, 2)

julia> Point(0.2, 1.3)
(0.2, 1.3)
```

There are two ways how to instantiate the `Point` type.  The first way is to create an instance of `Point{T}` without specifying the `T` parameter and letting Julia decide which type should be used.  The second way is to specify the `T` parameter manually.

```jldoctest structs
julia> Point(1, 2)
(1, 2)

julia> Point{Float32}(1, 2)
(1.0f0, 2.0f0)
```

Note that the default constructors work only if we use arguments with the same type or if we specify the `T` parameter manually. In all other cases, an error will occur.

```jldoctest structs
julia> Point(1, 2.0)
ERROR: MethodError: no method matching Point(::Int64, ::Float64)
Closest candidates are:
  Point(::T, !Matched::T) where T<:Real at none:3
```

This situation can be handled by defining custom constructors, as discussed in the next section.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Define a structure that represents 3D-point. Do not forget to define it as a subtype of the AbstractPoint type. Also, add a new method to the `coordinates` function.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Since we did not specify what the structure should look like, there are several possibilities for defining it. For example, we can define it as a structure with three fields as in the code below. Another option is to use, for example, a tuple to store the point coordinates.

```jldoctest structs; output = false
struct Point3D{T <: Real} <: AbstractPoint{T}
    x::T
    y::T
    z::T
end

coordinates(p::Point3D) = (p.x, p.y, p.z)

# output

coordinates (generic function with 2 methods)
```

Note that since the `show` function was defined for the abstract type `AbstractPoint` and uses the `coordinates` function, the custom print is immediately applied to the new type.

```jldoctest structs
julia> Point3D(1, 2, 3)
(1, 2, 3)

julia> Point3D{Float32}(1, 2, 3)
(1.0f0, 2.0f0, 3.0f0)
```

```@raw html
</p></details>
```

## Constructors

Constructors are functions that create new instances of composite types. When the user defines a new composite type,  Julia creates default constructors. However, sometimes it is very useful to add additional constructors. As an example, we can mention the case from the end of the previous section. In this case, it makes sense to have the ability to create an instance of the `Point` type from two numbers that can be of any subtypes of `Real`. This can be achieved by defining the following constructor.

```jldoctest structs; output = false
Point(x::Real, y::Real) = Point(promote(x, y)...)

# output

Point
```

Note that we use the `promote` function. This function converts its arguments to the type that can safely represent their types. For example, if we call `promote(1, 2.3)` the result will be a tuple `(1.0, 2.3)` because it is possible to represent `Int64` using `Float64` (not precisely), but it is not possible to represent `Float64` using `Int64`. We can test the new constructor on the example from the end of the previous section.

```jldoctest structs
julia> Point(1, 2.0)
(1.0, 2.0)

julia> typeof(Point(1, 2.0))
Point{Float64}
```

As expected, the result is of type `Point{Float64}`. The constructor defined above is called an outer constructor because it is defined outside the type definition. A constructor is just like any other function in Julia, i.e., its methods' combined behavior defines its overall behavior. Accordingly, you can add functionality to a constructor by defining new methods.

Outer constructors can be used to provide additional convenience methods for constructing objects. However, they can not be used to constructing self-referential objects or if we want to ensure that the resulting instance has some special properties. In such a case, we have to use inner constructors.  An inner constructor method is like an outer constructor method, except for two differences.

1. It is declared inside the block of a type declaration rather than outside of it like normal methods.
2. It has access to a special locally existent function called `new` that creates objects of the block's type.

For example, suppose one wants to declare a type that holds a pair of real numbers, subject to the constraint that the first number is not greater than the second one. One could declare it like this.

```jldoctest ordered; output = false
struct OrderedPair{T <: Real}
    x::Real
    y::Real

    function OrderedPair(x::Real, y::Real)
        x > y && error("out of order")
        xp, yp = promote(x, y)
        return new{typeof(xp)}(xp, yp)
    end
end

# output

```

If the user defines any inner constructor method, **no additional constructor method is defined by default**.  The example above means that any instance of the `OrderedPair` has to meet the assumption that `x <= y`.

```jldoctest ordered
julia> OrderedPair(1,2)
OrderedPair{Int64}(1, 2)

julia> OrderedPair(2,1)
ERROR: out of order
[...]
```

Moreover, outer constructor methods can only create objects by calling other constructor methods, i.e., some inner constructor must be called to create an object. It means that even if we add any number of outer constructors, the resulting object is created by the inner constructor and therefore has to meet its assumptions.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Define a structure that represents ND-point and stores coordinates as `NTuple` type. Do not forget to define it as a subtype of the `AbstractPoint` type. Also, add a new method to the `coordinates` function. Redefine the default inner constructor to create an instance of the `PointND` directly from different types' values.

**Hint:** use the `new` function in the definition of the new inner constructor.

**Hint:** in the `NTuple{N, T}` type, `N` represents a number of elements and `T` their type. Use similar notation in the definition of the `PointND` to specify a dimension.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

In this case, we can use an inner constructor with the optional number of input arguments. In the definition below, we use type annotation to set these arguments to be real numbers. Since we use the `new` function and our type is parametric, we have to specify `N` and type `T`.

```jldoctest structs; output = false
struct PointND{N, T <: Real} <: AbstractPoint{T}
    x::NTuple{N, T}

    function PointND(args::Real...)
        vals = promote(args...)
        return new{length(args), eltype(vals)}(vals)
    end
end

coordinates(p::PointND) = p.x

# output

coordinates (generic function with 3 methods)
```

Note that since the `show` function was defined for the abstract type `AbstractPoint` and uses the `coordinates` function, the custom print is immediately applied to the new type. Also note, that since we redefined the default constructors, we can create an instance of the `PointND` type from inputs of mixed types.

```jldoctest structs
julia> PointND(1, 2)
(1, 2)

julia> PointND(1, 2.2, 3, 4.5)
(1.0, 2.2, 3.0, 4.5)
```

```@raw html
</p></details>
```

## Default field values

In many cases, it is beneficial to define custom types with default field values. This can be achieved by defining a constructor that uses optional or keyword arguments. Another option is to use the `@kwdef` macro from the `Base`. This macro automatically defines a keyword-based constructor.

```jldoctest structs; output = false
Base.@kwdef struct MyType
    a::Int # required keyword
    b::Float64 = 2.3
    c::String = "hello"
end

# output

MyType
```

We can use the `methods` function to check which constructors have been created. As can be seen, there are three constructors.  The first constructor is the one created by the `@kwdef` macro. The latter two are the default constructors created since we did not provide any inner constructor.

```jldoctest structs
julia> methods(MyType)
# 3 methods for type constructor:
[1] MyType(; a, b, c) in Main at util.jl:438
[2] MyType(a::Int64, b::Float64, c::String) in Main at none:2
[3] MyType(a, b, c) in Main at none:2
```

The instance of the `MyType` type can be created using the default constructors as follows.

```jldoctest structs
julia> MyType(1, 2.3, "aaa")
MyType(1, 2.3, "aaa")
```

The other way is to use the constructor with predefined field values. In such a case, all values have to be passed as keyword arguments. The fields without default values are mandatory keyword arguments, i.e., we have to specify them.

```jldoctest structs
julia> MyType(; a = 3)
MyType(3, 2.3, "hello")

julia> MyType(; a = 5, b = 4.5)
MyType(5, 4.5, "hello")
```

```@raw html
<div class = "info-body">
<header class = "info-header">Function-like objects</header><p>
```
Methods are associated with types, so it is possible to make any arbitrary Julia object "callable" by adding methods to its type. Such "callable" objects are sometimes called "functors." Using this technique to the `MyType` defined above, we can define a method that returns all field's values as a tuple.

```jldoctest structs
julia> (m::MyType)() = (m.a, m.b, m.c)

julia> m = MyType(; a = 5, b = 4.5)
MyType(5, 4.5, "hello")

julia> m()
(5, 4.5, "hello")
```

Moreover, we can use multiple-dispatch to define other methods. The first method for a given real number computes a simple linear and uses fields `a`, `b` of the `MyType` as slope and intercept. The second method creates a string from the given string and a field `c` of the `MyType`.

```jldoctest structs; output = false
(m::MyType)(x::Real) = m.a*x + m.b
(m::MyType)(x::String) = "$(m.c), $(x)"

# output

```

If we use these two methods and the instance of the `MyType` defined in the example above,  we get the following results.

```jldoctest structs
julia> m(1)
9.5

julia> m("world")
"hello, world"
```

```@raw html
</p></div>
```


```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Write a structure `Gauss` that will represent a [Gaussian distribution](https://en.wikipedia.org/wiki/Normal_distribution). Write an inner constructor that checks if the given parameters are correct. Initialization without arguments `Gauss()` should return the standardized normal distribution (`` \mu = 0`` and `` \sigma = 1``).  Define a functor that computes the probability density function in the given point. Recall that the probability density function for the Gaussian distribution is defined as follows.

```math
f_{\mu, \sigma}(x) = \frac{1}{\sigma \sqrt{ 2\pi }} \exp\left\{ -\frac{1}{2} \left( \frac{x - \mu}{\sigma} \right) ^2 \right\},
```

where ``\mu \in \mathbb{R}`` and ``\sigma^2 > 0``. Verify that the probability density function is defined correctly, i.e., its integral equals 1. Create a plot of the probability density function.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

One of the possible ways how to define structure from the description of the exercise is the following. We use the `@kwdef` macro to define the default values of the parameters. We also defined an inner constructor that checks if the variance is positive.

```jldoctest structs_gauss; output = false
Base.@kwdef struct Gauss{T<:Real}
    μ::T = 0
    σ::T = 1

    function Gauss(μ::Real, σ::Real)
        σ > 0 || error("the variance `σ^2` must be positive")
        pars = promote(μ, σ)
        return new{eltype(pars)}(pars...)
    end
end

# output

```

Note that in the inner constructor, we use the `promote` function and that we specify the parameter `T` in the call of the `new` function. The probability density function can be defined as a functor in the following way.


```jldoctest structs_gauss; output = false
(d::Gauss)(x::Real) = exp(-1/2 * ((x - d.μ)/d.σ)^2)/(d.σ * sqrt(2*π))

# output

```

We used type annotation to ensure that all input arguments are real numbers.

```jldoctest structs_gauss
julia> gauss = Gauss()
Gauss{Int64}(0, 1)

julia> gauss(0)
0.3989422804014327
```

The integral of the probability density function over all real numbers should equal one. We can check it numerically by discretizing the integral into a finite sum.

```jldoctest structs_gauss
julia> step = 0.01
0.01

julia> x = -100:step:100;

julia> sum(Gauss(), x) * step
1.0000000000000002

julia> sum(Gauss(0.1, 2.3), x) * step
1.0
```

We use the `sum` function, which can accept a function as the first argument and apply it to each value before summation. Since we defined a functor for the `Gauss` type, we can pass its instance as the fits argument, and the result will be the same as if we use `sum(Gauss().(x))`. The difference is that the former, similarly to generators, does not allocate an array.

We can also visualize the probability density functions with the [Plots.jl](https://github.com/JuliaPlots/Plots.jl) package. Unfortunately, we cannot use the syntax for the plotting function described in the [Function plotting](@ref Function-plotting) section, i.e., the following will not work even though the `Gauss` type is callable.

```julia
plot(x, Gauss())
```

However, we can define a custom plot for our type using the `@recipe` macro. The syntax is straightforward. In the function head, we define two inputs: our type and some input `x`. Then in the function body, we define plot attributes in the same way as if we pass them in the `plot` function. Finally, we define the output of the function. Note that we use two different syntaxes for defining plot attributes. If we use `:=` operator, the attribute will be set to the provided value and can not be changed by the user. On the other hand, if we use `-->` operator, the provided value is used as default and can be changed by the user.

```julia
using Plots

@recipe function f(d::Gauss, x)
    seriestype := :path
    label --> "Gauss(μ = $(d.μ), σ = $(d.σ))"
    xguide --> "x"
    yguide --> "f(x)"
    linewidth --> 2
    return x, d.(x)
end
```

The recipe above is equivalent to calling the `plot` function as follows.

```julia
d = Gauss()
plot(x, d.(x);
    seriestype := :path,
    label = "Gauss(μ = $(d.μ), σ = $(d.σ))",
    xguide = "x",
    yguide --> "f(x)",
    linewidth --> 2
)
```

```@setup plots
using Plots

Base.@kwdef struct Gauss{T<:Real}
    μ::T = 0
    σ::T = 1

    function Gauss(μ::Real, σ::Real)
        σ > 0 || error("the variance `σ^2` must be positive")
        pars = promote(μ, σ)
        return new{eltype(pars)}(pars...)
    end
end

(d::Gauss)(x::Real) = exp(-1/2 * ((x - d.μ)/d.σ)^2)/(d.σ * sqrt(2*π))

@recipe function f(d::Gauss, x)
    seriestype  :=  :path
    label --> "Gauss(μ = $(d.μ), σ = $(d.σ))"
    xguide --> "x"
    yguide --> "f(x)"
    linewidth --> 2
    x, d.(x)
end
```

With the new plot recipe, we can plot the probability density function of Gaussian distribution with different parameters in a simple way.

```@example plots
using Plots
x = -15:0.1:15

plot(Gauss(), x)
plot!(Gauss(4, 2), x)
plot!(Gauss(-3, 2), x)
savefig("gauss.svg") # hide
```

![](gauss.svg)

```@raw html
</p></details>
```
