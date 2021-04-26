using Base.Iterators: partition
using Random
using BSON
using Statistics
using MLDatasets
using Flux
using Flux: onehotbatch, onecold, crossentropy
using Flux.Data: DataLoader
using Plots
using ImageInspector

T = Float32
X_train, y_train = MLDatasets.MNIST.traindata(T)
X_test, y_test = MLDatasets.MNIST.testdata(T)

# Exercise

unique(y_train)

inds = findall(y_train .== 0)[1:15]

imageplot(1 .- X_train, inds; nrows=3, size=(800,480))

# Exercise

typeof(X_train)

size(X_train)

function reshape_data(X::AbstractArray{<:Real, 3})
    s = size(X)
    return reshape(X, s[1], s[2], 1, s[3])
end

# Loading data

function load_data(dataset; T=Float32, onehot=false, classes=0:9)
    X_train, y_train = dataset.traindata(T)
    X_test, y_test = dataset.testdata(T)
    
    X_train = reshape_data(X_train)
    X_test = reshape_data(X_test)

    if onehot
        y_train = onehotbatch(y_train, classes)
        y_test = onehotbatch(y_test, classes)
    end

    return X_train, y_train, X_test, y_test
end

X_train, y_train, X_test, y_test = load_data(MLDatasets.MNIST; T=T, onehot=true)

# Exercise

load_data(MLDatasets.CIFAR10; T=T, onehot=true)

reshape_data(X::AbstractArray{<:Real, 4}) = X

# Exercise

typeof(load_data(MLDatasets.CIFAR10; T=T, onehot=true))

batchsize = 32
batches = DataLoader((X_train, y_train); batchsize, shuffle = true)

# Bonus

batches = map(partition(randperm(size(y, 2)), batchsize)) do inds
    return (X[:, :, :, inds], y[:, inds])
end

[(X[:, :, :, inds], y[:, inds]) for inds in partition(randperm(size(y, 2)), batchsize)]

# Define model

Random.seed!(666)
m = Chain(
    Conv((2,2), 1=>16, relu),
    MaxPool((2,2)),
    Conv((2,2), 16=>8, relu),
    MaxPool((2,2)),
    flatten,
    Dense(288, size(y_train,1)),
    softmax,
)

L(X, y) = crossentropy(m(X), y)

# Train model

function train_model!(m, L, X, y;
        opt = Descent(0.1),
        batchsize = 128,
        n_epochs = 10,
        file_name = "")

    batches = DataLoader((X, y); batchsize, shuffle = true)

    for _ in 1:n_epochs
        Flux.train!(L, params(m), batches, opt)
    end

    !isempty(file_name) && BSON.bson(file_name, m=m)

    return
end

# Exercise

file_name = "mnist_simple.bson"
train_model!(m, L, X_train, y_train; n_epochs=1, file_name=file_name)

accuracy(x, y) = mean(onecold(m(x)) .== onecold(y))

"Test accuracy = " * string(accuracy(X_test, y_test))

# Exercise

function train_or_load!(file_name, m, args...; force=false, kwargs...)
    
    !isdir(dirname(file_name)) && mkpath(dirname(file_name))

    if force || !isfile(file_name)
        train_model!(m, args...; file_name=file_name, kwargs...)
    else
        m_weights = BSON.load(file_name)[:m]
        Flux.loadparams!(m, params(m_weights))
    end
end

file_name = joinpath("data", "mnist.bson")
train_or_load!(file_name, m, L, X_train, y_train)

"Test accuracy = " * string(accuracy(X_test, y_test))
