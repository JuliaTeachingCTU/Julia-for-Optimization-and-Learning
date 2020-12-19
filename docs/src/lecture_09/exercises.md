```@setup nn
n_digits = 4
round_a(x::Number) = round(x, digits=n_digits)
round_a(x) = round_a.(x)

using BSON: @load

file_name = joinpath("data", "iris.bson")
@load file_name X y y_name

using Random

Random.seed!(666)

function split(X::AbstractMatrix, y::AbstractVector; ratio_train=0.8)
    @assert size(X,1) == size(y,1)
    
    n = size(X,1)
    n_train = Int.(round(ratio_train*n))
    i_rand = randperm(n)
    i_train = i_rand[1:n_train]
    i_test = i_rand[n_train+1:end]

    return X[i_train,:], y[i_train], X[i_test,:], y[i_test]
end

using Statistics

function normalize(X_train, X_test)
    col_means = [mean(X_col) for X_col in eachcol(X_train)]'
    col_std = [std(X_col) for X_col in eachcol(X_train)]'

    return (X_train .- col_means) ./ col_std, (X_test .- col_means) ./ col_std
end

function onehot(y, classes)
    y_onehot = zeros(length(classes), length(y))
    for i in 1:length(classes)
        y_onehot[i,y.==classes[i]] .= 1
    end
    return y_onehot
end

onecold(y, classes) = [classes[findmax(y_part)[2]] for y_part in eachcol(y)]

function prepare_data(X, y; do_normal=true, kwargs...)
    X_train, y_train, X_test, y_test = split(X, y; kwargs...)

    if do_normal
        X_train, X_test = normalize(X_train, X_test)
    end

    X_train = Matrix(X_train')
    X_test = Matrix(X_test')

    classes = unique(y)

    y_train = onehot(y_train, classes)
    y_test = onehot(y_test, classes)

    return X_train, y_train, X_test, y_test, classes
end

function m(x, W1, b1, W2, b2)
    z1 = W1*x .+ b1
    a1 = max.(z1, 0)
    z2 = W2*a1 .+ b2
    a2 = exp.(z2) ./ sum(exp.(z2), dims=1)
end

loss(y_hat, y; ϵ=1e-10) = -sum(y .* log.(y_hat .+ ϵ))

function initialize(n1, n2, n3)
    W1 = randn(n2,n1)
    b1 = randn(n2)
    W2 = randn(n3,n2)
    b2 = randn(n3)
    return W1, b1, W2, b2
end

function grad(x::AbstractVector, y, W1, b1, W2, b2; ϵ=1e-10)
    z1 = W1*x .+ b1
    a1 = max.(z1, 0)
    z2 = W2*a1 .+ b2
    a2 = exp.(z2) ./ sum(exp.(z2))
    l = loss(a2, y; ϵ=ϵ)

    e_z2 = exp.(z2)
    l_part = (- e_z2 * e_z2' + Diagonal(e_z2 .* sum(e_z2))) / sum(e_z2)^2

    l_a2 = - y ./ (a2 .+ ϵ)
    l_z2 = l_part * l_a2 
    l_a1 = W2' * l_z2
    l_z1 = l_a1 .* (a1 .> 0)
    l_x = W1' * l_z1

    l_W2 = l_z2 * a1'
    l_b2 = l_z2
    l_W1 = l_z1 * x'
    l_b1 = l_z1

    return l, l_W1, l_b1, l_W2, l_b2
end

using LinearAlgebra
using Statistics

mean_tuple(d::AbstractArray{<:Tuple}) = [mean([d[k][i] for k in 1:length(d)]) for i in 1:length(d[1])]

predict(X) = m(X, W1, b1, W2, b2)
accuracy(X, y) = mean(onecold(predict(X), classes) .== onecold(y, classes))
```




```@example nn
ratio_train(X_train, X_test) = size(X_train, 2) / (size(X_train,2) + size(X_test,2))
```

```@example nn
X_train, y_train, X_test, y_test, classes = prepare_data(X, y; do_normal=false)
ratio_train(X_train, X_test)
```
```@example nn
X_train, y_train, X_test, y_test, classes = prepare_data(X, y; ratio_train=0.5)
ratio_train(X_train, X_test)
```

```@example nn
X_train, y_train, X_test, y_test, classes = prepare_data(X, y; do_normal=false, ratio_train=0.5)
ratio_train(X_train, X_test)
```





```@example nn
X_train, y_train, X_test, y_test, classes = prepare_data(X[:,3:4], y)

W1, b1, W2, b2 = initialize(size(X_train,1), 5, size(y_train,1))

α = 1e-1
max_iter = 1000
L = zeros(max_iter)
for iter in 1:max_iter
    grad_all = [grad(X_train[:,k], y_train[:,k], W1, b1, W2, b2) for k in 1:size(X_train,2)]
    grad_mean = mean_tuple(grad_all)

    L[iter] = grad_mean[1]
    
    W1 .-= α*grad_mean[2]
    b1 .-= α*grad_mean[3]
    W2 .-= α*grad_mean[4]
    b2 .-= α*grad_mean[5] 
end
```



```@example nn
x_diff = 0.1
x = collect(-2:x_diff:2)
n = length(x)
xy = hcat(repeat(x, n, 1), repeat(x', n, 1)[:])'
z = m(xy, W1, b1, W2, b2)
z = onecold(z, classes)
```



```@example nn
using Plots

function rectangles(x, y, r)
    x = x[:]
    y = y[:]
    xs = hcat(x.-r, x.+r, x.+r, x.-r, x.-r)
    ys = hcat(y.-r, y.-r, y.+r, y.+r, y.-r)
    return xs', ys'
end

colours = (:blue, :red, :green)

y_onecold = onecold(y_test, classes)
for i in 1:length(classes)
    i == 1 ? p = plot : p = plot!
    p(rectangles(xy[1,z.==classes[i]], xy[2,z.==classes[i]], x_diff/2)..., line=(0, 0.2, colours[i]), fill=(0, 0.2, colours[i]), label="")
    scatter!(X_test[1,y_onecold.==classes[i]][:], X_test[2,y_onecold.==classes[i]][:], marker=(8, 0.8, colours[i]), label=y_name[classes[i]], legend=:topleft)
end

savefig("Separation.png")
```

![](Separation.png)




















```@example nn
X_train, y_train, X_test, y_test = split(X, y)
X_train, X_test = normalize(X_train, X_test)

X_train = Matrix(X_train')
X_test = Matrix(X_test')

classes = unique(y)

y_train = onehot(y_train, classes)
y_test = onehot(y_test, classes)

W1, b1, W2, b2 = initialize(size(X_train,1), 50, size(y_train,1))

α = 1e-1
max_iter = 3000
L_train = zeros(max_iter)
L_test = zeros(max_iter)
for iter in 1:max_iter
    grad_all = [grad(X_train[:,k], y_train[:,k], W1, b1, W2, b2) for k in 1:size(X_train,2)]
    grad_mean = mean_tuple(grad_all)
    
    W1 .-= α*grad_mean[2]
    b1 .-= α*grad_mean[3]
    W2 .-= α*grad_mean[4]
    b2 .-= α*grad_mean[5] 

    L_train[iter] = mean(loss(m(X_train, W1, b1, W2, b2), y_train))
    L_test[iter] = mean(loss(m(X_test,  W1, b1, W2, b2), y_test))
end
```


```@example nn
plot(L_train[100:end])
plot!(L_test[100:end])
```







# Exercises

```@raw html
<div class = "homework-body">
<header class = "homework-header">Homework: ???</header><p>
```

```@raw html
</p></div>
```   





```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 1: Showing the contours</header><p>
```
???
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
???
```@raw html
</p></details>
```




```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 2: Overfitting</header><p>
```
???
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
???
```@raw html
</p></details>
```

