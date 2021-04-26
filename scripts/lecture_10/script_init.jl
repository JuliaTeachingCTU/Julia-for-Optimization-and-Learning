using Pkg
Pkg.activate(".")
Pkg.instantiate()

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

plot(1:10)

iris = dataset("datasets", "iris")

T = Float32
X_train, y_train = MLDatasets.MNIST.traindata(T)
X_train = reshape(X_train, size(X_train,1), size(X_train,2), 1, size(X_train,3))
y_train = onehotbatch(y_train, 0:9)
MLDatasets.MNIST.testdata(T)
MLDatasets.CIFAR10.traindata(T)

imageplot(1 .- X_train, 1:3; nrows=1, size=(800,480))

m_aux = Chain(
    Conv((2,2), 1=>16, relu),
    MaxPool((2,2)),
    Conv((2,2), 16=>8, relu),
    MaxPool((2,2)),
    flatten,
    Dense(288, size(y_train,1)),
    softmax,
)

L_aux(X, y) = crossentropy(m_aux(X), y)

batches_aux = DataLoader((X_train, y_train); batchsize=64, shuffle = true)

gradient(() -> L_aux(X_train[:,:,:,1:10], y_train[:,1:10]), params(m_aux))

onecold(m_aux(X_train[:,:,:,1:10]))
