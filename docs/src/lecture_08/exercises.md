```@setup ex_log
using Plots
using StatsPlots
using RDatasets
using Statistics
using LinearAlgebra

function log_reg(X, y, w; max_iter=100)
    X_mult = [row*row' for row in eachrow(X)]
    for i in 1:max_iter
        y_hat = 1 ./(1 .+exp.(-X*w))
        grad = X'*(y_hat.-y) / size(X,1)
        hess = y_hat.*(1 .-y_hat).*X_mult |> mean
        w -= hess \ grad
    end
    return w
end

iris = dataset("datasets", "iris")
iris_reduced = iris[iris.Species .!= "setosa", :]

X = hcat(Matrix(iris_reduced[:, 3:4]), ones(size(iris_reduced,1)))
y = iris_reduced.Species .== "virginica"

w = log_reg(X, y, zeros(size(X,2)))
```





# [Exercises](@id l8-exercises)

```@raw html
<div class = "homework-body">
<header class = "homework-header">Homework: Data normalization</header><p>
```
Data are often normalized. Each feature subtracts its mean and then divides the result by its standard deviation. The normalized features have zero mean and unit standard deviation. This may help in several cases:
- When each feature has a different order of magnitude (such as millimetres and kilometres). Then the gradient would ignore the feature with the smaller values.
- When problems such as vanishing gradients are present (we will elaborate on this in Exercise 4).

Write function ```normalize``` which takes as an input a dataset and normalizes it. Then train the same classifier as we did for [logistic regression](@ref log-reg). Use the original and normalized dataset. Which differences did you observe when
- the logistic regression is optimized via gradient descent?
- the logistic regression is optimized via Newton's method?
Do you have any intuition as to why?

Write a short report (in Latex) summarizing your findings.
```@raw html
</p></div>
```   







```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 1</header><p>
```
The logistic regression on the iris dataset failed in 6 out of 100 samples. But the visualization shows the failure only in 5 cases. How is it possible?
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
We use the same code as before and find indices of the misclassified samples
```@example ex_log
y_hat = 1 ./(1 .+exp.(-X*w))
pred = y_hat .>= 0.5
ii = findall(pred .!= y)

nothing # hide
```
Then we show the values of the data and labels at these indices. We sort the rows by ```sortslices```. You cannot use ```sort``` as it would not sort rows, but it would perform the sorting operator on every column independently.
```@example ex_log
aux = hcat(X[ii,:], y[ii])
sortslices(aux, dims=1)
```
A short look at the image shows that the point ``(4.8, 1.8)`` is misclassified but the image shows it correctly. Let us show all such points
```@example ex_log
ii = findall((X[:,1].==4.8) .& (X[:,2].==1.8))
aux = hcat(X[ii,:], y[ii])
```
As we can see, there are three samples with the same data. Two of them have label 1 and one label 0. Since the incorrectly classified sample was redrawn, it was not possible to see it.
```@raw html
</p></details>
```







```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 2: Why not use sigmoid</header><p>
```
Show that Newton's method fails when started from the vector ``(1,2,3)``. Can you guess why it happened? What are the consequences for optimization? Is gradient descent going to suffer from the same problems?
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
First, we run the logistic regression as before, only with a different starting point
```@example ex_log
log_reg(X, y, [1;2;3])
```
This resulted in NaNs. When something fails, it may be a good idea to run a step-by-step analysis. In this case, we will run the first iteration of Newton's method
```@repl ex_log
w = [1;2;3];
X_mult = [row*row' for row in eachrow(X)];
y_hat = 1 ./(1 .+exp.(-X*w))
grad = X'*(y_hat.-y) / size(X,1)
hess = y_hat.*(1 .-y_hat).*X_mult |> mean
w -= hess \ grad
```
Starting from the bottom, we can see that even though we started with relatively small ``w``, the next iteration is four degrees of magnitude larger. This happened because the Hessian ```hess``` is much smaller than the gradient ```grad```. This indicates that there is some kind of numerical instability. The prediction ```y_hat``` should lie in the interval ``[0,1]`` but it seems that it is almost always close to 1. Let us verify this by showing the extrema of ```y_hat```
```@example ex_log
extrema(y_hat)
```
They are indeed too large.

Now we explain the reason. We know that the prediction equals to
```math
\hat y_i = \sigma(w^\top x_i),
```
where ``\sigma`` is the sigmoid function. Since the mimimum from ``w^\top x_i``
```@example ex_log
minimum(X*[1;2;3])
```
is large, all ``w^\top x_i`` are large. But plotting the sigmoid funtion
```@example ex_log
σ(z) = 1/(1+exp(-z))
xs = -10:0.01:10
plot(xs, σ, label="", ylabel="Sigmoid function")

savefig("sigmoid.svg") # hide
```

![](sigmoid.svg)

it is clear that all ``w^\top x_i`` hit the part of the sigmoid which is flat. This means that the derivative is almost zero and the Hessian is "even smaller" zero. Then the ratio of the gradient and Hessian is huge as we observed above.

The gradient descent will probably run into the same difficulty. Since the gradient will be too small, it will take a very large number of iterations to escape the flat region of the sigmoid. This is a known problem of the sigmoid function. It is also the reason why it was replaced in neural networks by other activation functions.
```@raw html
</p></details>
```











```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 3 (theory)</header><p>
```
Show the details for the derivation of the loss function of the logistic regression.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
Since ``\hat y`` equals the probability of predicting ``1``, we have
```math
\hat y = \frac{1}{1+e^{-w^\top x}}
``` 
Then the cross-entropy loss reduces to
```math
\begin{aligned}
\operatorname{loss}(y,\hat y) &= - y\log \hat y - (1-y)\log(1-\hat y) \\
&= y\log(1+e^{-w^\top x}) - (1-y)\log(e^{-w^\top x}) + (1-y)\log(1+e^{-w^\top x}) \\
&= \log(1+e^{-w^\top x}) + (1-y)w^\top x.
\end{aligned}
```
Then it remains to sum this term over all samples.
```@raw html
</p></details>
```







```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 4 (theory)</header><p>
```
Show that if the Newton's method converged for the logistic regression, then it found a point globally minimizing the logistic loss. 
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
We derived that the Hessian of the objective function for logistic regression is
```math
\nabla^2 L(w) = \frac 1n \sum_{i=1}^n\hat y_i(1-\hat y_i)x_i x_i^\top.
```
For any vector ``a``, we have
```math
a^\top x_i x_i^\top a = (x_i^\top a)^\top (x_i^\top a) = \|x_i^\top a\|^2 \ge 0,
```
which implies that ``x_i x_i^\top`` is a positive semidefinite matrix (it is known as rank-1 matrix as its rank is always 1 if ``x_i`` is a non-zero vector). Since ``y_i(1-\hat y_i)\ge 0``, it follows that ``\nabla^2 L(w)`` is a positive semidefinite matrix. If a Hessian of a function is positive semidefinite everywhere, the function is immediately convex. Since the Newton's method found a stationary point, this points is a global minimum.
```@raw html
</p></details>
```




