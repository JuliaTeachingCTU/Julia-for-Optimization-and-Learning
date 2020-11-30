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

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
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

It is not possible to append new elements into arrays (with exception of vectors) directly. However, arrays with matching dimensions can be concatenated. For example, we can horizontally concatenate our matrix `m` using function `hcat`

```@repl matrices
hcat(m, m)
```

or vertically using function `vcat`

```@repl matrices
vcat(m, m)
```

There is also a general function `cat` that concatenate given arrays alongside dimension specified by keyword argument `dims`

```@repl matrices
cat(m, m; dims = 2) # equivalent to hcat(m, m)
cat(m, m; dims = 1) # equivalent to vcat(m, m)
```

```@repl matrices
v = [11, 12]
hcat(m, v)
```

```@repl matrices
vcat(m, v)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@raw html
</p></details>
```

## `N`-dimensional arrays

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@raw html
</p></details>
```

## Views

As in other programming languages, arrays are pointers to location in memory, thus we need to pay attention when we handle them. If we create an array `A` and we assign it to a variable `b`, the elements of the original array can be modified be modified by accessing `b`:

```@repl
a = [1,2,3]
b = a
b[2] = 42
a
```

This is particularly useful because it lets us save memory, but may have undesirable effects. If we want to make a copy of an array we need to use the function `copy`

```@repl
a = [1,2,3]
b = copy(a)
b[2] = 42
b
a
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@raw html
</p></details>
```

## Array constructors

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@raw html
</p></details>
```

## Operations on Arrays

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@raw html
</p></details>
```

## Elementwise Operations

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@raw html
</p></details>
```

## Linear algebra

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@raw html
</p></details>
```

## Broadcasting

In Julia, with broadcasting we indicate the action of mapping a function or an operation (which are the same in Julia) over an array or a matrix element by element. The broadcasting notation for operators consists of adding a dot `.` before the operator (for example `.*`)

```@repl broadcasting
a = [1,2,3] # column vector
b = [4,5,6] # column vector
c = [4 5 6] # row vector
```

Without the dot, we get an error, since we cannot multiply column vector by another column vector

```@repl broadcasting
a * b
c * a
```

This makes perfectly sense from a mathematical point of view and operators behave how we would mathematically expect. Nonetheless, in programming it is often useful to write operations which work on an element by element basis, and for this reason broadcasting comes to our help.

```@repl broadcasting
a .* b
c .* a
```

We can use the broadcasting notation also to map a function over an n-dimensional array. There is no speed gain in doing so, as it will be exactly equivalent to writing a for loop, but its conciseness may be useful sometimes. So the core idea in Julia is to write functions that take single values and use broadcasting when needed, unless the functions must explicitly work on arrays (for example to compute the mean of a series of values, perform matrix operations, vector multiplications, etc).

```@repl
a = [1,2,3]
ff(x) = x + 1
ff.(a)
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

```@raw html
</p></details>
```
