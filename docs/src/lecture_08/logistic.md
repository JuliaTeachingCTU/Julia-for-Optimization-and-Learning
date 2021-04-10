# [Logistic regression](@id log-reg)

We continue with logistic regression, where the labels are discrete variables. Most regression models employ the sigmoid function
```math
\sigma(z) = \frac{1}{1+e^{-z}} = \frac{e^z}{1+e^z}
```
because its values are in the interval ``[0,1]`` and can be interpreted as probabilities.

## Theory of logistic regression

The name logistic regression is misleading because it is actually a classification problem. In its simplest form, it assumes binary labels ``y\in\{0,1\}`` and predicts the positive and negative classes with probabilities
```math
\begin{aligned}
\mathbb{P}(y=1\mid x) &= \sigma(w^\top x) = \frac{1}{1+e^{-w^\top x}}, \\
\mathbb{P}(y=0\mid x) &= 1 - \sigma(w^\top x) = \frac{e^{-w^\top x}}{1+e^{-w^\top x}}.
\end{aligned}
```
Denoting ``\hat y = \mathbb{P}(y=1\mid x)`` the probabily of predicting ``1``, the loss function is the cross-entropy loss
```math
\operatorname{loss}(y,\hat y) = - y\log \hat y - (1-y)\log(1-\hat y).
```


```@raw html
<div class = "info-body">
<header class = "info-header">Cross-entropy loss</header><p>
```
Even though the cross-entropy loss may seem overwhelming, it is quite simple. When a sample is of the positive class, we have ``y=1``, and the cross-entropy loss reduces to
```math
\operatorname{loss}(1,\hat y) = - \log \hat y.
```
Since ``\hat y`` lies in the interval ``(0,1)`` due to the sigmoid function, the cross-entropy is minimized when ``\hat y = 1``. Since we get similar results for ``y=0``, the cross-entropy is minimal whenever the labels ``y`` equal to the predictions ``\hat y``.
```@raw html
</p></div>
```

Then is not difficult to show that then the logistic regression problems reads
```math
\operatorname{minimize}_w\qquad \frac1n\sum_{i=1}^n\left(\log(1+e^{-w^\top x_i}) + (1-y_i)w^\top x_i \right).
```

#### [Soft and hard predictions](@id soft-hard)

The previous paragraph used the soft prediction, where the output was the probability ``\hat y`` of the positive class. If we need to provide a hard prediction, we predict the positive class whenever ``\hat y\ge \frac 12`` and the negative class whenever ``\hat y < \frac12``.  Since
```math
\hat y = \frac{1}{1+e^{-w^\top x}} \ge \frac12
```
is equivalent to
```math
w^\top x \ge 0,
```
the prediction function is again linear.

#### Numerical method

The logistic regression can be optimized by Newton's method. Denoting the loss function ``L(w)``, its partial derivative with respect to one component equals to
```math
\begin{aligned}
\frac{\partial L}{\partial w_j}(w) &= \frac1n\sum_{i=1}^n\left(-\frac{1}{1+e^{-w^\top x_i}}e^{-w^\top x_i}x_{i,j} + (1-y_i)x_{i,j} \right) \\
&= \frac1n\sum_{i=1}^n\left(-\frac{1}{1+e^{w^\top x_i}}x_{i,j} + (1-y_i)x_{i,j} \right),
\end{aligned}
```
where ``x_{i,j}`` is the ``j``-th component of ``x_i`` (it is also the ``(i,j)`` entry of matrix ``X``). The second partial derivative amounts to
```math
\frac{\partial^2 L}{\partial w_j \partial w_k}(w) = \frac1n\sum_{i=1}^n \frac{1}{(1+e^{w^\top x_i})^2}e^{w^\top x_i}x_{i,j}x_{i,k} = \frac1n\sum_{i=1}^n \hat y_i(1-\hat y_i)x_{i,j}x_{i,k}.
```
Now we will write it in a more compact notation (recall that ``x_i`` is a column vector). We have
```math
\begin{aligned}
\nabla L(w) &= \frac1n \sum_{i=1}^n \left((\hat y_i-1)x_i + (1-y_i)x_i \right) = \frac1n \sum_{i=1}^n (\hat y_i-y_i)x_i, \\ 
\nabla^2 L(w) &= \frac 1n \sum_{i=1}^n\hat y_i(1-\hat y_i)x_i x_i^\top.
\end{aligned}
```
If the fit is perfect, ``y_i=\hat y_i``, then the Jacobian ``\nabla L(w)`` is zero. Then the optimizer minimized the objective and satisfied the optimality condition.


## Loading and preparing data

The last part predicted a continuous variable. This part will be closer to the iris dataset spirit: It will predict one of two classes. We load the data as before.

```@example logistic
using StatsPlots
using RDatasets

iris = dataset("datasets", "iris")

nothing # hide
```

The data contain three classes. However, we considered only binary problems with two classes. We therefore cheat.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Create the `iris_reduced` dataframe in the following way:
- Label "setosa" will be deleted.
- Label "versicolor" will be the negative class.
- Label "virginica" will be the positive class.
- Add the `intercept` column with ones as entries.
For the features, consider only petal length and petal width.

**Hint**: Use the `Query` package or do it manually via the `!insertcols` function.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The modification of the dataframe can be by the `Query` package.

```@example logistic
using Query

iris_reduced = @from i in iris begin
    @where i.Species != "setosa"
    @select {
        i.PetalLength,
        i.PetalWidth,
        intercept = 1,
        i.Species,
        label = i.Species == "virginica",
    }
    @collect DataFrame
 end

nothing # hide
```

We can also perform this procedure manually.

```@example logistic
iris_reduced2 = iris[iris.Species .!= "setosa", :]
iris_reduced2 = iris_reduced2[:,[3;4;5]]

insertcols!(iris_reduced2, 3, :intercept => 1)
insertcols!(iris_reduced2, 5, :label => iris_reduced2.Species .== "virginica")

nothing # hide
```

We can check that both approaches give the same result.
```@example logistic
isequal(iris_reduced, iris_reduced2)
```

```@raw html
</p></details>
```

Now we extract the data ```X``` and labels ```y```. Since ```iris_reduced``` is a DataFrame, we need to convert it first into a ```Matrix```. The matrix `X` is formed by the petal length, width and the intercept. 
 
```@example logistic
X = Matrix(iris_reduced[:, 1:3])
y = iris_reduced.label

nothing # hide
```


We again plot the data. Since we are interested in a different prediction than last time, we will plot them differently.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Since ```X``` has two features (columns), it is simple to visualize. Use scatter plot to show the data. Use different colours for different classes. Try to produce a nice graph by including names of classes and axis labels (petal length and petal width).
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
We make use of the ```iris_reduced``` variable. To plot the points in different colours, we use the keyword ```group = :Species```.
```@example logistic
using Plots

@df iris_reduced scatter(
    :PetalLength,
    :PetalWidth;
    group = :Species,
    xlabel = "Petal length",
    ylabel = "Petal width",
    legend = :topleft,
)

savefig("iris1.svg") # hide
```
```@raw html
</p></details>
```

![](iris1.svg)

We see that the classes are almost perfectly separable. It would not be difficult to estimate the separating hyperplane by hand. However, we will do it automatically.

## Training the classifier

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Write a function ```log_reg``` which takes as an input the dataset, the labels and the initial point. It should use Newton's method to find the optimal weights ``w``. Print the results when started from zero.

It would be possible to use the code ```optim(f, g, x, s::Step)``` from the previous lecture and define only the step function ```s``` for the Newton's method. However, sometimes it may be better to write simple functions separately instead of using more complex machinery.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
To write the desired function, we need to implement the gradient and Hessian from derived in the theoretical lecture. First, we define the sigmoid function in `σ`. Then we need to create ``\hat y``. We may use for loop notation ```[σ(-w'*x) for x in eachrow(X)]```. However, in this case, it is simpler to use matrix operations ```σ.(-X*w)``` to get the same result. The gradient can be written in the same way. Again, we use matrix notation. For the Hessian, we first create ```X_mult = [row*row' for row in eachrow(X)]``` which computes all products ``x_ix_i^\top``. This creates an array of length ``100``; each element of this array is a ``2\times 2`` matrix. Since it is an array, we may multiply it by ```y_hat.*(1 .-y_hat)```. As ```mean``` from the ```Statistics``` package operates on any array, we can call it (or similarly ```sum```). We may use ```mean(???)``` but we find the alternative  ```??? |> mean``` more readable in this case. We use ```hess \ grad```, as explained in the previous lecture for Newton's method, to update the weights.
```@example logistic
using Statistics

σ(z) = 1/(1+exp(z))

function log_reg(X, y, w; max_iter=100, tol=1e-6)
    X_mult = [row*row' for row in eachrow(X)]
    for i in 1:max_iter
        y_hat = σ.(-X*w)
        grad = X'*(y_hat.-y) / size(X,1)
        hess = y_hat.*(1 .-y_hat).*X_mult |> mean
        w -= hess \ grad
    end
    return w
end

nothing # hide
```
The definition of ```X_mult``` should be outside the for loop, as it needs to be computed only once. 

After the tough work, it remains to call it.
```@example logistic
w = log_reg(X, y, zeros(size(X,2)))

nothing # hide
```
```@raw html
</p></details>
```
The correct solution is
```@example logistic
println(round.(w, digits=4)) # hide
```

## Analyzing the solution

We can now show the solution. Since the intercept is the third component with ``x_3=1``, the section on [soft and hard predictions](@ref soft-hard) derived that the separating hyperplane takes the form
```math
w_1x_1 + w_2x_2 + w_3 = 0.
```
To express it as a function, we obtain
```math
\operatorname{separ}(x_1) = x_2 = \frac{-w_1x_1 - w_3}{w_2}.
```
Now we plot it.
```@example logistic
separ(x, w) = (-w[3]-w[1]*x)/w[2]

xlims = extrema(iris_reduced.PetalLength) .+ [-0.1, 0.1]
ylims = extrema(iris_reduced.PetalWidth) .+ [-0.1, 0.1]

@df iris_reduced scatter(
    :PetalLength,
    :PetalWidth;
    group = :Species,
    xlabel = "Petal length",
    ylabel = "Petal width",
    legend = :topleft,
    xlims,
    ylims,
)

plot!(xlims, x -> separ(x,w); label = "Separation", line = (:black,3))

savefig("iris2.svg") # hide
```

![](iris2.svg)

Anything above the separating hyperplane is classified as virginica, while anything below it is versicolor.

This is the optimal solution obtained by the logistic regression. Since the norm of the gradient
```@example logistic
using LinearAlgebra

y_hat = σ.(-X*w)
grad = X'*(y_hat.-y) / size(X,1)
norm(grad)
```
equals to zero, we found a stationary point. It can be shown that logistic regression is a convex problem, and, therefore, we found a global solution.


The picture shows that there are misclassified samples. The next exercise analyses them.
```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Compute how many samples were correctly and incorrectly classified.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
Since ``\hat y_i`` is the probability that a sample is of the positive class, we will predict that it is positive if this probability is greater than ``\frac 12``. Then it suffices to compare the predictions ```pred``` with the correct labels ```y```.
```@example logistic
pred = y_hat .>= 0.5
"Correct number of predictions: " * string(sum(pred .== y))
"Wrong   number of predictions: " * string(sum(pred .!= y))

nothing # hide
```
There is an alternative (but equivalent way). Since the separating hyperplane has form ``w^\top x``, we predict that a sample is positive whenever ``w^\top x\ge 0``. Write arguments on why these two approaches are equivalent.
```@raw html
</p></details>
```
The correct answer is
```@example logistic
println("Correct number of predictions: " * string(sum(pred .== y))) # hide
println("Wrong   number of predictions: " * string(sum(pred .!= y))) # hide
```
