using Pkg
Pkg.activate(".")
Pkg.instantiate()

using BenchmarkTools
using Distributions
using GLM
using HypothesisTests
using LinearAlgebra
using Plots
using Random
using RDatasets
using SpecialFunctions
using Statistics

Random.seed!(666)

plot(0:0.1:10, gamma;
    xlabel="x",
    ylabel="gamma(x): log scale",
    label="",
    yscale=:log10,
)

xs_aux = rand(Uniform(-1, 1), 100)

histogram(xs_aux)

d_aux = Normal()
pdf(d_aux, 1)
cdf(TDist(10), 1)
fit(Normal, xs_aux)

OneSampleTTest(xs_aux)

wages_aux = dataset("plm", "Snmesp")
model_aux = lm(@formula(W ~ 1 + N + Y + I + K + F), wages_aux)
model_aux = glm(@formula(W ~ 1 + N + Y + I + K + F), wages_aux, Normal(), IdentityLink())

X_aux = randn(10, 4)
eigen_aux = eigen(X_aux'*X_aux)

@time eigen(X_aux'*X_aux);
