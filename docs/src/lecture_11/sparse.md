# Linear regression with sparse constraints

The standard regression problem reads

```math
\operatorname{minimize}_w\qquad \sum_{i=1}^n(w^\top x_i - y_i)^2.
```

Often, a regularization term is added. There are two possibilities. The [ridge regression](https://en.wikipedia.org/wiki/Ridge_regression) adds the weighted squared ``l_2``-norm penalization term to the objective:

```math
\operatorname{minimize}_w\qquad \sum_{i=1}^n(w^\top x_i - y_i)^2 + \frac{\mu}{2}\|w\|_2^2.
```

[LASSO](https://en.wikipedia.org/wiki/Lasso_(statistics)) adds the weighted ``l_1``-norm penalization term to the objective:

```math
\operatorname{minimize}_w\qquad \sum_{i=1}^n(w^\top x_i - y_i)^2 + \mu \|w|\|_1.
```

Both approaches try to keep the norm of parameters ``w`` small to prevent overfitting. The first approach results in a simpler numerical method, while the second one induces sparsity. Before we start with both topics, we will briefly mention matrix decompositions which plays a crucial part in numerical computations.


## Theory of matrix eigendecomposition


Consider a square matrix ``A\in \mathbb R^{n\times n}`` with real-valued entries. We there exist ``\lambda\in\mathbb R`` and ``v\in\mathbb^n`` such that

```math
Av = \lambda b,
```

we say that ``\lambda`` is a eigenvalue of ``A`` and ``v`` is the corresponding eigenvector.

For the rest of this section, we will assume that ``A`` is a symmetric matrix. Then these eigenvector are perpendicular to each other. We create the diagonal matrix ``\Lambda`` with eigenvalues on diagonal and the matrix ``Q`` with columns consisting of the corresponding eigenvectors. Then we have

```math
A = Q\Lambda Q^\top
```

and for any real number ``\mu``, we also have

```math
A + \mu I = Q(\Lambda + \mu I) Q^\top
```

Since the eigenvectors are perpendicular, ``Q`` is an orthonormal matrix and therefore ``Q^{-1} = Q^\top``. This implies that we can easily invert the matrix ``A + \mu I`` by

```math
(A + \mu I)^{-1} = Q^\top (\Lambda + \mu I)^{-1} Q.
```

Because ``\Lambda + \mu I`` is a diagonal matrix, its inverse is simple to compute.



## Theory of ridge regression


The optimality condition for the ridge regression reads

```math
X^\top (Xw - y) + \mu w = 0.
```

Therefore, the optimal solution satisfies

```math
w = (X^\top X + \mu I)^{-1}X^\top y.
```

For ``\mu=0``, we obtain the classical result for the linear regression. Since ``X^\top X`` is symmetric, we can compute its eigendecomposition

```math
X^\top X = Q\Lambda Q^\top.
```

Then the formula for optimal weights simplifies into 

```math
w = Q^\top (\Lambda+\mu I)^{-1} QX^\top y.
```

Since this formula uses only matrix-vector multiplication and an inversion of a diagonal matrix, we can employ it to fast compute the solution for multiple values of ``\mu``.



## Theory of LASSO


Unlike ridge regression, LASSO does not have a closed-form solution. Since it is a structured convex problem, it can be solved the [ADMM algorithm](https://web.stanford.edu/~boyd/papers/pdf/admm_distr_stats.pdf). It is a primal-dual algorithm, which employs the primal original variable ``w``, the primal auxiliary variable ``z`` and the dual variable ``u`` with the iterative updates:

```math
\begin{aligned}
w^{k+1} &= (X^\top X + \rho I)^{-1}(X^\top y + \rho z^k - \rho u^k), \\
z^{k+1} &= S_{\mu / \rho}(w^{k+1} + u^k) \\
u^{k+1} &= u^k + w^{k+1} - z^k.
\end{aligned}
```

Here, ``\rho > 0`` is an arbitrary number and

```math
S_\eta(z) = \max\{z - \eta, 0\} - \max\{-z -\eta, 0\}
```

is the so-called soft thresholding operator. Since these updates must be performed many times, it may be a good idea to perform the same factorization of the matrix ``X^\top X + \rho I`` as in the case of ridge regression.




## Ridge regression


We will randomly generate ``10000`` samples in ``\mathbb R^{1000}``.

```@example sparse
using LinearAlgebra
using Random
using Plots

n = 10000
m = 1000

Random.seed!(666)
X = randn(n, m)

nothing # hide
```

The real dependence depends only on the first two features and reads

```math
y = 10x_1 + x_2.
```

This is a natural problem for sparse models because most of the weights should be zero. We generate the labels but add noise to them.

```@example sparse
y = 10*X[:,1] + X[:,2] + randn(n)

nothing # hide
```











The first exercise compares both approaches to solving the ridge regression.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Implement the methods for the `ridge_reg` function. Verify that the result in the same result.

**Hint**: The eigendecomposition can be found by `eigen(A)` or `eigen(A).values`.

**Hint**: The identity matrix is implemented by `I` in the `LinearAlgebra` package.

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The simple implementation for the solution is the same as in the case of linear regression. We only need to add `μ*I`.

```@example sparse
ridge_reg(X, y, μ) = (X'*X + μ*I) \ (X'*y)

nothing # hide
```

We first compute the eigendecomposition and save it into `eigen_dec`. Then we extract the eigenvector and eigenvalues. We also transpose the matrix ``Q`` and save it into `Q_inv` so that we do not have to compute it repeatedly.

```@example sparse
eigen_dec = eigen(X'*X)
Q = eigen_dec.vectors
Q_inv = Matrix(Q')
λ = eigen_dec.values

nothing # hide
```

The more sophisticated way of solving the ridge regression contains only matrix-vector multiplication and the inversion of the diagonal matrix ``(\Lambda + \mu I)^{-1}``. We need to properly add paranthesis, to start multiplication from the right and evade matrix-matrix multiplication, which would occur if we started from the left. Since the matrix ``\Lambda + \mu I`` is diagonal, its inverse is the digonal matrix formed from the inverted diagonal.

```@example sparse
ridge_reg(X, y, μ, Q, Q_inv, λ) = Q * ((Diagonal(1 ./ (λ .+ μ)) * ( Q_inv * (X'*y))))

nothing # hide
```

When we compare both solution, we see that they are the same.

```@example sparse
w1 = ridge_reg(X, y, 10)
w2 = ridge_reg(X, y, 10, Q, Q_inv, λ)

norm(w1 - w2)
```

```@raw html
</p></details>
```














To test the speed, we use the `BenchmarkTools` package. The second option is significantly faster. The price to pay is the need to pre-compute the matrix decomposition.

```julia
julia> using BenchmarkTools

julia> @time ridge_reg(X, y, 10);
  0.204391 seconds (9 allocations: 22.912 MiB)

julia> @btime ridge_reg(X, y, 10, Q, Q_inv, λ);
  6.251 ms (5 allocations: 39.69 KiB)
```

Now we create multiple values of ``\mu`` and compute the ridge regression for all of them. Since the broadcasting would broadcast all matrices, we need to fix all but one by the `Ref` command.

```@example sparse
μs = range(0, 1000; length=50)

ws = hcat(ridge_reg.(Ref(X), Ref(y), μs, Ref(Q), Ref(Q_inv), Ref(λ))...)

plot(μs, abs.(ws');
    label="",
    yscale=:log10,
    xlabel="mu",
    ylabel="weights: log scale",
)

savefig("Sparse1.svg") # hide
```

![](Sparse1.svg)

The regularization seems to have a small effect on the solution.


## Lasso

For LASSO, we define the soft thresholding operator.

```@example sparse
S(x, η) = max(x-η, 0) - max(-x-η, 0)

nothing # hide
```

Then we define the iterative updates from ADMM. It is important that we allow to insert the initial values for ``w^0``, ``z^0`` and ``u^0``. If they are not provided, they are initialized by zeros with the correct dimension. We should implement a proper termination condition but, for simplicity, we run ADMM for a fixed number of iterations.

```@example sparse
function lasso(X, y, μ, Q, Q_inv, λ;        
        max_iter = 100,
        ρ = 1e3,
        w = zeros(size(X,2)),
        u = zeros(size(X,2)),
        z = zeros(size(X,2)),
    )
    
    for i in 1:max_iter
        w = Q * ( (Diagonal(1 ./ (λ .+ ρ)) * ( Q_inv * (X'*y + ρ*(z-u))))) 
        z = S.(w + u, μ / ρ)
        u = u + w - z
    end
    return w, u, z  
end

nothing # hide
```

Finally, we compute the values for all regularization parameters ``\mu``. The second line in the loop says that if ``i=1``, then run LASSO without the initial values, and if ``i>1``, then run it with the initial values from the previous iteration. SInce the visibility of `w`, `u` and `z` is only one iteration, we need to specify that they are global variables.

```@example sparse
ws = zeros(size(X,2), length(μs))

for (i, μ) in enumerate(μs)
    global w, u, z
    w, u, z = i > 1 ? lasso(X, y, μ, Q, Q_inv, λ; w, u, z) : lasso(X, y, μ, Q, Q_inv, λ)
    ws[:,i] = w
end
```

When we plot the parameter values, we see that they are significantly smaller than for the ridge regression. This is precisely what we meant when we mentioned that ``l_1``-norm regularization induces sparsity. 


```@example sparse
plot(μs, abs.(ws');
    label="",
    yscale=:log10,
    xlabel="mu",
    ylabel="weights: log scale",
)
```

```@raw html
<div class = "info-body">
<header class = "info-header">Warm start</header><p>
```

The technique of starting from a previously computed value is called warm start or hor start. It is commonly used when some parameter changes only slightly. Then the solution changes only slightly and the previous solution provides is close to the new solution. Therefore, we initialize the algorithm from the old solution.

```@raw html
</p></div>
```

