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
import RDatasets: dataset

# Introduction to Flux

include("utilities.jl")

Random.seed!(666)

iris = dataset("datasets", "iris")

X = Matrix(iris[:, 1:4])
y = iris.Species

X_train, y_train, X_test, y_test, classes = prepare_data(X', y; dims=2)

n_hidden = 5
m = Chain(
    Dense(size(X_train,1), n_hidden, relu),
    Dense(n_hidden, size(y_train,1), identity),
    softmax,
)

m(X_train)

params(m[2])[2] .= [-1;0;1]

L(x,y) = crossentropy(m(x), y)

L(X_train, y_train)

ps = params(m)
grad = gradient(() -> L(X_train, y_train), ps)

grad = gradient(() -> L(X_train, y_train), params(X_train))

size(grad[X_train])

opt = Descent(0.1)
max_iter = 250

acc_test = zeros(max_iter)
for i in 1:max_iter
    gs = gradient(() -> L(X_train, y_train), ps)
    Flux.Optimise.update!(opt, ps, gs)
    acc_test[i] = accuracy(X_test, y_test)
end

plot(acc_test, xlabel="Iteration", ylabel="Test accuracy", label="", ylim=(-0.01,1.01))

# Loading data

T = Float32
X_train, y_train = MLDatasets.MNIST.traindata(T)
X_test, y_test = MLDatasets.MNIST.testdata(T)

# Exercise



# Exercise



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



# Exercise



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



# Exercise



