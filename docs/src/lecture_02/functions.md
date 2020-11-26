# Functions
In Julia, a function is an object that maps a tuple of argument values to a return value. In the following example we define function that

```jldoctest f_func
function f(x,y)
    x * y
end
```

This function accepts two arguments `x` and `y` and returns the value of the last expression evaluated, which is `x * y`.

```jldoctest f_func
julia> [f(2, 3), f(2, -3)]
```

Sometimes it is useful to return something other than the last expression.  For such a case there is an `return` keyword:

```jldoctest g_func
function g(x,y)
    val = x * y
    if val < 0
        return -val
    else
        return val
    end
end
```

This function accepts two arguments `x` and `y` and computes `val = x * y`. Then if `val` is less than zero, it returns` -val`, otherwise it returns `val`.

```jldoctest g_func
julia> [g(2, 3), g(2, -3)]
```

The traditional function declaration syntax demonstrated above is equivalent to the following compact form, which is very common in Julia:

```jldoctest
julia> f(x,y) = x * y
```

## Optional and keyword arguments

Other very useful things are optional and keyword arguments, which can be added in a very easy way

```jldoctest f_hello_func
function f_hello(x, y, a = 0; sayhello = false)
    sayhello && println("Hello everyone 👋" )
    x * y + a
end
```

This function accepts two arguments `x` and `y`, one optional argument `a` and one keyword argument `sayhello`. If the function is called only with mandatory arguments, then it returns `x * y + 0`

```jldoctest f_hello_func
julia> f_hello(2,3)
```

The change of the optional argument `a` will change the output value to `x * y + a`

```jldoctest f_hello_func
julia> f_hello(2,3,2)
```

Since `f_hello` is a function with good manners (as opposed to `f`), it says hello if the keyword argument `sayhello` is true

```jldoctest f_hello_func
julia> f_hello(2,3; sayhello = true)
```

## Anonymous functions

It is also common to use anonymous functions, ie functions without specified name. Such a function can be defined in almost the same way as a normal function:

```jldoctest
h1 = function (x)
    x^2 + 2x - 1
end
julia> h2 = x ->  x^2 + 2x - 1
```

Those two function declarations create functions with automatically generated names. Then variables `h1` and `h2` only refers to these functions. The primary use for anonymous functions is passing them to functions which take other functions as arguments. A classic example is `map`, which applies a function to each value of an array and returns a new array containing the resulting values:

```jldoctest
julia> map(x -> x^2 + 2x - 1, [1,3,-1])
```

For more complicated functions, the `do` blocks can be used

```jldoctest
map([1,3,-1]) do x
    x^2 + 2x - 1
end
```
