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



# Exercise



norm(w-w2)

# Exercise




###########################################
# Logistic regression
###########################################

# Exercise






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

σ(z) = 1/(1+exp(z))

# Exercise







w = log_reg(X, y, zeros(size(X,2)))

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

y_hat = σ.(-X*w)
grad = X'*(y_hat.-y) / size(X,1)
norm(grad)

# Exercise




