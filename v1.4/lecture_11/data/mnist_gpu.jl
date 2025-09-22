using MLDatasets
using Flux

include(joinpath(dirname(@__FILE__), ("utilities.jl")))

dataset = MLDatasets.MNIST
T = Float32
X_train, y_train, X_test, y_test = load_data(dataset; T=T, onehot=true)

# model = Chain(
#     Conv((2, 2), 1 => 16, sigmoid),
#     MaxPool((2, 2)),
#     Conv((2, 2), 16 => 8, sigmoid),
#     MaxPool((2, 2)),
#     Flux.flatten,
#     Dense(288, size(y_train, 1)),
#     softmax,
# ) |> gpu

model = Chain(
    Conv((2, 2), 1 => 16, relu),
    MaxPool((2, 2)),
    Conv((2, 2), 16 => 8, relu),
    MaxPool((2, 2)),
    Flux.flatten,
    Dense(288, size(y_train, 1)),
    softmax,
)

file_name = evaldir("mnist.jld2")
train_or_load!(file_name, model, X_train, y_train; n_epochs=100, force=true)

accuracy(model, X_test, y_test)
