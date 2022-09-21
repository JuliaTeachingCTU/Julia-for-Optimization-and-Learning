## Vectors

A vector is a particular case of an array with only one dimension. It is represented as a list of ordered data with the same type (`Int64`, `Float64`, `Any`,...). A vector in Julia can be constructed directly using square brackets and a comma (or semicolon) as separators.

```jldoctest vectors
julia> v = [1, 2, 3, 4, 5, 6, 7, 8] # or equivalently v = [1; 2; 3; 4; ...]
8-element Vector{Int64}:
 1
 2
 3
 4
 5
 6
 7
 8
```

The number of dimensions and the type of elements can be obtained from the output of the `typeof` function.

```jldoctest vectors
julia> typeof(v)
Vector{Int64} (alias for Array{Int64, 1})
```

The general description of an array in Julia is as follows: `Array{T,N}` denotes `N`-dimensional dense array with elements of type `T`. From this description, we can immediately see that vector `v` has one dimension and contains elements of type `Int64`. Another way to get this information is to use the `ndims` and `eltype` functions.

```jldoctest vectors
julia> ndims(v)
1

julia> eltype(v)
Int64
```

We can also check the size and the length of a vector using the `size` and `length` functions.

```jldoctest vectors
julia> size(v)
(8,)

julia> length(v)
8
```

The `size` function returns a [tuple](@ref Tuples) containing the array size along all dimensions. The `length` function returns a total number of elements.

Elements of a vector can be accessed via square brackets. Contrary to other programming languages like C or Python, and similarly to Matlab, arrays are indexed from `1`. For example, the third element of vector `v` can be accessed via the following syntax:

```jldoctest vectors
julia> v[3]
3
```

There are also special keywords to access the first and last element of a vector.

```jldoctest vectors
julia> v[begin] # the first element
1

julia> v[end] # the last element
8
```

Multiple elements can be accessed at once. The only difference is that instead of only one index, we use a vector of multiple indices. For example, to access the second and third element of vector `v`, we can do:

```jldoctest vectors
julia> v[[2, 3]]
2-element Vector{Int64}:
 2
 3
```

It is also possible to select multiple indices using the `range` function. It always accepts the starting point as a first argument, and then the keyword argument `stop` or `length`. The user can also set the step length using the keyword argument `step`. If the keywords `length`, `stop`, and `step` are all specified, they must agree. For example, to generate integers from `1` to `10` with step length `2`, the following code can be used:

```jldoctest
julia> range(1; stop = 10, step = 2) # or equivalently range(1, 10; step = 2)
1:2:9
```

Ranges can also be constructed using the shorter syntax `start:step:stop`, where the `step` can be omitted if it equals `1`. The previous example can be equivalently rewritten as

```jldoctest vectors
julia> 1:2:10
1:2:9
```

This shorter syntax is handy for accessing array elements.

```jldoctest vectors
julia> v[1:3] # the first three elements
3-element Vector{Int64}:
 1
 2
 3

julia> v[1:2:end] # select all elements with odd index
4-element Vector{Int64}:
 1
 3
 5
 7

julia> v[:] # all elements
8-element Vector{Int64}:
 1
 2
 3
 4
 5
 6
 7
 8
```

New elements can be appended to the vector using the `append!` function. Notice the `!` symbol in the function name. This is Julia's convention for naming functions that modify their input arguments (usually the first one). In this case, the `append!` function appends one or more elements to the end of the given vector.

```jldoctest vectors
julia> v = [1,2,3]
3-element Vector{Int64}:
 1
 2
 3

julia> append!(v, 4)
4-element Vector{Int64}:
 1
 2
 3
 4

julia> append!(v, [5,6])
6-element Vector{Int64}:
 1
 2
 3
 4
 5
 6

julia> append!(v, 7:8)
8-element Vector{Int64}:
 1
 2
 3
 4
 5
 6
 7
 8
```

As has already been said, the elements of a vector share the same type. In this case, we have a vector with elements of type `Int64`. If we try to append a value that is not representable as `Int64`, it will result in an error.

```jldoctest vectors
julia> append!(v, 3.0)
9-element Vector{Int64}:
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

In the first case, it is possible to append a floating-point number since it can be represented as an integer. We can use the `isinteger` function to test whether the number is numerically equal to some integer.

```jldoctest
julia> isinteger(3.0)
true
```

In the second case, we cannot convert the given number to `Int64` without losing precision, thus the error. The vector `v` can store only values of type `Int64` or values that can be safely converted to `Int64` (such as `Int32`). To avoid these errors, we can initialize the type of elements when creating a vector. It can be done using a type name followed by a square bracket.

```jldoctest
julia> v = Float64[1, 2, 3]
3-element Vector{Float64}:
 1.0
 2.0
 3.0

julia> append!(v, 3.1415)
4-element Vector{Float64}:
 1.0
 2.0
 3.0
 3.1415
```

Since arrays in Julia are mutable objects, it is possible to change their values. This can be done by assigning a new value to an element.

```jldoctest vectors
julia> v = [1, 2, 3, 4]
4-element Vector{Int64}:
 1
 2
 3
 4

julia> v[2] = 4
4

julia> v
4-element Vector{Int64}:
 1
 4
 3
 4
```

It is also possible to assign one value to multiple array elements at once. However, in this case, we have to use dot syntax, which Julia uses for [element-wise operations](@ref Broadcasting).

```jldoctest vectors
julia> v[3:4] .= 11
2-element view(::Vector{Int64}, 3:4) with eltype Int64:
 11
 11

julia> v
4-element Vector{Int64}:
  1
  4
 11
 11
```

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body">
```

Create a vector of positive integers that contains all odd numbers smaller than `10`. Then change the first element to `4` and the last two elements to `1`.

```@raw html
</div></div>
<details class = "admonition is-category-solution">
<summary class = "admonition-header">Solution:</summary>
<div class = "admonition-body">
```

Such a vector can be either created manually by

```jldoctest vectors_ex
julia> v = [1,3,5,7,9]
5-element Vector{Int64}:
 1
 3
 5
 7
 9
```

or we can use the `range` function to create a range with given properties and then use the `collect` function to create a vector. Another possibility is to use the `Vector` type to convert the range into a vector.

```jldoctest vectors_ex
julia> collect(1:2:9)
5-element Vector{Int64}:
 1
 3
 5
 7
 9

julia> Vector(1:2:9)
5-element Vector{Int64}:
 1
 3
 5
 7
 9
```

The values stored in the vector can be changed using the `.=` sign and proper indices. Do not forget to add the dot before the `=` sign to perform the element-wise operation.

```jldoctest vectors_ex
julia> v[1] = 4
4

julia> v[end-1:end] .= 1
2-element view(::Vector{Int64}, 4:5) with eltype Int64:
 1
 1

julia> v
5-element Vector{Int64}:
 4
 3
 5
 1
 1
```

```@raw html
</div></details>
```

## Matrices

A matrix is a special case of an array with precisely two dimensions. In Julia, we can construct a matrix by the square brackets similarly to vectors. Matrices are built row by row. Elements in rows are separated by spaces, and rows are separated by semicolons.

```jldoctest matrices
julia> M = [1  2  3  4; 5  6  7  8]
2×4 Matrix{Int64}:
 1  2  3  4
 5  6  7  8
```

The same functions can obtain the basic information about matrices as for vectors.

```jldoctest matrices
julia> typeof(M)
Matrix{Int64} (alias for Array{Int64, 2})

julia> eltype(M)
Int64

julia> ndims(M)
2

julia> size(M)
(2, 4)

julia> length(M)
8
```

Accessing matrix elements can be also done in the same way as for vectors.

```jldoctest matrices
julia> M[1] # the first element, equivalent to m[begin]
1

julia> M[2] # the the second element element
5

julia> M[end-1] # the second to last element
4
```

Note that the second element is `5`. The reason is that Julia is column-oriented. Element at a specific position in a matrix can be accessed by the following syntax `matrix[row_index, column_index]`. The following code returns the second element in the first row.

```jldoctest matrices
julia> M[1, 2]
2
```

It is also possible to access multiple elements at once

```jldoctest matrices
julia> M[1, [2, 3]] # the second and third element in the first row
2-element Vector{Int64}:
 2
 3

julia> M[1:3] # the first three elements according to linear indexing
3-element Vector{Int64}:
 1
 5
 2

julia> M[:, 1:3] # the first three columns
2×3 Matrix{Int64}:
 1  2  3
 5  6  7

julia> M[1, :] # the first row
4-element Vector{Int64}:
 1
 2
 3
 4

julia> M[:] # all elements
8-element Vector{Int64}:
 1
 5
 2
 6
 3
 7
 4
 8
```

It is impossible to append new elements into arrays directly, except for vectors. However, arrays with matching sizes along a dimension can be concatenated in this dimension. For example, we can horizontally concatenate the matrix `m` using the `hcat` function.

```jldoctest matrices
julia> hcat(M, M)
2×8 Matrix{Int64}:
 1  2  3  4  1  2  3  4
 5  6  7  8  5  6  7  8
```

For concatenating vertically, we use the `vcat` function.

```jldoctest matrices
julia> vcat(M, M)
4×4 Matrix{Int64}:
 1  2  3  4
 5  6  7  8
 1  2  3  4
 5  6  7  8
```

The general function `cat` concatenates arrays along the dimension specified by the `dims` keyword argument.

```jldoctest matrices
julia> cat(M, M; dims = 2) # equivalent to hcat(m, m)
2×8 Matrix{Int64}:
 1  2  3  4  1  2  3  4
 5  6  7  8  5  6  7  8

julia> cat(M, M; dims = 1) # equivalent to vcat(m, m)
4×4 Matrix{Int64}:
 1  2  3  4
 5  6  7  8
 1  2  3  4
 5  6  7  8
```

If the sizes of arrays do not match, an error occurs.

```jldoctest matrices
julia> v = [11, 12]
2-element Vector{Int64}:
 11
 12

julia> hcat(M, v)
2×5 Matrix{Int64}:
 1  2  3  4  11
 5  6  7  8  12

julia> vcat(M, v)
ERROR: ArgumentError: number of columns of each array must match (got (4, 1))
[...]
```

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body">
```

Create two vectors: vector of all odd positive integers smaller than `10` and vector of all even positive integers smaller than `10`. Then concatenate these two vectors horizontally and fill the third row with `4`.

```@raw html
</div></div>
<details class = "admonition is-category-solution">
<summary class = "admonition-header">Solution:</summary>
<div class = "admonition-body">
```

First, we have to create the two vectors. We can do it manually, or we can use ranges and the `collect` function as in the exercise in the previous section.

```jldoctest matrices_ex
julia> v1 = collect(1:2:9)
5-element Vector{Int64}:
 1
 3
 5
 7
 9

julia> v2 = collect(2:2:10)
5-element Vector{Int64}:
  2
  4
  6
  8
 10
```

Then we use the `hcat` function to concatenate these two vectors horizontally.

```jldoctest matrices_ex
julia> M = hcat(v1, v2)
5×2 Matrix{Int64}:
 1   2
 3   4
 5   6
 7   8
 9  10
```

Finally, we select all elements in the third row and assign the new value to them.

```jldoctest matrices_ex
julia> M[3,:] .= 4
2-element view(::Matrix{Int64}, 3, :) with eltype Int64:
 4
 4

julia> M
5×2 Matrix{Int64}:
 1   2
 3   4
 4   4
 7   8
 9  10
```

```@raw html
</div></details>
```

## `N`-dimensional arrays

In many cases, it is useful to use arrays with more dimensions to store data. As an example, we can mention RGB images, which are typically stored in `3`-dimensional arrays. In Julia, there is no straightforward way to create `N`-dimensional arrays. The typical way to make such an array is to create an empty array of appropriate size and then fill it manually or using a loop. In this lecture, we will focus only on the basics of creating arrays. The lecture focused on [loops](@ref for-and-while-loops) will explain this topic in more details.

!!! compat "New features in Julia 1.7"
    Starting with Julia 1.7, it is possible to create multidimensional arrays in a similar way to matrices and vectors. Repeated semicolons can be used inside array concatenation expressions to separate dimensions of an array, with the number of semicolons specifying the dimension.
    ```julia
    julia> [1; 2; 3]
    3-element Vector{Int64}:
    1
    2
    3

    julia> [1;; 2;; 3]
    1×3 Matrix{Int64}:
    1  2  3

    julia> [1;;; 2;;; 3]
    1×1×3 Array{Int64, 3}:
    [:, :, 1] =
    1

    [:, :, 2] =
    2

    [:, :, 3] =
    3
    ```

There are several ways to initialize an array. The simplest and most common is using the `zeros` function. By default, this function creates an array of given size filled with zeros of type `Float64`.

```jldoctest arrays
julia> A = zeros(3, 5, 2) # equivalent to A = zeros((3, 5, 2))
3×5×2 Array{Float64, 3}:
[:, :, 1] =
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0

[:, :, 2] =
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
 0.0  0.0  0.0  0.0  0.0
```

The element type can be changed by passing the type as a first argument.

```jldoctest arrays
julia> B = zeros(Int64, 3, 5, 2)  # equivalent to B = zeros(Int64, (3, 5, 2))
3×5×2 Array{Int64, 3}:
[:, :, 1] =
 0  0  0  0  0
 0  0  0  0  0
 0  0  0  0  0

[:, :, 2] =
 0  0  0  0  0
 0  0  0  0  0
 0  0  0  0  0
```

As in the case of vectors and matrices, we can use the same functions to obtain basic information about arrays.

```jldoctest arrays
julia> typeof(A)
Array{Float64, 3}

julia> eltype(A)
Float64

julia> ndims(A)
3

julia> size(A)
(3, 5, 2)

julia> length(A)
30
```

Assigning a new value to the element of an array is also the same.

```jldoctest arrays
julia> B[1] = 1 # assign 1 to the first element
1

julia> B[1, 2, 2] = 2 # assign 2 to the element at position (1,2,2)
2

julia> B[2,:,1] .= 4
5-element view(::Array{Int64, 3}, 2, :, 1) with eltype Int64:
 4
 4
 4
 4
 4

julia> B
3×5×2 Array{Int64, 3}:
[:, :, 1] =
 1  0  0  0  0
 4  4  4  4  4
 0  0  0  0  0

[:, :, 2] =
 0  2  0  0  0
 0  0  0  0  0
 0  0  0  0  0
```

Other useful functions can be used to initialize an array. The `ones` function is similar to the `zeros` function, but instead of an array filled with zeros, it creates an array filled with ones.

```jldoctest
julia> ones(Float32, 2, 3, 1)
2×3×1 Array{Float32, 3}:
[:, :, 1] =
 1.0  1.0  1.0
 1.0  1.0  1.0
```

Function `fill` creates an array of given size filled with the given value.

```jldoctest
julia> fill(1.234, 2, 3, 1)
2×3×1 Array{Float64, 3}:
[:, :, 1] =
 1.234  1.234  1.234
 1.234  1.234  1.234
```

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body">
```

Create three matrices with the following properties:
- Matrix `A` is of size `2x3`, and all its elements equal 0.
- Matrix `B` is of size `2x3x1`, and all its elements equal 1.
- Matrix `C` is of size `2x3`, and all its elements equal 2.
Concatenate these three matrices along the third dimension.

**Hint:** use the `cat` function and the keyword `dims`.

```@raw html
</div></div>
<details class = "admonition is-category-solution">
<summary class = "admonition-header">Solution:</summary>
<div class = "admonition-body">
```

Matrix `A` can be created using the `zeros` function, and similarly, matrix `B` using the `ones` function. To create a matrix `C`, we can use the `fill` function.

```jldoctest arrays_ex
julia> A = zeros(2, 3)
2×3 Matrix{Float64}:
 0.0  0.0  0.0
 0.0  0.0  0.0

julia> B = ones(2, 3, 1)
2×3×1 Array{Float64, 3}:
[:, :, 1] =
 1.0  1.0  1.0
 1.0  1.0  1.0

julia> C = fill(2, 2, 3)
2×3 Matrix{Int64}:
 2  2  2
 2  2  2
```

Now we can use the `cat` function with `dims = 3` to concatenate the matrices along the third dimension.

```jldoctest arrays_ex
julia> cat(A, B, C; dims = 3)
2×3×3 Array{Float64, 3}:
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
</div></details>
```

## Broadcasting

In Julia, broadcasting maps a function or an operation (which are the same in Julia) over an array (or any other iterable object) element by element. Since it is equivalent to writing a for loop, there is no speed gain, but its conciseness may be useful. Julia's core idea is to write functions that take single values as inputs and use broadcasting whenever needed. The exception is when a function must explicitly work on arrays such as sorting, computing means, or matrix operations.

The broadcasting notation for operators consists of adding a dot `.` before the operator such as `.*`, `.+` or `./`).

```jldoctest broadcasting
julia> a = [1,2,3] # column vector
3-element Vector{Int64}:
 1
 2
 3

julia> a .-= 4 # from each element of vector subtracts 4
3-element Vector{Int64}:
 -3
 -2
 -1
```

Without the dot, we get an error since we cannot subtract a number from a vector.

```jldoctest broadcasting
julia> a -= 1
ERROR: MethodError: no method matching -(::Vector{Int64}, ::Int64)
For element-wise subtraction, use broadcasting with dot syntax: array .- scalar
[...]
```

The same syntax can be applied to any function in Julia. It is beneficial for basic operations. For example, we can compute the absolute value of all elements by

```jldoctest broadcasting
julia> abs.(a)
3-element Vector{Int64}:
 3
 2
 1
```

With broadcasting, it is effortless to compute complex mathematical formulas. For example, if we want to evaluate the following formulas:

```math
\sum_{i = 1}^{3} \frac{\exp\{\sqrt{|a_{i} - 1|}\}}{2}
```

we can use the following code

```jldoctest broadcasting
julia> sum(exp.(sqrt.(abs.(a .- 1)))./2)
8.577270075873834
```

Broadcasting can also be used for matrix multiplication. Consider the following two vectors.

```jldoctest broadcasting
julia> a = [1,2,3] # column vector
3-element Vector{Int64}:
 1
 2
 3

julia> b = [4,5,6] # column vector
3-element Vector{Int64}:
 4
 5
 6
```

Since we have two column vectors, the matrix multiplication will not work.

```jldoctest broadcasting
julia> a * b
ERROR: MethodError: no method matching *(::Vector{Int64}, ::Vector{Int64})
[...]
```

It makes perfect sense from a mathematical perspective, and the `*` operator behaves how we would mathematically expect. If we want to use matrix multiplication, we have to transpose one of the vectors.

```jldoctest broadcasting
julia> a' * b
32

julia> a * b'
3×3 Matrix{Int64}:
  4   5   6
  8  10  12
 12  15  18
```

Nonetheless, it is often useful to write operations in an element-wise manner in programming. In such cases, broadcasting is helpful.

```jldoctest broadcasting
julia> a .* b
3-element Vector{Int64}:
  4
 10
 18
```

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body">
```

Construct a matrix whose elements are given by the following formula

```math
A_{i, j} = \frac{1}{2}\exp\{(B_{i, j} + 1)^2\}, \quad i \in \{1, 2\}, \; j \in  \{1, 2, 3\}
```

where the matrix `B` is defined by

```jldoctest broadcasting_ex; output=false
B = [
    -1  0  2;
    2  -3  1;
]

# output
2×3 Matrix{Int64}:
 -1   0  2
  2  -3  1
```

```@raw html
</div></div>
<details class = "admonition is-category-solution">
<summary class = "admonition-header">Solution:</summary>
<div class = "admonition-body">
```

Each element of the matrix `A` depends on only one element of the matrix `B`. In other words, matrix `A` can be created in an element-wise manner from matrix `B`, i.e. we can use broadcasting.

```jldoctest broadcasting_ex
julia> A = exp.((B .+ 1) .^ 2) ./ 2
2×3 Matrix{Float64}:
    0.5    1.35914  4051.54
 4051.54  27.2991     27.2991
```

We use a dot before each operation since we want to perform all operations element-wise. In this case, we can use the `@.` macro, which automatically adds a dot before each operator and each function.

```jldoctest broadcasting_ex
julia> A = @. exp((B + 1) ^ 2) / 2
2×3 Matrix{Float64}:
    0.5    1.35914  4051.54
 4051.54  27.2991     27.2991
```

Just for the comparison, the same matrix can be created as follows using [`for` loop](@ref for-and-while-loops).

```jldoctest broadcasting_ex
julia> A = zeros(2, 3);

julia> for i in 1:length(A)
           A[i] = exp((B[i] + 1)^2)/2
       end

julia> A
2×3 Matrix{Float64}:
    0.5    1.35914  4051.54
 4051.54  27.2991     27.2991
```

```@raw html
</div></details>
```

## Views

As in other programming languages, arrays are pointers to memory location. Thus we need to pay attention to how we handle them. If we create an array `A` and assign it to a variable `B`, the original array elements can be modified by changing `B`.

```jldoctest views
julia> A = [1 2 3; 4 5 6]
2×3 Matrix{Int64}:
 1  2  3
 4  5  6

julia> B = A
2×3 Matrix{Int64}:
 1  2  3
 4  5  6

julia> B[2] = 42
42
```

We can check that both arrays are equal even though we modified only array `B`.

```jldoctest views
julia> A == B
true
```

The reason is that Julia, by default, does not create a copy of an array when assigning to a variable. This behavior is advantageous because it saves memory. However, it also may have undesirable effects. If we want to make a copy of an array, we have to use the `copy` function.

```jldoctest views
julia> C = copy(A)
2×3 Matrix{Int64}:
  1  2  3
 42  5  6

julia> C[4] = 10
10

julia> A == C
false
```

Different behaviour occurs when accessing elements. Every time we access multiple array elements at once, a new array is created.

```jldoctest views
julia> D = A[1:2, 1:2]
2×2 Matrix{Int64}:
  1  2
 42  5

julia> D[1] = 15
15
```

In this case, we modified array `D`, while array `A` remains unchanged.

```jldoctest views
julia> D == A[1:2, 1:2]
false
```

Even if we want to select a subarray, it may be useful to create only a link to the original array and not create a new array. This can be achieved by the `view` function or the `@view` macro.

```jldoctest views
julia> E = view(A, 1:2, 1:2)
2×2 view(::Matrix{Int64}, 1:2, 1:2) with eltype Int64:
  1  2
 42  5

julia> E = @view A[1:2, 1:2]
2×2 view(::Matrix{Int64}, 1:2, 1:2) with eltype Int64:
  1  2
 42  5

julia> E[4] = 78
78
```

If we change only the array `D`, this change is propagated to `A`.

```jldoctest views
julia> E == A[1:2, 1:2]
true
```

The function `view` creates the special type `SubArray`.

```jldoctest views
julia> typeof(E)
SubArray{Int64, 2, Matrix{Int64}, Tuple{UnitRange{Int64}, UnitRange{Int64}}, false}
```

Since `SubArray` is a subtype of `AbstractArray`, we can apply any function defined for `AbstractArray`s to `SubArray`. In other words, (almost) all functions that work for arrays will also work for subarrays.

```jldoctest views
julia> A = [1 2 3; 4 5 6]
2×3 Matrix{Int64}:
 1  2  3
 4  5  6

julia> A_view = @view A[:, :]
2×3 view(::Matrix{Int64}, :, :) with eltype Int64:
 1  2  3
 4  5  6

julia> sum(A)
21

julia> sum(A_view)
21

julia> minimum(A; dims = 1)
1×3 Matrix{Int64}:
 1  2  3

julia> minimum(A_view; dims = 1)
1×3 Matrix{Int64}:
 1  2  3
```

This means that we can use arrays and subarrays interchangeably without the necessity of changing existing code. Of course, there are some limitations, but we will talk about them later.

The `@view` macro can only be applied directly to a reference expression. We do not want to use views throughout the whole expression in many cases. In such a case, we can add the `@view` macro before each array-slicing operation.

```jldoctest views
julia> A = [1 2 3; 4 5 6];

julia> sum(exp.(sqrt.(abs.(@view(A[1, :]) .- @view(A[2, :]))))./2)
8.478350511051136
```

However, the resulting expression is long and difficult to read. To simplify this task, Julia provides the `@views` macro that converts every array-slicing operation in the given expression to return a view.

```jldoctest views
julia> @views sum(exp.(sqrt.(abs.(A[1, :] .- A[2, :])))./2)
8.478350511051136
```
