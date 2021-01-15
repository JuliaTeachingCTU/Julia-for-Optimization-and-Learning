# Loops and iterators

As in other languages, Julia supports two basic constructs for repeated evaluation: the `while` and` for` loops. Loops are useful when we want to repeat some computation multiple times with different values. A typical example is performing operations on array elements.

## `for` and `while` loop

The `while` loop evaluates the condition expression, and as long it remains `true`, keeps also evaluating the body of the `while` loop. If the condition expression is `false` when the while loop is first reached, the body is never evaluated

```jldoctest
julia> i = 1
1

julia> while i <= 5
           @show i
           i += 1
       end
i = 1
i = 2
i = 3
i = 4
i = 5
```

The `@show` macro used in the example above takes an expression and prints the expression and its result. It can also be used to print multiple variables at once

```jldoctest
julia> a, b, c = 1, "hello", :world;

julia> @show (a, b, c);
(a, b, c) = (1, "hello", :world)
```

The `for` loops can be created similarly as in Matlab. In the following example, we iterate over the range of integers from 1 to 10, and in each iteration, we use the `@show` macro to print the current value of the variable `i`

```jldoctest
julia> for i in 1:5
           @show i
       end
i = 1
i = 2
i = 3
i = 4
i = 5
```

```@raw html
<div class = "info-body">
<header class = "info-header">An alternative notation for <code>for</code> loops</header><p>
```

There are two alternative notations for the `for` loop. It is possible to use  the `=` or `∈` symbol instead of the `in` keyword

```jldoctest
julia> for i = 1:5
           @show i
       end
i = 1
i = 2
i = 3
i = 4
i = 5
```

However, it is better to use the `in` keyword to improve the code's readability or be consistent and use the same keyword in all `for` loops.

```@raw html
</p></div>
```

In Julia (similarly to Python), it is possible to loop not only over ranges but over any iterable object. For example, it is possible to loop over arrays or tuples. This possibility is advantageous because it allows us to get elements of iterable objects directly without having to use indexes

```jldoctest
julia> persons = ["Alice", "Bob", "Carla", "Daniel"];

julia> for name in persons
           println("Hi, my name is $name.")
       end
Hi, my name is Alice.
Hi, my name is Bob.
Hi, my name is Carla.
Hi, my name is Daniel.
```

It is also possible to iterate over other data structures. For example, we can iterate over dictionaries. In such a case, in each iteration, we get a tuple of the key and corresponding value

```jldoctest
julia> persons = Dict("Alice" => 10, "Bob" => 23, "Carla" => 14, "Daniel" => 34);

julia> for (name, age) in persons
           println("Hi, my name is $name and I am $age old.")
       end
Hi, my name is Carla and I am 14 old.
Hi, my name is Alice and I am 10 old.
Hi, my name is Daniel and I am 34 old.
Hi, my name is Bob and I am 23 old.
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use `for` or `while` loop to print integers from `1` to `100`.  Use conditions to print only the integers divisible by `3` and `7` simultaneously.

**Hint:** use the `mod` function.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The first thing that we have to do is to check if the given integer is divisible by `3` and `7` simultaneously. It can be done using the `mod` function in combination with the `if-else` statement as follows

```jldoctest
julia> i = 21
21

julia> if mod(i, 3) == 0 && mod(i, 7) == 0
           println("$(i) is divisible by 3 and 7")
       end
21 is divisible by 3 and 7
```

or using the short-circuit evaluation

```jldoctest
julia> i = 21
21

julia> mod(i, 3) == mod(i, 7) == 0 && println("$(i) is divisible by 3 and 7")
21 is divisible by 3 and 7
```

When we know how to check the given conditions, it is easy to write a `for` loop to iterate over integers from `1` to `100` as follows

```jldoctest
julia> for i in 1:100
           mod(i, 3) == mod(i, 7) == 0 && @show i
       end
i = 21
i = 42
i = 63
i = 84
```

A `while` loop can be created in a similar way

```jldoctest
julia> i = 0;

julia> while i < 100
           i += 1
           mod(i, 3) == mod(i, 7) == 0 && @show i
       end
i = 21
i = 42
i = 63
i = 84
```

```@raw html
</p></details>
```

### `break` and `continue`

It is sometimes useful to stop the `for` loop based on some condition. It can be done using the `break` keyword. In the following example, the loop iterates over the range from 1 to 10 and breaks when `i == 4`, i.e., only the first four numbers are printed

```jldoctest
julia> for i in 1:10
           i == 4 && break
           @show i
       end
i = 1
i = 2
i = 3
```

Another useful feature is to skip some elements. It can be done using the `continue` keyword. For example, the following code prints all even numbers from 1 to 10

```jldoctest
julia> for i in 1:10
           mod(i, 2) == 0 || continue
           @show i
       end
i = 2
i = 4
i = 6
i = 8
i = 10
```

Note that the code after the `continue` keyword expression is not evaluated.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Rewrite the code from the exercise in the section above. Use the combination of the `while` loop and keywords `continue` to print integers from `1` to `100` divisible by by `3` and `7` simultaneously. In the declaration of the `while` loop use the `true` value instead of a condition. Use the `break` keyword and proper condition to terminate the loop.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

If we use the `true` value in the declaration of the` while` loop, we will create an infinite loop, and it is necessary to end it in the loop with the `break` keyword. Because the variable `i` represents an integer and we want to iterate over integers from 1 to 100, the correct termination condition is` i> 100`

```jldoctest
julia> i = 0;

julia> while true
           i += 1
           i > 100 && break
           mod(i, 3) == mod(i, 7) == 0 || continue
           @show i
       end
i = 21
i = 42
i = 63
i = 84
```

Note that we use short-circuit evaluation to break the loop. To check the given integer's divisibility, we use the same condition as in the exercise above. However, we use `||` instead of `&&` because we want to use the `continue` keyword.

```@raw html
</p></details>
```

### Nested loops

In Julia, Nested loops can be created in a standard way as in other languages

```jldoctest
julia> for i in 1:3
           for j in i:3
               @show (i, j)
           end
       end
(i, j) = (1, 1)
(i, j) = (1, 2)
(i, j) = (1, 3)
(i, j) = (2, 2)
(i, j) = (2, 3)
(i, j) = (3, 3)
```

Note that the inner loop range depends on the variable `i` from the outer loop. This style of writing nested loops is typical in other languages and is very useful. However, in Julia, it is possible to use an even shorter syntax

```jldoctest
julia> for i in 1:3, j in i:3
           @show (i, j)
       end
(i, j) = (1, 1)
(i, j) = (1, 2)
(i, j) = (1, 3)
(i, j) = (2, 2)
(i, j) = (2, 3)
(i, j) = (3, 3)
```

In this case, the output is the same as in the previous example, but this syntax is not equivalent to the previous one. The main difference is when using the `break` keyword. If we use the first syntax, the `break` keyword inside an inner loop exits only the inner loop.

```jldoctest
julia> for i in 1:3
           for j in i:10
               j > 3 && break
               @show (i, j)
           end
       end
(i, j) = (1, 1)
(i, j) = (1, 2)
(i, j) = (1, 3)
(i, j) = (2, 2)
(i, j) = (2, 3)
(i, j) = (3, 3)
```

However, if we use the shorter syntax, the `break` keyword inside an inner loop exits the entire nested loops

```jldoctest
julia> for i in 1:3, j in i:10
           j > 3 && break
           @show (i, j)
       end
(i, j) = (1, 1)
(i, j) = (1, 2)
(i, j) = (1, 3)
```

There are other limitations of the shorter syntax. For example, it is not possible to perform any operation outside the inner loop. Nevertheless, it is still a very useful syntax in many cases.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use nested loops to create a matrix with elements given by the following formula

```math
A_{i, j} = \frac{1}{2}\exp\left\{\frac{1}{2} (x_{i}^2 - y_{j}^2) \right\} \quad i \in \{1, 2, 3\}, \; j \in  \{1, 2, 3, 4\}
```

where ``x \in \{0.4, 2.3, 4.6\}``, ``y \in \{1.4, -3.1, 2.4, 5.2\}``.

**Bonus:** try to create the same matrix in a more effective way.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Firstly, we have to define vectors `x` and `y`

```jldoctest nestedloops_ex; output = false
x = [0.4, 2.3, 4.6]
y = [1.4, -3.1, 2.4, 5.2]

# output
4-element Array{Float64,1}:
  1.4
 -3.1
  2.4
  5.2
```

If we want to use nested loops, we have to create an empty array of the proper size and element type

```jldoctest nestedloops_ex; output = false
A = zeros(Float64, length(x), length(y))

# output
3×4 Array{Float64,2}:
 0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0
```

In this case, the element type specification can be omitted since the elements will be of type `Float64`, which is a default type for the `zeros` function. Now we have to use proper indexes since we want to fill the `A` array. In this case, we get the indexes `1:3` for the vector `x` and `1:4` for the vector `y`. Altogether, we get the following nested `for` loops

```jldoctest nestedloops_ex
julia> for i in 1:length(x), j in 1:length(y)
           A[i, j] = exp((x[i]^2 - y[j]^2)/2)/2
       end

julia> A
3×4 Array{Float64,2}:
    0.203285    0.00443536     0.030405  7.27867e-7
    2.64284     0.0576626      0.395285  9.46275e-6
 7382.39      161.072       1104.17      0.0264329
```

However, there are more efficient ways how to create this array in Julia. The one way is to use broadcasting. It can be done as follows

```jldoctest nestedloops_ex
julia> y_row = y'
1×4 LinearAlgebra.Adjoint{Float64,Array{Float64,1}}:
 1.4  -3.1  2.4  5.2

julia> A = @. exp((x^2 - y_row^2)/2)/2
3×4 Array{Float64,2}:
    0.203285    0.00443536     0.030405  7.27867e-7
    2.64284     0.0576626      0.395285  9.46275e-6
 7382.39      161.072       1104.17      0.0264329
```

Note that we use `y'`, which indicates the transposition of the vector `y`, i.e.,  the resulting array represents a row vector. Also, note that we use the `@ .` macro to perform all operations elementwise.  The third way to create the same matrix is to use a list comprehension, and we will discuss it in the next section.

```@raw html
</p></details>
```

## List comprehension

As we mentioned in the exercise's solution above, one way to create an array with prescribed elements is to use list comprehension. Comprehensions provide a general and powerful way to construct arrays, and the syntax is similar to set construction notation in mathematics

```julia
A = [f(x, y, ...) for x in X, y in Y, ...]
```

The previous example reads: the function `f` will be evaluated for each combination of elements of iterable objects  `X`, `Y`, etc. The result will be an `n`-dimensional array of size `(length(X), length(Y), ...)`. Returning to the previous exercise, we can create the required array as follows

```jldoctest comprehension
julia> X = [0.4, 2.3, 4.6];

julia> Y = [1.4, -3.1, 2.4, 5.2];

julia> A = [exp((x^2 - y^2)/2)/2 for x in X, y in Y]
3×4 Array{Float64,2}:
    0.203285    0.00443536     0.030405  7.27867e-7
    2.64284     0.0576626      0.395285  9.46275e-6
 7382.39      161.072       1104.17      0.0264329
```

Note that the resulting array type depends on the types of the computed elements. In order to control the type explicitly, a type can be prepended to the comprehension

```jldoctest comprehension
julia> A = Float32[exp((x^2 - y^2)/2)/2 for x in X, y in Y]
3×4 Array{Float32,2}:
    0.203285    0.00443536     0.030405  7.27867f-7
    2.64284     0.0576626      0.395285  9.46275f-6
 7382.39      161.072       1104.17      0.0264329
```

A handy feature is that it is possible to filter values when creating list comprehensions using the `if` keyword. However, in such a case, the result will always be a vector. In the example below, we create a vector of tuples `(x, y, x + y)`, where `x + y < 5`

```jldoctest
julia> [(x, y, x + y)  for x in 1:10, y in 1:10 if x + y < 5]
6-element Array{Tuple{Int64,Int64,Int64},1}:
 (1, 1, 2)
 (2, 1, 3)
 (3, 1, 4)
 (1, 2, 3)
 (2, 2, 4)
 (1, 3, 4)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use the list comprehension to create a vector of all integers from `1` to `100` divisible by `3` and `7` simultaneously. What is the sum of all these integers?

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

We can use list comprehension with the same condition that we used in the exercise in the first section

```jldoctest compheresions_ex
julia> v = [i for i in 1:100 if mod(i, 3) == mod(i, 7) == 0]
4-element Array{Int64,1}:
 21
 42
 63
 84
```

Then we can use the `sum` function to get their sum

```jldoctest compheresions_ex
julia> sum(v)
210
```

```@raw html
</p></details>
```

## Generator expressions

List comprehensions can also be written without enclosing square brackets, producing an object known as a generator. This object can be iterated to produce values on demand instead of allocating an array and storing them in advance. For example, the following expression sums a series without allocating memory.

```jldoctest
julia> sum(1/n^2 for n in 1:1000)
1.6439345666815615
```

It is possible to write nested list comprehensions and generators. The syntax is similar to writing nested loops

```jldoctest
julia> [(i,j) for i in 1:3 for j in 1:2]
6-element Array{Tuple{Int64,Int64},1}:
 (1, 1)
 (1, 2)
 (2, 1)
 (2, 2)
 (3, 1)
 (3, 2)

julia> gen = ((i,j) for i in 1:3 for j in 1:2);

julia> collect(gen)
6-element Array{Tuple{Int64,Int64},1}:
 (1, 1)
 (1, 2)
 (2, 1)
 (2, 2)
 (3, 1)
 (3, 2)
```

Iterables may still refer to outer loop variables. However, in such a case, it is necessary to use the `for` keyword before each iterable statement, and the result will be a vector

```jldoctest
julia> gen = ((i,j) for i in 1:3 for j in 1:i);

julia> collect(gen)
6-element Array{Tuple{Int64,Int64},1}:
 (1, 1)
 (2, 1)
 (2, 2)
 (3, 1)
 (3, 2)
 (3, 3)
```

Generated values can also be filtered using the `if` keyword.  Similarly to list comprehensions, the result in such a case will be a vector

```jldoctest
julia> gen = ((i,j) for i in 1:3 for j in 1:i if i+j == 4);

julia> collect(gen)
2-element Array{Tuple{Int64,Int64},1}:
 (2, 2)
 (3, 1)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use a generator to sum the square of all integers from `1` to `100`, which are divisible by `3` and `7` simultaneously.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

There are two ways how to solve the exercise. We can create a generator first and then use the `sum` function to get the result

```jldoctest
julia> gen = (i^2 for i in 1:100 if mod(i, 3) == mod(i, 7) == 0);

julia> sum(gen)
13230
```

or we can use the shorter syntax that allows us to write a generator inside the `sum` function

```jldoctest compheresions_ex
julia> sum(i^2 for i in 1:100 if mod(i, 3) == mod(i, 7) == 0)
13230
```

```@raw html
</p></details>
```

## Iterators

Many structures are iterable in Julia. However, in many cases, it is not sufficient to iterate only over elements of a structure. Imagine the situation that we have the following array and we want to iterate over all its elements

```jldoctest iterators
julia> A = [2.3 4.5; 6.7 7.1]
2×2 Array{Float64,2}:
 2.3  4.5
 6.7  7.1
```

Additionally, in each iteration, we want to print the index and the corresponding value. It can be done in the following way

```jldoctest iterators
julia> for i in 1:length(A)
           println("i = $(i) and A[i] = $(A[i])")
       end
i = 1 and A[i] = 2.3
i = 2 and A[i] = 6.7
i = 3 and A[i] = 4.5
i = 4 and A[i] = 7.1
```

However, there is an even simpler way. We can do the same using the `enumerate` function that returns an iterator (an iterable object that can be iterated in for loops). It will produce couples of the form `(i, x[i])`

```jldoctest iterators
julia> for (i, val) in enumerate(A)
           println("i = $(i) and A[i] = $(val)")
       end
i = 1 and A[i] = 2.3
i = 2 and A[i] = 6.7
i = 3 and A[i] = 4.5
i = 4 and A[i] = 7.1
```

Other very useful functions return iterators. For example, the `eachcol` function returns an iterator that will iterate over columns of the given matrix

```jldoctest iterators
julia> for col in eachcol(A)
           println("col = $(col)")
       end
col = [2.3, 6.7]
col = [4.5, 7.1]
```

Similarly, the `eachrow` function returns an iterator that will iterate over the given matrix's rows. A convenient function is the `zip` function, which can zip together multiple iterable objects and iterate over them simultaneously

```jldoctest
julia> for (i, j, k) in zip([1, 4, 2, 5], 2:12, (:a, :b, :c))
           @show (i, j, k)
       end
(i, j, k) = (1, 2, :a)
(i, j, k) = (4, 3, :b)
(i, j, k) = (2, 4, :c)
```

Note that in this case, the iterable objects can be of different lengths. However, the iterator returned by the `zip` function will have the same length as the shortest of the input iterable objects

It is also possible to combine these handy functions to get an even more useful iterator.

```jldoctest
julia> for (i, vals) in enumerate(zip([1, 4, 2, 5], 2:12, (:a, :b, :c)))
           @show (i, vals)
       end
(i, vals) = (1, (1, 2, :a))
(i, vals) = (2, (4, 3, :b))
(i, vals) = (3, (2, 4, :c))
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Create a matrix with elements given by the following formula

```math
A_{i, j} = \frac{1}{2}\exp\left\{\frac{1}{2} (x_{i}^2 - y_{j}^2) \right\} \quad i \in \{1, 2, 3\}, \; j \in  \{1, 2, 3, 4\}
```

where ``x \in \{0.4, 2.3, 4.6\}``, ``y \in \{1.4, -3.1, 2.4, 5.2\}``. Compute the sum of all elements in each row and print the following message:
> *Sum of all elements in a row `i` is `i_sum`*,
where `i` represents row's number and `i_sum` the sum of all elements in this row. Do the same for each column and print the following message:
> *Sum of all elements in a column `i` is `i_sum`*,

**Hint:** use iterators `eachcol` and `eachrow`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Firstly we have to generate the matrix `A`. It can be done using list comprehension as follows

```jldoctest iterators_ex; output = false
X = [0.4, 2.3, 4.6]
Y = [1.4, -3.1, 2.4, 5.2]
A = [exp((x^2 - y^2)/2)/2 for x in X, y in Y]

# output
3×4 Array{Float64,2}:
    0.203285    0.00443536     0.030405  7.27867e-7
    2.64284     0.0576626      0.395285  9.46275e-6
 7382.39      161.072       1104.17      0.0264329
```

To compute the sum of each row and print the appropriate message, we can use a combination of the `enumerate` and `eachrow` functions

```jldoctest iterators_ex
julia> for (i, row) in enumerate(eachrow(A))
           println("Sum of all elements in a row $(i) is $(sum(row))")
       end
Sum of all elements in a row 1 is 0.2381259460051036
Sum of all elements in a row 2 is 3.0957940729669864
Sum of all elements in a row 3 is 8647.66342895583
```

Similarly, to compute the sum of each column and print the appropriate message, we can use a combination of the `enumerate` and `eachcol` functions

```jldoctest iterators_ex
julia> for (i, row) in enumerate(eachcol(A))
           println("Sum of all elements in a column $(i) is $(sum(row))")
       end
Sum of all elements in a column 1 is 7385.236904243371
Sum of all elements in a column 2 is 161.13431527671185
Sum of all elements in a column 3 is 1104.5996863997295
Sum of all elements in a column 4 is 0.026443054989612996
```

```@raw html
</p></details>
```
