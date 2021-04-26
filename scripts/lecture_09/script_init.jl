using Pkg
Pkg.activate(".")
Pkg.instantiate()

using RDatasets
using Random
using Statistics
using LinearAlgebra
using Plots

iris = dataset("datasets", "iris")
randn(10)
plot(1:10)
