## Statistics

Multiple standard packages are shipped together with Julia's release. Those packages are not loaded by default in the new Julia session and need to be load manually.

The first package we mention is the `Statistics` package, which provides fundamental statistic related functions such as functions for computing mean, variance, or standard deviation

```@repl
using Statistics
x = rand(10);
mean(x)
var(x)
std(x)
```

See official [documentation](https://docs.julialang.org/en/v1/stdlib/Statistics/) for more information. More statistics-related functions can be found in [StatsBase](https://juliastats.org/StatsBase.jl/stable/) package. This package provides functions for computing scalar statistics, high-order moment computation, counting, ranking, covariances, sampling, and empirical density estimation.

## LinearAlgebra

Another package that should be mentioned is the [LinearAlgebra](https://docs.julialang.org/en/v1/stdlib/LinearAlgebra/) package, which provides a native implementation of many common and useful linear algebra operations. The package provides functions for computing matrix determinant, inversion, norm or eigenvalues, and eigenvectors

```@repl lingebra
using LinearAlgebra
A = [-4.0 -17.0; 2.0 2.0]

det(A)
inv(A)
norm(A)
eigvals(A)
eigvecs(A)
```

The package also provides an implementation of multiple matrix types that represent matrices with special symmetries and structures. As an example, we can mention `Symmetric`, `Hermitian` or `Diagonal` matrices. These special matrix types allow for fast computation using specialized algorithms developed for particular matrix types. Matrices of these types can be constructed via their constructors. For example, a diagonal matrix can be created as follows

```@repl lingebra
D = Diagonal([1,2,3])
```

Another handy function provided by the package is the identity operator `I` representing the identity matrix. The identity operator `I` is defined as a constant and is an instance of `UniformScaling`. The size of this operator is generic and match the other matrix in the binary operations `+`, `-`, `*` and `\`

```@repl lingebra
D + I
D - I
```

Note that for `D+I` and `D-I`, the matrix `D` must be square.

## Random

The last package that we will describe in more detail is the [Random](https://docs.julialang.org/en/v1/stdlib/Random/) package. This package provides more functionality for generating random numbers in Julia. The package allows setting the seed for the random generator using the `seed!` function. The `seed!` function can be used to create a reproducible code  that contains randomly generated values

```@repl rand
using Random
using Random: seed!

seed!(1234);
rand(2)
seed!(1234);
rand(2)
```

The package also other handy functions. For example, the `randperm` function constructs a random permutation of the given length

```@repl rand
randperm(4)
```

or the `shuffle` function that returns a randomly permuted copy of the given array
```@repl rand
v = [1,2,3,4]
shuffle(v)
```

```@raw html
<div class = "info-body">
<header class = "info-header">Other useful standard packages</header><p>
```

There are other useful standard packages in Julia, but there is not enough space to present them all. So we provide at least a list of the most important
- `Test`: provides simple unit testing functionality. Unit testing is a way to see if your code is correct by checking that the results are what you expect. It can help to ensure your code still works after you make changes. Unit tests can also be used when developing as a way of specifying the behaviors your code should have when complete
- `SparseArrays`: provides special types to store and work with sparse arrays.
- `Distributed`: provides support for distributed computing.

See section Standard Library in the official [documentation](https://docs.julialang.org/en/v1/) for more information.

```@raw html
</p></div>
```
