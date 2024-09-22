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
- separator of positinal and keywor arguments
- `return` keyword

However, we highly recommend to use these optional features when writing own functions, since it will improve code readibility and prevent unwanted errors. 

We will discuss the function declaration in more detail [later](@ref Functions).
