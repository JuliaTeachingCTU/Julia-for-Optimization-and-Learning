```@setup grad
using Plots

f(x) = sin(x[1] + x[2]) + cos(x[1])^2
g(x) = [cos(x[1] + x[2]) - 2*cos(x[1])*sin(x[1]); cos(x[1] + x[2])]

xs = range(-3, 1, length = 40)
ys = range(-2, 1, length = 40)
f_mod = (x, y) -> f([x; y])
```

```@setup steps
f(x) = sin(x[1] + x[2]) + cos(x[1])^2
g(x) = [cos(x[1] + x[2]) - 2*cos(x[1])*sin(x[1]); cos(x[1] + x[2])]
```

# Numerical methods

This part introduces the most basic optimization algorithm called gradient (or steepest) descent.

## Gradient descent

We learnt that the gradient is the direction of steepest descent. The straightforward idea is to move in the opposite direction. This gives rise to the gradient descent algorithm
```math
x^{k+1} = x^k - \alpha^k\nabla f(x^k).
```
The stepsize ``\alpha^k>0`` can be tuned as a hyperparameter.


```@raw html
<div class="admonition is-info">
<header class="admonition-header">Terminology</header>
<div class="admonition-body"><p>
```
In classical optimization, the usual terminology is:
- Variable is to be optimized.
- Parameter is external (fixed) such as material parameters.
In machine learning, the usual terminology is:
- Parameter is to be optimized.
- Hyperparameter is an external model parameter which is not optimized and needs to be tuned. The example is the steplength because the gradient descent finds a different solution for different steplength but it is not changed during the optimization.
The different terminology (and the fact that there are adaptive schemes to select the steplenght which should make it a parameter instead of a hyperparameter) makes the notation confusing.
```@raw html
</p></div></div>
```

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Gradient descent</header>
<div class="admonition-body"><p>
```
Implement function `optim` which takes as inputs function ``f``, its gradient, starting point ``x^0`` and fixed stepsize ``\alpha`` and runs the gradient descent. Its output should be the first 100 iterations.

This example is rather artificial because usually only the last iteration is returned and some stopping criterion is employed instead of the fixed number of iterations. We want to get all iterations to make visualizations.
```@raw html
</p></div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
First we need to create an empty array into which we store the iterates. Then at every iteration we compute the gradient ```g(x)```, perform the update and save the new value of ``x``. 
```@example grad
function optim(f, g, x, α; max_iter=100)
    xs = zeros(length(x), max_iter+1)
    xs[:,1] = x
    for i in 1:max_iter
        x -= α*g(x)
        xs[:,i+1] = x
    end
    return xs
end
nothing # hide
```
```@raw html
</p>
</details>
```
The implementation does not use the values of ``f`` but only its gradient ``\nabla f``. Moreover, if the algorithm converges ``x^k \to \bar x``, then passing to the limit in the gradient update results in ``\nabla f(\bar x)=0``. Therefore, as most optimization methods, gradient descent looks for stationary points.


```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Gradient descent</header>
<div class="admonition-body"><p>
```
Use the implementation of the gradient descent to minimize the function
```math
f(x) = \sin(x_1 + x_2) + \cos(x_1)^2
```
from the starting point ``x^0=(0,-1)`` and constant stepsize ``\alpha=0.1``. Store all iterations into matrix ```xs```.

Plot again the contours of ``f`` and all iterations ```xs```.

Use one line of code to evaluate the function values for all iterations ```xs``` (hint: you need to iterate via ```eachcol(xs)``` or ```eachrow(xs)``` depending on how you represent ```xs```). Plot these values. ```@raw html
</p></div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
We call ```optim``` written in the previous exercise. Then we plot the contours as before. Since ```x_gd[1,:]``` stores the ``x`` coordinate of all iterations and similarly ```x_gd[2,:]```, we plot them. We need to use ```plot!``` instead of ```plot``` to add the line to the contour plot.
```@example grad
x_gd = optim([], g, [0; -1], 0.1)

contourf(xs, ys, f_mod, color = :jet)

plot!(x_gd[1,:], x_gd[2,:], line=(4,:black), label = "")

savefig("numer1.svg") # hide
```
This example is similar to ```[? for h in hs]``` encountered earlier. To iterate over all columns, we use ```[? for x in eachcol(x_gd)]``` and apply ```f(x)``` instead of ```?```. Another (more complicated) way is to iterate over indices instead of vectors and write ```[f(x_gs[:,i]) for i in 1:size(x_gd,2)]```.
```@example grad
f_gd = [f(x) for x in eachcol(x_gd)]

plot(f_gd, label="", xlabel="Iteration", ylabel="Function value")

savefig("numer2.svg") # hide
```
```@raw html
</p></details>
```

![](numer1.svg)

![](numer2.svg)

The convergence looks very nice, and the function value decreases. First, the decrease is faster, but when the iterations get closer to the minimum, it slows down.

What happens if we choose a different stepsize though? Let us try with two different values. First let us try ``\alpha=0.01``.
```@example grad
x_gd = optim([], g, [0; -1], 0.01)

contourf(xs, ys, f_mod, color = :jet)

plot!(x_gd[1,:], x_gd[2,:], line=(4,:black), label = "")

savefig("numer3.svg") # hide
```

![](numer3.svg)

We see that when the stepsize is reduced, the steps are shorter and we would need to increase the number of iterations (and thus time) to converge. When the stepsize is larger, say ``\alpha=1``, the situation is different. 
```@example grad
x_gd = optim([], g, [0; -1], 1)

contourf(xs, ys, f_mod, color = :jet)

plot!(x_gd[1,:], x_gd[2,:], line=(4,:black), label = "")

savefig("numer4.svg") # hide
```

![](numer4.svg)

For a large stepsize, the algorithm gets close to the solution and then starts jumping around. If we further increase the stepsize, it will even diverge to infinite. Try it.

## Adaptive stepsize

To handle this numerical instability, safeguards are introduced. One of the possibilities is the Armijo condition which automatically selects the stepsize. It looks for ``\alpha^k`` which satisfies
```math
f(x^k - \alpha^k\nabla f(x^k)) \le f(x^k) - c \alpha^k \|\nabla f(x^k)\|^2.
```
Here  ``c\in(0,1)`` is a small constant, usually ``c=10^{-4}``. Since the left-hand side is the function value at the new iterate ``x^{k+1}``, the Armijo condition ensures that the sequence of function values is strictly decreasing. This prevents oscillations.

The implementation of ```optim(f, g, x, α; max_iter=100)``` from the exercise above is rather stupid because it does not allow to modify the selection of the step. The simplest fix would be to include if conditions inside the function. However, this would result in a long function, which may be difficult to debug and modify. A more elegant solution is to create an abstract class
```@example steps
abstract type Step end
```
and for each possible step selection method implement a ```optim_step``` method, which selects the step. First, we create the gradient descent class ```GD``` as a subclass of ```Step``` by
```@example steps  
struct GD <: Step
    α::Real
end
```
It is a structure with parameter ```α```. Then we create the ```optim_step``` function by
```@example steps
optim_step(s::GD, f, g, x) = -s.α*g(x)
nothing # hide
```
Due to the first input argument, it will be called only for the  ```GD``` stepsize. To access the parameter ```α```, we need to retrieve it from the structure by ```s.α```. Now we can modify the ```optim``` function by
```@example steps
function optim(f, g, x, s::Step; max_iter=100)
    for i in 1:max_iter
        x += optim_step(s, f, g, x)
    end
    return x
end
nothing # hide
```
The specification of the input ```s::Step``` allows for any subclass of the abstract class ```Step```. Using this implentation results in
```@example steps
gd = GD(0.1)
x_opt = optim(f, g, [-1;0], gd)
println(x_opt) # hide
```
We obtained the same results as in the previous case. This is not surprising as the code does exactly the same things; it is only written differently. The next exercise shows the power of defining the ```Step``` class.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Armijo condition</header>
<div class="admonition-body"><p>
```
Implement the ```Armijo``` subclass of the ```Step``` class. It should have two parameters ```c``` from the definition and ```α_max``` which will be the initial value of ``\alpha``. The value ``\alpha`` should be divided by two until the Armijo condition is satisfied.

Then run the optimization with the Armijo selection of the stepsize.
```@raw html
</p></div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
We define the class in the same way as for ```GD```:
```@example steps
struct Armijo <: Step
    c::Real
    α_max::Real
end
```
For the search for the stepsize, we first save the values for the function value ``f(x)`` and the gradient ``\nabla f(x)``. If we do not do this, it will be recomputed at every step. Then we initialize the value of ``\alpha`` and run the while loop until the Armijo condition is satisfied. We added a termination condition (also a safe check) ```α <= 1e-6``` to prevent the loop for continuing indefinitely.
```@example steps
function optim_step(s::Armijo, f, g, x)
    fun = f(x)
    grad = g(x)
    α = s.α_max
    while f(x .- α*grad) > fun - s.c*α*(grad'*grad)
        α /= 2
        if α <= 1e-6
            warning("Armijo line search failed.")
            break
        end
    end
    return -α*grad
end
nothing # hide
```
Then we create the ```Armijo``` object and run the optimization again.
```@example steps
gd = Armijo(1e-4, 1)
x_opt = optim(f, g, [-1;0], gd)
nothing # hide
```
```@raw html
</p></details>
```

The correct solution is
```@example steps
println(round.(x_opt, digits=4)) # hide
```
