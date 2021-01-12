## Vectors

A vector is a special case of an array with only one dimension and is represented as a list of ordered data that share a common type (`Int64`, `Float64`, `Any`,...). A vector in Julia can be constructed directly using square brackets and a comma (or semicolon) as value separators

```jldoctest vectors
julia> v = [1, 2, 3, 4, 5, 6, 7, 8] # or equivalently v = [1; 2; 3; 4; ...]
8-element Array{Int64,1}:
 1
 2
 3
 4
 5
 6
 7
 8
```

Information about the number of dimension or type of elements of a given vector can be obtained from the output of the `typeof` function

```jldoctest vectors
julia> typeof(v)
Array{Int64,1}
```

The general description of an array in Julia is as follows: `Array{T,N}` denotes `N`-dimensional dense array with elements of type `T`. From this description, we can immediately see that vector `v` has one dimension and contains elements of type `Int64`. Another way how to get this information is to use the `ndims` and `eltype` function

```jldoctest vectors
julia> ndims(v)
1

julia> eltype(v)
Int64
```

We can also check the size and the length of a vector using the `size` and `length` functions

```jldoctest vectors
julia> size(v)
(8,)

julia> length(v)
8
```

The `size` function returns a [tuple](@ref Tuples) containing the given array's sizes along each dimension. The `length` function returns a total number of elements in the given array.

Elements of a vector can be accessed via square brackets and the index of the element. Contrary to other programming languages like C or Python and similarly to Matlab, arrays are indexed from `1`. For example, the third element of vector `v` can be accessed via the following syntax

```jldoctest vectors
julia> v[3]
3
```

There are also special keywords to access the first and last element of a given vector

```jldoctest vectors
julia> v[begin] # the first element
1

julia> v[end] # the last element
8
```

Multiple elements can be accessed at once using a similar syntax. The only difference is that instead of only one index, we use a vector of multiple indexes. For example, to access the second and third element of vector `v`, we can do

```jldoctest vectors
julia> v[[2, 3]]
2-element Array{Int64,1}:
 2
 3
```

It is also possible to select multiple indexes using the `range` function. The `range` function always accepts the starting point as a first argument, and then the keyword argument `stop` or `length`. The user can also set the step length using the keyword argument `step`. If the keywords `length`, `stop`, and `step` are all specified, they must agree. For example, to generate integers from `1` to `10` with step length `2`, the following code can be used

```jldoctest
julia> range(1; stop = 10, step = 2)
1:2:9
```

Ranges can also be constructed using the shorter syntax `start:step:stop`, where the `step` can be omitted if equal to `1`. Then the previous example can be equivalently rewritten as

```jldoctest vectors
julia> 1:2:10
1:2:9
```

This shorter syntax is handy for accessing array elements

```jldoctest vectors
julia> v[1:3] # the first three elements
3-element Array{Int64,1}:
 1
 2
 3

julia> v[1:2:end] # select all elements with odd index
4-element Array{Int64,1}:
 1
 3
 5
 7

julia> v[:] # all elements
8-element Array{Int64,1}:
 1
 2
 3
 4
 5
 6
 7
 8
```

New elements can be appended to the vector using the `append!` function. Notice the `!` symbol in the function name. This is Julia's convention for naming functions that modify their input arguments (usually the first one). In this case, the `append!` function appends one or more elements to the end of the given vector

```jldoctest vectors
julia> v = [1,2,3]
3-element Array{Int64,1}:
 1
 2
 3

julia> append!(v, 4)
4-element Array{Int64,1}:
 1
 2
 3
 4

julia> append!(v, [5,6])
6-element Array{Int64,1}:
 1
 2
 3
 4
 5
 6

julia> append!(v, 7:8)
8-element Array{Int64,1}:
 1
 2
 3
 4
 5
 6
 7
 8
```

As has already been said, the elements of a vector share the same type. In this case, we have a vector with elements of type `Int64`. If we try to append the value that is not representable as `Int64` it will result in an errors

```jldoctest vectors
julia> append!(v, 3.0)
9-element Array{Int64,1}:
 1
 2
 3
 4
 5
 6
 7
 8
 3

julia> append!(v, 3.1415)
ERROR: InexactError: Int64(3.1415)
```

In the first case, it is possible to append a floating-point number since it can be represented as an integer. We can use the `isinteger` function to test whether the number is numerically equal to some integer

```jldoctest
julia> isinteger(3.0)
true
```

In the second case, we cannot convert the given number to an `Int64` without losing precision, thus the error. The vector `v` can store only values of type `Int64` or values that can be safely converted to `Int64` (such as `Int32`). To avoid these errors, we can initialize the type of elements when creating a vector. It can be done using a type name followed by a square bracket

```jldoctest
julia> v = Float64[1, 2, 3]
3-element Array{Float64,1}:
 1.0
 2.0
 3.0

julia> append!(v, 3.1415)
4-element Array{Float64,1}:
 1.0
 2.0
 3.0
 3.1415
```

Since arrays in Julia are mutable objects, it is possible to change the values of their elements. It can be done simply by assigning a new value to some element

```jldoctest vectors
julia> v = [1, 2, 3, 4]
4-element Array{Int64,1}:
 1
 2
 3
 4

julia> v[2] = 4
4

julia> v
4-element Array{Int64,1}:
 1
 4
 3
 4
```

It is also possible to assign one value to multiple elements of an array at once. However, in this case, we have to use dot syntax, which is in Julia used for [element-wise operations](@ref Broadcasting)

```jldoctest vectors
julia> v[3:4] .= 11
2-element view(::Array{Int64,1}, 3:4) with eltype Int64:
 11
 11

julia> v
4-element Array{Int64,1}:
  1
  4
 11
 11
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Create a vector of positive integers that contains all odd numbers smaller than `10`. Then change the first element to `4` and the last two elements to `1`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Such a vector can be created in a manual way as follows

```jldoctest matrices
julia> v = [1,3,5,7,9]
5-element Array{Int64,1}:
 1
 3
 5
 7
 9
```

or we can use the `range` function to create a range with given properties and then use the `collect` function to create a vector or use the `Vector` type to convert the range to a vector

```jldoctest matrices
julia> collect(1:2:9)
5-element Array{Int64,1}:
 1
 3
 5
 7
 9

julia> Vector(1:2:9)
5-element Array{Int64,1}:
 1
 3
 5
 7
 9
```

The values stored in the vector can be changed using the `.=` sign and proper indexes. Do not forget to add a dot before the `=` sign to perform operation element-wise.

```jldoctest matrices
julia> v[1] = 4
4

julia> v[end-1:end] .= 1
2-element view(::Array{Int64,1}, 4:5) with eltype Int64:
 1
 1

julia> v
5-element Array{Int64,1}:
 4
 3
 5
 1
 1
```

```@raw html
</p></details>
```

## Matrices

A matrix is a special case of an array with precisely two dimensions. In Julia, we can construct a matrix using square brackets similarly to vectors. Matrices are constructed row by row. Elements in rows are separated using spaces, and rows are separated using semicolons

```jldoctest matrices
julia> m = [1  2  3  4; 5  6  7  8]
2×4 Array{Int64,2}:
 1  2  3  4
 5  6  7  8
```

The basic information about matrices can be obtained using the same functions as for vectors

```jldoctest matrices
julia> typeof(m)
Array{Int64,2}

julia> eltype(m)
Int64

julia> ndims(m)
2

julia> size(m)
(2, 4)

julia> length(m)
8
```

Also, accessing matrix elements can be done in the same way as for vectors

```jldoctest matrices
julia> m[1] # the first element, equivalent to m[begin]
1

julia> m[2] # the second element
5

julia> m[end-1] # the last element
4
```

Note that the second element is `5`. The reason is that Julia is column-oriented. Element at a specific position in a matrix can be accessed by the following syntax `matrix[row_index, column_index]`. The following code returns the second element in the first row

```jldoctest matrices
julia> m[1, 2]
2
```

It is also possible to access multiple elements at once

```jldoctest matrices
julia> m[1, [2, 3]] # the second and third element in the first row
2-element Array{Int64,1}:
 2
 3

julia> m[1:3] # the first three elements according to linear indexing
3-element Array{Int64,1}:
 1
 5
 2

julia> m[:, 1:3] # the first three columns
2×3 Array{Int64,2}:
 1  2  3
 5  6  7

julia> m[1, :] # the first row
4-element Array{Int64,1}:
 1
 2
 3
 4

julia> m[:] # all elements
8-element Array{Int64,1}:
 1
 5
 2
 6
 3
 7
 4
 8
```

It is not possible to append new elements into arrays directly, except for vectors. However, arrays with matching sizes along some dimensions can be concatenated in this dimension. For example, we can horizontally concatenate the matrix `m` using the `hcat` function

```jldoctest matrices
julia> hcat(m, m)
2×8 Array{Int64,2}:
 1  2  3  4  1  2  3  4
 5  6  7  8  5  6  7  8
```

or vertically using hte `vcat` function

```jldoctest matrices
julia> vcat(m, m)
4×4 Array{Int64,2}:
 1  2  3  4
 5  6  7  8
 1  2  3  4
 5  6  7  8
```

There is also a general function `cat` that concatenate given arrays along dimension specified by the `dims` keyword argument

```jldoctest matrices
julia> cat(m, m; dims = 2) # equivalent to hcat(m, m)
2×8 Array{Int64,2}:
 1  2  3  4  1  2  3  4
 5  6  7  8  5  6  7  8

julia> cat(m, m; dims = 1) # equivalent to vcat(m, m)
4×4 Array{Int64,2}:
 1  2  3  4
 5  6  7  8
 1  2  3  4
 5  6  7  8
```

If the sizes of arrays do not match, an error occurs

```jldoctest matrices
julia> v = [11, 12]
2-element Array{Int64,1}:
 11
 12

julia> vcat(m, v)
ERROR: ArgumentError: number of columns of each array must match (got (4, 1))
[...]
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Create two vectors: vector of all odd positive integers smaller than `10` and vector of all even positive integers smaller than `10`. Then concatenate these two vectors horizontally and fill the third row with `4`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

First, we have to create the two vectors. We can do it manually, or we can use ranges and the `collect` function as in the exercise in the previous section

```jldoctest matrices_ex
julia> v1 = collect(1:2:9)
5-element Array{Int64,1}:
 1
 3
 5
 7
 9

julia> v2 = collect(2:2:10)
5-element Array{Int64,1}:
  2
  4
  6
  8
 10
```

Then we can use the `hcat` function to concatenate these two vectors horizontally

```jldoctest matrices_ex
julia> m = hcat(v1, v2)
5×2 Array{Int64,2}:
 1   2
 3   4
 5   6
 7   8
 9  10
```

Finally, we select all elements in the third row and assign a new value to them

```jldoctest matrices_ex
julia> m[3,:] .= 4
2-element view(::Array{Int64,2}, 3, :) with eltype Int64:
 4
 4

julia> m
5×2 Array{Int64,2}:
 1   2
 3   4
 4   4
 7   8
 9  10
```

```@raw html
</p></details>
```

## `N`-dimensional arrays

In many cases, it is useful to use arrays with more dimensions to store data. As an example, we can mention RGB images, which are typically stored in `3`-dimensional arrays. In Julia, there is no straightforward way to create `N`-dimensional arrays. The typical way to create such an array is to create an empty array of appropriate size and then fill it manually or using a loop. In this lecture, we will focus only on the basics of creating arrays. The lecture focused on [loops](@ref Loops-and-iterators) will be later in the course.

There are several ways to initialize an array. The simplest and most common is using the `zeros` function. This function by default creates an array of given size filled with zeros of type `Float64`

```jldoctest arrays
julia> A = zeros(3, 5, 2) # equivalent to A = zeros((3, 5, 2))
3×5×2 Array{Float64,3}:
[:, :, 1] =
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0

[:, :, 2] =
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
```

The type of elements can be changed by passing the type as a first argument

```jldoctest arrays
julia> B = zeros(Int64, 3, 5, 2)  # equivalent to B = zeros(Int64, (3, 5, 2))
3×5×2 Array{Int64,3}:
[:, :, 1] =
 0  0  0  0  0
 0  0  0  0  0
 0  0  0  0  0

[:, :, 2] =
 0  0  0  0  0
 0  0  0  0  0
 0  0  0  0  0
```

As in the case of vectors and matrices, we can use the same functions to obtain basic information about the arrays

```jldoctest arrays
julia> typeof(A)
Array{Float64,3}

julia> eltype(A)
Float64

julia> ndims(A)
3

julia> size(A)
(3, 5, 2)

julia> length(A)
30
```

The process of assigning a new value to the element of an array is also the same

```jldoctest arrays
julia> B[1] = 1 # assign 1 to the first element
1

julia> B[1, 2, 2] = 2 # assign 2 to the element at position (1,2,2)
2

julia> B[2,:,1] .= 4
5-element view(::Array{Int64,3}, 2, :, 1) with eltype Int64:
 4
 4
 4
 4
 4

julia> B
3×5×2 Array{Int64,3}:
[:, :, 1] =
 1  0  0  0  0
 4  4  4  4  4
 0  0  0  0  0

[:, :, 2] =
 0  2  0  0  0
 0  0  0  0  0
 0  0  0  0  0
```

Other useful functions can be used to initialize an array. The `ones` function is similar to the `zeros` function, but instead of an array filled with zeros, it creates an array filled with ones

```jldoctest
julia> ones(Float32, 2, 3, 1)
2×3×1 Array{Float32,3}:
[:, :, 1] =
 1.0  1.0  1.0
 1.0  1.0  1.0
```

Function `fill` creates an array of given size filled with the given value

```jldoctest
julia> fill(1.234, 2, 2)
2×2 Array{Float64,2}:
 1.234  1.234
 1.234  1.234
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Create three matrices with the following properties:
- Matrix `A` is of size `2x3`, and all its elements are equal to 0.
- Matrix `B` is of size `2x3x1`, and all its elements are equal to 1.
- Matrix `C` is of size `2x3`, and all its elements are equal to 2.
Concatenate these three matrices along with the third dimension.

**Hint:** use the `cat` function and the keyword `dims`.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Matrix `A` can be created using the `zeros` function, and similarly, matrix `B` using the `ones` function. To create a matrix `C`, we can use the `fill` function

```jldoctest arrays_ex
julia> A = zeros(2,3)
2×3 Array{Float64,2}:
 0.0  0.0  0.0
 0.0  0.0  0.0

julia> B = ones(2,3, 1)
2×3×1 Array{Float64,3}:
[:, :, 1] =
 1.0  1.0  1.0
 1.0  1.0  1.0

julia> C = fill(2, 2, 3)
2×3 Array{Int64,2}:
 2  2  2
 2  2  2
```

Now we can use the `cat` function with `dims = 3` to concatenate the matrices along with the third dimension

```jldoctest arrays_ex
julia> cat(A, B, C; dims = 3)
2×3×3 Array{Float64,3}:
[:, :, 1] =
 0.0  0.0  0.0
 0.0  0.0  0.0

[:, :, 2] =
 1.0  1.0  1.0
 1.0  1.0  1.0

[:, :, 3] =
 2.0  2.0  2.0
 2.0  2.0  2.0
```

```@raw html
</p></details>
```

## Broadcasting

In Julia, with broadcasting, we indicate mapping a function or an operation (which are the same in Julia) over an array (or any other iterable object) element by element. There is no speed gain in doing so, as it will be exactly equivalent to writing a for loop, but its conciseness may be useful sometimes. So the core idea in Julia is to write functions that take single values and use broadcasting when needed unless the functions must explicitly work on arrays (for example, to compute the mean of a series of values, perform matrix operations, vector multiplications, etc.).

The broadcasting notation for operators consists of adding a dot `.` before the operator (for example, `.*`, `.+`, `./`)

```jldoctest broadcasting
julia> a = [1,2,3] # column vector
3-element Array{Int64,1}:
 1
 2
 3

julia> a .-= 4 # from each element of vector subtracts 4
3-element Array{Int64,1}:
 -3
 -2
 -1
```

Without the dot, we get an error since we cannot subtract a number from a vector

```jldoctest broadcasting
julia> a -= 1
ERROR: MethodError: no method matching -(::Array{Int64,1}, ::Int64)
For element-wise subtraction, use broadcasting with dot syntax: array .- scalar
[...]
```

The same syntax can be applied to any function in Julia. It is extremely useful for basic operations. For example, we can compute the absolute value of all elements by the following code

```jldoctest broadcasting
julia> abs.(a)
3-element Array{Int64,1}:
 3
 2
 1
```

With broadcasting, it is effortless to compute complex mathematical formulas. For example, if we want to evaluate the following formulas

```math
\sum_{i = 1}^{3} \frac{\exp\{\sqrt{|a_{i} - 1|}\}}{2}
```

we can simply us the following code

```jldoctest broadcasting
julia> sum(exp.(sqrt.(abs.(a .- 1)))./2)
8.577270075873834
```

Broadcasting can also be used for matrix multiplication. Consider the following two vectors.

```jldoctest broadcasting
julia> a = [1,2,3] # column vector
3-element Array{Int64,1}:
 1
 2
 3

julia> b = [4,5,6] # column vector
3-element Array{Int64,1}:
 4
 5
 6
```

Since we have two column vectors, the matrix multiplication will not work

```jldoctest broadcasting
julia> a * b
ERROR: MethodError: no method matching *(::Array{Int64,1}, ::Array{Int64,1})
[...]
```

It makes perfect sense from a mathematical perspective, and the `*` operator behaves how we would mathematically expect. If we want to use matrix multiplication, we have to transpose one of the vectors

```jldoctest broadcasting
julia> a' * b
32

julia> a * b'
3×3 Array{Int64,2}:
  4   5   6
  8  10  12
 12  15  18
```

Nonetheless, in programming, it is often useful to write operations that work in an element-wise manner. In such cases, broadcasting comes to our help

```jldoctest broadcasting
julia> a .* b
3-element Array{Int64,1}:
  4
 10
 18
```

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Construct a matrix whose elements are given by the following formula
```math
A_{i, j} = \frac{1}{2}\exp\{(x_{i, j} + 1)^2\}, \quad i \in \{1, 2\}, \; j \in  \{1, 2, 3\}
```

where the matrix `B` is defined as follows

```jldoctest broadcasting_ex; output=false
B = [
    -1  0  2;
    2  -3  1;
]

# output
2×3 Array{Int64,2}:
 -1   0  2
  2  -3  1
```

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Each element of the matrix `A` depends on only one element of the matrix `B`. In other words, matrix `A` can be created in an element-wise manner from matrix `B`, i.e. we can use broadcasting

```jldoctest broadcasting_ex
julia> A = exp.((B .+ 1) .^ 2) ./ 2
2×3 Array{Float64,2}:
    0.5    1.35914  4051.54
 4051.54  27.2991     27.2991
```

Note that we use a dot before each operation since we want to perform all operations element-wise. In this case, we can use the `@.` macro.  The `@.` macro adds a dot before each operator and each function in an expression

```jldoctest broadcasting_ex
julia> A = @. exp((B + 1) ^ 2) / 2
2×3 Array{Float64,2}:
    0.5    1.35914  4051.54
 4051.54  27.2991     27.2991
```

Just for the comparison, the same matrix can be created as follows using [`for` loop](@ref for-and-while-loop)

```jldoctest broadcasting_ex
julia> A = zeros(2, 3);

julia> for i in 1:length(A)
           A[i] = exp((B[i] + 1)^2)/2
       end

julia> A
2×3 Array{Float64,2}:
    0.5    1.35914  4051.54
 4051.54  27.2991     27.2991
```

```@raw html
</p></details>
```

## Views

As in other programming languages, arrays are pointers to a location in memory. Thus we need to pay attention when we handle them. If we create an array `A` and we assign it to a variable `B`, the elements of the original array can be modified by accessing `B`

```jldoctest views
julia> A = [1 2 3; 4 5 6]
2×3 Array{Int64,2}:
 1  2  3
 4  5  6

julia> B = A
2×3 Array{Int64,2}:
 1  2  3
 4  5  6

julia> B[2] = 42
42
```

We can check that both arrays are equal even though we modified only the array `B`

```jldoctest views
julia> A == B
true
```

The reason is that Julia, by default, will not create a copy of an array when assigning to a variable. This behavior is advantageous because it allows us to save memory. However, it also may have undesirable effects. If we want to make a copy of an array, we have to use the `copy` function

```jldoctest views
julia> C = copy(A)
2×3 Array{Int64,2}:
  1  2  3
 42  5  6

julia> C[4] = 10
10

julia> A == C
false
```

The different behavior occurs when accessing elements. Every time we access multiple elements of an array at once, a new array is created

```jldoctest views
julia> D = A[1:2, 1:2]
2×2 Array{Int64,2}:
  1  2
 42  5

julia> D[1] = 15
15
```

In this case, we modified only the array `D`, and array `A` remains unchanged

```jldoctest views
julia> D == A[1:2, 1:2]
false
```

However, even if we want to select some subarray, it may be useful to create only a link to the original array and not create a new array. In Julia, this can be achieved using the `view` function or alternatively, using the `@view` macro

```jldoctest views
julia> E = view(A, 1:2, 1:2)
2×2 view(::Array{Int64,2}, 1:2, 1:2) with eltype Int64:
  1  2
 42  5

julia> E = @view A[1:2, 1:2]
2×2 view(::Array{Int64,2}, 1:2, 1:2) with eltype Int64:
  1  2
 42  5

julia> E[4] = 78
78
```

We see that even if we change only the array in `D`, the change is propagated to `A`

```jldoctest views
julia> E == A[1:2, 1:2]
true
```

Note that  function view creates a special type `SubArray`

```jldoctest views
julia> typeof(E)
SubArray{Int64,2,Array{Int64,2},Tuple{UnitRange{Int64},UnitRange{Int64}},false}
```

Since `SubArray` is a subtype of `AbstractArray`, we can apply any function defined for `Abstract Arrays` to `SubArray` too. In other words, (almost) all functions that work for arrays will also work for subarray.

```jldoctest views
julia> A = [1 2 3; 4 5 6]
2×3 Array{Int64,2}:
 1  2  3
 4  5  6

julia> A_view = @view A[:, :]
2×3 view(::Array{Int64,2}, :, :) with eltype Int64:
 1  2  3
 4  5  6

julia> sum(A)
21

julia> sum(A_view)
21

julia> minimum(A; dims = 1)
1×3 Array{Int64,2}:
 1  2  3

julia> minimum(A_view; dims = 1)
1×3 Array{Int64,2}:
 1  2  3
```

It means that we can use arrays and subarray interchangeably without the necessity of changing existing code. Of course, there are some limitations, but we will talk about them later.

Note that the `@view` macro can only be applied directly to a reference expression. In many cases, we want to use views throughout the whole expression. In such a case, we can add the `@view` macro before each array-slicing operation

```jldoctest views
julia> A = [1 2 3; 4 5 6];

julia> sum(exp.(sqrt.(abs.(@view(A[1, :]) .- @view(A[2, :]))))./2)
8.478350511051136
```

However, the resulting expression is long and difficult to read. To simplify this task, Julia provides the `@views` macro that converts every array-slicing operation in the given expression to return a view

```jldoctest views
julia> @views sum(exp.(sqrt.(abs.(A[1, :] .- A[2, :])))./2)
8.478350511051136
```
