# Loops and iterators

As in other languages, Julia supports two basic constructs for repeated evaluation: the `while` and` for` loops. Loops are useful when we want to repeat some computation multiple times with different values. A typical example is performing operations on array elements.

## `for` and `while` loop

The `while` loop evaluates the condition expression, and as long it remains `true`, keeps also evaluating the body of the `while` loop. If the condition expression is `false` when the while loop is first reached, the body is never evaluated.

```@repl
i = 1
while i <= 5
    @show i
    global i += 1
end
```

Note, that we use `global` statement inside the `while` loop. The reason is, that in the REPL Julia uses so-called soft scope, i.e. it is possible to use variables from outside of the loop, but when we want to change them, we have to use `global` keyword. We will talk about local and global scope of variables later.

Also note, that the `@show` macro takes an expression as an input and prints the expression and its result. It can be used to print multiple variables at once in a nice way

```@repl
a, b, c = 1, "hello", :world;
@show (a, b, c);
```
In the previous example, we can see, that we use a semicolon. In the REPL, if we evaluate any expression, its result is printed. If we use the semicolon, the print is omitted. It is similar behavior as in Matlab, but in Julia, the print is automatic only in the REPL.


`for` loops can be created in a similar way as in Matlab. In the following example, we iterate over the range of integers from 1 to 10. In the following example, we iterate over the range of integers from 1 to 10, and in each iteration, we use the `@show` macro to print the current value of the variable `i`

```@repl
for i in 1:5
    @show i
end
```

```@raw html
<div class = "info-body">
<header class = "info-header">An alternative notation for <code>for</code> loops</header><p>
```
There are two alternative notation for the `for` loop. It is possible to use `=` or `∈` instead of `in` keyword
```@repl
for i = 1:5
    @show i
end
```
However, for better readability, it is better to always use `in`. Or at least be consistent and use the same keyword in all `for` loops.

```@raw html
</p></div>
```

In Julia, it is possible to loop not only over ranges. For example, it is possible to loop over arrays or tuples. This is very useful because it allows us to get elements of iterable objects directly without having to use indexes

```@repl
persons = ["Alice", "Bob", "Carla", "Daniel"]
for name in persons
    println("Hi, my name is $name.")
end
```

It is also possible to iterate over other data structures. For example, we can iterate over dictionaries

```@repl
persons = Dict("Alice" => 10, "Bob" => 23, "Carla" => 14, "Daniel" => 34)
for (name, age) in persons
    println("Hi, my name is $name and I am $age old.")
end
```

Note, that in this case, we iterate over pairs of the key and corresponding value.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use both `for` and `while` loop to print integers from `1` to `100`, which are divisible by `3` and `7`.

**Hint:** use the modulo function.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The exercise can be solved as follows for the `for` loop
```@repl
for i in 1:100
    mod(i, 3) == mod(i, 7) == 0 && println(i)
end
```

and for `while` loop as follows

```@repl
i = 1;
while i <= 100
    mod(i, 3) == mod(i, 7) == 0 && println(i)
    global i += 1
end
```
```@raw html
</p></details>
```

### `break` and `continue`

It is sometimes useful to stop the `for` loop based on some condition. It can be done using the `break` keyword. In the following example, the loop iterates over the range from 1 to 10 and breaks when `i == 4`, i.e. only the first four numbers are printed

```@repl
for i in 1:10
    i == 4 && break
    @show i
end
```

Another useful feature is to skip some elements. It can be done using `continue` keyword. For example, the following code prints all even numbers from 1 to 10

```@repl
for i in 1:10
    mod(i, 2) == 0 || continue
    @show i
end
```

Note, that the code after `continue` keyword expression is not evaluated

### Nested loops

It is possible to create nested `for` loops in the following way

```@repl
for i in 1:3
    for j in i:3
        @show (i, j)
    end
end
```
Note, that the range in the inner loop depends on the variable `i` from the outer loop. This style of writing nested loops is common in other languages and is very useful. However, in Julia, it is possible to use an even shorter syntax

```@repl
for i in 1:3, j in i:3
    @show (i, j)
end
```
In this case, the output is the same as in the previous example, but this syntax is not equivalent to the previous one. The main difference is when using break statement. If we use the first syntax, a `break` statement inside an inner loop exits only the inner loop.
```@repl
for i in 1:3
    for j in i:10
        j > 3 && break
        @show (i, j)
    end
end
```
On the other hand, if we use the shorter syntax, a `break` statement inside an inner loop exits the entire nest of loops
```@repl
for i in 1:3, j in i:10
    j > 3 && break
    @show (i, j)
end
```
There are other limitations to sorter syntax. For example, it is not possible to perform any operation outside the inner loop. Nevertheless, it is still a very useful syntax in many cases.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Use nested loops to create a matrix whose elements are given by the following formula

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

```@example nestedloops_ex
x = [0.4, 2.3, 4.6]
y = [1.4, -3.1, 2.4, 5.2]
nothing # hide
```
If we want to use nested loops, we have to create an empty array of the proper size and element type

```@example nestedloops_ex
A = zeros(Float64, length(x), length(y))
nothing # hide
```

In this case, the specification of the element type can be omitted, since `Float64` is the default type. Now we have to use proper indexes since we want to fill in the `A` array. In this case, we get indexes `1:3` for the vector `x` and `1:4` for the vector `y`. Altogether, we get the following nested `for` loops

```@repl nestedloops_ex
for i in 1:length(x), j in 1:length(y)
    A[i, j] = exp((x[i]^2 - y[j]^2)/2)/2
end
A
```

However, there are more efficient ways how to create this array in Julia. The one way is to use broadcasting. It can be done in a simple way as follows

```@repl nestedloops_ex
y_row = y'
A = @. exp((x^2 - y_row^2)/2)/2
```

Note that we use `y'`, which indicates the transposition of the vector `y`, i.e. `y'` is a row vector. Note also that we use the `@ .` macro to make all operations in the expression elementwise. The third way how to create the same matrix is to use list comprehension and we will discuss it in the next section.

```@raw html
</p></details>
```

## List comprehension

As we mentioned in the solution of the exercise above, one way how to create an array with prescribed elements is to use list comprehension. Comprehensions provide a general and powerful way to construct arrays and the syntax is similar to set construction notation in mathematics:

```julia
A = [f(x, y, ...) for x in X, y in Y, ...]
```
The previous example means, that the function `f` will be evaluated for each combination of elements of iterable objects  `X`, `Y`, etc. The result will be an `n`-dimensional array of size (length(X), length(Y), ...). Returning to the previous exercise, we can simply create the required array as follows

```@repl comprehension
X = [0.4, 2.3, 4.6];
Y = [1.4, -3.1, 2.4, 5.2];
A = [exp((x^2 - y^2)/2)/2 for x in X, y in Y]
```

Note, that the resulting array type depends on the types of the computed elements. In order to control the type explicitly, a type can be prepended to the comprehension

```@repl comprehension
A = Float32[exp((x^2 - y^2)/2)/2 for x in X, y in Y]
```

A very useful feature is, that it is possible to filter values when creating list comprehensions using `if` keyword. However, in this case, the result is always a 1-d array. In the example below, we create a vector of tuples `(x, y, x + y)`, where `x + y < 5`

```@repl
[(x, y, x + y)  for x in 1:10, y in 1:10 if x + y < 5]
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use the list comprehension to create a vector of all integers from `1` to `100`, which are divisible by `3` and `7`. What is the sum of all these integers?

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

We can simply use list comprehension with the condition that we used in the exercise in the first section

```@repl compheresions_ex
v = [i for i in 1:100 if mod(i, 3) == mod(i, 7) == 0]
```
Then we can use the `sum` function to get their sum

```@repl compheresions_ex
sum(v)
```

```@raw html
</p></details>
```

## Generator expressions

Comprehensions can also be written without the enclosing square brackets, producing an object known as a generator. This object can be iterated to produce values on demand, instead of allocating an array and storing them in advance (see Iteration). For example, the following expression sums a series without allocating memory.

```@repl
sum(1/n^2 for n in 1:1000)
```

Ranges in generators and comprehensions can depend on previous ranges by writing multiple for keywords. In such cases, the result is always 1-d array.

```@repl
gen = ((i,j) for i in 1:3 for j in 1:i);
collect(gen)
```
Note, that we have to use the function `collect` to evaluate the generator. Generated values can also be filtered using the if keyword. Also in this case, the result is always 1-d array.

```@repl
gen = ((i,j) for i in 1:3 for j in 1:i if i+j == 4);
collect(gen)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Use a generator to sum the square of all integers from `1` to `100`, which are divisible by `3` and `7`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

There are two ways how to solve the exercise. We can create a generator first and then use the `sum` function to get the result

```@repl
gen = (i^2 for i in 1:100 if mod(i, 3) == mod(i, 7) == 0);
sum(gen)
```

or we can use the shorter syntax, that allows us to write generator inside the `sum` function

```@repl compheresions_ex
sum(i^2 for i in 1:100 if mod(i, 3) == mod(i, 7) == 0)
```

```@raw html
</p></details>
```

## Iterators

Many structures are iterable in Julia. However, in many cases, it is not sufficient to iterate only over elements of a structure. Imagine the situation, that we have an array

```@repl iterators
A = [2.3 4.5; 6.7 7.1]
```

and we want to iterate over all its elements, and in each iteration, we want to print the number of the iteration and the value of the current element of the array. It can be done in the following way

```@repl iterators
for i in 1:length(A)
    println("i = $(i) and A[i] = $(A[i])")
end
```

But there is an even simpler way. We can do the same using the `enumerate` function. The `enumerate` returns an iterator (which is something like an array which can be iterated in for loops). It will produce couples of the form `(i, x[i])`

```@repl iterators
for (i, val) in enumerate(A)
    println("i = $(i) and A[i] = $(val)")
end
```

There are other very useful functions that return iterators. For example, `eachcol` function returns an iterator, that will iterate over columns of the given matrix

```@repl iterators
for col in eachcol(A)
    println("col = $(col)")
end
```

Similarly, `eachrow` function returns an iterator, that will iterate over rows of the given matrix. A very handy function is the `zip` function, which can zip together multiple iterable objects and iterate over them

```@repl
for (i, j, k) in zip([1, 4, 2, 5], 2:12, (:a, :b, :c))
    @show (i, j, k)
end
```

Note that the iterable objects can be of different length, however, the iterator returned by the `zip` function will have the length of the shortest of the given iterable objects.

It is also possible to combine these handy function to get an even more useful iterator

```@repl
for (i, vals) in enumerate(zip([1, 4, 2, 5], 2:12, (:a, :b, :c)))
    @show (i, vals)
end
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Create a matrix whose elements are given by the following formula

```math
A_{i, j} = \frac{1}{2}\exp\left\{\frac{1}{2} (x_{i}^2 - y_{j}^2) \right\} \quad i \in \{1, 2, 3\}, \; j \in  \{1, 2, 3, 4\}
```

where ``x \in \{0.4, 2.3, 4.6\}``, ``y \in \{1.4, -3.1, 2.4, 5.2\}``. Compute the sum of all elements in each row and print the following message:
> *Sum of all elements in row `i` is `i_sum`*,
where `i` represents the number of the row and `i_sum` the sum of all elements in this row. Do the same for each column and print the following message:
> *Sum of all elements in column `i` is `i_sum`*,

**Hint:** use iterators `eachcol` and `eachrow`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Firstly we have to generate the matrix `A`. It can be done using list comprehension as follows

```@example iterators_ex
X = [0.4, 2.3, 4.6]
Y = [1.4, -3.1, 2.4, 5.2]
A = [exp((x^2 - y^2)/2)/2 for x in X, y in Y]
nothing # hide
```
To compute the sum of each row and print the appropriate message, we can use combinations of `enumerate` and `eachrow` function

```@repl iterators_ex
for (i, row) in enumerate(eachrow(A))
    println("Sum of all elements in row $(i) is $(sum(row))")
end
```
In a similar way, to compute the sum of each column and print the appropriate message, we can use combinations of `enumerate` and `eachcol` function

```@repl iterators_ex
for (i, row) in enumerate(eachcol(A))
    println("Sum of all elements in column $(i) is $(sum(row))")
end
```
```@raw html
</p></details>
```
