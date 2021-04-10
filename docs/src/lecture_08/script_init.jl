using Plots
using StatsPlots
using RDatasets
using LinearAlgebra
using Query
using Statistics

iris = dataset("datasets", "iris")

@df iris scatter(
    :PetalLength,
    :PetalWidth;
    label="",
    xlabel = "Petal length",
    ylabel = "Petal width"
)    
