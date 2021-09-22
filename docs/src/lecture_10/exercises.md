```@setup nn
using RDatasets
using Plots
using Random
using Statistics
using LinearAlgebra

function split(X, y::AbstractVector; dims=1, ratio_train=0.8, kwargs...)
    n = length(y)
    size(X, dims) == n || throw(DimensionMismatch("..."))

    n_train = round(Int, ratio_train*n)
    i_rand = randperm(n)
    i_train = i_rand[1:n_train]
    i_test = i_rand[n_train+1:end]

    return selectdim(X, dims, i_train), y[i_train], selectdim(X, dims, i_test), y[i_test]
end

function normalize(X_train, X_test; dims=1, kwargs...)
    col_means = mean(X_train; dims)
    col_std = std(X_train; dims)

    return (X_train .- col_means) ./ col_std, (X_test .- col_means) ./ col_std
end

function onehot(y, classes)
    y_onehot = falses(length(classes), length(y))
    for (i, class) in enumerate(classes)
        y_onehot[i, y .== class] .= 1
    end
    return y_onehot
end

onecold(y, classes) = [classes[argmax(y_col)] for y_col in eachcol(y)]

function prepare_data(X, y; do_normal=true, do_onehot=true, kwargs...)
    X_train, y_train, X_test, y_test = split(X, y; kwargs...)

    if do_normal
        X_train, X_test = normalize(X_train, X_test; kwargs...)
    end

    classes = unique(y)

    if do_onehot
        y_train = onehot(y_train, classes)
        y_test = onehot(y_test, classes)
    end

    return X_train, y_train, X_test, y_test, classes
end

# SimpleNet

struct SimpleNet{T<:Real}
    W1::Matrix{T}
    b1::Vector{T}
    W2::Matrix{T}
    b2::Vector{T}
end

SimpleNet(n1, n2, n3) = SimpleNet(randn(n2, n1), randn(n2), randn(n3, n2), randn(n3))

function (m::SimpleNet)(x)
    z1 = m.W1*x .+ m.b1
    a1 = max.(z1, 0)
    z2 = m.W2*a1 .+ m.b2
    return exp.(z2) ./ sum(exp.(z2), dims=1)
end

function grad(m::SimpleNet, x::AbstractVector, y; ϵ=1e-10)
    z1 = m.W1*x .+ m.b1
    a1 = max.(z1, 0)
    z2 = m.W2*a1 .+ m.b2
    a2 = exp.(z2) ./ sum(exp.(z2), dims=1)
    l = -sum(y .* log.(a2 .+ ϵ))

    e_z2 = exp.(z2)
    l_part = (- e_z2 * e_z2' + Diagonal(e_z2 .* sum(e_z2))) / sum(e_z2)^2

    l_a2 = - y ./ (a2 .+ ϵ)
    l_z2 = l_part * l_a2
    l_a1 = m.W2' * l_z2
    l_z1 = l_a1 .* (a1 .> 0)
    l_x = m.W1' * l_z1

    l_W2 = l_z2 * a1'
    l_b2 = l_z2
    l_W1 = l_z1 * x'
    l_b1 = l_z1

    return l, l_W1, l_b1, l_W2, l_b2
end

mean_tuple(d::AbstractArray{<:Tuple}) = Tuple([mean([d[k][i] for k in 1:length(d)]) for i in 1:length(d[1])])

predict(X) = m(X)
accuracy(X, y) = mean(onecold(predict(X), classes) .== onecold(y, classes))
```

```@setup nn
iris = dataset("datasets", "iris")

X = Matrix(iris[:, 1:4])
y = iris.Species
```

# [Exercises](@id l9-exercises)

!!! homework "Homework: Optimal setting"
    Perform an analysis of hyperparameters of the neural network from this lecture. Examples may include network architecture, learning rate (stepsize), activation functions or normalization.

    Write a short summary (in LaTeX) of your suggestions.

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise 1: Keyword arguments</header>
<div class="admonition-body">
```

Keyword arguments (often denoted as `kwargs` but any name may be used) specify additional arguments which do not need to be used when the function is called. We recall the `prepare_data` function written earlier.

```@example nn
function prepare_data(X, y; do_normal=true, do_onehot=true, kwargs...)
    X_train, y_train, X_test, y_test = split(X, y; kwargs...)

    if do_normal
        X_train, X_test = normalize(X_train, X_test; kwargs...)
    end

    classes = unique(y)

    if do_onehot
        y_train = onehot(y_train, classes)
        y_test = onehot(y_test, classes)
    end

    return X_train, y_train, X_test, y_test, classes
end
nothing # hide
```

All keyword arguments `kwargs` will be passed to the `split` and `normalize` functions. The benefit is that we do not need to specify the keyword arguments for `split` in `prepare_data`.

Recall that `split` takes `ratio_split` as an optional argument. Write a one-line function ```ratio_train``` which gets the training and testing sets and computes the ratio of samples in the training set. Then call the `prepare_data` with:
- no normalization and the default split ratio;
- normalization and the split ratio of 50/50;

```@raw html
</div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The ```ratio_train``` function reads:

```@example nn
ratio_train(X_train, X_test) = size(X_train, 2) / (size(X_train,2) + size(X_test,2))
nothing # hide
```

The first case uses the default ratio; hence we do not pass `ratio_split`. Since we do not want to use normalization, we need to pass `do_normal=false`.

```@example nn
X_train, y_train, X_test, y_test, classes = prepare_data(X', y; dims=2, do_normal=false)
println("Ratio train/test = ", ratio_train(X_train, X_test))
```

The second case behaves the other way round. We use the default normalization; thus, we do not need to specify `do_normal=true` (even though it may be a good idea). We need to pass `ratio_train=0.5`.

```@example nn
X_train, y_train, X_test, y_test, classes = prepare_data(X', y; dims=2, ratio_train=0.5)
println("Ratio train/test = ", ratio_train(X_train, X_test))
```

```@raw html
</p></details>
```

The goal of the following exercise is to show the prediction function graphically. For this reason, we will consider only two features. All the following exercises use the data with the fixed seed for reproducibility.

```@example nn
Random.seed!(666)
X_train, y_train, X_test, y_test, classes = prepare_data(X[:,3:4]', y; dims = 2)

nothing # hide
```

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise 2: Showing the contours</header>
<div class="admonition-body">
```

Use the same training procedure for 1000 iterations to train the classifier with the new data. Then plot a graph depicting which classes are predicted at subregions of ``[-2,2]\times [-2,2]``. Moreover, depict the testing data in this graph.

**Hint**: use the `heatmap` function.

```@raw html
</div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

The procedure for training the network is the same as during the lecture.

```@example nn
m = SimpleNet(size(X_train,1), 5, size(y_train,1))

α = 1e-1
max_iter = 1000
for iter in 1:max_iter
    grad_all = [grad(m, X_train[:,k], y_train[:,k]) for k in 1:size(X_train,2)]
    grad_mean = mean_tuple(grad_all)

    m.W1 .-= α*grad_mean[2]
    m.b1 .-= α*grad_mean[3]
    m.W2 .-= α*grad_mean[4]
    m.b2 .-= α*grad_mean[5] 
end

nothing # hide
```

The prediction function is `m([x;y])`. Since this creates a one-hot representation, we need to convert it into a one-cold representation. However, it is not possible to use `onecold(m([x; y]), classes)`, which would result in one of the three string labels. We need to use `onecold(m([x; y]), 1:3)` to convert it to a real number. Then we call the `heatmap` function. Since we will later use plotting in a loop, we assign the graph to `plt`.

```@example nn
colours = [:blue, :red, :green]

xs = -2:0.01:2
plt = heatmap(xs, xs, (x, y) -> onecold(m([x; y]), 1:3)[1];
    color = colours,
    opacity = 0.2,
    axis = false,
    ticks = false,
    cbar = false,
    legend = :topleft,
)

nothing # hide
```

To add the predictions of the testing set, we find the indices `inds` of samples from each class. Then we add them via the `scatter!` plot. We keep `colours` from the previous part to have the same colours. Since we plotted in a loop, we need to `display` the plot.

```@example nn
for (i, class) in enumerate(classes)
    inds = findall(onecold(y_test, classes) .== class)
    scatter!(plt, X_test[1, inds], X_test[2, inds];
        label = class,
        marker=(8, 0.8, colours[i]),
    )
end
display(plt)

savefig("Separation.svg") # hide
```

```@raw html
</p></details>
```

![](Separation.svg)

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise 3: Overfitting</header>
<div class="admonition-body">
```

This exercise shows the well-known effect of overfitting. Since the model sees only the training set, it may fit it too perfectly (overfit it) and generalize poorly to the testing set of unseen examples.

Consider the same data as in the previous exercise but train a network with 25 hidden neurons for 25000 iterations. Plot the loss function values on the training and testing sets. Then plot the same prediction visualization as in the previous exercise for both testing and training sets. Describe what went wrong.

```@raw html
</div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

We first specify the loss function.

```@example nn
loss(X, y; ϵ = 1e-10) = mean(-sum(y .* log.(m(X) .+ ϵ); dims = 1))
nothing # hide
```

Then we train the network as before. The only change is that we need to save the training and testing objective.

```@example nn
m = SimpleNet(size(X_train,1), 25, size(y_train,1))

α = 1e-1
max_iter = 25000
L_train = zeros(max_iter)
L_test = zeros(max_iter)
for iter in 1:max_iter
    grad_all = [grad(m, X_train[:,k], y_train[:,k]) for k in 1:size(X_train,2)]
    grad_mean = mean_tuple(grad_all)
    
    m.W1 .-= α*grad_mean[2]
    m.b1 .-= α*grad_mean[3]
    m.W2 .-= α*grad_mean[4]
    m.b2 .-= α*grad_mean[5] 

    L_train[iter] = loss(X_train, y_train)
    L_test[iter] = loss(X_test, y_test)
end
```

Then we plot it. We ignore the first nine iterations, where the loss is large there. We see the classical procedure of overfitting. While the loss function on the training set decreases steadily, on the testing set, it decreases first, and after approximately 100 iterations, it starts increasing. This behaviour may be prevented by several techniques, which we discuss in the following lecture.

```@example nn
plot(L_train[10:end], xlabel="Iteration", label="Training loss", legend=:topleft)
plot!(L_test[10:end], label="Testing loss")

savefig("Train_test.svg") # hide
```

![](Train_test.svg)

We create the contour plot in the same way as in the previous exercise.

```@example nn
plt = heatmap(xs, xs, (x, y) -> onecold(m([x; y]), 1:3)[1];
    color = colours,
    opacity = 0.2,
    axis = false,
    ticks = false,
    cbar = false,
    legend = :topleft,
)

for (i, class) in enumerate(classes)
    inds = findall(onecold(y_test, classes) .== class)
    scatter!(plt, X_test[1, inds], X_test[2, inds];
        label = class,
        marker=(8, 0.8, colours[i]),
    )
end
display(plt)

savefig("Separation2.svg") # hide
```

![](Separation2.svg)

```@example nn
plt = heatmap(xs, xs, (x, y) -> onecold(m([x; y]), 1:3)[1];
    color = colours,
    opacity = 0.2,
    axis = false,
    ticks = false,
    cbar = false,
    legend = :topleft,
)

for (i, class) in enumerate(classes)
    inds = findall(onecold(y_train, classes) .== class)
    scatter!(plt, X_train[1, inds], X_train[2, inds];
        label = class,
        marker=(8, 0.8, colours[i]),
    )
end
display(plt)

savefig("Separation3.svg") # hide
```

![](Separation3.svg)

The separation on the testing set is quite good, but it could be better for the two bottommost green circles (iris virginica). The model predicted (in the background) the red colour (iris versicolor) there. This is wrong. The reason is clear from the picture depicting the training set. The classifier tried to perfectly fit the boundary between the green and red points, making an outward-pointing tip. This is precisely overfitting and the reason for the misclassification on the testing set.

```@raw html
</p></details>
```

![](Separation2.svg)
![](Separation3.svg)

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise 4: Generalization</header>
<div class="admonition-body">
```

The contour plots from Exercises 2 and 3 are strikingly different, especially in the top-left and bottom-right corners. Why is that?

```@raw html
</div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Since the dataset does not contain any data in the top-left or bottom-right corners, it does not know what to predict. From its perspective, both separations are very good.

!!! info "Generalization:"
    If a classifier does not have any data in some region, it may predict anything there, including predictions with no sense.

```@raw html
</p></details>
```

```@raw html
<div class="admonition is-category-exercise">
<header class="admonition-header">Exercise 5: Universal approximation of neural networks (theory)</header>
<div class="admonition-body">
```

Proof the theorem about universal approximation of neural networks.

```@raw html
</div></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Since piecewise linear functions are dense in the set of continuous functions, there is a piecewise linear function ``h`` such that ``\|h-g\|_{\infty}\le \varepsilon``. Assume that ``h`` has kinks at ``x_1<\dots<x_n`` with function values ``h(x_i)=y_i`` for ``i=1,\dots,n``. Defining

```math
d_i = \frac{y_{i+1}-y_i}{x_{i+1}-x_i},
```

then ``h`` has the form

```math
h(x) = y_i + d_i(x-x_i) \qquad\text{ for }x\in [x_i,x_{i+1}].
```

It is not difficult to show that

```math
h(x) = y_1 + \sum_{i=1}^n(d_i-d_{i-1})\operatorname{max}\{x-x_i,0\},
```

where we defined ``d_0=0``.

Then ``h`` can be represented as the following network with two layers:
- Dense layer with ``n`` hidden neurons and ReLU activation function. Neuron ``i`` has weight ``1`` and bias ``-x_i``.
- Dense layer with ``1`` output neurons and identity activation function. Connection ``i`` has weight ``d_i-d_{i-1}`` and the joint bias is ``y_1``.
This finishes the proof.

```@raw html
</p></details>
```
