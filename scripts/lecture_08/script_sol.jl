###########################################
# From last lecture
###########################################

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

###########################################
# Linear regression
###########################################

# EXTRA

σ(z) = 1/(1+exp(-z))
plot(-10:0.01:10, σ)

# Load data

using Plots
using StatsPlots
using RDatasets
using LinearAlgebra
using Query
using Statistics

iris = dataset("datasets", "iris")

iris[1:5,:]

# Exercise

y = iris.PetalWidth
X = hcat(iris.PetalLength, ones(length(y)))

@df iris scatter(
    :PetalLength,
    :PetalWidth;
    label="",
    xlabel = "Petal length",
    ylabel = "Petal width"
)    

# Exercise

w = (X'*X)^(-1)*X'*y
w = (X'*X)^(-1)*(X'*y)
w = X'*X \ X'*y

g(w) = X'*(X*w-y)
w2 = optim([], g, zeros(size(X,2)), GD(1e-4); max_iter=10000)

norm(w-w2)

# EXTRA

w = (X'*X)^(-1)*X'*y
w = (X'*X)^(-1)*(X'*y)
w = X'*X \ X'*y

A = randn(1000,1000)
b = randn(1000)

@time (A*A)*b;
@time A*(A*b);

# Exercise

f_pred(x::Real, w) = ([x 1]*w)[1]
f_pred(x::Real, w) = w[1]*x + w[2]*1

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

###########################################
# Logistic regression
###########################################

# Exercise

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

# EXTRA

iris_reduced2 = iris[iris.Species .!= "setosa", :]
iris_reduced2 = iris_reduced2[:,[3;4;5]]

insertcols!(iris_reduced2, 3, :intercept => 1)
insertcols!(iris_reduced2, 5, :label => iris_reduced2.Species .== "virginica")

isequal(iris_reduced, iris_reduced2)

# Extract data

X = Matrix(iris_reduced[:, 1:3])
y = iris_reduced.label

# Exercise

@df iris_reduced scatter(
    :PetalLength,
    :PetalWidth;
    group = :Species,
    xlabel = "Petal length",
    ylabel = "Petal width",
    legend = :topleft,
)

# EXTRA

ii = iris_reduced.Species .== "virginica"

scatter(iris_reduced.PetalLength[ii,:], iris_reduced.PetalWidth[ii,:];
    xlabel = "Petal length",
    ylabel = "Petal width",
    legend = :topleft,
    label = "virginica"
)

scatter!(iris_reduced.PetalLength[.!ii,:], iris_reduced.PetalWidth[.!ii,:];
    label = "versicolor"
)

# Exercise

function log_reg(X, y, w; max_iter=100, tol=1e-6)
    X_mult = [row*row' for row in eachrow(X)]
    for i in 1:max_iter
        y_hat = σ.(X*w)
        grad = X'*(y_hat.-y) / size(X,1)
        hess = y_hat.*(1 .-y_hat).*X_mult |> mean
        w -= hess \ grad
    end
    return w
end

w = log_reg(X, y, zeros(size(X,2)))

# EXTRA

function g(w, X, y)
    n = size(X,1)
    y_hat = σ.(X*w)
    return X'*(y_hat - y) / n
end

optim([], w -> g(w, X, y), [0;0;0], GD(5e-1); max_iter=1000000)

# Plot the separating hyperplane

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

# Check optimality

y_hat = σ.(X*w)
grad = X'*(y_hat.-y) / size(X,1)
norm(grad)

# Exercise

pred = y_hat .>= 0.5
"Correct number of predictions: " * string(sum(pred .== y))
"Wrong   number of predictions: " * string(sum(pred .!= y))
