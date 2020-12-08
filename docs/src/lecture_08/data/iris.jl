using MLDatasets
using BSON
using BSON: @load
using Plots
using Statistics

function prepare_data(file_name)
    X = Iris.features()
    y_orig = Iris.labels()

    y_name = unique(y_orig)
    y = zeros(length(y_orig))
    for i in 1:length(y_name)
        y[y_orig .== y_name[i]] .= i
    end

    X = Matrix(X')
    y = Int64.(y[:])

    BSON.bson(file_name, X=X, y=y, y_name=y_name)
end

function normalize_data(X)
    col_mean = mean(X, dims=1)
    col_std = std(X, dims=1)
    return (X .- col_mean) ./ col_std
end

file_name = joinpath("src", "lecture_08", "data", "iris.bson")
prepare_data(file_name)
