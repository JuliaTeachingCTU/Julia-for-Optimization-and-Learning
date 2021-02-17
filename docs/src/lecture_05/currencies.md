# Bank Account

This section aims to show the real power of the type system in combination with multiple-dispatch in Julia. The best way how to do it is to use an example. Nowadays is everything about money and our goal in this section is to create a structure that will represent a bank account with the following properties:

- The structure has two fields: `owner`, `transaction`.
- It is possible to make transactions in different currencies.
- All transactions are stored in the currency in which they were made.

To be able to create such a structure, we first define an abstract type `Currency`.

```jldoctest currency; output=false
abstract type Currency end

# output

```

Since the `Currency` is an abstract type, it is impossible to create an instance of it. Abstract types in Julia are used to create logical type hierarchies. Defining abstract type allows us to define methods for all subtypes of the abstract type at once. Now we can create the `BankAccount` type as follows.

```jldoctest currency; output=false
struct BankAccount{C<:Currency}
    owner::String
    transaction::Vector{<:Currency}

    function BankAccount(owner::String, C::Type{<:Currency})
        return new{C}(owner, Currency[zero(C)])
    end
end

# output

```

There are few things we need to explain. The structure has two fields with predefined types:

- The `owner` field represents the name of the owner of the account, i.e., it makes sense to use `String`  as a field type.
- The `transaction` field represents all executed transactions. In this case, we need to store two pieces of information: the amount of money and which currency was used. Since we defined the abstract type `Currency`, every currency can be defined as a subtype of this abstract type. These subtypes will store both pieces of information that we need, i.e., we can store transactions as a vector with elements of type `Currency`.

```@raw html
<div class = "info-body">
<header class = "info-header">Avoid containers with abstract type parameters</header><p>
```

It is generally not good to use [containers with abstract element type](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-abstract-container) as we use for storing transactions. We use it in the example above because we do not want to convert all transactions to the common currency. Consider the following situation. We have several numbers in different numeric types, and we want to create a vector of them. In such a case, a promotion system converts all these numbers to their promote type to allow Julia to store them in memory efficiently.

```jldoctest
julia> [Int32(123), 1, 1.5, 1.234f0]
4-element Array{Float64,1}:
 123.0
   1.0
   1.5
   1.2339999675750732
```

Note that the type of the result is `Array{Float64, 1}`. However, sometimes it is useful not to convert the variables. In such a case, we can specify the type of the resulting array manually as follows

```jldoctest
julia> Real[Int32(123), 1, 1.5, 1.234f0]
4-element Array{Real,1}:
 123
   1
   1.5
   1.234f0
```

In this case, the types of all elements are preserved.

```@raw html
</p></div>
```

In the definition of the `BankAccount` type, we also define the following inner constructor.

```julia
function BankAccount(owner::String, C::Type{<:Currency})
    return new{C}(owner, Currency[zero(C)])
end
```

This constructor rewrites the default constructor for creating a new instance of the `BankAccount` type. The idea is as follows: when we want to create a new account, we must know the owner's name and the primary currency of the account. The constructor above accepts two inputs arguments: the name of the owner and the primary currency. Then it will create a new instance of the `BankAccount` type with the name of the owner and zero transaction, i.e., the transaction of amount zero in the primary currency. Note that we defined the `BankAccount` type as a parametric type, where the parameter is the account's primary currency. Also note, that the primary currency is stored only in the parameter of the type.

One may notice that we use only the abstract type `Currency` in the definition of the `BankAccount` type. It is very useful since it allows us to write a generic code that is not specified for some concrete type. However, we are now in a situation that we defined a new type, but we cannot test it since the type uses concrete subtypes of the `Currency` abstract type. Moreover, we used functions that are not defined for the `Currency` type, such as the `zero` function, and there are other functions such as the `sum` function or the `convert` function that should be defined for currencies as well.

The situation with the `zero` function can be fixed easily by adding new methods to the `zero` function from the `Base`.

```jldoctest currency; output=false
Base.zero(C::Type{<:Currency}) = C(0)
Base.zero(c::Currency) = zero(typeof(c))

# output

```

In our case, we added two new methods. The former one works for any subtype of the `Currency` type and the latter for any instance of any subtype of the `Currency` type. In the functions above, we use only the latter method. However, for convenience, it is useful to define the former method too. The rest of the methods can not be defined in such a simple way. In the rest of the section, we will show how to define the `conversion` function for currencies. We will also show how to define arithmetic operations and other basic functions on currencies.

## Concrete types

Firstly we create one concrete subtype of the `Currency` abstract type that allows us to test functions. It can be done as follows.

```jldoctest currency; output=false
struct Euro <: Currency
    value::Float64
end

# output

```

Note that we use the `Float64` type to store the amount of the currency. It should probably be better to define the `Euro` type as a parametric type as follows.

```julia
struct Euro{T<:Real} <: Currency
    value::T
end
```

However, since we want to make all examples as understandable as possible, we use the simplified version. Since `Euro` is a concrete type, we can create its instance.

```jldoctest currency
julia> Euro(1)
Euro(1.0)

julia> Euro(1.5)
Euro(1.5)
```

We can also use the `isa` function to check that the resulting instance is of the type that is a subtype of `Currency` type.

```jldoctest currency
julia> isa(Euro(1), Currency) # equivalent to typeof(Euro(1)) <: Currency
true
```

Each currency typically has its symbol that is used instead of the name of the currency. We can redefine the `show` function to print the currencies in a prettier way. Firstly we define a new function `symbol` that will return the symbol of the used currency.

```jldoctest currency; output=false
symbol(T::Type{<:Currency}) = string(nameof(T))
symbol(::Type{Euro}) = "€"

# output

symbol (generic function with 2 methods)
```

Note that we defined one method for all subtypes of the `Currency` type and then one method that is used only for the `Euro` type. With the `symbol` function, we can define custom pretty printing. It can be done by adding a new method to the `show` function from the `Base`. It is possible to define a custom show function for different output formats. For example, it is possible to define different formating for HTML output. In the example below, we show only the basic usage. For more information the [official documentation](https://docs.julialang.org/en/v1/manual/types/#man-custom-pretty-printing).

```jldoctest currency; output=false
Base.show(io::IO, c::T) where {T <: Currency} = print(io, c.value, " ", symbol(T))

# output

```

We can check that now the printing of the currencies is prettier than the default one.

```jldoctest currency
julia> Euro(1)
1.0 €

julia> Euro(1.5)
1.5 €
```

Finally, we can check that we define the `zero` function properly.

```jldoctest currency
julia> zero(Euro)
0.0 €

julia> zero(Euro(1.5))
0.0 €
```

It seems that everything works well. Note one big difference against Python. In Python, we can create a class and then define methods inside the class. If we want to add a new method, we have to modify the class. In Julia, methods for types can be defined at any time without the necessity to modify the type definition.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

In the next section, we will define the `conversion` function for the currencies. However, we have defined only one currency so far. Define `Dollar` currency, and do not forget to add a new method to the `symbol` function.

**Hint:** the dollar symbol `$` has a special meaning in Julia. Do not forget to use the `\` symbol when using the dollar symbol in a string.


```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The `Dollar` currency can be defined in the same way as we defined `Euro` earlier.

```jldoctest currency; output=false
struct Dollar <: Currency
    value::Float64
end

# output

```

When adding a new method to the `symbol` function, we have to take in mind that we used the currency type for dispatch, i.e., we have to use `::Type{Dollar}` instead of `::Dollar` in the type annotation.

```jldoctest currency; output=false
symbol(::Type{Dollar}) = "\$"

# output

symbol (generic function with 3 methods)
```

Now we can check that all is defined properly.

```jldoctest currency
julia> Dollar(1)
1.0 $

julia> Dollar(1.5)
1.5 $

julia> zero(Dollar)
0.0 $

julia> zero(Dollar(1.5))
0.0 $
```

```@raw html
</p></details>
```

## Conversion

In the previous section, we have defined two currencies. A natural question is how to convert one currency to the other.  In the real world, the exchange operation between currencies is not transitive. However, we will assume that the **exchange is transitive** for simplicity and educational purposes. It will allow us to define the `convert` function without defining the exchange rate for all pairs of currencies.

The simplest way how to define conversion between currencies is to define the conversion function for each combination of pairs of currencies. It can be done in a simple way if we have only two currencies.

```jldoctest currency; output=false
dollar2euro(c::Dollar) = Euro(0.83 * c.value)
euro2dollar(c::Euro) = Euro(c.value / 0.83)

# output

euro2dollar (generic function with 1 method)
```

We can easily check that the result is correct.

```jldoctest currency
julia> eur = dollar2euro(Dollar(1.3))
1.079 €

julia> euro2dollar(eur)
1.3 €
```

It is a valid way to write a code. However, we can do it more generically. To write a generic code, we have to realize few things. Consider the situation that we have two currencies, and we know the exchange rate ``r_{1 \rightarrow 2}`` from the first currency to the second one. The transitivity assumption implies that the second currency's exchange rate to the first one is `r_{2 \rightarrow 1} = r_{1 \rightarrow 2}^{-1}`. This means that we only need to define one exchange rate from which the other can be calculated.

```jldoctest currency; output=false
rate(::Type{Euro}, ::Type{Dollar}) = 0.83

# output

rate (generic function with 1 method)
```

and then we can use a generic function that will define the exchange rate for the opposite direction

```jldoctest currency; output=false
rate(T::Type{<:Currency}, ::Type{Euro}) = 1 / rate(Euro, T)

# output

rate (generic function with 2 methods)
```

If we use only the two methods above, it will work perfectly to compute the exchange rate between `Dollar` and `Euro`

```jldoctest currency
julia> rate(Euro, Dollar)
0.83

julia> rate(Dollar, Euro)
1.2048192771084338
```

However, the definition is not complete because the `rate` function will not work if we use the same currencies

```jldoctest currency
julia> rate(Euro, Euro)
ERROR: StackOverflowError:
[...]

julia> rate(Dollar, Dollar)
ERROR: MethodError: no method matching rate(::Type{Dollar}, ::Type{Dollar})
[...]
```

To solve this issue, we have to add two new methods. The first one defines that the exchange rate between two same currencies is `1`.

```jldoctest currency; output=false
rate(::Type{T}, ::Type{T}) where {T<:Currency} = 1

# output

rate (generic function with 3 methods)
```

This method solves the issue for the `Dollar` to `Dollar` conversion.

```jldoctest currency
julia> rate(Dollar, Dollar)
1
```

However, it does not solve the problem with `Euro` to `Euro` conversion.

```jldoctest currency
julia> rate(Euro, Euro)
ERROR: StackOverflowError:
[...]
```

The reason is, that methods are selected based on the input arguments. There is a simple rule:  the most specific method definition matching the number and types of the arguments will be executed. We can use the `methods` function to get the list of all methods defined for the `rate` function.

```julia
julia> methods(rate)
# 3 methods for generic function "rate":
[1] rate(::Type{Euro}, ::Type{Dollar}) in Main at none:1
[2] rate(T::Type{var"#s37"} where var"#s37"<:Currency, ::Type{Euro}) in Main at none:1
[3] rate(::Type{T}, ::Type{T}) where T<:Currency in Main at none:1
```

There are three methods, and two of them are specified for the `Euro` type. So we have to define a specific method for  `Euro` to `Euro` conversion as follows.

```jldoctest currency; output=false
rate(::Type{Euro}, ::Type{Euro}) = 1

# output

rate (generic function with 4 methods)
```

This method solves the issue, as can be seen in the example below.

```jldoctest currency
julia> rate(Euro, Euro)
1
```

The last thing we need to realize is the following. Instead of converting the `C1` currency directly to the` C2` currency, we can first convert it to some `C` currency and then convert the` C` currency to the `C2` currency. Recall that this is only possible since we assume transitivity of the exchange operation. In our case, we use the `Euro` as the intermediate currency, i.e., we can add a new method to the rate function that will finalize the converting pipeline.

```jldoctest currency; output=false
rate(T::Type{<:Currency}, C::Type{<:Currency}) = rate(Euro, C) * rate(T, Euro)

# output

rate (generic function with 5 methods)
```

To test if the `test` function works as intended, we have to add a new currency.

```jldoctest currency; output=false
struct Pound <: Currency
    value::Float64
end

symbol(::Type{Pound}) = "£"

rate(::Type{Euro}, ::Type{Pound}) = 1.13

# output

rate (generic function with 6 methods)
```

We can easily test that the rate function works in all possible cases correctly in the following way.

```jldoctest currency
julia> rate(Pound, Pound) # 1
1

julia> rate(Euro, Pound) # 1.13
1.13

julia> rate(Pound, Euro) # 1/1.13 = 0.8849557522123894
0.8849557522123894

julia> rate(Dollar, Pound) # 1.13 * 1/0.83 = 1.36144578313253
1.3614457831325302

julia> rate(Pound, Dollar) # 0.83 * 1/1.13 = 0.7345132743362832
0.7345132743362832
```

We see that the results are correct. Since we defined the `rate` function with all necessary methods, we are able to easily extend the `convert` function to support conversion between currencies by defining a new method to the `convert` function from `Base`.

```jldoctest currency; output=false
Base.convert(::Type{T}, c::T) where {T<:Currency} = c
Base.convert(::Type{T}, c::C) where {T<:Currency, C<:Currency} = T(c.value * rate(T, C))

# output

```

Note that we define two methods. The first method is unnecessary because the `rate` function returns `1`, and the second method can be used instead.  However, when converting to the same type in Julia, the result is usually the same object and not a new instance. So we defined the first method to follow the convention. Finally, we can test that the `conversion` function works.

```jldoctest currency
julia> eur = convert(Euro, Dollar(1.3))
1.079 €

julia> pnd = convert(Pound, eur)
0.9548672566371682 £

julia> dlr = convert(Dollar, pnd)
1.3 $
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

We see that the print style of currencies is not ideal. Usually, we are not interested in more than the first two digits after the decimal point. Redefine the method in the `show` function to print currencies so that the result will be rounded to 2 digits after the decimal point.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Any real number can be rounded to 2 digits after the decimal point using the `round` function with the keyword argument `digits = 2`. Then we can use an almost identical definition of the method as before and only add the `round` function.

```jldoctest currency; output=false
function Base.show(io::IO, c::T) where {T <: Currency}
    val = round(c.value; digits = 2)
    return print(io, val, " ", symbol(T))
end

# output

```

If we use the same example as the one placed before this exercise, we get the following results.

```jldoctest currency
julia> eur = convert(Euro, Dollar(1.3))
1.08 €

julia> pnd = convert(Pound, eur)
0.95 £

julia> dlr = convert(Dollar, pnd)
1.3 $
```

```@raw html
</p></details>
```

## Promotion

Before defining the basic arithmetic operations for currencies, we have to decide how to work with money in different currencies. Imagine the situation, that we want to sum `1€` with `1$`. What should be the result? Should it be euro or dollar? For such a situation, Julia provides a promotion system that allows defining simple rules for promoting custom types. The promotion system can be modified by defining custom methods for the `promote_rule` function. For example, the following definition means that the euro has precedence against all other currencies

```jldoctest currency; output=false
Base.promote_rule(::Type{Euro}, ::Type{<:Currency}) = Euro

# output

```

Note that one does not need to define both methods, as can be seen below.

```julia
Base.promote_rule(::Type{Euro}, ::Type{<:Currency}) = ...
Base.promote_rule(::Type{Euro}, ::Type{<:Currency}) = ...
```

The symmetry is implied by the way `promote_rule` is used in the promotion process. Since we have three different currencies, we also have to define the promotion type for pair `Dollar`, `Pound`.

```jldoctest currency; output=false
Base.promote_rule(::Type{Dollar}, ::Type{Pound}) = Dollar

# output

```

The `promote_rule` function is used as a building block to define a second function called `promote_type`, which, given any number of type objects, returns the common type to which those values, as arguments to promote should be promoted. Thus, if one wants to know, in absence of actual values, what type a collection of values of certain types would promote to, one can use promote_type:

```jldoctest currency
julia> promote_type(Euro, Dollar)
Euro

julia> promote_type(Pound, Dollar)
Dollar

julia> promote_type(Pound, Dollar, Euro)
Euro
```

To perform actual promotion, we can use the `promote` function that converts all its input arguments to their promote type.

```jldoctest currency
julia> promote(Euro(2), Dollar(2.4))
(2.0 €, 1.99 €)

julia> promote(Pound(1.3), Euro(2))
(1.47 €, 2.0 €)

julia> promote(Pound(1.3), Dollar(2.4), Euro(2))
(1.47 €, 1.99 €, 2.0 €)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Define a new currency, `CzechCrown`, that will represent Czech crowns. The exchange rate to euro is `0.038.`

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Firstly we have to define a new type `CzechCrown`.

```jldoctest currency; output=false
struct CzechCrown <: Currency
    value::Float64
end

# output

```

With the defined type, we must add new methods for the `symbol` and `rate` function.

```jldoctest currency; output=false
symbol(::Type{CzechCrown}) = "Kč"

rate(::Type{Euro}, ::Type{CzechCrown}) = 0.038

# output

rate (generic function with 7 methods)
```

We also must add promotion rules for the dollar and pound.

```jldoctest currency; output=false
Base.promote_rule(::Type{CzechCrown}, ::Type{Dollar}) = Dollar
Base.promote_rule(::Type{CzechCrown}, ::Type{Pound}) = Pound

# output

```

Finally, we can test the functionality.

```jldoctest currency
julia> CzechCrown(2.8)
2.8 Kč

julia> zero(CzechCrown)
0.0 Kč

julia> dl = convert(Dollar, CzechCrown(64))
2.93 $

julia> convert(CzechCrown, dl)
64.0 Kč

julia> promote(Pound(1.3), Dollar(2.4), Euro(2), CzechCrown(2.8))
(1.47 €, 1.99 €, 2.0 €, 0.11 €)
```

```@raw html
</p></details>
```

## Basic arithmetic operations

Now we are ready to define basic arithmetic operations. As usual, it can be done by adding a new method into standard functions. We will start with the addition. There are two cases that we have to take into account. The first is that we want to sum two different currencies. In this case, we use the `promote` function to convert these to currencies to their promote type.

```jldoctest currency; output=false
Base.:+(x::Currency, y::Currency) = +(promote(x, y)...)

# output

```

The second case is that we want to sum money in the same currency. In this case, we know the resulting currency, and we can sum the `value` fields.

```jldoctest currency; output=false
Base.:+(x::T, y::T) where {T <: Currency} = T(x.value + y.value)

# output

```

And that is all. Now we are able to sum money in different currencies

```jldoctest currency
julia> Dollar(1.3) + CzechCrown(4.5)
1.51 $

julia> CzechCrown(4.5) + Euro(3.2) + Pound(3.6) + Dollar(12)
17.4 €
```

Moreover, we can use, for example, the `sum` function without any additional changes.

```jldoctest currency
julia> sum([CzechCrown(4.5), Euro(3.2), Pound(3.6), Dollar(12)])
17.4 €
```

Also, the broadcasting will work natively if we use arrays of currencies.

```jldoctest currency
julia> CzechCrown.([4.5, 2.4, 16.7, 18.3]) .+ Pound.([1.2, 2.6, 0.6, 1.8])
4-element Array{Pound,1}:
 1.35 £
 2.68 £
 1.16 £
 2.42 £
```

However, there is a problem if we want a sum vector of currencies with one currency. In such a case, the error will occur.

```julia
julia> CzechCrown.([4.5, 2.4, 16.7, 18.3]) .+ Dollar(12)
ERROR: MethodError: no method matching length(::Main.Dollar)
[...]
```

The reason is that Julia assumes that custom structure is iterable. But in our case, all subtypes of the `Currency` type represent scalar values. This situation can be easily fixed by defining a new method to the `broadcastable` function from the `Base` module

```jldoctest currency; output=false
Base.broadcastable(c::Currency) = Ref(c)

# output

```

This function should return either the given object or some representation of the given object that supports the `axes` function, `ndims` function, and `indexing`. To create such a representation of all subtypes of the `Currency` type, we can use the `Ref` function. The `Ref` function creates an object that refers to the given currency instance and supports all necessary operations.

```jldoctest currency
julia> c_ref = Ref(Euro(1))
Base.RefValue{Euro}(1.0 €)

julia> axes(c_ref)
()

julia> ndims(c_ref)
0

julia> c_ref[]
1.0 €
```

Now we can test if the broadcasting works as expected.

```jldoctest currency
julia> CzechCrown.([4.5, 2.4, 16.7, 18.3]) .+ Dollar(12)
4-element Array{Dollar,1}:
 12.21 $
 12.11 $
 12.76 $
 12.84 $
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

In the section above, we defined the addition for all subtypes of the `Currency`. We also told the broadcasting system in Julia to treat all subtypes of the `Currency` as scalars. Follow the same pattern and define all following operations: `-`, `*`, `/`.

**Hint:** Define only the operations that make sense. For example, It makes sense to multiply `1 €` by 2 and get `2 €`. But it does not make sense to multiply `1 €` by `2 €`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The `-` operation can be defined in the exact same way as the addition in the previous section.

```jldoctest currency; output=false
Base.:-(x::Currency, y::Currency) = -(promote(x, y)...)
Base.:-(x::T, y::T) where {T <: Currency} = T(x.value - y.value)

# output

```

In the example below, we can see that everything works as intended.

```jldoctest currency
julia> Dollar(1.3) - CzechCrown(4.5)
1.09 $

julia> CzechCrown.([4.5, 2.4, 16.7, 18.3]) .- Dollar(12)
4-element Array{Dollar,1}:
 -11.79 $
 -11.89 $
 -11.24 $
 -11.16 $
```

The situation with the multiplication is a little bit different. It makes sense to multiply `1 €` by 2 and get `2 €`. But it does not make sense to multiply `1 €` by `2 €`. It means that we have to define a method for multiplying the instance of any `Currency` subtype by a real number. Moreover, we have to define multiplication from the right and also from the left. It can be done as follows.

```jldoctest currency; output=false
Base.:*(a::Real, x::T) where {T <: Currency} = T(a * x.value)
Base.:*(x::T, a::Real) where {T <: Currency} = T(a * x.value)

# output

```

As in the previous cases, everything works as expected, and broadcasting is supported without any additional steps.

```jldoctest currency
julia> 2 * Dollar(1.3) * 0.5
1.3 $

julia> 2 .* CzechCrown.([4.5, 2.4, 16.7, 18.3]) .* 0.5
4-element Array{CzechCrown,1}:
 4.5 Kč
 2.4 Kč
 16.7 Kč
 18.3 Kč
```

Finally, we can define division. In this case, it makes sense to define the division of the instance of any `Currency` subtype by a real number. In such a case, the result is the instance of the same currency

```jldoctest currency; output=false
Base.:/(x::T, a::Real) where {T <: Currency} = T(x.value / a)

# output

```

But it also makes sense to define the division of one amount of money by another amount of money. In this case, a result is a real number that represents the ratio of the given amounts of money.

```jldoctest currency; output=false
Base.:/(x::Currency, y::Currency) = /(promote(x, y)...)
Base.:/(x::T, y::T) where {T <: Currency} = x.value / y.value

# output

```

The result is as follows.


```jldoctest currency
julia> Dollar(1.3) / 2
0.65 $

julia> 2 .* CzechCrown.([1, 2, 3, 4]) ./ CzechCrown(1)
4-element Array{Float64,1}:
 2.0
 4.0
 6.0
 8.0
```

```@raw html
</p></details>
```

## Currency comparison

The last thing we should define is comparison operators. To provide all comparison operators' full functionality, we have to add new methods to two functions. The first one is value equality operator `==`. By default, the following definition is used `==(x, y) = x === y`. The `===` operator determines whether `x` and `y` are identical, in the sense that no program could distinguish them.

```jldoctest currency
julia> Dollar(1) == Euro(0.83)
false

julia> Dollar(1) != Euro(0.83)
true
```

Note that the result does not match the expected behavior since the `0.83 €` is equal to `1 $` with the given exchange rate. The reason is that we want to compare values stored in the structures and not the structures themselves. To allow this kind of comparison, we can define new methods to the `==` function as follows.

```jldoctest currency; output=false
Base.:(==)(x::Currency, y::Currency) = ==(promote(x, y)...)
Base.:(==)(x::T, y::T) where {T <: Currency} = ==(x.value, y.value)

# output

```

With these two methods defined, the comparison works as expected.

```jldoctest currency
julia> Dollar(1) == Euro(0.83)
true

julia> Dollar(1) != Euro(0.83)
false
```

Another function that we have to extend is the `isless` function. In this case, the logic is the same as before: we want to compare values stored in the structure.

```jldoctest currency; output=false
Base.isless(x::Currency, y::Currency) = isless(promote(x, y)...)
Base.isless(x::T, y::T) where {T <: Currency} = isless(x.value, y.value)

# output

```

As can be seen below, all operations work as intended.

```jldoctest currency
julia> Dollar(1) < Euro(0.83)
false

julia> Dollar(1) > Euro(0.83)
false

julia> Dollar(1) <= Euro(0.83)
true

julia> Dollar(1) >= Euro(0.83)
true
```

Moreover, also other functions work for all subtypes of the `Currency` type immediately without any additional changes.

```jldoctest currency
julia> vals = Currency[CzechCrown(100), Euro(0.83),  Pound(3.6), Dollar(1.2)]
4-element Array{Currency,1}:
 100.0 Kč
 0.83 €
 3.6 £
 1.2 $

julia> extrema(vals)
(0.83 €, 3.6 £)

julia> argmin(vals)
2

julia> sort(vals)
4-element Array{Currency,1}:
 0.83 €
 1.2 $
 100.0 Kč
 3.6 £
```

## Back to bank account

In the previous sections, we defined all the functions and types needed for the proper functionality of the `BankAccount` type defined at the top of the page. We can test it by creating a new instance of this type.

```jldoctest currency
julia> b = BankAccount("Paul", CzechCrown)
BankAccount{CzechCrown}("Paul", Currency[0.0 Kč])
```

Now it is time to define some auxiliary functions. For example, we can define the `balance` function that will return the account's current balance. Since we store all transactions in a vector, the current balance of the account can be simply computed as a sum of the `transaction` field.

```jldoctest currency; output=false
balance(b::BankAccount{C}) where {C} = convert(C, sum(b.transaction))

# output

balance (generic function with 1 method)
```

Note that we convert the balance to the primary currency of the account.

```jldoctest currency
julia> balance(b)
0.0 Kč
```

Another thing that we can define is custom pretty-printing.

```jldoctest currency; output=false
function Base.show(io::IO, b::BankAccount{C}) where {C<:Currency}
    println(io, "Bank Account:")
    println(io, "  - Owner: ", b.owner)
    println(io, "  - Primary currency: ", nameof(C))
    println(io, "  - Balance: ", balance(b))
    print(io,   "  - Number of transactions: ", length(b.transaction))
end

# output

```

which results in the following output.

```jldoctest currency
julia> b
Bank Account:
  - Owner: Paul
  - Primary currency: CzechCrown
  - Balance: 0.0 Kč
  - Number of transactions: 1
```

The last function that we define is the function that adds a new transaction into the given bank account. This function can be defined like a normal function. However, we decided to use a special syntax. Since methods are associated with types, it is possible to make any arbitrary Julia object "callable" by adding methods to its type. Such "callable" objects are sometimes called "functors." Functor for the `BankAccount` type can be defined in the following way.

```jldoctest currency; output=false
function (b::BankAccount{T})(c::Currency) where {T}
    balance(b) + c >= zero(T) || throw(ArgumentError("insufficient bank account balance."))
    push!(b.transaction, c)
    return
end

# output

```

The first thing that happened in the function above is the check if there is a sufficient bank account balance. If not, the function will throw an error. Otherwise, the function will push a new element to the `transaction` field.

```jldoctest currency
julia> b(Dollar(10))

julia> b(-2*balance(b))
ERROR: ArgumentError: insufficient bank account balance.

julia> b(Pound(10))

julia> b(Euro(23.6))

julia> b(CzechCrown(152))

julia> b
Bank Account:
  - Owner: Paul
  - Primary currency: CzechCrown
  - Balance: 1288.84 Kč
  - Number of transactions: 5
```

Note that all transactions are stored in their original currency, as can be seen, if we print the `transaction` field.

```jldoctest currency
julia> b.transaction
5-element Array{Currency,1}:
 0.0 Kč
 10.0 $
 10.0 £
 23.6 €
 152.0 Kč
```
