# Bank Account

The goal of this section is to show the true power of the type system in combination with multiple-dispatch in Julia. The best way how to do it is to use an example. Nowadays is everything about money and our goal in this section is to create a structure that will represent a bank account with the following properties:

- The structure has three fields: `owner`, `transaction`.
- All transactions are stored in the currency in which they were made.
- It is possible to make transactions in different currencies.

To be able to create such a structure, we first define an abstract type `Currency`.

```@example currency
abstract type Currency end
nothing # hide
```

Since the `Currency` is an abstract type, it is not possible to create an instance of it. Abstract types in Julia are used to create logical type hierarchies. As an example, we can mention the `Real` abstract type that covers types that represent real numbers such as Float64, Int32, etc. Defining abstract type also allows us to define methods for all subtypes of the abstract type at once. Now we can create the `BankAccount` structured as follows

```@example currency
struct BankAccount{C<:Currency}
    owner::String
    transaction::Vector{<:Currency}

    function BankAccount(owner::String, C::Type{<:Currency})
        return new{C}(owner, Currency[zero(C)])
    end
end
nothing # hide
```

There are many things we need to explain. The structure has three fields with predefined types:

- The `owner` field represents the name of the owner of the account, i.e., it makes sense to use `String`  as a type of the field.
- The `transaction` field represents all executed transactions. In this case, we need to store two pieces of information: the amount of money and which currency was used. Since we defined the abstract type `Currency`, every currency can be defined as a subtype of this abstract type. These subtypes will store both pieces of information that we need, i.e., we can store transactions as a vector with elements of type `Currency`.

!!! warning "Avoid containers with abstract type parameters"
    It is not a good practice to use [containers with abstract element type](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-abstract-container) as we use for storing transactions. The reason why we use it in the example above is, that we do not want to convert all transactions to the common currency.

In the definition of the `BankAccount` type, we also define the following inner constructor

```julia
function BankAccount(owner::String, C::Type{<:Currency})
    return new{C}(owner, Currency[zero(C)])
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

The reason is, that Julia assumes, that custom structure is iterable. But in our case, all subtypes of the `Currency` type represent scalar values. This situation can be easily fixed by defining a new method to the `broadcastable` function from the `Base` module

```@example currency
Base.broadcastable(c::Currency) = Ref(c)
nothing # hide
```

This function should return either the given object or some representation of the given object, that supports `axes`, `indexing`, and  `ndims`. To create such representation of all subtypes of the `Currency` type, we use the `Ref` function. The `Ref` function creates an object that refers to the given currency instance and supports axes, indexing, and `ndims`

```@repl currency
c_ref = Ref(Euro(1))
axes(c_ref)
ndims(c_ref)
c_ref[]
```

Now we can test if the broadcasting works as expected

```@repl currency
CzechCrown.([4.5, 2.4, 16.7, 18.3]) .+ Dollar(12)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

In the section above we defined the addition for all subtypes of the `Currency` and we also told the broadcasting system in Julia to treat all subtypes of the `Currency` as scalars. Follow the same pattern and define all following operations: `-`, `*`, `/`.

**Hint:** Define only the operations that make sense. For example, It makes sense to multiply `1 €` by 2 and get `2 €`. But it does not make sense to multiply `1 €` by `2 €`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The `-` operation can be defined in the exact same way as the addition in the previous section

```@example currency
Base.:-(x::Currency, y::Currency) = -(promote(x, y)...)
Base.:-(x::T, y::T) where {T <: Currency} = T(x.value - y.value)
nothing # hide
```

In the example below, we can see, that everything works as intended

```@repl currency
Dollar(1.3) - CzechCrown(4.5)
CzechCrown.([4.5, 2.4, 16.7, 18.3]) .- Dollar(12)
```

The situation with the multiplication is a little bit different.   It makes sense to multiply `1 €` by 2 and get `2 €`. But it does not make sense to multiply `1 €` by `2 €`. It means, that we have to define a method for multiplying the instance of the `Currency` by a real number. Moreover, we have to define multiplication from the right and also from the left. It can be done as follows

```@example currency
Base.:*(a::Real, x::T) where {T <: Currency} = T(a * x.value)
Base.:*(x::T, a::Real) where {T <: Currency} = T(a * x.value)
nothing # hide
```

As in the previous cases, everything works as expected and broadcasting is supported without any additional steps
```@repl currency
2 * Dollar(1.3) * 0.5
2 .* CzechCrown.([4.5, 2.4, 16.7, 18.3]) .* 0.5
```

Finally, we can define division. In this case, it makes sense to define the division of the instance of  `Currency` by a real number. In such a case, the result is the instance of the same currency

```@example currency
Base.:/(x::T, a::Real) where {T <: Currency} = T(x.value / a)
nothing # hide
```

But it also makes sense to define the division of one amount of money by another amount of money. In this case, the result is a real number that represents the ratio of the given amounts of money

```@example currency
Base.:/(x::Currency, y::Currency) = /(promote(x, y)...)
Base.:/(x::T, y::T) where {T <: Currency} = x.value / y.value
nothing # hide
```

The result is as follows


```@repl currency
Dollar(1.3) / 2
2 .* CzechCrown.([1, 2, 3, 4]) ./ CzechCrown(1)
```

```@raw html
</p></details>
```

## Currency comparison

The last thing we should define are comparison operators. To provide the full functionality of all comparison operators we have to add new methods to two functions. The first one is value equality operator `==`. By default, the following definition is used `==(x, y) = x === y`. The `===` operator determines whether `x` and `y` are identical, in the sense that no program could distinguish them.

```@repl currency
Dollar(1) == Euro(0.83)
Dollar(1) != Euro(0.83)
```

Note that the result does not match the expected behavior since the `0.83 €` is equal to `1 $` with the given exchange rate. The reason is, that we want to compare values stored in the structures and not the structures themselves. To allow this kind of comparison, we can define new methods to the `==` function as follows

```@example currency
Base.:(==)(x::Currency, y::Currency) = ==(promote(x, y)...)
Base.:(==)(x::T, y::T) where {T <: Currency} = ==(x.value, y.value)
nothing # hide
```

With these two methods defined, the comparison works as expected

```@repl currency
Dollar(1) == Euro(0.83)
Dollar(1) != Euro(0.83)
```

Another function that we have to extend is the `isless` function. The logic, in this case, is the same as before: we want to compare values stored in the structure

```@example currency
Base.isless(x::Currency, y::Currency) = isless(promote(x, y)...)
Base.isless(x::T, y::T) where {T <: Currency} = isless(x.value, y.value)
nothing # hide
```

As can be seen below, all operations work as intended

```@repl currency
Dollar(1) < Euro(0.83)
Dollar(1) > Euro(0.83)
Dollar(1) <= Euro(0.83)
Dollar(1) >= Euro(0.83)
```

Moreover, also other functions work for all subtypes of the `Currency` type immediately without any additional changes

```@repl currency
vals = Currency[CzechCrown(100), Euro(0.83),  Pound(3.6), Dollar(1.2)]
extrema(vals)
argmin(vals)
sort(vals)
```

## Back to bank account

In the previous sections, we defined all the functions and types needed for the proper functionality of the `BankAccount` type defined at the top of the page. We can test it by creating a new instance of this type

```julia
julia> b = BankAccount("Paul", CzechCrown)
BankAccount{CzechCrown}("Paul", Currency[0.0 Kč])
```

Now it is time to define some auxiliary functions. For example, we can define the `balance` function that will return the current balance of the account. Since we store all transactions in a vector, the current balance of the account can be simply computed as a sum of the `transaction` field

```@example currency
balance(b::BankAccount{C}) where {C} = convert(C, sum(b.transaction))
b = BankAccount("Paul", CzechCrown) # hide
nothing # hide
```

Note that we convert the balance to the primary currency of the account.

```@repl currency
balance(b)
```

Another thing that we can define is custom pretty-printing

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

which results in the following output

```@repl currency
b
```

The last function that we define is the function that adds a new transaction into the given bank account. This function can be defined as usual, but we use special syntax. Since methods are associated with types, it is possible to make any arbitrary Julia object "callable" by adding methods to its type. Such "callable" objects are sometimes called "functors." Functor for the `BankAccount` type can be defined in the following way

```@example currency
function (b::BankAccount{T})(c::Currency) where {T}
    balance(b) + c >= zero(T) || throw(ArgumentError("insufficient bank account balance."))
    push!(b.transaction, c)
    return
end
nothing # hide
```

The first thing that happened in the function above is the check if there is a sufficient bank account balance. If not, the function will throw an error, otherwise, the function will push new element to the `transaction` field

```@repl currency
b(Dollar(10))
b(-2*balance(b))
b(Pound(10))
b(Euro(23.6))
b(CzechCrown(152))
b
```

Note that all transactions are stored in their original currency as can be seen if we print the `transaction` field

```@repl currency
b.transaction
```

## Extension

```@example currency
Base.delete_method.(methods(rate))
```

```@example currency
const ExchangeRates = Dict{String, Float64}()

function rate(T::Type{<:Currency}, C::Type{<:Currency})
    key = string(nameof(T), "->", nameof(C))
    haskey(ExchangeRates, key) || error("exchange rate not defined")
    return ExchangeRates[key]
end

function addrate(T::Type{<:Currency}, C::Type{<:Currency}, r::Real)
    key = string(nameof(T), "->", nameof(C))
    ExchangeRates[key] = r
    return
end
```

```@example currency
addrate(Euro, Dollar, 0.82)
addrate(Euro, Pound, 1.14)
addrate(Euro, CzechCrown, 0.039)

addrate(Dollar, Euro, 1.21)
addrate(Dollar, Pound, 1.38)
addrate(Dollar, CzechCrown, 0.047)

addrate(Pound, Euro, 0.88)
addrate(Pound, Dollar, 0.72)
addrate(Pound, CzechCrown, 0.034)

addrate(CzechCrown, Euro, 25.76)
addrate(CzechCrown, Dollar, 21.23)
addrate(CzechCrown, Pound, 29.33)
nothing # hide
```


```@repl currency
ExchangeRates
```


```@repl currency
b = BankAccount("Paul", CzechCrown)
b(Dollar(10))
b(-2*balance(b))
b(Pound(10))
b(Euro(23.6))
b(CzechCrown(152))
b
```
