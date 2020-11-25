# Numerical methods

We learnt that the gradient is the direction of the steepest descent. The straightforward idea is to move in the opposite direction. This gives rise to the gradient descent algorithm
```math
x^{k+1} = x^k - \alpha^k\nabla f(x^k).
```
The stepsize ``\alpha^k>0`` can be tuned as a hyperparameter.

EXAMPLE

Implement function `optim` which takes function ``f``, gradient `g`, starting point ``x^0`` and fixed stepsize ``\alpha`` and runs the gradient descent. It should return first 100 iterations of the algorithm.


```@example optim
function optim(f, g, x, α; max_iter=100)
    x_all = zeros(length(x), max_iter+1)
    x_all[:,1] = x
    for i in 1:max_iter
        x = x - α*g(x)
        x_all[:,i+1] = x
    end
    return x_all
end
```

NOTE TAHT F IS NOT NEEDED.

Apply it to the function

```math
f(x,y) = \sin(x + y) + \cos(x)^2
```
with starting point ``x^0=(0,-1)`` and stepsize ``\alpha=1``. Plot the contour plot and individual iterations.

```@example optim
x_all = optim([], x -> compute_gradient(f, x), [0; -1], 0.7)

plot(x_range, y_range, (x, y) -> f([x; y]),
    st = :contourf,
    color = :jet,
)

plot!(x_all[1,:], x_all[2,:],
    linewidth = 4,
    linecolor = :black,
    label = "",
)

savefig("grad4.svg") # hide
```

![](grad4.svg)

PLAY WITH STEPSIZE SELECTION. WHAT DID YOU OBSERVE?

