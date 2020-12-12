```@setup linear
abstract type Step end

struct GD <: Step
    α::Real
end

optim_step(s::GD, f, g, x) = -s.α*g(x)

function optim(f, g, x, s::Step; max_iter=100)
    for i in 1:max_iter
        x += optim_step(s, f, g, x)
    end
    return x
end
```


# Linear regression

To experiment with machine learning models, we first need to load the data by
```@example linear
using BSON

file_name = joinpath("data", "iris.bson")
data = BSON.load(file_name)
```
This creates a dictionary ```data``` whose entries can be accessed via ```data[:X]```. The simpler way of loading is
```@example linear
using BSON: @load

@load file_name X y y_name
```
The columns of ```X``` (features) are sepal length, sepal width, petal length and petal width (in this order).

When designing a classification method, a good practice is to perform an analysis of the data. That may include checking for NaNs, infinite values, obvious errors, standard deviations of features or others. Here, we only plot the data. 

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
For simplicity of visualization, remove all features besides petal length and petal width. Since we need to include the bias (intercept), add a column of ones as the last column.

Then plot the dataset.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
Since the peral length and width are the third and fourth columns, respectively, we use ```X[:,3:4]```. Then we need to cat it with a vector of ones.
```@example linear
y = X[:,4]
X = hcat(X[:,3], repeat([1], size(X,1)))
nothing # hide
```
The best plot in this case is the scatter plot.
```@example linear
using Plots

scatter(X[:,1], y, label="", xlabel="Petal length", ylabel="Petal width")

savefig("iris_lin1.svg") # hide

nothing # hide
```
```@raw html
</p></details>
```

![](iris_lin1.svg)

The figure shows a positive correlation between length and width. This is natural as bigger petals means both longer and wider petals. We will estimate the dependence of the linear regression.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Use the closed-form formula to solve the coefficient for the linear regression. Then use the ```optim``` method derived in the previous lecture to solve the optimization problem via gradient descent. The results should be identical. Compare the elapsed time.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The closed-form expression is ``(X^\top X)^{-1}X^\top y``. This can be coded as ```(X'*X) \ (X'*y)```. To measure the time, we use the ```@time``` macro.
```@example linear
@time w = (X'*X) \ (X'*y)
```
For using the gradient, we first realize that the formula for the derivate is ``X^\top *(Xw-y)``. Defining the derivative function in ```g```, we call the ```optim``` method in the same way as last lecture. Note that we needed to use much smaller stepsize this time.  
```@example linear
g(w) = (X'*(X*w-y))
@time w2 = optim([], g, zeros(size(X,2)), GD(1e-4); max_iter=10000)
```
The difference between the solutions is
```@example linear
using LinearAlgebra

norm(w-w2)
```
which is acceptable.
```@raw html
</p></details>
```

The correct solution is
```@example linear
w # hide
```
This gives an advice how to predict the petal width if only petal length is known.


```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Write the dependence on the petal width on the petal length. Plot it on the previous graph.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The desired dependence is
```math
\text{width} = -0.3665 + 0.4164*\text{length}.
```
To plot the prediction, we save the function into ```f_pred```, then create the limits ```x_lim``` and finally plot a function which connects the two points. We move the legend to the top-left corner and we prescribe the limits on the ``y`` axis.
```@example linear
scatter(X[:,1], y, label="", xlabel="Petal length", ylabel="Petal width")

f_pred(x) = w[1]*x + w[2]
x_lim = [minimum(X[:,1])-0.1; maximum(X[:,1])+0.1]
plot!(x_lim, f_pred.(x_lim), label="Prediction", legend=:topleft, line=(:black,3))

savefig("iris_lin2.svg") # hide
```
```@raw html
</p></details>
```

![](iris_lin2.svg)
