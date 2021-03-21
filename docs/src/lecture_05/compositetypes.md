# Abstract types

Julia does not allow abstract types to be instantiated. They can only be used to create a logical hierarchy of types. The following figure shows this hierarchy for numeric types introduced in the first lecture.

![](types.svg)

All types depicted in blue are abstract types, and all green types are concrete types. For example, `Int8`, `Int16`, `Int32`, `Int64` and `Int128` are signed integer types, `UInt8`, `UInt16`, `UInt32`, `UInt64` and `UInt128` are unsigned integer types, while `Float16`, `Float32` and `Float64` are floating-point types. In many cases, the inputs must be of a specific type. An algorithm to find the greatest common denominator should work any integer types, but it should not work for any floating-point inputs. Abstract types specify these cases and provide a context into which concrete types can fit.

Abstract types are defined by `abstract type` followed by the type. It is possible to specify a type to be a subtype of another abstract type. The definition of abstract numeric types would be:

```julia
abstract type Number end
abstract type Real <: Number end
abstract type AbstractFloat <: Real end
abstract type AbstractIrrational <: Real end
abstract type Integer <: Real end
abstract type Signed <: Integer end
abstract type Unsigned <: Integer end
```

When no supertype is specified, such as for `Number`, the default supertype is `Any`. The `Any` type is sometimes called the *top* type since all types are its subtypes. The *bottom* type is `Union{}`, and all types are supertypes of `Union{}`.

The `<:` operator can be used to check if the left operand is a subtype of the right operand.

```jldoctest
julia> Signed <: Integer
true

julia> Signed <: Number
true

julia> Signed <: AbstractFloat
false
```

Julia also provides the `isa` function, which checks if a variable is an instance of a type.

```jldoctest
julia> isa(1, Int64) # equivalent to typeof(1) <: Int64
true

julia> isa(1, Integer) # equivalent to typeof(1) <: Integer
true

julia> isa(1, AbstractFloat) # equivalent to typeof(1) <: AbstractFloat
false
```

Other handy functions are `isabstracttype` and `isconcretetype` that check whether a type is abstract and concrete, respectively.

```jldoctest
julia> isabstracttype(Real)
true

julia> isabstracttype(Float64)
false

julia> isconcretetype(Real)
false

julia> isconcretetype(Float64)
true
```

# Composite types

A composite type is a collection of key-value pairs. In many languages, composite types are the only kind of user-definable type. Even though Julia allows defining other types, composite types are used the most. Their main goal is to collect all information about one object within one structure. We will soon define the `Rectangle` type containing information about the size and the bottom-left point position of a rectangle. Collecting this information into one structure makes it simple to pass all information about the rectangle as arguments and use it for further computation.

The `struct` keyword defines composite types. It is followed by the composite type name and field names, where the latter may be annotated with types.

```jldoctest structs; output = false
struct Rectangle
    bottomleft::AbstractVector{Float64}
    width
    height
end

# output

```

If the type annotation is omitted, `Any` is used, and such a field may contain any value. A Julia convention suggests making the first letter in custom type names uppercase. We can create a new instance of the above type by calling `Rectangle` as a function. Its input arguments represent the fields of the `Rectangle` type.

```jldoctest structs
julia> r = Rectangle([1,2], 3, 4)
Rectangle([1.0, 2.0], 3, 4)

julia> isa(r, Rectangle)
true
```

A constructor is calling a type as a function. Two constructors are automatically generated when a type is created. One accepts any arguments and converts them to the field types, and the other accepts arguments that match the field types exactly. If all fields are `Any`, only one constructor is generated. Julia creates these two constructors to make it easier to add new definitions without replacing the default constructor. We can list all constructors by the `methods` function.

```jldoctest structs
julia> methods(Rectangle)
# 2 methods for type constructor:
[1] Rectangle(bottomleft::AbstractArray{Float64,1}, width, height) in Main at none:2
[2] Rectangle(bottomleft, width, height) in Main at none:2
```

The fields of composite types can be accessed via the dot notation similarly to named tuples or via the `getproperty` function.

```jldoctest structs
julia> r.width
3

julia> getproperty(r, :width)
3
```

The fields can be then accessed anywhere, for example, within a function.

```jldoctest structs
julia> area(r::Rectangle) = r.width * r.height
area (generic function with 1 method)

julia> area(r)
12
```

The convenient function `fieldnames` returns a tuple with names of all structure fields represented as symbols.

```jldoctest structs
julia> fieldnames(Rectangle)
(:bottomleft, :width, :height)

julia> fieldnames(typeof(r))
(:bottomleft, :width, :height)
```

Composite types declared with `struct` keyword are immutable and cannot be modified after being constructed.

```jldoctest structs
julia> r.bottomleft = [2;2]
ERROR: setfield! immutable struct of type Rectangle cannot be changed
```

However, immutability is not recursive. If an immutable object contains a mutable object, such as an array, elements of this mutable object can be modified. Even though `Rectangle` is an immutable type, its `bottomleft` field is a mutable array and can be changed.

```jldoctest structs
julia> r.bottomleft[1] = 5
5

julia> r.bottomleft
2-element Array{Float64,1}:
 5.0
 2.0
```

To allow changing their fields, we need to define composite types as mutable by adding the `mutable` keyword.

```jldoctest structs; output = false
mutable struct MutableRectangle
    bottomleft::AbstractVector{Float64}
    width
    height
end

# output

```

We can work with mutable and immutable types in the same way.

```jldoctest structs
julia> mr = MutableRectangle([1,2], 3, 4)
MutableRectangle([1.0, 2.0], 3, 4)

julia> isa(mr, MutableRectangle)
true
```

Similarly to accessing field values, we can change them by the dot notation or the `setproperty!` function.

```jldoctest structs
julia> mr.width = 1.5
1.5

julia> setproperty!(mr, :height, 2.5)
2.5

julia> mr
MutableRectangle([1.0, 2.0], 1.5, 2.5)
```

```@raw html
<div class = "info-body">
<header class = "info-header">Type unions</header><p>
```

The `area` function defined earlier will only work for `Rectangle` but not for `MutableRectangle` types. To define it for both types, we need type unions. The `Union` keyword creates a supertype of its inputs.

```jldoctest structs
julia> AbstractRectangle = Union{Rectangle, MutableRectangle}
Union{MutableRectangle, Rectangle}

julia> Rectangle <: AbstractRectangle
true

julia> MutableRectangle <: AbstractRectangle
true
```

We now create the `circumference(r::AbstractRectangle)` function. Since we specify that its input is an `AbstractRectangle`, it will work for both mutable `MutableRectangle` and immutable `Rectangle` types.

```jldoctest structs
julia> circumference(r::AbstractRectangle) = 2*(r.width + r.height)
circumference (generic function with 1 method)

julia> circumference(r)
14

julia> circumference(mr)
8.0
```

```@raw html
</p></div>
```

## Parametric types

An important and powerful feature of the Julia type system is that it is parametric. Types can take parameters, and type declarations introduce a whole family of new types (one for each possible combination of parameter values). Parametric (abstract) types can be defined as follows:

```jldoctest structs; output = false
abstract type AbstractPoint{T} end

struct Point{T <: Real} <: AbstractPoint{T}
    x::T
    y::T
end

# output

```

The example above defines a parametric abstract type `AbstractPoint` and its parametric subtype `Point`. The declaration of the concrete type `Point{T <: Real}` has two fields of type `T`, where `T` can be any subtype of `Real`. This definition ensures that both fields are always of the same type. Note that `Point{Float64}` is a concrete type equivalent to replacing `T` in the definition of `Point` by `Float64`.

```jldoctest structs
julia> isconcretetype(Point{Float64})
true
```

This single declaration declares a concrete type for each type `T` that is a subtype of `Real`.  The `Point` type itself is also a valid type object, containing all instances `Point{Float64}`, `Point{Int64}`, etc., as subtypes.

```jldoctest structs
julia> Point{Float64} <: Point <: AbstractPoint
true

julia> Point{Int64} <: Point <: AbstractPoint
true
```

Concrete `Point` types with different `T` values are never subtypes of each other. Even though `Float64` is a subtype of ` Real`, `Point{Float64}` is not a subtype of  `Point{Real}`.

```jldoctest structs
julia> Point{Float64} <: Point{Real}
false

julia> Point{Float64} <: AbstractPoint{Float64}
true

julia> Point{Float64} <: AbstractPoint{Real}
false
```

This behaviour has important consequences: while any instance of `Point{Float64}` may be represented as an instance of `Point{Real}`, these two types have different representations in memory:

- An instance of `Point{Float64}` can be efficiently represented as a pair of 64-bit values;
- An instance of `Point{Real}` must be able to hold any pair of `Real` values. Since instances of `Real` can have arbitrary size and structure, an instance of `Point{Real}` must be represented as a pair of pointers to individually allocated `Real` objects.

This efficiency gain is magnified for arrays: `Array{Float64}` can be stored as a contiguous memory block of 64-bit floating-point values, whereas `Array{Real}` is an array of pointers to `Real` objects.

Since `Point{Float64}` is not a subtype of `Point{Real}`, the following method cannot be applied to arguments of type `Point{Float64}`.

```julia structs
julia> coordinates(p::Point{Real}) = (p.x, p.y)

julia> coordinates(Point(1,2))
ERROR: MethodError: no method matching coordinates(::Point{Int64})
[...]

julia> coordinates(Point(1.0,2.0))
ERROR: MethodError: no method matching coordinates(::Point{Float64})
[...]
```

The correct way to define a method that accepts all arguments of type `Point{T}` where `T` is a subtype of `Real` is as follows:

```jldoctest structs
julia> coordinates(p::Point{<:Real}) = (p.x, p.y)
coordinates (generic function with 1 method)

julia> coordinates(Point(1,2))
(1, 2)

julia> coordinates(Point(1.0,2.0))
(1.0, 2.0)
```

It is also possible to define a function for all subtypes of some abstract type.

```jldoctest structs
julia> Base.show(io::IO, p::AbstractPoint) = print(io, coordinates(p))

julia> Point(4, 2)
(4, 2)

julia> Point(0.2, 1.3)
(0.2, 1.3)
```

There are two ways how to instantiate the `Point` type.  The first one does not specify the `T` parameter and lets Julia automatically decide the appropriate type. The second one specifies the `T` parameter manually.

```jldoctest structs
julia> Point(1, 2)
(1, 2)

julia> Point{Float32}(1, 2)
(1.0f0, 2.0f0)
```

The first way works only if the arguments have the same type.

```jldoctest structs
julia> Point(1, 2.0)
ERROR: MethodError: no method matching Point(::Int64, ::Float64)
Closest candidates are:
  Point(::T, !Matched::T) where T<:Real at none:3
```

This situation can be handled by defining custom constructors, as we will discuss in the next section.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Define a structure that represents 3D-points. Do not forget to define it as a subtype of the AbstractPoint type. Then add a new method to the `coordinates` function.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

There are several possibilities for defining the structure. We define it as a structure with three fields. Another option is to use a tuple to store the point coordinates.

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

Since the `show` function was defined for the abstract type `AbstractPoint` and uses the `coordinates` function, the custom print is applied to `Point3D` without the need for further changes.

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

Constructors are functions that create new instances of composite types. When a user defines a new composite type,  Julia creates the default constructors. Sometimes it is helpful to add additional constructors. In the example from the previous section, we may want to create an instance of `Point` from two numbers with different types. This can be achieved by defining the following constructor.

```jldoctest structs; output = false
Point(x::Real, y::Real) = Point(promote(x, y)...)

# output

Point
```

The `promote` function converts its arguments to the supertype that can represent both inputs. For example, `promote(1, 2.3)` results in the tuple `(1.0, 2.3)` because it is possible to represent `Int64` by `Float64`, but not the other way round. We can test the new constructor on the example from the end of the previous section. As expected, the result has the type `Point{Float64}`. 

```jldoctest structs
julia> Point(1, 2.0)
(1.0, 2.0)

julia> typeof(Point(1, 2.0))
Point{Float64}
```

The constructor defined above is the outer constructor because it is defined outside of the type definition. A constructor behaves like any other function in Julia and may have multiple methods. We can define new methods to add additional functionality to a constructor. On the other hand, outer constructors cannot construct self-referential objects or instances with some special properties. In such a case, we have to use inner constructors, which differ from outer constructors in two aspects:
    
1. They are declared inside the composite type declaration rather than outside of it.
2. They have access to the local function `new` that creates new instances of the composite type.
    
For example, one may want to create a type with two real numbers, where the first number cannot be greater than the second one. The inner constructor can ensure this.

```jldoctest ordered; output = false
struct OrderedPair{T <: Real}
    x::Real
    y::Real

    function OrderedPair(x::Real, y::Real)
        x > y && error("wrong input: x > y")
        xp, yp = promote(x, y)
        return new{typeof(xp)}(xp, yp)
    end
end

# output

```

If an inner constructor method is provided, **no default constructor method is constructed**.  The example above ensures that any instance of the `OrderedPair` satisfies `x <= y`.

```jldoctest ordered
julia> OrderedPair(1,2)
OrderedPair{Int64}(1, 2)

julia> OrderedPair(2,1)
ERROR: wrong input: x > y
[...]
```

Inner constructors have an additional advantage. Since outer constructors create the object by calling an appropriate inner constructor, even if we define any number of outer constructors, the inner constructor will create the instances of `OrderedPair`, and they will, therefore, always satisfy `x <= y`.

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

It may be beneficial to define custom types with default field values. Since a constructor is a function, one way to achieve this is to use optional or keyword arguments in its declaration. Another option is to use the `@kwdef` macro from `Base` that automatically defines keyword-based constructors.

```jldoctest structs; output = false
Base.@kwdef struct MyType
    a::Int # required keyword
    b::Float64 = 2.3
    c::String = "hello"
end

# output

MyType
```
    
The `methods` function shows that Julia created three constructors.  The `@kwdef` macro creates the first constructor; the other two constructors are the default constructors.

```jldoctest structs
julia> methods(MyType)
# 3 methods for type constructor:
[1] MyType(; a, b, c) in Main at util.jl:438
[2] MyType(a::Int64, b::Float64, c::String) in Main at none:2
[3] MyType(a, b, c) in Main at none:2
```

A `MyType` instance can be created by the default constructors.

```jldoctest structs
julia> MyType(1, 2.3, "aaa")
MyType(1, 2.3, "aaa")
```

The other way is to use the constructor with predefined field values. Then all values have to be passed as keyword arguments. The fields without default values are mandatory keyword arguments: we have to specify them.

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
