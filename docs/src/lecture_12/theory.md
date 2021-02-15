```@setup optim
using Plots
```

# Differential equations

Differential equations describe many natural phenomena. The Newton's law of motion
```math
F = \frac{\partial}{\partial t}mv
```
is a simple but extremely important example of an ordinary differential equation. Besides applications in physics and engineering, differential equations appear in almost any (smoothly) evolving system. Examples include economics (Black-Scholes formula) or biology (population growth). There are whole fields dedicated to solving a single equation such as the wave or heat equations. The basic distinction is:
- *Ordinary differential equations* (ODEs) depend only on time.
- *Partial differential equations* (PDEs) depend both on time and space. The spacial variable is usually 1D, 2D or 3D.
There are many extensions; let us name systems of differential equations, stochastic differential equations, differential algebraic equations (system of differential and non-differential equations) and others.

## Ordinary differential equations

Oridnary differential equations take form
```math
\dot y(t) = f(t, y(t))
```
on some interval ``t\in [0,T]``. To obtain a correct definition, the initial value ``y(0)=y_0`` needs to be provided. A solution is a (sufficiently smooth) function ``y(t)`` such that the above formula is satisfied (almost) everywhere on ``[0,T]``. The existence and uniqueness is ensured by mild conditions.

```@raw html
<div class = "theorem-body">
<header class = "theorem-header">Picard–Lindelöf theorem</header><p>
```
Suppose ``f`` is uniformly Lipschitz continuous in ``y`` (the Lipschitz constant is independent of ``t``) and continuous in ``t``. Then for some value ``\varepsilon > 0``, there exists a unique solution ``y(t)`` to the initial value problem on the interval ``[t_0-\varepsilon, t_0+\varepsilon]``.
```@raw html
</p></div>
```
However, it may happen than even simple equations do not have a unique solution.

```@raw html
<div class = "info-body">
<header class = "info-header">Uniqueness</header><p>
```
The uniqueness of solution is not guaranteed even for simple equations. Equation
```math
\begin{aligned}
\dot y(t) &= y^{\frac 23}(t), \\
y(0) &= 0
\end{aligned}
```
has at least two solution: ``y_1(t)=0`` and ``y_2(t)=(\frac t3)^3``. This is possible because the right-hand side of the ODE has an infinite derivative at zero and the Lipschitz continuity assumption of the Picard–Lindelöf theorem is not satisfied.
```@raw html
</p></div>
```

The theory of partial differential equations is complicated because they employ a special definition of derivative (weak derivative) and the solution is defined on special spaces (Sobolev spaces). It may happen that a function has (weak) derivative but it is not continuous.

## Linear ODE

Linear ordinary equations
```math
\dot y(t) = Ay(t) + b(t)
```
form an important subclass of differential equations. They admit a "closed-form" solution. This closed form employs the matrix exponential defined by
```math
e^{A} = \sum_{k=0}^{\infty} \frac{A^k}{k!},
```
where ``A^k`` is the standard multiplication of matrices. This is a generalization from scalars to matrices and has similar properties. For example, the derivative of the matrix exponential is the same object due to
```math
\frac{\partial}{\partial A}e^{A} = \sum_{k=0}^{\infty} A\frac{A^{k-1}}{k!} = \sum_{k=0}^{\infty} \frac{A^k}{k!} = e^{A}.
```
Then the solution of the linear equation above equals to
```math
y(t) = e^{At}\left(y_0 + \int_0^t e^{-As}b(s)ds\right).
```
Indeed, the derivative of the previous term equals to
```math
\dot y(t) = Ae^{At}\left(y_0 + \int_0^t e^{-As}b(s)ds\right) + e^{At}e^{-At}b(t) = Ay(t) + b(t)
```
because ``e^{At}e^{-At}`` is the identity matrix (similarly to ``e^xe^{-x}=1``). The matrix exponential can be computed using matrix decompositions.

## Matrix decompositions

There are many matrix decompositions. They are closely related to finding eigenvalues and eigenvectors. We mention only two basic decompositions.

#### Cholesky decomposition

For a real positive semidefinite matrix ``A``, its Cholesky decomposition always exists and reads
```math
A = LL^\top,
```
where ``L`` is a real lower triangular matrix (zeros above the diagonal). This matrix is easily invertible and the decomposition is used in iterative algorithms where the matrix inversion needs to be computed many times.

#### Eigenvalue decomposition

For a square matrix ``A`` of size ``n\times n``, we assume that there are ``n`` linearly independent eigenvectors (matrices which do not satisfy this are called defective). Then the eigendecomposition equals to
```math
A = Q\Lambda Q^{-1},
```
where ``\Lambda`` is a diagonal matrix with eigenvalues on the diagonal and the columns of ``Q`` are orthonormal eigenvectors. This allows us to compute the matrix exponential
```math
e^A = e^{Q\Lambda Q^{-1}} = Qe^\Lambda Q^{-1}
```
as ``e^\Lambda`` is a diagonal matrix with entries
```math
(e^\Lambda)_{ij} = \begin{cases} e^{\Lambda_{ii}}&\text{if }i=j \\ 0&\text{otherwise}\end{cases}.
```
This allows to compute the closed-form solution of the linear ODEs.