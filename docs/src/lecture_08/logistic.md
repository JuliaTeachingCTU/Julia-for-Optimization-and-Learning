# Logistic regression

The last part predicted a continuous variable. This part will be closer to the iris dataset's spirit: It will predict one of two classes.

Load the data as before
```@example logistic
using BSON: @load

file_name = joinpath("data", "iris.bson")
@load file_name X y y_name
```
The data contain three classes ```[1 2 3]```. However, we considered only binary problems with two classes. We therefore cheat.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Write function ```modify_data``` which converts ```X``` and ```y``` into binary dataset in the following way:
- Label 1 will be deleted.
- Label 2 will be the negative class.
- Label 3 will be the positive class.
For ```X``` consider only columns 3 and 4 (petal length and width). Then call the function.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
Since we want to keep ``y\in\{2,3\}``, we store the indices into ```i```. Then we reduce ```X```, ```y``` and ```y_name``` into the correct rows and columns.
```@example logistic
function modify_data(X, y, y_name)
    ii = y .> 1.5
    return X[ii,3:4], y[ii] .> 2.5, y_name[2:3]
end
nothing # hide
```
Finally, we call the function
```@example logistic
X, y, y_name = modify_data(X, y, y_name)
nothing # hide
```
```@raw html
</p></details>
```

We again plot the data. Since we are interested in a different prediction than last time, we will plot them differently.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Since ```X``` has two features (columns), it is simple to visualize. Use scatter plot to show the data. Use different colours for different classes. Try to produce a nice graph by including names of classes (in ```y_name```) and axis labels (petal length and petal width).
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
This should be known by now. The only possibly unknown command is ```legend=:topleft``` to move the legend to the top-left corner.
```@example logistic
using Plots

scatter(X[y.==0,1], X[y.==0,2], label=y_name[1], legend=:topleft,
    xlabel="Petal length", ylabel="Petal width")
scatter!(X[y.==1,1], X[y.==1,2], label=y_name[2])

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
To write the desired function, we need to implement the gradient and Hessian from derived in the theoretical lecture. First, we need to create ``\hat y``. We may use for loop notation ```[1/(1+exp(-w'*x)) for x in eachrow(X)]```. However, in this case, it is simpler to use matrix operations ```1 ./(1 .+exp.(-X*w))``` to get the same result. The gradient can be written in the same way. Again, we use matrix notation. For the Hessian, we first create ```X_mult = [row*row' for row in eachrow(X)]``` which computes all products ``x_ix_i^\top``. This creates an array of length ``100``, each element of this array is a ``2\times 2`` matrix. Since it is an array, we may multiply it by ```y_hat.*(1 .-y_hat)```. As ```mean``` from the ```Statistics``` package operates on any array, we can call it (or similarly ```sum```). We may use ```mean(???)``` but we find the alternative  ```??? |> mean``` more readable in this case. We use ```hess \ grad```, as explained in the previous lecture for Newton's method, to update the weights.
```@example logistic
using Statistics

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
nothing # hide
```
The definition of ```X_mult``` should be outside the for loop, as it needs to be computed only once. 

After the tough work, it remains to call it.
```@example logistic
w0 = zeros(size(X,2))
w_wrong = log_reg(X, y, w0)
nothing # hide
```
The name ```w_wrong``` suggests that something is wrong. The problem is that the logistic regression was called with the original dataset. However, in doing so, there is no intercept. For this reason, we need to modify ```X``` first by including the column of ones and then calling the logistic regression again.
```@example logistic
X_ext = hcat(X, repeat([1],size(X,1)))
w = log_reg(X_ext, y, zeros(size(X_ext,2)))
nothing # hide
```
Hooray, this time it is correct.
```@raw html
</p></details>
```
If you obtained
```@example logistic
println(round.(w_wrong, digits=4)) # hide
```
the function for solving the logistic regression is correct. However, it was called in a wrong way. The correct solution is
```@example logistic
println(round.(w, digits=4)) # hide
```

## Analyzing the solution

We can now show the solution. Since the intercept is the third component (where ``x_3=1``), the separating hyperplane takes form
```math
w_1x_1 + x_2x_2 + w_3 = 0.
```
To express it as a function, we obtain
```math
\operatorname{sep}(x_1) = x_2 = \frac{-w_1x_1 - w_3}{w_2}.
```
Now we plot it.
```@example logistic
f_hyper(x) = (-w[3]-w[1]*x)/w[2]

x_lim = [minimum(X[:,1])-0.1; maximum(X[:,1])+0.1]
scatter(X[y.==0,1], X[y.==0,2], label=y_name[1], legend=:topleft,
    xlabel="Petal length", ylabel="Petal width")
scatter!(X[y.==1,1], X[y.==1,2], label=y_name[2])
plot!(x_lim, f_hyper.(x_lim), label="Separating hyperplane", line=(:black,3),
    ylim=(minimum(X[:,2])-0.1,maximum(X[:,2])+0.1))

savefig("iris2.svg") # hide
```

![](iris2.svg)

This is the optimal solution obtained by the logistic regression. Since the norm of the gradient
```@example logistic
using LinearAlgebra

y_hat = 1 ./(1 .+exp.(-X_ext*w))
grad = X_ext'*(y_hat.-y) / size(X_ext,1)
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
