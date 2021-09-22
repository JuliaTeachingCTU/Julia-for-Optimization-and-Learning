# Differential equations

Differential equations describe many natural phenomena. Newton's law of motion

```math
F = \frac{\partial}{\partial t}mv
```

is a simple but important example of an ordinary differential equation. Besides applications in physics and engineering, differential equations appear in almost any (smoothly) evolving system. Examples include economics (Black-Scholes formula) or biology (population growth). There are whole fields dedicated to solving a single equation, such as the wave or heat equations. The basic distinction is:
- *Ordinary differential equations* (ODEs) depend only on time.
- *Partial differential equations* (PDEs) depend on space and may depend on time. The spatial variable is usually 1D, 2D or 3D.
There are many extensions; let us name systems of differential equations, stochastic differential equations or differential algebraic equations (system of differential and non-differential equations).

## Ordinary differential equations

Ordinary differential equations take the form

```math
\dot y(t) = f(t, y(t))
```

on some interval ``t\in [0,T]``. To obtain a correct definition, the initial value ``y(0)=y_0`` needs to be provided. A solution is a (sufficiently smooth) function ``y(t)`` such that the above formula is satisfied (almost) everywhere on ``[0,T]``. Mild conditions ensure its existence and uniqueness.

```@raw html
<div class="admonition is-category-theorem">
<header class="admonition-header">Picard–Lindelöf theorem</header>
<div class="admonition-body">
```

Suppose ``f`` is uniformly Lipschitz continuous in ``y`` (the Lipschitz constant is independent of ``t``) and continuous in ``t``. Then for some value ``\varepsilon > 0``, there exists a unique solution ``y(t)`` to the initial value problem on the interval ``[t_0-\varepsilon, t_0+\varepsilon]``.

```@raw html
</div></div>
```

However, it may happen that even simple equations do not have a unique solution.

!!! info "Uniqueness:"
    The uniqueness of solution is not guaranteed even for simple equations. Equation
    ```math
    \begin{aligned}
    \dot y(t) &= y^{\frac 23}(t), \\
    y(0) &= 0
    \end{aligned}
    ```
    has at least two solution: ``y_1(t)=0`` and ``y_2(t)=(\frac t3)^3``. This is possible because the right-hand side of the ODE has an infinite derivative at zero, and the Lipschitz continuity assumption of the Picard–Lindelöf theorem is not satisfied.

The theory of partial differential equations is complicated because they employ a special definition of derivative (weak derivative), and the solution is defined on special spaces (Sobolev spaces).

## Linear ordinary differential equations

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
\frac{\partial}{\partial A}e^{A} = \sum_{k=1}^{\infty} \frac{kA^{k-1}}{k!} = \sum_{k=1}^{\infty} \frac{A^{k-1}}{(k-1)!} = e^{A}.
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

!!! info "Matrix decompositions in solving linear ODEs"
    The [lecture on statistics](@ref matrix-eigen) showed the eigendecomposition for square matrices ``A\in\mathbb R^{n\times n}``. The eigendecomposition

    ```math
    A = Q\Lambda Q^{-1}
    ```

    exists whenever ``A`` has ``n`` eigenvalues, which may even be even complex. Then the matrix exponential equals to

    ```math
    e^{At} = e^{Q(\Lambda t) Q^{-1}} = Qe^{\Lambda t} Q^{-1}.
    ```

    Because ``\Lambda`` is a diagonal matrix, its exponential equals to a diagonal matrix with entries

    ```math
    (e^{\Lambda t})_{ij} = \begin{cases} e^{\Lambda_{ii} t}&\text{if }i=j, \\ 0&\text{otherwise.}\end{cases}
    ```

    Since we need to compute the matrix exponential multiple times, similarly to [LASSO](@ref lasso), using the eigendecomposition saves computational times.
