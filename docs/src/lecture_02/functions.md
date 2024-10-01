## Function basics

So far, we did not show how to define functions. In Julia, a function is an object that maps a tuple of argument values to a return value. There are multiple ways to create a function. Each of them is useful in different situations. The following example shows the basic way how to define a function using `function ... end` syntax 

```jldoctest functions; output = false
function quadratic(x::Real; a::Real = 1, b::Real = 1, c::Real = 1)
    value = a*x^2 + b*x + c 
    deriv = 2* a*x + b

    return value, deriv
end

# output
quadratic (generic function with 1 method)
```

The function definition consists of multiple parts:

- keywords `function` and `end`
- function name `quadratic`
- positional argument `x` with type annotation
- separator `;` of positional and keyword arguments  
- keyword arguments `a`, `b` and `c` with type annotations and default values
- actual code that computed the output values
- `return` keyword that specifies the function output followed by comma separated list of output values

Note that not all parts of the function definition above are mandatory. The following parts are optional:

- type annotations
- separator of positional and keyword arguments
- `return` keyword

However, we highly recommend to use these optional features when writing your own functions, since it will improve code readability and prevent unwanted errors.

!!! warning "Exercise:"
    Test how the function behaves with different input values. Test what happens when the input is not a real number, i.e. `x = "a"`.

!!! details "Solution:"
    Positional arguments do not need to be named:
    ```jldoctest functions
    julia> quadratic(2)
    (7, 5)
    ```

    but the keyword arguments have to be specified. Their order of being called does not matter.
    ```jldoctest functions
    julia> quadratic(2; b=3, a=1)
    (11, 7)
    ```

    When a function has specific type annotation, the function throws a `MethodError`, because the function specifically needs `x` to be of type `Real`.
    ```jldoctest functions
    julia> quadratic("a")
    ERROR: MethodError: no method matching quadratic(::String)

    Closest candidates are:
      quadratic(!Matched::Real; a, b, c)
       @ Main none:1

    Stacktrace:
     [1] top-level scope
       @ none:1
    ```

    This is different to a a case when we would define the function without the type annotation:

    ```jldoctest functions; output = false
    function quadratic2(x; a = 1, b = 1, c = 1)
        value = a*x^2 + b*x + c 
        deriv = 2* a*x + b

        return value, deriv
    end

    # output
    quadratic2 (generic function with 1 method)
    ```
    
    which returns a different error when calling for `x = "a"`:

    ```jldoctest functions
    julia> quadratic2("a")
    ERROR: MethodError: no method matching *(::Int64, ::String)

    Closest candidates are:
      *(::Any, ::Any, !Matched::Any, !Matched::Any...)
       @ Base operators.jl:587
      *(::Real, !Matched::Complex{Bool})
       @ Base complex.jl:327
      *(!Matched::Missing, ::Union{AbstractChar, AbstractString})
       @ Base missing.jl:184
      ...

    Stacktrace:
     [1] quadratic2(x::String; a::Int64, b::Int64, c::Int64)
       @ Main ./none:2
     [2] quadratic2(x::String)
       @ Main ./none:1
     [3] top-level scope
       @ none:1
    ```

We will discuss the function declaration in more detail [later](@ref Functions).