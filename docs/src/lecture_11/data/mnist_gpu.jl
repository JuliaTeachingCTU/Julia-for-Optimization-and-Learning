using MLDatasets
using Flux
using BSON
using Random
using Statistics
using Base.Iterators: partition
using Flux: crossentropy, onehotbatch, onecold


accuracy(x, y) = mean(onecold(cpu(m(x))) .== onecold(cpu(y)))

function reshape_data(X::AbstractArray{T, 3}, y::AbstractVector) where T
    s = size(X)
    return reshape(X, s[1], s[2], 1, s[3]), reshape(y, 1, :)
end

function train_model!(m, X, y;
    opt=ADAM(0.001),
    batch_size=128,
    n_epochs=10,
    file_name="")

    loss(x, y) = crossentropy(m(x), y)

    batches_train = map(partition(randperm(size(y, 2)), batch_size)) do inds
        return (gpu(X[:, :, :, inds]), gpu(y[:, inds]))
    end

    for i in 1:n_epochs
        println("Iteration " * string(i))
        Flux.train!(loss, params(m), batches_train, opt)
    end

    !isempty(file_name) && BSON.bson(file_name, m=m|>cpu)

    return
end

function load_data(dataset; onehot=false, T=Float32)
    classes = 0:9
    X_train, y_train = reshape_data(dataset(T, :train)[:]...)
    X_test, y_test = reshape_data(dataset(T, :test)[:]...)
    y_train = T.(y_train)
    y_test = T.(y_test)

    if onehot
        y_train = onehotbatch(y_train[:], classes)
        y_test = onehotbatch(y_test[:], classes)
    end

    return X_train, y_train, X_test, y_test
end

dataset = MLDatasets.MNIST
T = Float32
X_train, y_train, X_test, y_test = load_data(dataset; T=T, onehot=true)

m = Chain(
    Conv((2,2), 1=>16, sigmoid),
    MaxPool((2,2)),
    Conv((2,2), 16=>8, sigmoid),
    MaxPool((2,2)),
    flatten,
    Dense(288, size(y_train,1)), softmax) |> gpu

file_name = joinpath("data", "mnist_sigmoid.bson")
train_model!(m, X_train, y_train; file_name=file_name, n_epochs=100)

accuracy(X_test |> gpu, y_test |> gpu)
