```@setup optim
using Plots

function create_anim(f, path, xlims, ylims; file_name = "", fps=15)
    xs = range(xlims...; length = 100)
    ys = range(ylims...; length = 100)
    plt = contourf(xs, ys, f, color = :jet, axis = false, ticks = false, cbar = false)

    # adds an empty plot to plt
    plot!(Float64[], Float64[]; line = (4, :black), label = "")
    
    # extracts last plot series
    plt_path = plt.series_list[end]
    
    # creates the  animation
    anim = Animation()
    for x in eachcol(path)
        push!(plt_path, x[1], x[2]) # add new point to plt_grad
        frame(anim)
    end
    gif(anim, file_name, fps = fps)
    return nothing
end

f(x) = sin(x[1] + x[2]) + cos(x[1])^2
g(x) = [cos(x[1] + x[2]) - 2*cos(x[1])*sin(x[1]); cos(x[1] + x[2])]

f(x1,x2) = f([x1;x2])
```


# [Constrained optimization](@id lagrangian)

The usual formulation of constrained optimization is
```math
\tag{P}
\begin{aligned}
\text{minimize}\qquad &f(x) \\
\text{subject to}\qquad &g_i(x) \le 0,\ i=1,\dots,I, \\
&h_j(x) = 0,\ j=1,\dots,J.
\end{aligned}
```
This optimization problem is also called the primal formulation. It is closely connected with the Lagrangian
```math
L(x;\lambda,\mu) = f(x)  + \sum_{i=1}^I \lambda_i g_i(x) + \sum_{j=1}^J \mu_j h_j(x).
```
Namely, it is simple to show that the primal formulation (P) is equivalent to
```math
\operatorname*{minimize}_x\quad \operatorname*{maximize}_{\lambda\ge 0,\mu}\quad L(x;\lambda,\mu).
```
The dual problem then switches the minimization and maximization to arrive at
```math
\tag{D} \operatorname*{maximize}_{\lambda\ge 0,\mu} \quad\operatorname*{minimize}_x\quad L(x;\lambda,\mu).
```

```@raw html
<div class = "info-body">
<header class = "info-header">Linear programming</header><p>
```
The linear program
```math
\begin{aligned}
\text{minimize}\qquad &c^\top x \\
\text{subject to}\qquad &Ax=b, \\
&x\ge 0
\end{aligned}
```
is equivalent to
```math
\begin{aligned}
\text{maximize}\qquad &b^\top \mu \\
\text{subject to}\qquad &A^\top \mu\le c.
\end{aligned}
```
We can observe several things:
1. Primal and dual problems switch minimization and maximization.
2. Primal and dual problems switch variables and constraints.
```@raw html
</p></div>
```

The optimality conditions for constrained optimization take a more complex form.

```@raw html
<div class = "theorem-body">
<header class = "theorem-header">Theorem: Karush-Kuhn-Tucker conditions</header><p>
```
Let ``f``, ``g_i`` and ``h_j`` be differentiable function and let a constraint qualification hold. If ``x`` is a local minimum of the primal problem (P), then there are $\lambda\ge 0$ and $\mu$ such that
```math
    \begin{aligned}
    &\text{Optimality:} && \nabla_x L(x;\lambda,\mu) = 0, \\
    &\text{Feasibility:} && \nabla_\lambda L(x;\lambda,\mu)\le 0,\ \nabla_\mu L(x;\lambda,\mu) = 0, \\
    &\text{Complementarity:} && \lambda^\top g(x) = 0.
    \end{aligned}
```
If $f$ and $g$ are convex and $h$ is linear, then every stationary point is a global minimum of (P).
```@raw html
</p></div>
```

## Numerical method

We present only the simplest method for constraint optimization. Projected gradients 
```math
\begin{aligned}
y^{k+1} &= x^k - \alpha^k\nabla f(x^k), \\
x^{k+1} &= P_X(y^{k+1})
\end{aligned}
```
compute the gradient as for standard gradient descent, and then project the point onto the feasible set. Since the projection needs to be simple to compute, projected gradients are used for simple sets ``X`` such as boxes or balls. 

We will use projected gradients to solve
```math
\begin{aligned}
\text{minimize}\qquad &\sin(x_1 + x_2) + \cos(x_1)^2 \\
\text{subject to}\qquad &x_1, x_2\in [-1,1].
\end{aligned}
```
The implementation of projected gradients is the same as gradient descent but it needs projection function ```P``` as input. For reasons of plotting, it returns both ``x`` and ``y``.
```@example optim
function optim(f, g, P, x, α; max_iter=100)
    xs = zeros(length(x), max_iter+1)
    ys = zeros(length(x), max_iter)
    xs[:,1] = x
    for i in 1:max_iter
        ys[:,i] = xs[:,i] - α*g(xs[:,i])
        xs[:,i+1] = P(ys[:,i])
    end
    return xs, ys
end

nothing # hide
```
The projection function ```P``` computes the projection on ```[x_min, x_max]```. Since it is a box, the projection is computed componentwise:
```@example optim
P(x, x_min, x_max) = min.(max.(x, x_min), x_max)

nothing # hide
```
Now we can call projected gradients from the same starting point as before
```@example optim
x_min = [-1; -1]
x_max = [0; 0]

xs, ys = optim(f, g, x -> P(x,x_min,x_max), [0;-1], 0.1)

nothing # hide
```
To plot the path, we need to merge them together when one point from ```xs``` is followed by a point from ```ys``` and so on. Since ```xs``` and ```ys``` have different number of entries, we can do it via
```@example optim
xys = hcat(reshape([xs[:,1:end-1]; ys][:], 2, :), xs[:,end])

nothing # hide
```
It is probably not the nicest thing to do, but it is Saturday evening, I am tired and it works. Sorry :) The animation can be created in the same way aa before. 
```@example optim
xlims = (-3, 1)
ylims = (-2, 1)

create_anim(f, xys, xlims, ylims; file_name = "anim6.gif")

nothing # hide
```

![](anim6.gif)

There is one significant drawback to this animation: One cannot see the boundary. One possibility would be to reduce the plotting ranges ```xlims``` and ```ylims```. However, then one would not see the iterations outside of the box. Another possibility is to modify ```f``` into ```f_mod``` which has the same values inside the box and is constant outside of it. Because ```f``` is bounded below by ``-1``, we define ```f_mod``` by ``-2`` outside of the box. 
```@example optim
f_mod(x) = all(x .>= x_min) && all(x .<= x_max) ? f(x) : -2
f_mod(x1,x2) = f_mod([x1; x2])

create_anim(f_mod, xys, xlims, ylims; file_name = "anim7.gif")

nothing # hide
```

![](anim7.gif)

The animation shows that projected gradients converge to the global minimum. Most of the iterations are outside of the feasible region but they are projected back to boundary. 
