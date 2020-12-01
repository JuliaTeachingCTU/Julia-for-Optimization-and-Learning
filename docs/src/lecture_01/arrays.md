# Arrays

Arrays are the most common container used for storing data.

## Vectors

A vector is a special case of an array with only one dimension and is represented as a list of ordered data which share a common type (`Int64`, `Float64`, `Any`,...). A vector in Julia can be constructed directly using square brackets and a comma (or semicolon) as value separators

```@repl vectors
v = [1, 2, 3, 4, 5, 6, 7, 8] # or equivalently v = [1; 2; 3; 4; ...]
```

Information about the number of dimension or type of elements of a given vector can be obtained using `typeof` function

```@repl vectors
typeof(v)
```

We can see, that the general description of any array in Julia is as follows: `Array{T,N}` denotes `N`-dimensional dense array with elements of type `T`. From this description, we can immediately see, that vector `v` has one dimension and contains elements of type `In64`. Another way how to get this information is to use `ndims` and `eltype` function

```@repl vectors
ndims(v)
eltype(v)
```

We can also check the size and the length of a vector using `size` and `length` function

```@repl vectors
size(v)
length(v)
```

The `size` function returns a [tuple](@ref Tuples) containing the sizes of the given array along each dimension. The `length` function returns total number of elements in the given array.

Elements of a vector can be accessed via square brackets and the index of the element. Contrary to other programming languages like C or Python and similarly to Matlab, arrays are indexed from `1`. To access the third element of vector `v`, we simply use the following syntax

```@repl vectors
v[3]
```
There are also special keywords to access first and last element of a given vector

```@repl vectors
v[begin] # the first element
v[end] # the last element
```

It is also possible to access multiple elements at once using the same syntax. The only difference is that instead of only one index, we use a vector of multiple indexes. For example, to access the second and third element of vector `v`, we can do

```@repl vectors
v[[2, 3]]
```

Multiple indexes can be also selected using `range` function. The `range` function always accepts the starting point as a first argument and then keyword arguemnt `stop` or `length`. The user can also set the step length using keyword argument `step`. If `length`, `stop`, and `step` are all specified, they must agree. For example, to generate integers from `1` to `10` with step length `2` we can use following code

```@repl
range(1; stop = 10, step = 2)
```

Ranges can also be constructed using the shorter syntax `start:step:stop` (the `step` can be omitted if it is equal to `1`). Then the previous example can be equivalently rewritten as

```@repl vectors
1:2:10
```

This shorter syntax is very useful for accessing array elements

```@repl vectors
v[1:3] # the first three elements
v[1:2:end] # select all elements with odd index
v[:] # all elements
```

It is possible to add new elements to a vector using `append!` function. Notice the `!`, this is a Julia convention to say that the function will modify the first argument given to the function. In this case, the `append!` function appends one or more elements to the end of the given vector

```@repl vectors
v = [1,2,3]
append!(v, 4)
append!(v, [5,6])
append!(v, 7:8)
```

As has already been said, the elements of a vector share the same type. In this case, we have a vector with elements of type `Int64`. If we want to append a value to a vector with a different type it will result in an error

```@repl
v = Int64[]; # hide
append!(v, 3.1415)
```

In this case, we cannot convert a `Float64` to an `Int64` without losing precision, thus the error. Our vector `v` can store only values of type `Int64` or values that can be safely converted to `Int64` (such as `Int32` for example). To avoid these errors, we can initialize the type of elements when creating a vector. It can be done using a type name followed by a square bracket.

```@repl
v = Float64[1, 2, 3]
append!(v, 3.1415)
```

It is possible to change the value of an element of a given vector. This can be done simply by assigning a new value to the desired element

```@repl vectors
v = [1,2,3, 4]
v[2] = 4
v
```

It is also possible to assign one value to multiple elements of a vector at once. However, in this case, we have to use so-called dot syntax which is in Julia used for [element-wise operations](@ref Broadcasting)

```@repl vectors
v[3:4] .= 11
v
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Create a vector of integers that contains all odd numbers smaller than `10`. Then changed the first element to `4` and the last two elements to `1`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The vector can be created manually as follows

```@repl matrices
v = [1,3,5,7,9]
```

or we can use `range` function to create a range with given properties and then use `collect` function to create a vector or use `Vector` type to convert range to a vector

```@repl matrices
collect(1:2:9)
Vector(1:2:9)
```

Then we can easily assign new values to the desired positions

```@repl matrices
v[1] = 4
v[end-1:end] .= 1
v
```

```@raw html
</p></details>
```

## Matrices

A matrix is a special case of an array with exactly two dimensions. In Julia, we can construct a matrix using square brackets similarly to vectors. Matrices are constructed row by row and all rows are separated by semicolons. Elements in a row are separated by space

```@repl matrices
m = [1  2  3  4; 5  6  7  8]
```

We can use the same functions as for vectors to obtain basic information about the matrices

```@repl matrices
typeof(m)
eltype(m)
ndims(m)
size(m)
length(m)
```

To access elements of a matrix, we can use the same syntax as for vectors

```@repl matrices
m[1] # the first element, equivalent to m[begin]
m[2] # the second element
m[end-1] # the last element
```

Note that the second element is `5`. The reason is, that Julia is column-oriented. Element at specific position in a matrix can accessed by `matrix[row_index, column_index]`, i.e. the following code returns the second element in the first row

```@repl matrices
m[1, 2]
```

It is also possible to access multiple elements at once

```@repl matrices
m[1, [2, 3]] # the second and third element in the first row
m[1:3] # the first three elements according to linear indexing
m[:, 1:3] # the first three columns
m[1, :] # the first row
m[:] # all elements
```

It is not possible to append new elements into arrays (with exception of vectors) directly. However, arrays with matching sizes along some dimension can be concatenated in this dimension. For example, we can horizontally concatenate our matrix `m` using function `hcat`

```@repl matrices
hcat(m, m)
```

or vertically using function `vcat`

```@repl matrices
vcat(m, m)
```

There is also a general function `cat` that concatenate given arrays along dimension specified by keyword argument `dims`

```@repl matrices
cat(m, m; dims = 2) # equivalent to hcat(m, m)
cat(m, m; dims = 1) # equivalent to vcat(m, m)
```

If the sizes of arrays do not match, an error occurs

```@repl matrices
v = [11, 12]
vcat(m, v)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Create two vectors: vector all odd numbers smaller than `10` and vector of all even numbers smaller than `10`. Then concatenate these two vectors horizontally and fill the third row with `4`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

First, we have to create the two vectors. We can do it manually or ve can use ranges and `collect` function as in the exercise in the previous section

```@repl matrices_ex
v1 = collect(1:2:9)
v2 = collect(2:2:10)
```

Then we use function `hcat` to horizontally concatenate these two vectors

```@repl matrices_ex
m = hcat(v1, v2)
```

and finally, we select all elements in the third row and assign a new value to them

```@repl matrices_ex
m[3,:] .= 4
m
```

```@raw html
</p></details>
```


## `N`-dimensional arrays

In many cases, it is useful to use arrays with more dimensions to store data. As an example, we can mention RGB images, which are typically stored in `3`-dimensional arrays. In julia, there is no explicit way to create `N`-dimensional arrays. The typical way how to create such an array is to create an empty array of appropriate size and then fill it either manually of using a loop. In this lecture, we will focus only on the basics of creating arrays. The lecture focused on [loops](@ref Iteration) will be later in the course.

There are several ways to initialize an array. The simplest and most common is using `zeros` function. This function by default creates an array of given size filled with zeros of type `Float64`

```@repl arrays
A = zeros(3, 5, 2) # equivalent to A = zeros((3, 5, 2))
```

The type of elements can be changed by passing the desired type as a first argument

```@repl arrays
B = zeros(Int64, 3, 5, 2)  # equivalent to B = zeros(Int64, (3, 5, 2))
```

As in the case of vectors and matrices, we can use the same functions to obtain basic information about the arrays

```@repl arrays
typeof(A)
eltype(A)
ndims(A)
size(A)
length(A)
```

The process of assigning a new value to the element of an array is the same as in the case of a vector or matrixs

```@repl arrays
B[1] = 1 # assign 1 to the first element
B[1, 2, 2] = 2 # assign 2 to the element at position (1,2,2)
B[2,:,1] .= 4
B
```

There are other useful functions which can be used to initialize an array. The `ones` function is similar to the `zeros` function, but instead of an array filled with zeros, it creates an array filled with ones

```@repl
ones(Float32, 2, 3, 1)
```

Function `fill` creates an array of given size filled with the given value

```@repl
fill(1.234, 2, 2)
```

## Broadcasting

In Julia, with broadcasting we indicate the action of mapping a function or an operation (which are the same in Julia) over an array or a matrix element by element. There is no speed gain in doing so, as it will be exactly equivalent to writing a for loop, but its conciseness may be useful sometimes. So the core idea in Julia is to write functions that take single values and use broadcasting when needed, unless the functions must explicitly work on arrays (for example to compute the mean of a series of values, perform matrix operations, vector multiplications, etc).

The broadcasting notation for operators consists of adding a dot `.` before the operator (for example `.*`)

```@repl broadcasting
a = [1,2,3] # column vector
a .-= 4 # from each element of vector subtracts 4
```

Without the dot, we get an error, since we cannot multiply substract a number from a vector

```@repl broadcasting
a -= 1
```

This syntax can be applied to any function in Julia. it is extremely useful for basic operations. For example, we can compute the absolute value of all elements simply by the following code

```@repl broadcasting
abs.(a)
```

It can be also used for matrix multiplication. Consider the following example

```@repl broadcasting
a = [1,2,3] # column vector
b = [4,5,6] # column vector
a * b
```

This makes perfectly sense from a mathematical point of view and operators behave how we would mathematically expect. If we want to use matrix multiplication, we have to transpose one of the vectors

```@repl broadcasting
a' * b
a * b'
```

Nonetheless, in programming it is often useful to write operations which work on an element by element basis, and for this reason broadcasting comes to our help

```@repl broadcasting
a .* b
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Construct the matrix whose elements are given by the following formula
```math
A_{i, j} = \frac{1}{2}\exp\{(x_{i, j} + 1)^2\} \quad i \in \{1, 2\}, \; j \in  \{1, 2, 3\}
```

where

```@example broadcasting_ex
x = [
    -1  0  2;
    2  -3  1;
]
nothing # hide
```


```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

There are several ways to create matrix `A`. The most obvious one is to use [`for` loop](@ref for-loop) (we will talk about loops later)

```@repl broadcasting_ex
A = zeros(2, 3);

for i in eachindex(A)
    A[i] = exp((x[i] + 1)^2)/2
end
A
```

or using list comprehension (this topic will be discussed later too)

```@repl broadcasting_ex
A = [exp((xi + 1)^2)/2 for xi in x]
```

But the most elegant way (subjectively) is to use broadcasting

```@repl broadcasting_ex
A = exp.((x .+ 1) .^ 2) ./ 2
```

There is a macro `@.` in Julia, that adds a dot before each operator and each function in an expression

```@repl broadcasting_ex
A = @. exp((x + 1) ^ 2) / 2
```

```@raw html
</p></details>
```

## Views

As in other programming languages, arrays are pointers to location in memory, thus we need to pay attention when we handle them. If we create an array `A` and we assign it to a variable `B`, the elements of the original array can be modified be modified by accessing `B`:

```@repl views
A = [1 2 3; 4 5 6]
B = A
B[2] = 42
```

We can check that both arrays are equal even though we modified only the array `B`

```@repl views
A == B
```

This is particularly useful because it lets us save memory, but may have undesirable effects. If we want to make a copy of an array we need to use the function `copy`

```@repl views
C = copy(A)
C[4] = 10
A == C
```

The different behavior occurs when accessing elements. Everytime we access multiple elements of an array at once, a new array is created

```@repl views
D = A[1:2, 1:2]
D[1] = 15
```
In this case, we modified only the array `D`, and array `A` remains unchanged

```@repl views
D == A[1:2, 1:2]
```

However, even if we want to select some subarray, it may be useful to create only a link to the original array and not a new array. In Julia, this can be done using `view` function

```@repl views
E = view(A, 1:2, 1:2)
E[4] = 78
```
We see that even if we change only the array in `D`, the change is propagated to `A`

```@repl views
E == A[1:2, 1:2]
```

To simplify the process of creating `view`s, there is a handy macro `@views`

```@repl views
@views A[1:2, 1:2] # equivalet to view(A, 1:2, 1:2)
```

Note that  function view creates a special type `SubArray`

```@repl views
typeof(E)
```

Since `SubArray` is a subtype of `AbstractArray`, we can apply any function defined for `Abstract Arrays` to `SubArray` too. In other words, (almost) all functions that work for arrays will also work for subarray.

```@repl views
A = [1 2 3; 4 5 6]
A_view = @views A[:, :]
sum(A)
sum(A_view)
minimum(A; dims = 1)
minimum(A_view; dims = 1)
```
This means that we can use arrays and subarray interchangeably without the necessity of changing existing code. Of course, there are some limitations, but we will talk about it later.
