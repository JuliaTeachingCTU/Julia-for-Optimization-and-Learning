# Bank Account

The goal of this section is to show the true power of the type system in combination with multiple-dispatch in Julia. The best way how to do it is to use an example. Nowadays is everything about money and our goal in this section is to create a structure that will represent a bank account with the following properties:

- The structure has three fields: `owner`, `transaction` and `date`
- The `transaction` and `date` fields are vectors of the same length.
- It is possible to make transactions in different currencies.

To be able to create such a structure, we first define an abstract type `Currency`.

```@example currency
abstract type Currency end
nothing # hide
```

Since the `Currency` is an abstract type, it is not possible to create an instance of it. Abstract types in Julia are used to create logical type hierarchies. As an example, we can mention the `Real` abstract type that covers types that represent real numbers such as Float64, Int32, etc. Defining abstract type also allows us to define methods for all subtypes of the abstract type at once. Now we can create the `BankAccount` structured as follows

```@example currency
using Dates

struct BankAccount{C<:Currency}
    owner::String
    transaction::Vector{<:Currency}
    date::Vector{<:DateTime}

    function BankAccount(owner::String, C::Type{<:Currency})
        return new{C}(owner, Currency[zero(C)], DateTime[now()])
    end
end
nothing # hide
```

There are many things we need to explain. The structure has three fields with predefined types:

- The `owner` field represents the name of the owner of the account, i.e., it makes sense to use `String`  as a type of the field.
- The `transaction` field represents all executed transactions. In this case, we need to store two pieces of information: the amount of money and which currency was used. Since we defined the abstract type `Currency`, every currency can be defined as a subtype of this abstract type. These subtypes will store both pieces of information that we need, i.e., we can store transactions as a vector with elements of type `Currency`.
- The `date` field represents the date when the transaction was executed. In this case, we use the `DateTime`  type defined in the `Dates` package to store the information.

!!! warning "Avoid containers with abstract type parameters"
    It is not a good practice to use [containers with abstract element type](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-abstract-container) as we use for storing transactions. The reason why we use it in the example above is, that we do not want to convert all transactions to the common currency.

In the definition of the `BankAccount` type, we also define the following inner constructor

```julia
function BankAccount(owner::String, C::Type{<:Currency})
    return new{C}(owner, Currency[zero(C)], DateTime[now()])
end
```

This constructor rewrites the default constructor for creating a new instance of the `BankAccount` type. The idea is as follows: when we want to create a new account, we must know the name of the owner and the primary currency of the account. The constructor above accepts two inputs arguments: the name of the owner and the primary currency. Then it will create a new instance of the `BankAccount` type with the name of the owner and zero transaction, i.e., the transaction of amount zero in the primary currency. Note that we defined the `BankAccount` type as a parametric type, where the parameter is the primary currency of the account. Also note, that the primary currency is stored only in the parameter of the type and not in the field.

One may notice, that we use only the abstract type `Currency` in the definition of the `BankAccount` type. It is very useful since it allows us to write a generic code that is not specified for some concrete type. However, we are now in a situation, that we defined a new type, but we are not able to test it, since the type uses concrete subtypes of the `Currency` abstract type. Moreover, we used functions that are not defined for the `Currency` type such as the `zero` function and there are other function such as the `sum` function or the `convert` function that should be defined for currencies.

The situation with the `zero` function can be fixed easily by adding new methods to the `zero` function from the `Base`

```@example currency
Base.zero(C::Type{<:Currency}) = C(0)
Base.zero(c::Currency) = zero(typeof(c))
```

In our case, we added two new methods. The former one works for any subtype of the `Currency` type and the latter for any instance of any subtype of the `Currency` type. In the functions above we use only the latter method, however, for convenience, it is useful to define the former method too. The rest of the methods can not be defined in such a simple way. In the rest of the section, we will show, how to define the `conversion` function for currencies. We will also show how to define arithmetic operations and other basic functions on currencies.

## Concrete types

Firstly we create one concrete subtype of the `Currency` abstract type that allows us to test functions. It can be done as follows

```@example currency
struct Euro <: Currency
    value::Float64
end
nothing # hide
```

Note that use `Float64` to store the amount of the currency. It should be probably better to define the `Euro` type as a parametric type as follows

```julia
struct Euro{T<:Real} <: Currency
    value::T
end
```

However, since we want to make all examples as understandable simple as possible, we use the simplified version. Since `Euro` is a concrete type, we can create its instance

```julia
julia> Euro(1)
Euro(1.0)

julia> Euro(1.5)
Euro(1.5)
```

We can also use the `isa` function to check that the resulting instance is of the type that is a subtype of `Currency` type

```@repl currency
isa(Euro(1), Currency) # equivalent to typeof(Euro(1)) <: Currency
```

Each currency typically has its own symbol that is used instead of the name of the currency. We can redefine the `show` function to print the currencies in a prettier way. Firstly we define a new function `symbol` that will return the symbol of the used currency

```@example currency
symbol(T::Type{<:Currency}) = string(nameof(T))
symbol(::Type{Euro}) = "€"
nothing # hide
```

Note that we defined one method that is generally for all subtypes of the `Currency` type and then one method that is used only for the `Euro` type. With the `symbol` function, we can define custom pretty printing. It can be done by adding a new method to the `show` function from the `Base`. It is possible to define a custom show function for different output formats. For example, it is possible to define different formating for HTML output. In the example below, we show only the basic usage. For more information the [official documentation](https://docs.julialang.org/en/v1/manual/types/#man-custom-pretty-printing).

```@example currency
Base.show(io::IO, c::T) where {T <: Currency} = print(io, c.value, " ", symbol(T))
nothing # hide
```

We can check, that now the printing of the currencies is prettier than the default one

```@repl currency
Euro(1)
Euro(1.5)
```

Finally, we can check, that we define the `zero` function properly

```@repl currency
zero(Euro)
zero(Euro(1.5))
```

It seems that everything works well. Note one big difference against Python. In Python, we can create a class and then define methods inside the class. If we want to add a new method, we have to modify the class. In Julia, methods for types can be defined at any time without the necessity to modify the type definition.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

In the next section, we will define the `conversion` function for the currencies. However, we have defined only one currency so far. Define `Dollar` currency and do not forget to add a new method to the `symbol` function.

**Hint:** the dollar symbol `$` has a special meaning in Julia. Do not forget to use the `\` symbol when using the dollar symbol in a string.


```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The `Dollar` currency can be defined in the same way as we defined `Euro` earlier

```@example currency
struct Dollar <: Currency
    value::Float64
end
nothing # hide
```

When adding a new method to the `symbol` function, we have to take in mind, that we used the currency type for dispatch, i.e., we have to use `::Type{Dollar}` instead of `::Dollar` in the type annotation.

```@example currency
symbol(::Type{Dollar}) = "\$"
nothing # hide
```

Now we can check, that all is defined properly

```@repl currency
Dollar(1)
Dollar(1.5)
zero(Dollar)
zero(Dollar(1.5))
```

```@raw html
</p></details>
```

## Conversion

In the previous section, we have defined two currencies. A natural question is how to convert one currency to the other.  In the real world, the exchange operation between currencies is not transitive. However, for simplicity and educational purposes, we will assume, that the **exchange is transitive**. It will allow us to define the `convert` function without the necessity to define the exchange rate for all pairs of currencies.

The simplest way how to define conversion between currencies is to define the conversion function for each combination of pairs of currencies. It can be done in a simple way if we have only two currencies

```@example currency
dollar2euro(c::Dollar) = Euro(0.83 * c.value)
euro2dollar(c::Euro) = Euro(c.value / 0.83)
nothing # hide
```

We see, that the result is correct

```@repl currency
eur = dollar2euro(Dollar(1.3))
euro2dollar(eur)
```

It is a valid way how to write a code, however, we can do it in a more generic way. To write a generic code, we have to realize few things. Consider amounts ``c_1`` and ``c_2`` in two different currencies. Then there exists value ``r \in  \mathbb{R}`` such as

```math
    c_1 = r \cdot c_2 \qquad \Leftrightarrow \qquad c_2 = \frac{1}{r} c_1
```

It means, that we have to define only the exchange rate from one currency to another

```@example currency
rate(::Type{Euro}, ::Type{Dollar}) = 0.83
nothing # hide
```

and then we can use a generic function that will define the exchange rate for the opposite direction

```@example currency
rate(T::Type{<:Currency}, ::Type{Euro}) = 1 / rate(Euro, T)
nothing # hide
```

If we use only the two methods above, it will work perfectly to compute the exchange rate between `Dollar` and `Euro`

```@repl currency
rate(Euro, Dollar)
rate(Dollar, Euro)
```

However, the definition is not complete, because the `rate` function will not work if we use the same currency

```julia
julia> rate(Euro, Euro)
ERROR: StackOverflowError:
[...]

julia> rate(Dollar, Dollar)
ERROR: MethodError: no method matching rate(::Type{Dollar}, ::Type{Dollar})
[...]
```

To solve this issue, we have to add two new methods. The first one defines, that the exchange rate between two same currencies is `1

```@example currency
rate(::Type{T}, ::Type{T}) where {T<:Currency} = 1
nothing # hide
```

This method solves the issue for the `Dollar` to `Dollar` conversion

```@repl currency
rate(Dollar, Dollar)
```

 However, it does not solve the problem with `Euro` to `Euro` conversion

```julia
julia> rate(Euro, Euro)
ERROR: StackOverflowError:
[...]
```

The reason is, that methods are selected based on the input arguments. There is a simple rule:  the most specific method definition matching the number and types of the arguments will be executed. We can use the `methods` function to get the list of all methods defined for the `rate` function

```julia
julia> methods(rate)
# 3 methods for generic function "rate":
[1] rate(::Type{Euro}, ::Type{Dollar}) in Main at none:1
[2] rate(T::Type{var"#s5"} where var"#s5"<:Currency, ::Type{Euro}) in Main at none:1
[3] rate(::Type{T}, ::Type{T}) where T<:Currency in Main at none:1
```

There are three methods and two of them are specified for the `Euro` type. So we have to define a specific method for  `Euro` to `Euro` conversion as follows

```@example currency
rate(::Type{Euro}, ::Type{Euro}) = 1
nothing # hide
```

This method solves the issue as can be seen in the example below

```@repl currency
rate(Euro, Euro)
```

The last thing we need to realize is the following. Instead of converting the `C1` currency directly to the` C2` currency, we can first convert it to some `C` currency and then convert the` C` currency to the `C2` currency. In our case, we use the `Euro` as the intermediate currency, i.e., we can add a new method to the rate function that will finalize the converting pipeline

```@example currency
rate(T::Type{<:Currency}, C::Type{<:Currency}) = rate(Euro, C) * rate(T, Euro)
nothing # hide
```

To test if the `test` function works as intended, we have to add a new currency

```@example currency
struct Pound <: Currency
    value::Float64
end
symbol(::Type{Pound}) = "£"
rate(::Type{Euro}, ::Type{Pound}) = 1.13
nothing # hide
```

Because we have only three currencies so far, we can easily test that the rate function works in all possible cases correctly

```@repl currency
rate(Pound, Pound) # 1
rate(Euro, Pound) # 1.13
rate(Pound, Euro) # 1/1.13 = 0.8849557522123894
rate(Dollar, Pound) # 1.13 * 1/0.83 = 1.36144578313253
rate(Pound, Dollar) # 0.83 * 1/1.13 = 0.7345132743362832
```

We see that the results are correct. Since we defined the `rate` function with all necessary methods, we are able to easily extend the `convert` function to support conversion between currencies.

```@example currency
Base.convert(::Type{T}, c::T) where {T<:Currency} = c
Base.convert(::Type{T}, c::C) where {T<:Currency, C<:Currency} = T(c.value * rate(T, C))
nothing # hide
```

Note that we define two methods. The first method is not necessary, because in such a case the `rate` function returns `1` and the second method can be used.  However,  in Julia, when converting to the same type the result is usually the same object and not a new instance. Finally, we can test that the `conversion` function works

```@repl currency
eur = convert(Euro, Dollar(1.3))
pnd = convert(Pound, eur)
dlr = convert(Dollar, pnd)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

We see that the print style of currencies is not ideal. Usually, we are not interested in more than the first two digits after the decimal point. Redefine method in the `show` function to print currencies in such a way, that the result will be rounded to 2 digits after the decimal point.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Any real number can be rounded to 2 digits after the decimal point using the `round` function with the keyword argument `digits = 2`. Then we can use the almost identical definition of the method as before and only add the `round` function

```@example currency
function Base.show(io::IO, c::T) where {T <: Currency}
    val = round(c.value; digits = 2)
    return print(io, val, " ", symbol(T))
end
nothing # hide
```

If we use the same example as the one placed before this exercise, we get


```@repl currency
eur = convert(Euro, Dollar(1.3))
pnd = convert(Pound, eur)
dlr = convert(Dollar, pnd)
```

```@raw html
</p></details>
```

## Promotion

Before we define the basic arithmetic operations for currencies, we have to decide how to work with money in different currencies. Imagine the situation, that we want to sum `1€` with `1$`. What should be the result? Should it be euro or dollar? Exactly for such a situation, Julia provides a promotion system that allows defining simple rules for promoting custom types. The promotion system can be modified by defining custom methods for the `promote_rule` function. For example, the following definition means, that the euro has precedence against all other currencies

```@example currency
Base.promote_rule(::Type{Euro}, ::Type{<:Currency}) = Euro
nothing # hide
```

Note that one does not need to define both
```julia
Base.promote_rule(::Type{Euro}, ::Type{<:Currency}) = ...
Base.promote_rule(::Type{Euro}, ::Type{<:Currency}) = ...
```
The symmetry is implied by the way `promote_rule` is used in the promotion process. Since we have three different currencies, we also have to define promotion type for pair `Dollar`, `Pound`

```@example currency
Base.promote_rule(::Type{Dollar}, ::Type{Pound}) = Dollar
nothing # hide
```

The `promote_rule` function is used as a building block to define a second function called `promote_type`, which, given any number of type objects, returns the common type to which those values, as arguments to promote should be promoted. Thus, if one wants to know, in absence of actual values, what type a collection of values of certain types would promote to, one can use promote_type:

```julia
julia> promote_type(Euro, Dollar)
Euro

julia> promote_type(Pound, Dollar)
Dollar

julia> promote_type(Pound, Dollar, Euro)
Euro
```

To perform actual promotion, we can use the `promote` function that converts all its input arguments to their promote type

```@repl currency
promote(Euro(2), Dollar(2.4))
promote(Pound(1.3), Euro(2))
promote(Pound(1.3), Dollar(2.4), Euro(2))
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Define a new currency `CzechCrown` that will represent Czech crowns. The exchange rate from the Czech crown to the euro is `0.038.`

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Firstly we have to define a new type `CzechCrown`

```@example currency
struct CzechCrown <: Currency
    value::Float64
end
nothing # hide
```

With the defined type, we must add new methods for the `symbol` and `rate` function

```@example currency
struct CzechCrown <: Currency
    value::Float64
end
symbol(::Type{CzechCrown}) = "Kč"
rate(::Type{Euro}, ::Type{CzechCrown}) = 0.038
nothing # hide
```

We also must add promotion rules for the dollar and pound

```@example currency
Base.promote_rule(::Type{CzechCrown}, ::Type{Dollar}) = Dollar
Base.promote_rule(::Type{CzechCrown}, ::Type{Pound}) = Pound
nothing # hide
```

Finally, we can test the functionality

```@repl currency
CzechCrown(2.8)
zero(CzechCrown)
dl = convert(Dollar, CzechCrown(64))
convert(CzechCrown, dl)
promote(Pound(1.3), Dollar(2.4), Euro(2), CzechCrown(2.8))
```

```@raw html
</p></details>
```

## Basic arithmetic operations

Now we are ready to define basic arithmetic operations. As usual, it can be done by adding a new method into standard functions. We will start with the addition. There are two cases that we have to take into account. The first is, that we want to sum two different currencies. In this case, we use the `promote` function to convert these to currencies to their promote type

```@example currency
Base.:+(x::Currency, y::Currency) = +(promote(x, y)...)
nothing # hide
```

The second case is that we want to sum money in the same currency. In this case, we know the resulting currency and we can simply sum the `value` fields

```@example currency
Base.:+(x::T, y::T) where {T <: Currency} = T(x.value + y.value)
nothing # hide
```

And that is all. Now we are able to sum money in different currencies

```@repl currency
Dollar(1.3) + CzechCrown(4.5)
CzechCrown(4.5) + Euro(3.2) + Pound(3.6) + Dollar(12)
```

Moreover, we can use for example the `sum` function

```@repl currency
sum([CzechCrown(4.5), Euro(3.2), Pound(3.6), Dollar(12)])
```

Also, the broadcasting will work natively if we use arrays of currencies

```@repl currency
CzechCrown.([4.5, 2.4, 16.7, 18.3]) .+ Pound.([1.2, 2.6, 0.6, 1.8])
```

However, there is a problem if we want a sum vector of currencies with one currency. In such a case, the error will occur

```julia
julia> CzechCrown.([4.5, 2.4, 16.7, 18.3]) .+ Dollar(12)
ERROR: MethodError: no method matching length(::Main.Dollar)
[...]
```

The reason is, that Julia assumes, that custom structure is iterable. But in our case, the currencies represent scalars. It can be easily fixed by defining a new method to the `broadcastable` function from the `Broadcast` module

```@example currency
Broadcast.broadcastable(c::Currency) = Ref(c)
nothing # hide
```

This function returns either the given object `x` or an object like `x` such that it supports axes, indexing, and its type supports `ndims`. In the method above, we use the `Ref` function that creates an object that refers to the given object and supports axes, indexing and `ndims`.

```@repl currency
CzechCrown.([4.5, 2.4, 16.7, 18.3]) .+ Dollar(12)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Define the following operations:

- Subtraction.
- Multiplication of by a real number.
- Division by the real number.
- Division by the same currency.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The subtraction can be defined in the exact same way as addition

```@example currency
Base.:-(x::Currency, y::Currency) = -(promote(x, y)...)
Base.:-(x::T, y::T) where {T <: Currency} = T(x.value - y.value)
nothing # hide
```

And the result is as follows

```@repl currency
Dollar(1.3) - CzechCrown(4.5)
CzechCrown(4.5) - Euro(3.2)
```

In the case of multiplication by a real number, we have to define multiplication from the right and also from the left.

```@example currency
Base.:*(a::Real, x::T) where {T <: Currency} = T(a * x.value)
Base.:*(x::T, a::Real) where {T <: Currency} = T(a * x.value)
nothing # hide
```

```@repl currency
2*Dollar(1.3)*0.5
```

```@example currency
Base.:/(x::T, a::Real) where {T <: Currency} = T(x.value / a)
Base.:/(x::Currency, y::Currency) = /(promote(x, y)...)
Base.:/(x::T, y::T) where {T <: Currency} = x.value / y.value
nothing # hide
```

```@repl currency
Dollar(1.3) / 2
Dollar(1.3) / Dollar(1.3)
Dollar(1.3) / convert(CzechCrown, Dollar(1.3))
```

```@raw html
</p></details>
```

## Basic functions

```@example currency
Base.isless(x::Currency, y::Currency) = isless(promote(x, y)...)
Base.isless(x::T, y::T) where {T <: Currency} = isless(x.value, y.value)
nothing # hide
```

```@example currency
Base.:(==)(x::Currency, y::Currency) = ==(promote(x, y)...)
Base.:(==)(x::T, y::T) where {T <: Currency} = ==(x.value, y.value)
nothing # hide
```

```@repl currency
Dollar(1) < Euro(0.83)
Dollar(1) > Euro(0.83)
Dollar(1) <= Euro(0.83)
Dollar(1) >= Euro(0.83)
Dollar(1) == Euro(0.83)
```

## Random generation and proper broadcasting

```@example currency
using Random

function Random.rand(rng::AbstractRNG, ::Random.SamplerType{T}) where {T <: Currency}
    return T(rand(rng))
end
nothing # hide
```

```@repl currency
100 .* rand(CzechCrown, 2, 3) .- CzechCrown(50)
```

## Back to bank account

With the `BankAccount` type defined, it makes sense to define some auxiliary functions. For example, we can define the `balance` function that will return the current balance of the account. Since we store all transactions in a vector, the current balance of the account can be simply computed as a sum of the `transaction` field

```@example currency
balance(b::BankAccount{C}) where {C} = convert(C, sum(b.transaction))
nothing # hide
```

Note that we convert the balance to the primary currency of the account. Now we can define custom pretty-printing

```@example currency
function Base.show(io::IO, b::BankAccount{C}) where {C<:Currency}
    println(io, "Bank Account:")
    println(io, "  - Owner: ", b.owner)
    println(io, "  - Primary currency: ", nameof(C))
    println(io, "  - Balance: ", balance(b))
    print(io,   "  - Number of transactions: ", length(b.transaction))
end
nothing # hide
```

The last function that we define is the `transaction!` function that adds a new transaction into the given bank account. This function accepts two arguments: the bank account and the amount of money in some specific currency. The first thing that happened in the function is the check if there is a sufficient bank account balance. If not, the function will throw an error, otherwise, the function will push new elements to the `transaction` and `date` vector.

```@example currency
function transaction!(b::BankAccount, c::Currency)
    val = balance(b) + c
    if val < zero(val)
        msg = ArgumentError("transaction cannot be performed due to insufficient bank account balance.")
        throw(msg)
    end
    push!(b.transaction, c)
    push!(b.date, now())
    return
end
nothing # hide
```


```@repl currency
b = BankAccount("Paul", CzechCrown)
transaction!(b, Dollar(10))
transaction!(b, Dollar(15))
transaction!(b, Pound(10))
transaction!(b, Euro(23.6))
transaction!(b, CzechCrown(152))
transaction!(b, -2*balance(b))
b
```
