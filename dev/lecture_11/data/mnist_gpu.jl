using MLDatasets
using Flux

include(joinpath(dirname(@__FILE__), "utilities.jl"))

dataset = MLDatasets.MNIST
T = Float32
X_train, y_train, X_test, y_test = load_data(dataset; T=T, onehot=true)

model = Chain(
    Conv((2, 2), 1 => 16, sigmoid),
    MaxPool((2, 2)),
    Conv((2, 2), 16 => 8, sigmoid),
    MaxPool((2, 2)),
    Flux.flatten,
    Dense(288, size(y_train, 1)),
    softmax,
) |> gpu

file_name = joinpath("data", "mnist_sigmoid.jld2")
train_model!(model, X_train, y_train; file_name=file_name, n_epochs=100)

accuracy(model, X_test, y_test)
