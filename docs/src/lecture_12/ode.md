
prevedeni PDE (v 1D) na ODE. pro 2D uz to takto jednoduse nejde (pokud neni ctverova mesh)


## Wave equation


The wave equation on ``t\in[0,T]`` has the form
```math
\frac{\partial^2 y(t,x)}{\partial t^2} = c^2 \frac{\partial^2 y(t,x)}{\partial x^2}.
```
To obtain a complete formulation, we need to add boundary (in space) and initial (in time) conditions. For a one-dimensional case (such as a string) on the interval ``[0,L]``. Assuming that the string is fixed on its edges, the boundary conditions
```math
y(\cdot,0) = y_0, \quad y(\cdot,L) = y_L
```
are not time-dependant. The initial conditions are prescribed by functions
```math
\begin{aligned}
y(0,\cdot) &= f(\cdot), \\
\frac{\partial y(0,\cdot)}{\partial t} &= g(\cdot),
\end{aligned}
```
which vary in space. For consistency, we need ``f(0)=y_0`` and ``f(L)=y_L``.

The following few exercises show how to solve the wave equation via the [finite differences](@ref comp-grad) technique.


```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Design a numerical method to solve the one-dimensional wave equation on ``[0,T]\times [0,L]`` by applying finite differences in time and space. Derive the formulas.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
To discretize, we need to choose stepsizes ``\Delta t`` and ``\Delta x``. For simplicity, we assume that the discretization is uniform (the length of the interval ``T`` can be divided by the time step ``\Delta t`` and similarly for ``L`` and ``\Delta x``). 

The initial conditions prescribe the value
```math
y(0,x) = f(x)
```
for all ``x\in\{0,\Delta x,2\Delta x,\dots,L\}``. For the values at ``\Delta t``, we approximate the initial condition for the derivative by the finite difference and get 
```math
y(\Delta t, x) = y(0, x) + \Delta t g(x).
```
Since the finite difference approximation of the first derivative is
```math
\frac{\partial y(t,x)}{\partial t} \approx \frac{y(t + \Delta t,x) - y(t,x)}{\Delta t},
```
the finite difference approximation of the second derivative can be obtained in the same way by
```math
\begin{aligned}
\frac{\partial^2 y(t,x)}{\partial t^2} &= \frac{1}{\Delta t}\left(\frac{y(t + \Delta t,x) - y(t,x)}{\Delta t} - \frac{y(t,x) - y(t-\Delta t,x)}{\Delta t}\right) \\
&= \frac{y(t+\Delta t,x) - 2y(t,x) + y(t-\Delta t,x)}{\Delta t^2}.
\end{aligned}
```
Doing the same discretization for ``x`` and plugging the result into the wave equation yields
```math
\frac{y(t+\Delta t,x) - 2y(t,x) + y(t-\Delta t,x)}{\Delta t^2} = c^2 \frac{y(t,x+\Delta x) - 2y(t,x) + y(t,x-\Delta x)}{\Delta x^2}.
```
The computation now is the same as for a normal ODE. We know the initial state ``y(\cdot,0)``, then we compute ``y(\cdot,\Delta t)``, then ``y(\cdot, 2\Delta t)`` and so on. These states can be computed by rearranging the previous formula to
```math
y(t + \Delta t,x) = \frac{c^2\Delta t^2}{\Delta x^2}  \Big(y(t,x + \Delta x) - 2y(t,x) + y(t,x - \Delta x)\Big) + 2y(t,x) - y(t - \Delta t,x).
```
This formula can be applied for ``t=2\Delta t, 3\Delta t, \dots,T``.
```@raw html
</p></details>
```

Before writing any code, it may be a good idea to decide on its structure. The following exercise aims to do so.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Write function declaration (function name, inputs and outputs) which will be needed to solve the wave equation and to plot the solution. Do not write any code.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
Before we can solve the wave equation, we need to perform discretization of time and space. We write the ```discretize``` function, whose inputs are the limits ```xlims```. We use optional keyword arguments, which may specify the stepsize or the number of discretized points. The output will be the discretization ```xs```. Even though we denote all inputs and outputs with ``x``, this function will be used for time as well.
```julia
function discretize(xlims; kwargs...)
    ...
    return xs
end
```
The simplest way to work with objects, which have the same fixed parameters, is to create a structure to save these parameters. We therefore create ```struct Wave``` with fields ```f```, ```g``` and ```c```. We do not use the boundary values ``y_0`` and ``y_L`` as they can be computed from ``f``.
```julia
struct Wave
    f
    g
    c
end
```
The wave equation is solved in ```solve_wave(ts, xs, wave::Wave)```. Its inputs are the time discretization ```ts```, the space discretization ```xs``` and the wave parameters stored in ```wave```. It returns a matrix ```y``` with dimensions equals the number of time and space points.
```julia
function solve_wave(ts, xs, wave::Wave)
    ...
    return y
end
```
Finally, to plot, we define ```plot_wave``` function with where the inputs are computed wave equation ```y```, the name of the file ```file_name``` to create the animation. The optional arguments can be the numbef of frames per second ```fps``` and any additional arguments used for plotting.
```julia
function plot_wave(y, file_name; fps=60, kwargs...)
    ...
    return nothing
end
```
```@raw html
</p></details>
```







The most difficult part is done. We have done the thinking and finished a structure of the code. Now we just need to do some manual labour and fill the empty functions with code.

```@setup wave
struct Wave
    f
    g
    c
end
```


```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Write the functions from the previous exercise. Do not forget to include any pacakges needed.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The discretization will use the ```range``` function. We pass it the keyword arguments, which will usually be either the length of the sequence ```length``` or the discretization step ```step```. To obtain an array, we use the ```collect``` function. If the step is specified, the last point of ```xs``` may be different from ```xlims[2]```. In such a case, we add it and throw a warning.
```@example wave
using Plots
using LinearAlgebra

function discretize(xlims; kwargs...)
    xs = range(xlims[1], xlims[2]; kwargs...) |> collect
    if xs[end] != xlims[2]
        @warn "Discretization not equidistant."
        push!(xs, xlims[2])
    end
    return xs
end

nothing # hide
```

To solve the wave equation, we first perform a check that both discretizations are uniform. The better way would be to write a function which admits a non-equidistant discretization but we did not derive the formulas for it. If ```ts``` is equidistant, then ```diff(ts)``` should be a vector of constants and therefore ```diff(diff(ts))``` should be a vector of zeros. 

Then we initialize ```y``` with zeros and set the terminal condition ```y[1,:]``` via ```wave.f``` and the boundary conditions ```y[:,1]``` and ```y[:,end]``` which are fixed and therefore the same as ```y[1,1]``` and ```y[1,end]```, respectively. We recall that the formulas for computing the solution are
```math
\begin{aligned}
y(\Delta t, x) &= y(0, x) + \Delta t g(x), \\
y(t + \Delta t,x) &= \frac{c^2\Delta t^2}{\Delta x^2}  \Big(y(t,x + \Delta x) - 2y(t,x) + y(t,x - \Delta x)\Big) + 2y(t,x) - y(t - \Delta t,x).
\end{aligned}
```
Since the boundary conditions are prescribed, we set the first condition to ```y[2,2:end-1]``` and the other to ```y[i+1,2:end-1]```.
```@example wave
function solve_wave(ts, xs, wave::Wave)
    norm(diff(diff(ts))) <= 1e-10 || error("Time discretization must be equidistant.")
    norm(diff(diff(xs))) <= 1e-10 || error("Space discretization must be equidistant.")

    n_t = length(ts)
    n_x = length(xs)
    
    y = zeros(n_t, n_x)    
    y[1,:] = wave.f.(xs)
    y[:,1] .= y[1,1]
    y[:,end] .= y[1,end]
    y[2,2:end-1] = y[1,2:end-1] + (ts[2]-ts[1])*wave.g.(xs[2:end-1])

    s = wave.c^2 * (ts[2]-ts[1])^2 / (xs[2]-xs[1])^2
    for i in 2:n_t-1
        y[i+1,2:end-1] .= s*(y[i,3:end]+y[i,1:end-2]) + 2*(1-s)*y[i,2:end-1] - y[i-1,2:end-1]
    end
    return y
end

nothing # hide
```
The best visualization of the wave equation is via an animation. Each frame will be the plot of of row of ```y```. We use the keyword arguments ```kwargs```. We run the for loop all rows, create the animation via the ```@animate``` macro and save it into ```anim```. To save the animation, we use the ```gif``` function, for which we specify fps.
```@example wave
function plot_wave(y, file_name; fps=60, kwargs...)
    anim = @animate for y_row in eachrow(y)
        plot(y_row; kwargs...)
    end
    gif(anim, file_name, fps=fps)
    return nothing
end

nothing # hide
```
```@raw html
</p></details>
```





Now we can finally plot the solution.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Solve the wave equation for ``L=\frac32\pi``, ``T=240``, ``c=0.02`` and the initial conditions
```math
\begin{aligned}
f(x) &= 2e^{-(x-\frac L2)^2} + \frac{y_L}{L}x, \\
g(x) &= 0.
\end{aligned}
```
Do the time discretization after with ``\Delta t=1`` and ``N_x=101`` and ``N_x=7`` steps.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The parameters are assigned in
```@example wave
f(x,L,y_L) = 2*exp(-(x-L/2)^2) + y_L*x/L
g(x) = 0

L = 1.5*pi
T = 240
c = 0.02
y_L = 1

nothing # hide
```
Since we want to do the same task for two different ``N_x``, we write a function ```run_wave```, which will perform the discretizations, create the wave structure, solve the wave equation and finally plot the wave. We use different keywords for the ```discretize``` function as we have stepsize for the temporal discretization and number of steps for the spatial discretization.
```@example wave
function run_wave(L, T, N_x::Int, file_name; kwargs...)
    xs = discretize((0,L); length=N_x)
    ts = discretize((0,T); step=1)
    wave = Wave(x -> f(x,L,y_L), g, c)

    y = solve_wave(ts, xs, wave)
    plot_wave(y, file_name; kwargs...)
end

nothing # hide
```
Now we call this function with different values of ``N_x``. All the keyword arguments will be passed to the ```plot```function inside ```plot_wave```.
```@example wave
run_wave(L, T, 101, "wave1.gif"; ylims=(-2,3), label="")
run_wave(L, T, 7, "wave2.gif"; ylims=(-2,3), label="")

nothing # hide
```
```@raw html
</p></details>
```

![](wave1.gif)

![](wave2.gif)

If you see these two waves in different phases (positions), please refresh the page (the animations have already run for a long time and the error accumulated).

After the potential reload, the waves should start from the same location and move at the same speed. This is an important property of any physical system: it is consistent. If we use a different discretization, their behaviour should be *roughly* similar. Of course, the finer spatial discretization results in smoother lines but both waves have similar shapes and move at similar speeds. If we see that one moves two times faster, there is a mistake in the code.
