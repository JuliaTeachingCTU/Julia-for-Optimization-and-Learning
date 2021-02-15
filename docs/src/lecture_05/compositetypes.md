# Abstract types

In Julia, abstract types cannot be instantiated and are used to create a logical hierarchy of types. This can be seen in the hierarchy of numeric types introduced in the first lecture

![](types.svg)

All types depicted in blue are abstract types. Note that Julia provides a variety of concrete types of numeric values. Although they have different representation sizes, `Int8`, `Int16`, `Int32`, `Int64`, and `Int128` all have in common that they are signed integer types. Likewise, `UInt8`, `UInt16`, `UInt32`, `UInt64`, and `UInt128` are all unsigned integer types, while `Float16`, `Float32`, and `Float64` are distinct in being floating-point types rather than integers. It is common for a piece of code to make sense, for example, only if its arguments are some kind of integer, but not really depend on what particular kind of integer. For example, the greatest common denominator algorithm works for all kinds of integers, but will not work for floating-point numbers. Abstract types allow the construction of a hierarchy of types, providing a context into which concrete types can fit. This allows you, for example, to easily program to any type that is an integer, without restricting an algorithm to a specific type of integer.

Abstract types can be defined using the `abstract type` keyword followed by the name of the type. Optionally, it is possible to specify that the type is a subtype of another existing abstract type. For example, the hierarchy of numeric types presented above can be defined as follows

```julia
abstract type Number end
abstract type Real <: Number end
abstract type AbstractFloat <: Real end
abstract type AbstractIrrational <: Real end
abstract type Integer <: Real end
abstract type Signed <: Integer end
abstract type Unsigned <: Integer end
```

When no supertype is given, the default supertype is Any, i.e., in our example, the `Number` type is a subtype of `Any`. The `Any` type is sometimes called the *top* type since all types are subtypes of it. In Julia, there is also the *bottom* type `Union{}`.  It is the exact opposite of the `Any` type since no object is an instance of `Union{}` and all types are supertypes of `Union{}`.

The `<:` operator can be used in expressions as a subtype operator that returns true when its left operand is a subtype of its right operand

```@repl
Signed <: Integer
Signed <: Number
Signed <: AbstractFloat
```

Julia also provides the `isa` function, which can be used to test if the given variable is an instance of some type or subtype of some abstract type

```@repl
isa(1, Int64) # equivalent to typeof(1) <: Int64
isa(1, Integer) # equivalent to typeof(1) <: Integer
isa(1, AbstractFloat) # equivalent to typeof(1) <: AbstractFloat
```

Julia also provides the `isabstracttype` function that checks whether the given type is abstract or not

```@repl
isabstracttype(Real)
isabstracttype(Float64)
```

and the `isconcretetype` function that checks  whether the given type is concrete or not

```@repl
isconcretetype(Real)
isconcretetype(Float64)
```

# Composite types

Composite types are called *records*, *structs*, or *objects* in various languages. A composite type is a collection of named fields, an instance of which can be treated as a single value. In many languages, composite types are the only kind of user-definable type, and they are by far the most commonly used user-defined type in Julia as well.

In object-oriented languages, such as Python or Java, composite types also have named functions associated with them, and the combination is called an *object*.  In Julia, all values are objects, but functions are not bundled with the objects they operate on. This is necessary since Julia chooses which method of a function to use by multiple-dispatch. It means that the types of all of a function's arguments are considered when selecting a method, rather than just the first one. Thus, it would be inappropriate for functions to "belong" to only their first argument. Organizing methods into function objects rather than having named bags of methods "inside" each object ends up being a highly beneficial aspect of the language design.

Composite types can be defined using the `struct` keyword followed by the type name and  field names that can be optionally annotated with types

```@example structs
struct Foo
    a
    b::Int
end
nothing # hide
```

Fields with no type annotation default to `Any`, and can accordingly hold any type of value. Note that there is a convention in Julia, that the first letters in custom type names are in uppercase. We can create a new instance of the above type by calling `Foo` as a function with input arguments representing fields of the `Foo` type

```@repl structs
foo = Foo([1,2,3], 4)
isa(foo, Foo)
```

When a type is applied like a function it is called a constructor. Two constructors are generated automatically. One accepts any arguments and calls convert to convert them to the types of the fields, and the other accepts arguments that match the field types exactly. We can list all constructors using the `methods` function

```@repl structs
methods(Foo)
```

The reason both of these are generated is that this makes it easier to add new definitions without inadvertently replacing a default constructor.

The fields of composite types can be accessed via dot notation similarly to named tuples

```@repl structs
foo.a
foo.b
```

Internally `foo.a` is just a shortcut for the `getproperty(foo, :a)`

```@repl structs
getproperty(foo, :a)
getproperty(foo, :b)
```

There is also a very handy function `fieldnames` that returns a tuple with names of all fields of a given structure. Note that all field names are represented as symbols

```@repl structs
fieldnames(Foo)
```

Composite objects declared with `struct` are immutable, i.e., they cannot be modified after construction.

```@repl structs
foo.a = 1
```

However, the immutability is not recursive. It means, that if an immutable object contains a mutable object (for example array), the elements of the mutable object can be modified. This can be seen in the following example. The `Foo` type is defined as immutable, but we instantiate the `foo` object with a vector as a first argument. Since vectors are mutable, we can modify the elements of the field `foo.a`

```@repl structs
foo.a[1] = 5
foo.a
```

Mutable composite types can be declared in the same way as immutable ones. The only difference is, that we have to add the `mutable` keyword before the `struct` keyword.

```@example structs
mutable struct MutableFoo
    a
    b::Int
end
nothing # hide
```

Instances of mutable types are created in the same way as in the case of the immutable types

```@repl structs
mfoo = MutableFoo([1,2,3], 4)
isa(mfoo, MutableFoo)
```

There are two ways how to change fields of mutable types. The first one is to use the `setproperty!` function. The second one is to use the shorthand dot syntax to access the field and the `=` operator to assign a new value

```@repl structs
mfoo.a = 2.345
setproperty!(mfoo, :a, 2)
mfoo
```

Note that the syntax `mfoo.a = 2.345` is only shorthand and internally the `setproperty!` function is called.

```@raw html
<div class = "info-body">
<header class = "info-header">Type unions</header><p>
```

A type union is a special abstract type which includes as objects all instances of any of its argument types, constructed using the special `Union` keyword

```@repl structs
AbstractFoo = Union{Foo, MutableFoo}
Foo <: AbstractFoo
MutableFoo <: AbstractFoo
```

The `Union` type can be very useful in many cases. For example, if there is no connection between multiple types, but we want to write a specialized function that is shared for all these types, we can use the type `Union` and write one function with type annotation to all of them at once

```@repl structs
geta(foo::AbstractFoo) = foo.a
geta(foo) == foo.a
geta(mfoo) == mfoo.a
```

```@raw html
</p></div>
```

## Parametric types

An important and powerful feature of Julia's type system is that it is parametric: types can take parameters, so that type declarations actually introduce a whole family of new types – one for each possible combination of parameter values. Parametric (abstract) types can be defined as follows

```@example structs
abstract type AbstractPoint{T} end

struct Point{T <: Real} <: AbstractPoint{T}
    x::T
    y::T
end
nothing # hide
```

In the example above, we defined one parametric abstract type and its parametric subtype. The declaration of the concrete type `Point{T <: Real}` has two fields of type `T`, where `T` can be any subtype of `Real`. This definition ensures that both fields are always of the same type. Note that `Point{Float64}` is a concrete type equivalent to the type defined by replacing `T` in the definition of `Point` with `Float64`

```@repl structs
isconcretetype(Point{Float64})
isconcretetype(Point{Int64})
```

Thus, this single declaration actually declares concrete type for each type `T` that is a subtype of `Real`. `Point` itself is also a valid type object, containing all instances `Point{Float64}`, `Point{Int64}`, etc. as subtypes

```@repl structs
Point{Float64} <: Point
Point{Int64} <: Point
Point{Float64} <: AbstractPoint
Point{Int64} <: AbstractPoint
```

Howeever, concrete `Point` types with different values of `T` are never subtypes of each other. Even though `Float64` is a subtype of ` Real` the `Point{Float64}` is not a subtype of  `Point{Real}`

```@repl structs
Point{Float64} <: Point{Real}
Point{Float64} <: AbstractPoint{Float64}
Point{Float64} <: AbstractPoint{Real}
```

This is for practical reasons: while any instance of `Point{Float64}` may conceptually be like an instance of `Point{Real}` as well, the two types have different representations in memory:

- An instance of `Point{Float64}` can be represented compactly and efficiently as an immediate pair of 64-bit values;
- An instance of `Point{Real}` must be able to hold any pair of instances of `Real`. Since objects that are instances of `Real` can be of arbitrary size and structure, in practice an instance of `Point{Real}` must be represented as a pair of pointers to individually allocated `Real` objects.

The efficiency gained by being able to store `Point{Float64}` objects with immediate values is magnified enormously in the case of arrays: an `Array{Float64}` can be stored as a contiguous memory block of 64-bit floating-point values, whereas an `Array{Real}` must be an array of pointers to individually allocated `Real` objects - which may well be boxed 64-bit floating-point values, but also might be arbitrarily large, complex objects, which are declared to be implementations of the `Real` abstract type.

Since `Point{Float64}` is not a subtype of `Point{Real}`, the following method can't be applied to arguments of type `Point{Float64}`

```julia
julia> norm(p::Point{Real}) = sqrt(p.x^2 + p.y^2)
norm (generic function with 1 method)

julia> norm(Point(1,2))
ERROR: MethodError: no method matching norm(::Point{Int64})
[...]

julia> norm(Point(1.0,2.0))
ERROR: MethodError: no method matching norm(::Point{Float64})
[...]
```

A correct way to define a method that accepts all arguments of type `Point{T}` where T is a subtype of Real is:

```@repl structs
norm(p::Point{<:Real}) = sqrt(p.x^2 + p.y^2)
norm(Point(1,2))
norm(Point(1.0,2.0))
```

There are two ways how to instantiate the `Point` type as can be seen in the following example

```@repl structs
p1 = Point(1, 2)
p1 = Point{Float32}(1, 2)
```

In the first case, the parameter `T` inf the `Point{T}` is determined from the given arguments, and in the second case, the parameter is defined by the user. Note that the default constructors work only if we use arguments with the same type or if we specify the parameter `T`

```julia
julia> Point(1, 2.0)
ERROR: MethodError: no method matching Point(::Int64, ::Float64)
Closest candidates are:
  Point(::T, !Matched::T) where T<:Real at none:3

julia> Point{Float64}(1, 2.0)
Point{Float64}(1.0, 2.0)
```

This situation can be handled by defining new constructors as discussed in the next section.

## Constructors

Constructors are functions that create new instances of composite types. When the user defines a new composite type,  Julia creates default constructors. However, sometimes it is very useful to add additional constructors. As an example, we can mention the case from the end of the previous section. In this case, it makes sense to have the ability to create an instance of the `Point` type from two numbers that can be of any subtypes of `Real`. This can be achieved by defining the following constructor

```@example structs
Point(x::Real, y::Real) = Point(promote(x, y)...)
nothing # hide
```

Note that we use the `promote` function. This function converts its arguments to the type, that can safely represents their types. For example, if we call `promote(1, 2.3)` the result will be a tuple `(1.0, 2.3)`, because it is possible to represent `Int64` using `Float64` (not precisely), but it is not possible to represent `Float64` using `Int64`. We can test the new constructor on the example from the end of the previous section

```@repl structs
Point(1, 2.0)
```

As expected, the result is of type `Point{Float64}`. The constructor defined above is called an outer constructor because it is defined outside the type definition. A constructor is just like any other function in Julia in that its overall behavior is defined by the combined behavior of its methods. Accordingly, you can add functionality to a constructor by simply defining new methods.

Outer constructors can be used to provide providing additional convenience methods for constructing objects. However, they can not be used to constructing self-referential objects or if we want to ensure that the resulting instance has some special properties. In such a case, we have to use inner constructors.  An inner constructor method is like an outer constructor method, except for two differences

1. It is declared inside the block of a type declaration, rather than outside of it like normal methods.
2. It has access to a special locally existent function called new that creates objects of the block's type.

For example, suppose one wants to declare a type that holds a pair of real numbers, subject to the constraint that the first number is not greater than the second one. One could declare it like this

```@example
struct OrderedPair
    x::Real
    y::Real

    OrderedPair(x,y) = x > y ? error("out of order") : new(x,y)
end
```

If any inner constructor method is defined, **no default constructor method is provided**.  In the example above it means, that any instance of the `OrderedPair` has to meet the assumption, that `x <= y`. Moreover, outer constructor methods can only create objects by calling other constructor methods, i.e., some inner constructor must be called to create an object. It means, that even if we add any number of outer constructors, the resulting object is created by the inner constructor and therefore has to meet its assumptions.

```@raw html
<div class = "info-body">
<header class = "info-header">Default field values</header><p>
```

In many cases, it is very useful to define custom types with default field values. This can be achieved by defining a constructor that uses optional or keyword arugments. Another option is to use the `@kwdef` macro from the `Base`. This macro automatically defines a keyword-based constructor

```@example structs
Base.@kwdef struct MyType
    a::Int # required keyword
    b::Float64 = 2.3
    c::String = "hello"
end
nothing # hide
```

```@repl structs
MyType(; a = 1)
MyType(a = 1, b = 4.5)
```


```@repl structs
MyType(1, 2.3, "aaa")
```

```@raw html
</p></div>
```
