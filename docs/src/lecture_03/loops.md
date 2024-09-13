# Loops

While `if` conditions are evaluated only once, loops are assessed multiple times.


## `for` and `while` loops

As in other languages, Julia supports two basic constructs for repeated evaluation: `while` and` for` loops. Loops are useful to repeat the same computation multiple times with different values. A typical example is performing operations on array elements.

The `while` loop evaluates the condition, and as long it remains `true`, it evaluates the body of the `while` loop. If the condition is `false`, the while loop is terminated. If the condition is `false` before the first iteration, the whole `while` loop is skipped.

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

The `@show` macro in this example prints the results of an expression. It can also be used to print multiple variables at once.

```jldoctest
julia> a, b, c = 1, "hello", :world;

julia> @show (a, b, c);
(a, b, c) = (1, "hello", :world)
```

The `for` loops are created similarly to Matlab. The following example iterates over all integers from 1 to 5, and in each iteration, we use the `@show` macro to print the current value of the variable `i`.

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

!!! info "An alternative notation for <code>for</code> loops:"
    There are two alternative notations for the `for` loop. It is possible to use the `=` or `∈` symbol instead of the `in` keyword.

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

    However, it is better to use the `in` keyword to improve code readability. Regardless of which notation is used, it is essential to be consistent and use the same notation in all `for` loops.

In Julia (similarly to Python), it is possible to loop not only over ranges but over any iterable object such as arrays or tuples. This is advantageous because it allows getting elements of iterable objects directly without using indices.

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

It is also possible to iterate over other data structures such as dictionaries. In such a case, we get a tuple of the key and the corresponding value in each iteration.

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

!!! warning "Exercise:"
    Use `for` or `while` loop to print all integers between `1` and `100` which can be divided by both `3` and `7`.

    **Hint:** use the `mod` function.

!!! details "Solution:"
    First, we need to check if a given integer is divisible by both `3` and `7`. This can be performed using the `mod` function in combination with the `if-else` statement as follows:

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

    When we know how to check the conditions, it is easy to write a `for` loop to iterate over integers from `1` to `100`.

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

    julia> while i <= 100
            i += 1
            mod(i, 3) == mod(i, 7) == 0 && @show i
        end
    i = 21
    i = 42
    i = 63
    i = 84
    ```

    The `for` loop should be used here because the range is known before-hand and unlike the `while` loop, it does not require to initialize `i`.

### `break` and `continue`

Sometimes it is useful to stop the loop when some condition is satisfied. This is done by the `break` keyword. In the following example, the loop iterates over the range from 1 to 10 and breaks when `i == 4`, i.e., only the first three numbers are printed.

```jldoctest
julia> for i in 1:10
           i == 4 && break
           @show i
       end
i = 1
i = 2
i = 3
```

Another useful feature is to skip elements using the `continue` keyword. The following code prints all even numbers from 1 to 10.

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

The code after the `continue` keyword is not evaluated.

!!! warning "Exercise:"
    Rewrite the code from the exercise above. Use a combination of the `while` loop and the keyword `continue` to print all integers between `1` and `100` divisible by both `3` and `7`. In the declaration of the `while` loop use the `true` value instead of a condition. Use the `break` keyword and a proper condition to terminate the loop.

!!! details "Solution:"
    The `true` value creates an infinite loop, i.e., it is necessary to end the loop with the `break` keyword. Because the variable `i` represents an integer and we want to iterate over integers between 1 and 100, the correct termination condition is `i > 100`.

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

    We used the short-circuit evaluation to break the loop. To check that the integer is divisible, we use the same condition as before. However, we must use `||` instead of `&&` because we want to use the `continue` keyword.

### Nested loops

In Julia, nested loops can be created in a similar way as in other languages.

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

The range of the inner loop depends on the variable `i` from the outer loop. This style of writing nested loops is typical in other languages. Julia allows for an additional shorter syntax:

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

Even though the output is the same, this syntax is not equivalent to the previous one. The main difference is when using the `break` keyword. If we use the traditional syntax and the `break` keyword inside the inner loop, it breaks only the inner loop. On the other hand, if we use the shorter syntax, the `break` keyword breaks both loops.

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

julia> for i in 1:3, j in i:10
           j > 3 && break
           @show (i, j)
       end
(i, j) = (1, 1)
(i, j) = (1, 2)
(i, j) = (1, 3)
```

There are other limitations of the shorter syntax, such as the impossibility to perform any operation outside the inner loop. Nevertheless, it is a useful syntax in many cases.

!!! warning "Exercise:"
    Use nested loops to create a matrix with elements given by the formula

    ```math
    A_{i, j} = \frac{1}{2}\exp\left\{\frac{1}{2} (x_{i}^2 - y_{j}^2) \right\} \quad i \in \{1, 2, 3\}, \quad j \in  \{1, 2, 3, 4\},
    ```

    where ``x \in \{0.4, 2.3, 4.6\}`` and ``y \in \{1.4, -3.1, 2.4, 5.2\}``.

    **Bonus:** try to create the same matrix in a more effective way.

!!! details "Solution:"
    First, we have to define vectors `x` and `y`, and an empty array of the proper size and element type to use in nested loops.

    ```jldoctest nestedloops_ex; output = false
    x = [0.4, 2.3, 4.6]
    y = [1.4, -3.1, 2.4, 5.2]
    A = zeros(Float64, length(x), length(y))

    # output
    3×4 Matrix{Float64}:
    0.0  0.0  0.0  0.0
    0.0  0.0  0.0  0.0
    0.0  0.0  0.0  0.0
    ```

    The element type specification can be omitted since the default value type is `Float64`. Now we have to use proper indices to fill `A`. In this case, we use the indices `1:length(x)` for `x` and `1:length(y)` for `y`.

    ```jldoctest nestedloops_ex
    julia> for i in 1:length(x), j in 1:length(y)
            A[i, j] = exp((x[i]^2 - y[j]^2)/2)/2
        end

    julia> A
    3×4 Matrix{Float64}:
        0.203285    0.00443536     0.030405  7.27867e-7
        2.64284     0.0576626      0.395285  9.46275e-6
    7382.39      161.072       1104.17      0.0264329
    ```

    There are more efficient ways to create this array. The one way is to use broadcasting.

    ```jldoctest nestedloops_ex
    julia> y_row = y'
    1×4 adjoint(::Vector{Float64}) with eltype Float64:
    1.4  -3.1  2.4  5.2

    julia> A = @. exp((x^2 - y_row^2)/2)/2
    3×4 Matrix{Float64}:
        0.203285    0.00443536     0.030405  7.27867e-7
        2.64284     0.0576626      0.395285  9.46275e-6
    7382.39      161.072       1104.17      0.0264329
    ```

    We use the `@ .` macro to perform all operations elementwise. Since `x` is a column vector and `y_row` is a row vector, `x - y_row` uses broadcasting to create a matrix.

    The third way to create this matrix is to use list comprehension. Due to its importance, we dedicate a whole section to it.

## List comprehension

As we mentioned in the last exercise, one way to create an array with prescribed elements is to use list comprehension. Comprehensions provide a general and powerful way to construct arrays, and the syntax is similar to the set construction notation from mathematics.

```julia
A = [f(x, y, ...) for x in X, y in Y, ...]
```

The previous example reads: The function `f` will be evaluated for each combination of elements of iterable objects  `X`, `Y`, etc. The result will be an `n`-dimensional array of size `(length(X), length(Y), ...)`. Returning to the previous exercise, we can create the required array as follows:

```jldoctest comprehension
julia> X = [0.4, 2.3, 4.6];

julia> Y = [1.4, -3.1, 2.4, 5.2];

julia> A = [exp((x^2 - y^2)/2)/2 for x in X, y in Y]
3×4 Matrix{Float64}:
    0.203285    0.00443536     0.030405  7.27867e-7
    2.64284     0.0576626      0.395285  9.46275e-6
 7382.39      161.072       1104.17      0.0264329
```

The resulting array type depends on the types of the computed elements. A type can be prepended to the comprehension to control the type explicitly.

```jldoctest comprehension
julia> A = Float32[exp((x^2 - y^2)/2)/2 for x in X, y in Y]
3×4 Matrix{Float32}:
    0.203285    0.00443536     0.030405  7.27867f-7
    2.64284     0.0576626      0.395285  9.46275f-6
 7382.39      161.072       1104.17      0.0264329
```

A handy feature is the possibility to filter values when creating list comprehensions by the `if` keyword. In such a case, the result will always be a vector. In the next example, we create a vector of tuples `(x, y, x + y)`, where `x + y < 5`.

```jldoctest
julia> [(x, y, x + y)  for x in 1:10, y in 1:10 if x + y < 5]
6-element Vector{Tuple{Int64, Int64, Int64}}:
 (1, 1, 2)
 (2, 1, 3)
 (3, 1, 4)
 (1, 2, 3)
 (2, 2, 4)
 (1, 3, 4)
```

!!! warning "Exercise:"
    Use the list comprehension to create a vector of all integers from `1` to `100` divisible by `3` and `7` simultaneously. What is the sum of all these integers?

!!! details "Solution:"
    We can use list comprehension with the same condition that we used in the exercise in the first section.

    ```jldoctest compheresions_ex
    julia> v = [i for i in 1:100 if mod(i, 3) == mod(i, 7) == 0]
    4-element Vector{Int64}:
    21
    42
    63
    84
    ```

    Then we can use the `sum` function to get their sum.

    ```jldoctest compheresions_ex
    julia> sum(v)
    210
    ```

## Generator expressions

List comprehensions can also be written without the enclosing square brackets. This produces an object known as a generator. When iterating over a generator, the values are generated on demand instead of pre-allocating an array. For example, the following expression sums a series without allocating the full array in memory.

```jldoctest
julia> gen = (1/n^2 for n in 1:1000);

julia> sum(gen)
1.6439345666815615

julia> sum(1/n^2 for n in 1:1000)
1.6439345666815615
```

It is possible to write nested list comprehensions and generators. The syntax is similar to writing nested loops.

```jldoctest
julia> [(i,j) for i in 1:3, j in 1:2]
3×2 Matrix{Tuple{Int64, Int64}}:
 (1, 1)  (1, 2)
 (2, 1)  (2, 2)
 (3, 1)  (3, 2)

julia> gen = ((i,j) for i in 1:3, j in 1:2);

julia> collect(gen)
3×2 Matrix{Tuple{Int64, Int64}}:
 (1, 1)  (1, 2)
 (2, 1)  (2, 2)
 (3, 1)  (3, 2)
```

Iterables may refer to outer loop variables. However, in such a case, it is necessary to use the `for` keyword before each iterable statement, and the result will be a vector.

```jldoctest
julia> gen = ((i,j) for i in 1:3 for j in 1:i);

julia> collect(gen)
6-element Vector{Tuple{Int64, Int64}}:
 (1, 1)
 (2, 1)
 (2, 2)
 (3, 1)
 (3, 2)
 (3, 3)
```

Generated values can also be filtered using the `if` keyword.  Similarly to list comprehensions, the result in such a case is a vector.

```jldoctest
julia> gen = ((i,j) for i in 1:3 for j in 1:i if i+j == 4);

julia> collect(gen)
2-element Vector{Tuple{Int64, Int64}}:
 (2, 2)
 (3, 1)
```

!!! warning "Exercise:"
    Use a generator to sum the square of all integers from `1` to `100`, which are divisible by `3` and `7` simultaneously.

!!! details "Solution:"
    There are two ways how to solve this exercise. The first one creates a generator and then uses the `sum` function.

    ```julia
    julia> gen = (i^2 for i in 1:100 if mod(i, 3) == mod(i, 7) == 0);

    julia> typeof(gen)
    Base.Generator{Base.Iterators.Filter{var"#2#4",UnitRange{Int64}},var"#1#3"}

    julia> sum(gen)
    13230
    ```

    It is worth noting that `gen` is a `Generator` object and not an array. The second way uses the shorter syntax that allows us to write a generator inside the `sum` function.

    ```jldoctest compheresions_ex
    julia> sum(i^2 for i in 1:100 if mod(i, 3) == mod(i, 7) == 0)
    13230
    ```

## Iterators

Many structures are iterable in Julia. However, it is not sufficient to iterate only over elements of a structure in many cases. Consider the situation when we have the following array, and we want to iterate over all its elements and print all indices and the corresponding values.

```jldoctest iterators
julia> A = [2.3 4.5; 6.7 7.1]
2×2 Matrix{Float64}:
 2.3  4.5
 6.7  7.1

julia> for i in 1:length(A)
           println("i = $(i) and A[i] = $(A[i])")
       end
i = 1 and A[i] = 2.3
i = 2 and A[i] = 6.7
i = 3 and A[i] = 4.5
i = 4 and A[i] = 7.1
```

There is an even more straightforward way. We can do the same using the `enumerate` function that returns an iterator (an iterable object that can be iterated in `for` loops). It produces couples of the form `(i, x[i])`.

```jldoctest iterators
julia> for (i, val) in enumerate(A)
           println("i = $(i) and A[i] = $(val)")
       end
i = 1 and A[i] = 2.3
i = 2 and A[i] = 6.7
i = 3 and A[i] = 4.5
i = 4 and A[i] = 7.1
```

Other beneficial functions return iterators. For example, the `eachcol` function returns an iterator that iterates over matrix columns.

```jldoctest iterators
julia> for col in eachcol(A)
           println("col = $(col)")
       end
col = [2.3, 6.7]
col = [4.5, 7.1]
```

Similarly, `eachrow` returns an iterator that iterates over matrix rows. Another convenient function is the `zip` function, which zips together multiple iterable objects and iterates over them simultaneously.

```jldoctest
julia> for (i, j, k) in zip([1, 4, 2, 5], 2:12, (:a, :b, :c))
           @show (i, j, k)
       end
(i, j, k) = (1, 2, :a)
(i, j, k) = (4, 3, :b)
(i, j, k) = (2, 4, :c)
```

In this case, the iterable objects were of different lengths. The iterator returned by the `zip` function will have the same length as the shortest of its inputs. It is also possible to combine these handy functions.

```jldoctest
julia> for (i, vals) in enumerate(zip([1, 4, 2, 5], 2:12, (:a, :b, :c)))
           @show (i, vals)
       end
(i, vals) = (1, (1, 2, :a))
(i, vals) = (2, (4, 3, :b))
(i, vals) = (3, (2, 4, :c))
```

!!! warning "Exercise:"
    Create a matrix with elements given by the following formula

    ```math
    A_{i, j} = \frac{1}{2}\exp\left\{\frac{1}{2} (x_{i}^2 - y_{j}^2) \right\} \quad i \in \{1, 2, 3\}, \; j \in  \{1, 2, 3, 4\}
    ```

    where ``x \in \{0.4, 2.3, 4.6\}``, ``y \in \{1.4, -3.1, 2.4, 5.2\}``. Compute the sum of all elements in each row and print the following message:
    > *Sum of all elements in a row `i` is `i_sum`*
    where `i` represents row's number and `i_sum` the sum of all elements in this row. Do the same for each column and print the following message:
    > *Sum of all elements in a column `i` is `i_sum`*

    **Hint:** use iterators `eachcol` and `eachrow`.

!!! details "Solution:"
    First, we have to generate the matrix `A`. It can be done using list comprehension as follows:

    ```jldoctest iterators_ex; output = false
    X = [0.4, 2.3, 4.6]
    Y = [1.4, -3.1, 2.4, 5.2]
    A = [exp((x^2 - y^2)/2)/2 for x in X, y in Y]

    # output
    3×4 Matrix{Float64}:
        0.203285    0.00443536     0.030405  7.27867e-7
        2.64284     0.0576626      0.395285  9.46275e-6
    7382.39      161.072       1104.17      0.0264329
    ```

    To compute the sum of each row and print the appropriate message, we use the combination of `enumerate` and `eachrow` functions.

    ```jldoctest iterators_ex
    julia> for (i, row) in enumerate(eachrow(A))
            println("Sum of all elements in a row $(i) is $(sum(row))")
        end
    Sum of all elements in a row 1 is 0.2381259460051036
    Sum of all elements in a row 2 is 3.0957940729669864
    Sum of all elements in a row 3 is 8647.66342895583
    ```

    Similarly, to compute the sum of each column and print the appropriate message, we use the combination of `enumerate` and `eachcol` functions.

    ```jldoctest iterators_ex
    julia> for (i, row) in enumerate(eachcol(A))
            println("Sum of all elements in a column $(i) is $(sum(row))")
        end
    Sum of all elements in a column 1 is 7385.236904243371
    Sum of all elements in a column 2 is 161.13431527671185
    Sum of all elements in a column 3 is 1104.5996863997295
    Sum of all elements in a column 4 is 0.026443054989612996
    ```
