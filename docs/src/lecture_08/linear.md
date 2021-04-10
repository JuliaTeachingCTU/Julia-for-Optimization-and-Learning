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

We start with linear regression, where the labels are continuous variables.

## Theory of linear regression

Linear regression uses the linear prediction function ``\operatorname{predict}(w;x) = w^\top x`` and the mean square error ``\operatorname{loss}(y, \hat y) = (y - \hat y)^2`` as the loss function. When we have a dataset with ``n`` data points (samples) ``x_i`` and labels ``y_i``, linear regression may be written as the following optimization problem. 
```math
\operatorname{minimize}_w\qquad \frac 1n\sum_{i=1}^n (w^\top x_i - y_i)^2.
```
The objective function is minimal if the predictions ``w^\top x_i`` equal to the labels ``y_i`` for all samples ``i=1,\dots,n``.

Some algorithms use the sum instead of the mean in the objective function. These approaches are equivalent. For the former case, it is simpler to work in the matrix notation, where we form a matrix ``X`` whose rows are the samples ``x_i``. It is not difficult to show that the previous problem is equivalent to
```math
\operatorname{minimize}_w\qquad \|Xw - y\|^2,
```
where the norm is the ``l_2`` norm. Since this is a convex quadratic problem, it is equivalent to its optimality conditions. Setting the derivative to zero yields
```math
2X^\top (Xw-y) = 0.
```
From here, we obtain the closed-form solution to the linear regression
```math
w = (X^\top X)^{-1}X^\top y.
```

```@raw html
<div class = "info-body">
<header class = "info-header">Closed-form solution</header><p>
```
Linear regression is probably the only machine learning model with a closed-form solution. All other models must be solved by iterative algorithms such as gradient descent. In some cases, it may be advantageous to use iterative algorithms even for linear regression. For example, this includes the case of a large number of features ``m`` because then ``X^\top X`` is an ``m\times m`` matrix that may be difficult to invert.
```@raw html
</p></div>
```

## UCI repository

Training a machine learning model requires data. Neural networks require lots of data. Since collecting data is difficult, there are many datasets at the [UCI Machine Learning Repository](http://archive.ics.uci.edu/ml/index.php). We will use the iris (kosatec in Czech) dataset which predicts one of the three types of iris based on sepal (kališní lístek in Czech) and petal (okvětní lístek in Czech) widths and lengths.

![](iris.png)

If you do not see any differences between these three species, machine learning to the rescue!


## Loading and preparing data

To experiment with machine learning models, we use the ```RDatasets``` package, which stores many machine learning datasets, and we load the data by
```@example linear
using Plots
using StatsPlots
using RDatasets

iris = dataset("datasets", "iris")

nothing # hide
```
```@example linear
iris[1:5,:] # hide
```
Printing the first five entries of the data shows that they are saved in DataFrame, and the columns (features) are sepal length, sepal width, petal length and petal width.

When designing a classification method, a good practice is to perform at least a basic analysis of the data. That may include checking for NaNs, infinite values, obvious errors, standard deviations of features or others. Here, we only plot the data. 

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
We will simplify the goal and estimate the dependence of petal width on petal length. Create the data ``X`` (do not forget to add the bias) and the labels ``y``.

Make a graph of the dependence of petal width on petal length.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
Since the petal length and width are the third and fourth columns, we assign them to ```X``` and ```y```, respectively. We can use ```iris[:, 4]``` or ```iris[:, :PetalWidth]``` instead of ```iris.PetalWidth```, but the first possibility is vulnerable to errors. We need to concatenate ```X``` it with a vector of ones to add the bias.
```@example linear
y = iris.PetalWidth
X = hcat(iris.PetalLength, ones(length(y)))

nothing # hide
```
The best visualization is by the scatter plot. We use the version from the `StatsPlots` package but the one from the `Plots` package would be naturally sufficient.
```@example linear
@df iris scatter(
    :PetalLength,
    :PetalWidth;
    label="",
    xlabel = "Petal length",
    ylabel = "Petal width"
)    

savefig("iris_lin1.svg") # hide

nothing # hide
```
```@raw html
</p></details>
```

![](iris_lin1.svg)

The figure shows a positive correlation between length and width. This is natural as bigger petals mean both longer and wider petals. We will quantify this dependence by linear regression.


## Training the classifier

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Use the closed-form formula to get the coefficients ``w`` for the linear regression. Then use the ```optim``` method derived in the previous lecture to solve the optimization problem via gradient descent. The results should be identical.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The closed-form expression is ``(X^\top X)^{-1}X^\top y``. In the [exercises](@ref l7-exercises) to the previous lecture, we explained that writing ```(X'*X) \ (X'*y)``` is better than `inv(X'*X)*X'*y` because the former does not compute the matrix inverse. As a side-note, can you guess the difference between `inv(X'*X)*X'*y` and `inv(X'*X)*(X'*y)`?
```@example linear
w = (X'*X) \ (X'*y)

nothing # hide
```
For the gradient descent, we first realize that the formula for the derivate is ``X^\top (Xw-y)``. Defining the derivative function in ```g```, we call the ```optim``` method in the same way as in the last lecture. Since we use the sum and not mean in the objective, we need to use a much smaller stepsize.
```@example linear
g(w) = X'*(X*w-y)
w2 = optim([], g, zeros(size(X,2)), GD(1e-4); max_iter=10000)

nothing # hide
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

Now we can estimate the petal width if only petal length is known.


```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Write the dependence on the petal width on the petal length. Plot it in the previous graph.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The desired dependence is
```math
\text{width} \approx -0.36 + 0.42*\text{length}.
```
Before plotting the prediction, we save it into ```f_pred```.
```@example linear
f_pred(x, w) = w[1]*x + w[2]

nothing # hide
```

Then we create the limits ```x_lim``` and finally plot the prediction function.

```@example linear
x_lims = extrema(iris.PetalLength) .+ [-0.1, 0.1]

@df iris scatter(
    :PetalLength,
    :PetalWidth;
    xlabel = "Petal length",
    ylabel = "Petal width",
    label = "",
    legend = :topleft,
)

plot!(x_lims, x -> f_pred(x,w); label = "Prediction", line = (:black,3))

savefig("iris_lin2.svg") # hide
```
```@raw html
</p></details>
```

![](iris_lin2.svg)
