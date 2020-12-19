using LinearAlgebra
using Statistics
using Random
using BSON: @load

file_name = joinpath("src", "lecture_09", "data", "iris.bson")
@load file_name X y y_name

function split(X::AbstractMatrix, y::AbstractVector; ratio_train=0.8)
    @assert size(X,1) == size(y,1)

    n = size(X,1)
    n_train = Int.(round(ratio_train*n))
    i_rand = randperm(n)
    i_train = i_rand[1:n_train]
    i_test = i_rand[n_train+1:end]

    return X[i_train,:], y[i_train], X[i_test,:], y[i_test]
end

X_train, y_train, X_test, y_test = split(X, y)

X_train = Matrix(X_train')
X_test = Matrix(X_test')

function onehot(y)
    classes = unique(y)
    y_onehot = zeros(length(classes), length(y))
    for i in 1:length(classes)
        y_onehot[i,y.==classes[i]] .= 1
    end
    return y_onehot
end

onecold(y) = [findmax(y_part)[2] for y_part in eachcol(y)]

y_train = onehot(y_train)
y_test = onehot(y_test)

function m(x, W1, b1, W2, b2)
    z1 = W1*x .+ b1
    #a1 = 1 ./ (1 .+ exp.(-z1))
    a1 = max.(z1, 0)
    z2 = W2*a1 .+ b2
    a2 = exp.(z2) ./ sum(exp.(z2), dims=1)
end

function initialize(n1, n2, n3)
    W1 = randn(n2,n1)
    b1 = randn(n2)
    W2 = randn(n3,n2)
    b2 = randn(n3)
    return W1, b1, W2, b2
end

W1, b1, W2, b2 = initialize(size(X_train,1), 10, size(y_train,1))

function grad(x::AbstractVector, y, W1, b1, W2, b2; ϵ=1e-10)
    z1 = W1*x .+ b1
    #a1 = 1 ./ (1 .+ exp.(-z1))
    a1 = max.(z1, 0)
    z2 = W2*a1 .+ b2
    a2 = exp.(z2) ./ sum(exp.(z2))
    l = -sum(y .* log.(a2 .+ ϵ))

    e_z2 = exp.(z2)
    l_part = (- e_z2 * e_z2' + Diagonal(e_z2 .* sum(e_z2))) / sum(e_z2)^2

    l_a2 = - y ./ (a2 .+ ϵ)
    l_z2 = l_part * l_a2
    l_a1 = W2' * l_z2
    #l_z1 = a1 .* (1 .-a1) .* l_a1
    l_z1 = (a1 .> 0) .* l_a1
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

α = 1e-1
max_iter = 1000
L = zeros(max_iter)
@time for iter in 1:max_iter
    grad_all = [grad(X_train[:,k], y_train[:,k], W1, b1, W2, b2) for k in 1:size(X_train,2)]
    grad_mean = mean_tuple(grad_all)

    L[iter] = grad_mean[1]

    W1 .-= α*grad_mean[2]
    b1 .-= α*grad_mean[3]
    W2 .-= α*grad_mean[4]
    b2 .-= α*grad_mean[5]
end

using Plots

plot(L)

predict(X) = m(X, W1, b1, W2, b2)
accuracy(X, y) = mean(onecold(predict(X)) .== onecold(y))

accuracy(X_train, y_train)
accuracy(X_test, y_test)