# Useful packages

Julia provides a large package library. To add a package, we enter the package REPL by pressing `]` and install a package by the keyword `add`.
```julia
(@v1.5) pkg> add Plots
```
Another option is to use the `Pkg` package to add it directly from the standard REPL.
```julia
julia> using Pkg

julia> Pkg.add("Plots")
```
We return from the package REPL `(@v1.5) pkg>` to the standard REPL `julia>` by pressing escape.

Multiple standard packages are shipped together with Julia. These packages do not need to be installed. They include `Pkg` and all packages introduced on this page. However, we still need to load them to use them.
```julia
julia> using Statistics
```

## Statistics

The first package we mention is the `Statistics` package, which provides statistical analysis functions such as computation of mean, variance, or standard deviation.

```@repl
using Statistics
x = rand(10);
mean(x)
var(x)
std(x)
```

See the official [documentation](https://docs.julialang.org/en/v1/stdlib/Statistics/) for more information. More statistics-related functions can be found in the [StatsBase](https://juliastats.org/StatsBase.jl/stable/) package. This package provides functions for computing scalar statistics, high-order moment computation, counting, ranking, covariances, sampling, and empirical density estimation. This course dedicates one lecture to [statisctics](@ref statistics).


## LinearAlgebra

Another package worth mentioning is the [LinearAlgebra](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/) package, which provides a native implementation of many linear algebra operations. The package provides functions for computing matrix determinant, inversion, norm, eigenvalues, or eigenvectors.

```@repl lingebra
using LinearAlgebra
A = [-4.0 -17.0; 2.0 2.0]

det(A)
inv(A)
norm(A)
eigvals(A)
eigvecs(A)
```

The package also provides implementation of multiple matrix types that represent matrices with special symmetries and structures. As examples, we mention `Symmetric`, `Hermitian` or `Diagonal` matrices. These particular matrix types allow for fast computation due to using specialized algorithms. Matrices of these types can be constructed via their constructors.

```@repl lingebra
D = Diagonal([1,2,3])
```

Another useful function provided by the package is the identity operator `I` representing the identity matrix. The identity operator `I` is defined as a constant and is an instance of `UniformScaling`. The size of this operator is generic and match the other matrix in the binary operations `+`, `-`, `*` and `\`.

```@repl lingebra
D + I
D - I
```

Note that for `D+I` and `D-I`, the matrix `D` must be square.

## Random

The last package that we will describe in more detail is the [Random](https://docs.julialang.org/en/v1/stdlib/Random/) package. This package provides advanced functionality for generating random numbers in Julia. The package allows setting the seed for the random generator using the `seed!` function. The `seed!` function is used to create a reproducible code that contains randomly generated values.

```@repl rand
using Random
using Random: seed!

seed!(1234);
rand(2)
seed!(1234);
rand(2)
```

The `randperm` function constructs a random permutation of a given length.

```@repl rand
randperm(4)
```

The `shuffle` function returns a randomly permuted copy of a given array.

```@repl rand
v = [1,2,3,4]
shuffle(v)
```

```@raw html
<div class = "info-body">
<header class = "info-header">Other useful standard packages</header><p>
```

There are other useful standard packages in Julia, but there is not enough space to present them all.
- `Test` provides simple unit testing functionality. Unit testing is a process to determine if your code is correct by checking that the results are what you expect. It helps to ensure the code works after changes. Unit tests can also be used during the development phase to specify the expected behaviour when implemented. We will provide more details [later](@ref unit-testing).
- `SparseArrays` provides special types to store and work with sparse arrays.
- `Distributed` includes support for distributed computing.

The section Standard Library in the official [documentation](https://docs.julialang.org/en/v1/) provides more information.

```@raw html
</p></div>
```
