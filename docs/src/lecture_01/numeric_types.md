# Numeric types

Julia provides a broad range of primitive numeric types. The following simple function can be used to print a hierarchy of subtypes for any abstract type (not just numeric types).

Then the whole tree of numerical types in Julia can be printed as follows

```@repl
using InteractiveUtils: subtypes

function print_subtypes(T::Type{<:Any}, k::Int = 0)
    col = isabstracttype(T) ? :blue : :green
    printstyled(repeat("   ", k)..., T, "\n"; color = col)
    print_subtypes.(subtypes(T), k + 1)
    return
end

print_subtypes(Number)
```

## Integers

Literal integers are represented in the standard manner:

```jldoctest
julia> 1
1

julia> 1234
1234
```

The default type for an integer literal depends on whether the target system has a 32-bit architecture or a 64-bit architecture. Nowadays, in most cases, the default type for integer literal is `Int64`. Larger integer literals that cannot be represented using only 32 bits but can be represented in 64 bits always create 64-bit integers, regardless of the system type.

```jldoctest
julia> typeof(1234)
Int64
```

The minimum and maximum representable values of primitive numeric types such as integers are given by the typemin and typemax functions:

```jldoctest
julia> for T in [Int8, Int16, Int32, Int64, Int128, UInt8, UInt16, UInt32, UInt64, UInt128]
           println(lpad(T, 7), ": [", typemin(T), ", ", typemax(T), "]")
       end
   Int8: [-128, 127]
  Int16: [-32768, 32767]
  Int32: [-2147483648, 2147483647]
  Int64: [-9223372036854775808, 9223372036854775807]
 Int128: [-170141183460469231731687303715884105728, 170141183460469231731687303715884105727]
  UInt8: [0, 255]
 UInt16: [0, 65535]
 UInt32: [0, 4294967295]
 UInt64: [0, 18446744073709551615]
UInt128: [0, 340282366920938463463374607431768211455]
```

The values returned by typemin and typemax are always of the given argument type.


## Floating-Point Numbers

Literal floating-point numbers are represented in the standard formats, using E-notation when necessary:

```jldoctest
julia> 1.0
1.0

julia> -1.26
-1.26

julia> 1e10
1.0e10

julia> 2.9e-4
0.00029
```

The above results are all `Float64` values. Literal `Float32` values can be entered by writing an `f` in place of `e`:

```jldoctest
julia> 0.5f0
0.5f0

julia> typeof(ans)
Float32
```

The variable ans is set to the value of the last expression evaluated in an interactive session. This does not occur when Julia code is run in other ways.

The typemin and typemax functions also apply to floating-point types:

```jldoctest
julia> map([Float16, Float32, Float64]) do T
           (type = T, min = typemin(T), max = typemax(T))
       end
3-element Array{NamedTuple{(:type, :min, :max),T} where T<:Tuple,1}:
 (type = Float16, min = -Inf16, max = Inf16)
 (type = Float32, min = -Inf32, max = Inf32)
 (type = Float64, min = -Inf, max = Inf)
```

Most real numbers cannot be represented exactly with floating-point numbers, and so for many purposes it is important to know the distance between two adjacent representable floating-point numbers, which is often known as machine epsilon. Julia provides `eps` function, which gives the distance between 1.0 and the next larger representable floating-point value:

```jldoctest
julia> eps(Float32)
1.1920929f-7

julia> eps(Float64)
2.220446049250313e-16

julia> eps() # same as eps(Float64)
2.220446049250313e-16
```

The eps function can also take a floating-point value as an argument, and gives the absolute difference between that value and the next representable floating point value. That is, eps(x) yields a value of the same type as x such that x + eps(x) is the next representable floating-point value larger than x:

```jldoctest
julia> eps(1.0)
2.220446049250313e-16

julia> eps(1000.)
1.1368683772161603e-13
```

The distance between two adjacent representable floating-point numbers is not constant, but is smaller for smaller values and larger for larger values. In other words, the representable floating-point numbers are densest in the real number line near zero, and grow sparser exponentially as one moves farther away from zero.

## Numerical Conversions

Julia supports three forms of numerical conversion, which differ in their handling of inexact conversions:

1. The notation `T(x)` or `convert(T,x)` converts `x` to a value of type `T`.
  - If `T` is a floating-point type, the result is the nearest representable value, which could be positive or negative infinity.
  - If `T` is an integer type, an `InexactError` is raised if `x` is not representable by `T`.
2. `x % T` converts an integer `x` to a value of integer type `T` congruent to `x` modulo `2^n`, where `n` is the number of bits in `T`. In other words, the binary representation is truncated to fit.
3. The Rounding functions take a type `T` as an optional argument. For example, `round(Int,x)` is a shorthand for `Int(round(x))`.

```jldoctest
julia> Int8(127) # equivalent to convert(Int8, 127)
127

julia> Int8(128)
ERROR: InexactError: trunc(Int8, 128)
[...]

julia> 127 % Int8
127

julia> 128 % Int8
-128

julia> round(Int8,127.4)
127

julia> round(Int8,127.6)
ERROR: InexactError: trunc(Int8, 128.0)
[...]
```
