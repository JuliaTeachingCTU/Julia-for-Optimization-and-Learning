###############################
# Load data
###############################

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

###############################
# Linear regression
###############################

using Plots
using RDatasets
using StatsPlots

iris = dataset("datasets", "iris")

y = iris.PetalWidth
X = hcat(iris.PetalLength, ones(length(y)))











