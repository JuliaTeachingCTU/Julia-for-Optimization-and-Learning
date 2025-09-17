# Exception handling

Unexpected behaviour may often occur during running code, which may lead to a situation where some function cannot return a reasonable value. Such behaviour should be handled by either terminating the program with a proper diagnostic error message or allowing that code to take appropriate action.

In the following example, we define a factorial function in the same way as we did in the [Short-circuit evaluation](@ref Short-circuit-evaluation) section.

```jldoctest exceptions; output = false
function fact(n)
    isinteger(n) && n >= 0 || error("argument must be non-negative integer")
    return n == 0 ? 1 : n * fact(n - 1)
end

# output
fact (generic function with 1 method)
```

We use the `error` function, which throws the `ErrorException` if the input argument does not meet the given conditions. This function works quite well and returns a reasonable error message for incorrect inputs.

```jldoctest exceptions
julia> fact(1.4)
ERROR: argument must be non-negative integer
[...]

julia> fact(-5)
ERROR: argument must be non-negative integer
[...]
```

However, it is better to use error messages that are as descriptive as possible. In the case above, the error message can also include the argument value. Julia provides several predefined types of exceptions that can be used to create more descriptive error messages. In our example, we want to check whether the argument is a non-negative integer. The more specific `DomainError` can do this.

```jldoctest exceptions; output = false
function fact(n)
    isinteger(n) && n >= 0 || throw(DomainError(n, "argument must be non-negative integer"))
    return n == 0 ? 1 : n * fact(n - 1)
end

# output
fact (generic function with 1 method)
```

We must use the `throw` function because the `DomainError(x, msg)` function only creates an instance of the type `DomainError`, but it does not raise an error.

```jldoctest exceptions
julia> fact(1.4)
ERROR: DomainError with 1.4:
argument must be non-negative integer
[...]

julia> fact(-5)
ERROR: DomainError with -5:
argument must be non-negative integer
[...]
```

The error message now contains a short description, the input value, and the type of exception. Now imagine that due to an error, the `fact` function is used to calculate the factorial from a string.

```julia
julia> fact("a")
ERROR: MethodError: no method matching isinteger(::String)
Closest candidates are:
  isinteger(::BigFloat) at mpfr.jl:859
  isinteger(::Missing) at missing.jl:100
  isinteger(::Integer) at number.jl:20
  ...
Stacktrace:
 [1] fact(::String) at ./REPL[1]:2
 [2] top-level scope at REPL[2]:1
```

In this case, the `MethodError` is raised for the `isinteger` function. Since the `DomainError` function is not even called, the error says nothing about the `fact` function. We can track that the error occurs when calling the `fact` function using the `Stacktrace` section located under the error message. The `Stacktrace` provides us with an ordered list of function calls (starting from the last one) that preceded the error. In this case, the last function call before the error is `fact(::String)`. It tells us that the error occurs in the function `fact` with a string as the input argument. In this particular case, it makes sense to define factorial function only for real numbers. This can be done by entering the input type in the function declaration.

```jldoctest exceptions; output = false
function fact_new(n::Real)
    isinteger(n) && n >= 0 || throw(DomainError(n, "argument must be non-negative integer"))
    return n == 0 ? 1 : n * fact(n - 1)
end

# output
fact_new (generic function with 1 method)
```

This function declaration will only work for subtypes of `Real`. Otherwise, a `MethodError` will occur.

```jldoctest exceptions
julia> fact_new("aaa")
ERROR: MethodError: no method matching fact_new(::String)
[...]
```

The `MethodError` provides two important pieces of information. First, it states that the `fact_new` function is not defined for arguments of type `String`. Second, it shows the list of methods closest to the one we called. In this case, the `fact_new` function has only one method, which works for any subtype of `Real`. This can be verified by using the `methods` function.

```jldoctest exceptions
julia> methods(fact_new)
# 1 method for generic function "fact_new" from Main:
 [1] fact_new(n::Real)
     @ none:1
```

A more precise description and a list of all predefined exception types can be found in the official [documentation](https://docs.julialang.org/en/v1/manual/control-flow/#Exception-Handling).
