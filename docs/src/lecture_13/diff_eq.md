# Julia package

To solve differential equations, we use the package [DifferentialEquations](https://diffeq.sciml.ai/stable/), which consider ODEs in the form

```math
\dot u(t) = f(t, u(t), p(t))
```

with the initial condition ``u(t_0)= u_0``. While ``u`` is the solution, ``p`` describes external parameters.

## Introduction

We start with the following simple problem:

```math
\begin{aligned}
\dot u(t) &= 0.98u, \\
u(0) &= 1.
\end{aligned}
```

This equation has the closed-form solution ``u(t) = e^{0.98t}``. To solve it by `DifferentialEquations`, we first need to create the problem `prob` by supplying the function ``f``, the initial point ``u_0`` and the time interval ``[t_0,t_1]`` to the constructor `ODEProblem`.

```@example intro
using DifferentialEquations

f(u,p,t) = 0.98*u

u0 = 1.0
tspan = (0.0, 1.0)

prob = ODEProblem(f, u0, tspan)

nothing # hide
```

Then we use the `solve` function to solve the equation.

```@example intro
sol = solve(prob)
```

The first line says that the solution was successful, which can be automatically checked by accessing the field `sol.retcode`. The second line specifies the interpolation method, and the following lines the solution. Even though the solution was evaluated at only five points, the interpolation allows plotting a smooth function.

```@example intro
using Plots

plot(sol; label="")

savefig("intro.svg") # hide
```

![](intro.svg)

The `sol` structure can be used to evaluate the solution ``u``.

```@example intro
sol(0.8)
```

The following exercise shows how to specify the interpolation technique and compares the results.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body">
```

When calling the `solve` function, we can specify the interpolation way. Solve the ODE with linear interpolation (`dense=false`) and the Runge-Kutta method of the fourth order (`RK4()`). Plot the results and compare them with the default and original solutions.

```@raw html
</div></div>
<details class = "admonition is-category-solution">
<summary class = "admonition-header">Solution:</summary>
<div class = "admonition-body">
```

To compute the additional solutions, we add the arguments as specified above.

```@example intro
sol2 = solve(prob, dense=false)
sol3 = solve(prob, RK4())

nothing # hide
```

We create a discretization ```ts``` of the time interval and then plot the four functions.

```@example intro
ts = range(tspan...; length = 100)

plot(ts, t->exp(0.98*t), label="True solution", legend=:topleft)
plot!(ts, t->sol(t), label="Default")
plot!(ts, t->sol2(t), label="Linear")
plot!(ts, t->sol3(t), label="Runge-Kutta")

savefig("Comparison.svg") # hide
```
```@raw html
</div></details>
```

![](Comparison.svg)

We see that all solutions are the same except for the linear approximation.

## Lorenz system

The [Lorenz system](https://en.wikipedia.org/wiki/Lorenz_system) is a prime example of the [butterfly effect](https://en.wikipedia.org/wiki/Butterfly_effect) in the chaos theory. There, small changes in the initial conditions result in large changes in the solution. This effect was first described in 1961 during work on weather modelling.

The following equations describe the three-dimensional Lorenz system:

```math
\begin{aligned}
\frac{\partial x}{\partial t} &= \sigma (y - x), \\
\frac{\partial y}{\partial t} &= x (\rho - z) - y, \\
\frac{\partial z}{\partial t} &= x y - \beta z.
\end{aligned}
```

We first define the right-hand side of the system.

```@example intro
function lorenz(u, p, t)
    σ, ρ, β = p
    x_t = σ*(u[2]-u[1])
    y_t = u[1]*(ρ-u[3]) - u[2]
    z_t = u[1]*u[2] - β*u[3]
    return [x_t; y_t; z_t]
end

nothing # hide
```

The parameters are saved in a tuple or array `p`. Since the right-hand side of the Lorenz system is a vector, we need to return a vector as well. Now, we compute the solution in the same way as before.

```@example intro
u0 = [1.0; 0.0; 0.0]
p = [10; 28; 8/3] 

tspan = (0.0, 100.0)
prob = ODEProblem(lorenz, u0, tspan, p)

sol = solve(prob)

nothing # hide
```

We plot the solution:

```@example intro
plot(sol)

savefig("lorenz0.svg") # hide
```

![](lorenz0.svg)

Since this is a two-dimensional graph of all coordinates, we need to specify that we want to plot a 3D graph.

```@example intro
plt1 = plot(sol, vars=(1,2,3), label="")

savefig("lorenz1.svg") # hide
```

![](lorenz1.svg)

We see the power of interpolation again. If we used linear interpolation, which amounts to connecting the points, we would obtain a much coarse graph.

```@example intro
plot(sol, vars=(1,2,3), denseplot=false; label="")

savefig("lorenz2.svg") # hide
```

![](lorenz2.svg)

This graph shows the strength of the `DifferentialEquations` package. With a small computational effort, it can compute a good solution. Note that the last plotting call is equivalent to:

```julia
traj = hcat(sol.u...)
plot(traj[1,:], traj[2,:], traj[3,:]; label="")
```

In the introduction, we mentioned chaos theory. We will elaborate on this in the following exercise.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body">
```

Use the `nextfloat` function to perturb the first parameter of `p` by the smallest possible value. Then solve the Lorenz system again and compare the results by plotting the two trajectories next to each other.

```@raw html
</div></div>
<details class = "admonition is-category-solution">
<summary class = "admonition-header">Solution:</summary>
<div class = "admonition-body">
```

We start with the smallest possible perturbation of the initial value.

```@example intro
p0 = (nextfloat(p[1]), p[2:end]...) 
```

Then we plot the graphs as before

```@example intro
prob0 = ODEProblem(lorenz, u0, tspan, p0)
sol0 = solve(prob0)

plt0 = plot(sol0, vars=(1,2,3), label="")

plot(plt1, plt0; layout=(1,2))

savefig("lorenz4.svg") # hide
```

```@raw html
</div></details>
```

![](lorenz4.svg)

The solutions look different. Comparing the terminal states of both solutions

```@example intro
hcat(sol(tspan[2]), sol0(tspan[2]))
```

shows that they are different by a large margin. This raises a natural question.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise:</header>
<div class="admonition-body">
```

Can we trust the solutions? Why?

```@raw html
</div></div>
<details class = "admonition is-category-solution">
<summary class = "admonition-header">Solution:</summary>
<div class = "admonition-body">
```

Unfortunately, we cannot. Numerical methods always introduce some errors by
- *Rounding errors* due to representing real numbers in machine precision.
- *Discretization errors* for continuous systems when the finite difference method approximates the derivative.
However, if the system itself is unstable and an extremely small perturbation results in big differences in solutions, the numerical method even enhances these errors. The solution could be trusted on some small interval but not after it.

```@raw html
</div></details>
```

The following section shows a situation where we try to mitigate this possible effect by using mathematical formulas to compute the exact solution as long as possible. This aproach delays the necessary discretization and may bring better stability.
