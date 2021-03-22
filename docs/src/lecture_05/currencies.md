# Bank account

This section aims to show the real power of the Julia type system in combination with multiple-dispatch. We will present it through an example, where the goal is to create a structure that represents a bank account with the following properties:

- The structure has two fields: `owner` and `transaction`.
- It is possible to make transactions in different currencies.
- All transactions are stored in the currency in which they were made.

Before creating such a structure, we first define an abstract type `Currency` and its two concrete subtypes.

```jldoctest currency; output=false
abstract type Currency end

struct Euro <: Currency
    value::Float64
end

struct Dollar <: Currency
    value::Float64
end

# output

```

Since `Euro` and `Dollar` are concrete types, we can create their instances and use `isa` to check that these instances are subtypes of `Currency`.

```jldoctest currency
julia> Euro(1)
Euro(1.0)

julia> isa(Dollar(2), Currency) # equivalent to typeof(Dollar(2)) <: Currency
true
```

As `Currency` is an abstract type, we cannot create its instance. However, abstract types allow us to define generic functions that work for all their subtypes. We do so and define the `BankAccount` composite type.

```jldoctest currency; output=false
struct BankAccount{C<:Currency}
    owner::String
    transaction::Vector{Currency}

    function BankAccount(owner::String, C::Type{<:Currency})
        return new{C}(owner, Currency[C(0)])
    end
end

# output

```

We will explain this type after creating its instance with the euro currency.

```jldoctest currency
julia> b = BankAccount("Paul", Euro)
BankAccount{Euro}("Paul", Currency[Euro(0.0)])
```

First, we observe that we use the `Euro` type (and not its instance) to instantiate the `BankAccount` type. The reason is the definition of the inner constructor for `BankAccount`, where the type annotation is `::Type{<:Currency}`. This is in contrast with `::Currency`. The former requires that the argument is a type, while the former needs an instance.

Second, due to the line `Currency[C(0)]` in the inner constructor, transactions are stored in a vector of type `Vector{Currency}`. The expression `C(0)` creates an instance of the currency `C` with zero value. The `Currency` type combined with the square brackets creates a vector that may contain instances of any subtypes of `Currency`. It is, therefore, possible to push a new transaction in a different currency to the `transaction` field.

Third, `BankAccount` is a parametric type, as can be seen from `BankAccount{Euro}`. In our example, this parameter plays the role of the primary account currency.

```jldoctest currency
julia> push!(b.transaction, Dollar(2))
2-element Array{Currency,1}:
 Euro(0.0)
 Dollar(2.0)

julia> b
BankAccount{Euro}("Paul", Currency[Euro(0.0), Dollar(2.0)])
```

It is crucial to use `Currency` in `Currency[C(0)]`. Without it, we would create an array of type `C` only. We would not be able to add transactions in different currencies to this array as Julia could not convert the different currencies to `C`.

```jldoctest currency
julia> w = [Euro(0)]
1-element Array{Euro,1}:
 Euro(0.0)

julia> push!(w, Dollar(2))
ERROR: MethodError: Cannot `convert` an object of type Dollar to an object of type Euro
[...]
```

We used only the abstract type `Currency` to define the `BankAccount` type. This allows us to write a generic code that not constrained to one concrete type. We created an instance of `BankAccount` and added a new transaction. However, we cannot calculate an account balance (the sum of all transactions), and we cannot convert money from one currency to another. In the rest of the lecture, we will fix this, and we will also define basic arithmetic operations such as `+` or `-`.


```@raw html
<div class = "info-body">
<header class = "info-header">Avoid containers with abstract type parameters</header><p>
```

It is generally not good to use [containers with abstract element type](https://docs.julialang.org/en/v1/manual/performance-tips/#man-performance-abstract-container) as we did for storing transactions. We used it in the example above because we do not want to convert all transactions to a common currency. When we create an array from different types, the promotion system converts these types to their smallest supertype for efficient memory storage.

```jldoctest
julia> [Int32(123), 1, 1.5, 1.234f0]
4-element Array{Float64,1}:
 123.0
   1.0
   1.5
   1.2339999675750732
```

The smallest supertype is `Float64`, and the result is `Array{Float64, 1}`. When we do not want to convert the variables, we must manually specify the resulting array supertype.

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


## Custom print

Each currency has its symbol, such as € for the euro. We will redefine the `show` function to print the currency in a prettier way. First, we define a new function `symbol` that returns the used currency symbol.

```jldoctest currency; output=false
symbol(T::Type{<:Currency}) = string(nameof(T))
symbol(::Type{Euro}) = "€"

# output

symbol (generic function with 2 methods)
```

We defined one method for all subtypes of `Currency` and one method for the `Euro` type. With the `symbol` function, we can define nicer printing by adding a new method to the `show` function from `Base`. It is possible to define a custom show function for different output formats. For example, it is possible to define different formating for HTML output. The example below shows only basic usage; for more information, see the [official documentation](https://docs.julialang.org/en/v1/manual/types/#man-custom-pretty-printing).

```jldoctest currency; output=false
Base.show(io::IO, c::C) where {C <: Currency} = print(io, c.value, " ", symbol(C))

# output

```

The `show` function has two input arguments. The first one is of type `IO` that specifies where the output will be printed (for example, in the REPL). The second argument is an instance of some currency. We used the `where` keyword in the function definition to get the currency type `C`, which we pass to the `symbol` function. Alternatively, we can use the `typeof` function.

```julia
Base.show(io::IO, c::Currency) = print(io, c.value, " ", symbol(typeof(c)))
```

We can check that the printing of currencies is prettier than before.

```jldoctest currency
julia> Euro(1)
1.0 €

julia> Euro(1.5)
1.5 €
```

There is one big difference with Python, where we can create a class and define methods inside the class. If we wanted to add a new method, we have to would modify the class. In Julia, we can add or alter methods any time without the necessity to change the class.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Define a new method for the `symbol` function for `Dollar`.

**Hint:** the dollar symbol `$` has a special meaning in Julia. Do not forget to use the `\` symbol when using the dollar symbol in a string.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

When adding a new method to the `symbol` function, we have to remember that we used the currency type for dispatch, i.e., we have to use `::Type{Dollar}` instead of `::Dollar` in the type annotation.

```jldoctest currency; output=false
symbol(::Type{Dollar}) = "\$"

# output

symbol (generic function with 3 methods)
```

Now we can check that everything works well.

```jldoctest currency
julia> Dollar(1)
1.0 $

julia> Dollar(1.5)
1.5 $
```

```@raw html
</p></details>
```

## Conversion

In the previous section, we have defined two currencies. A natural question is how to convert one currency to the other.  In the real world, the exchange operation between currencies is not transitive. However, we assume that the **exchange rate is transitive** and there are no exchange costs.

The simplest way to define conversions between the currencies is to define the conversion function for each pair of currencies. This can be done efficiently only for two currencies.

```jldoctest currency; output=false
dollar2euro(c::Dollar) = Euro(0.83 * c.value)
euro2dollar(c::Euro) = Euro(c.value / 0.83)

# output

euro2dollar (generic function with 1 method)
```

We can check that the result is correct.

```jldoctest currency
julia> eur = dollar2euro(Dollar(1.3))
1.079 €

julia> euro2dollar(eur)
1.3 €
```

Even though this is a way to write code, there is a more general way. We start with a conversion rate between two types.

```jldoctest currency; output=false
rate(::Type{Euro}, ::Type{Dollar}) = 0.83

# output

rate (generic function with 1 method)
```

Transitivity implies that if one exchange rate is ``r_{1 \rightarrow 2}``, the opposite exchange rate equals ``r_{2 \rightarrow 1} = r_{1 \rightarrow 2}^{-1}``. We create a generic function to define the exchange rate in the opposite direction.

```jldoctest currency; output=false
rate(T::Type{<:Currency}, ::Type{Euro}) = 1 / rate(Euro, T)

# output

rate (generic function with 2 methods)
```

If we use only the two methods above, it computes the exchange rate between `Dollar` and `Euro`.

```jldoctest currency
julia> rate(Euro, Dollar)
0.83

julia> rate(Dollar, Euro)
1.2048192771084338
```

However, the definition is not complete because the `rate` function does not work if we use the same currencies.

```jldoctest currency
julia> rate(Euro, Euro)
ERROR: StackOverflowError:
[...]

julia> rate(Dollar, Dollar)
ERROR: MethodError: no method matching rate(::Type{Dollar}, ::Type{Dollar})
[...]
```

To solve this issue, we have to add two new methods. The first one defines that the exchange rate between the same currency is `1`.

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

The reason is that methods are selected based on the input arguments. There is a simple rule:  the most specific method definition matching the number and types of the arguments will be executed. We use the `methods` function to list all methods defined for the `rate` function.

```julia
julia> methods(rate)
# 3 methods for generic function "rate":
[1] rate(::Type{Euro}, ::Type{Dollar}) in Main at none:1
[2] rate(T::Type{var"#s37"} where var"#s37"<:Currency, ::Type{Euro}) in Main at none:1
[3] rate(::Type{T}, ::Type{T}) where T<:Currency in Main at none:1
```

There are three methods. Since two of them can be selected when converting from euro to euro, we need to specify one more method.

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

The transitivity also implies that instead of converting the `C1` currency directly to the `C2` currency, we can convert it to some `C` and then convert `C` to `C2`. In our case, we use the `Euro` as the intermediate currency. When adding a new currency, it suffices to specify its exchange rate only to the euro.

```jldoctest currency; output=false
rate(T::Type{<:Currency}, C::Type{<:Currency}) = rate(Euro, C) * rate(T, Euro)

# output

rate (generic function with 5 methods)
```

To test the `rate` function, we add a new currency.

```jldoctest currency; output=false
struct Pound <: Currency
    value::Float64
end

symbol(::Type{Pound}) = "£"

rate(::Type{Euro}, ::Type{Pound}) = 1.13

# output

rate (generic function with 6 methods)
```


We can quickly test that the `rate` function works in all possible cases correctly in the following way.

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

We have defined the `rate` function with all necessary methods. To convert currency types, we need to extend the `convert` function from `Base` by the following two methods:

```jldoctest currency; output=false
Base.convert(::Type{T}, c::T) where {T<:Currency} = c
Base.convert(::Type{T}, c::C) where {T<:Currency, C<:Currency} = T(c.value * rate(T, C))

# output

```

The first method is unnecessary because the `rate` function returns `1`, and the second method could be used instead.  However, when converting to the same type, the result is usually the same object and not a new instance. We, therefore, defined the first method to follow this convention. Finally, we test that the `conversion` function indeed converts its input to a different type.

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

Note that the rounding is done only for printing, but the original value is unchanged.

```@raw html
</p></details>
```

## Promotion

Before defining the basic arithmetic operations for currencies, we have to decide how to work with money in different currencies. Imagine the situation, that we want to sum `1€` with `1$`. What should be the result? Should it be euro or dollar? For such a situation, Julia provides a promotion system that allows defining simple rules for promoting custom types. The promotion system can be modified by defining custom methods for the `promote_rule` function. For example, the following definition means that the euro has precedence against all other currencies.

```jldoctest currency; output=false
Base.promote_rule(::Type{Euro}, ::Type{<:Currency}) = Euro

# output

```

Note that one does not need to define both methods, as can be seen below.

```julia
Base.promote_rule(::Type{Euro}, ::Type{<:Currency}) = ...
Base.promote_rule(::Type{<:Currency}, ::Type{Euro}) = ...
```

The symmetry is implied by the way `promote_rule` is used in the promotion process. Since we have three different currencies, we also have to define the promotion type for pair `Dollar`, `Pound`.

```jldoctest currency; output=false
Base.promote_rule(::Type{Dollar}, ::Type{Pound}) = Dollar

# output

```

The `promote_rule` function is used as a building block to define a second function called `promote_type`, which, given any number of type objects, returns the common type to which those values, as arguments to promote should be promoted. In the absence of actual values, we can use the `promote_type` function to test to what type a collection of values of certain types would promote.

```jldoctest currency
julia> promote_type(Euro, Dollar)
Euro

julia> promote_type(Pound, Dollar)
Dollar

julia> promote_type(Pound, Dollar, Euro)
Euro
```

We can use the `promote` function that converts all its input arguments to their promote type to perform actual promotion.

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

Define a new currency, `CzechCrown`, that will represent Czech crowns. The exchange rate to euro is `0.038`, and all other currencies should take precedence over the Czech crown.

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

We must add new methods for the `symbol` and `rate` function with the defined type.

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

And that is all. Now we are able to sum money in different currencies.

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

However, there is a problem if we want a sum vector of currencies with one currency. In such a case, an error will occur.

```julia
julia> CzechCrown.([4.5, 2.4, 16.7, 18.3]) .+ Dollar(12)
ERROR: MethodError: no method matching length(::Main.Dollar)
[...]
```

The reason is that Julia assumes that custom structure is iterable. But in our case, all subtypes of the `Currency` type represent scalar values. This situation can be easily fixed by defining a new method to the `broadcastable` function from the `Base`.

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

The situation with the multiplication is a little bit different. It makes sense to multiply `1 €` by 2 and get `2 €`. But it does not make sense to multiply `1 €` by `2 €`. It means that we have to define a method for multiplying any `Currency` subtype by a real number. Moreover, we have to define multiplication from the right and also from the left. It can be done as follows.

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

Finally, we can define division. In this case, it makes sense to define the division of the instance of any `Currency` subtype by a real number. In such a case, the result is the instance of the same currency.

```jldoctest currency; output=false
Base.:/(x::T, a::Real) where {T <: Currency} = T(x.value / a)

# output

```

But it also makes sense to define the division of one amount of money by another amount of money. In this case, a result is a real number representing the ratio of the given amounts of money.

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

In the previous sections, we defined all the functions and types needed for the `BankAccount` type's proper functionality at the top of the page. We can test it by creating a new instance of this type.

```jldoctest currency
julia> b = BankAccount("Paul", CzechCrown)
BankAccount{CzechCrown}("Paul", Currency[0.0 Kč])
```

Now it is time to define some auxiliary functions. For example, we can define the `balance` function that will return the account's current balance. Since we store all transactions in a vector, the account's current balance can be simply computed as a sum of the `transaction` field.

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

The previous method definition results in the following output.

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
    balance(b) + c >= T(0) || throw(ArgumentError("insufficient bank account balance."))
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

Note that all transactions are stored in their original currency, as can be seen if we print the `transaction` field.

```jldoctest currency
julia> b.transaction
5-element Array{Currency,1}:
 0.0 Kč
 10.0 $
 10.0 £
 23.6 €
 152.0 Kč
```
