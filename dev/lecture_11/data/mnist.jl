using BSON
using Flux
using Flux: onehotbatch, onecold
using MLDatasets

Core.eval(Main, :(using Flux)) # hide

function reshape_data(X::AbstractArray{T, 3}, y::AbstractVector) where T
    s = size(X)
    return reshape(X, s[1], s[2], 1, s[3]), reshape(y, 1, :)
end

function train_or_load!(file_name, m, X, y; force=false, kwargs...)

    !isdir(dirname(file_name)) && mkpath(dirname(file_name))

    if force || !isfile(file_name)
        train_model!(m, X, y; file_name=file_name, kwargs...)
    else
        m_loaded = BSON.load(file_name)[:m]
        Flux.loadparams!(m, params(m_loaded))
    end
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

using Plots

plot_image(x::AbstractArray{T, 2}) where T = plot(Gray.(x'), axis=nothing)

function plot_image(x::AbstractArray{T, 4}) where T
    @assert size(x,4) == 1
    plot_image(x[:,:,:,1])
end

function plot_image(x::AbstractArray{T, 3}) where T
    @assert size(x,3) == 1
    plot_image(x[:,:,1])
end


T = Float32
dataset = MLDatasets.MNIST

X_train, y_train, X_test, y_test = load_data(dataset; T=T, onehot=true)





m = Chain(
    Conv((2,2), 1=>16, sigmoid),
    MaxPool((2,2)),
    Conv((2,2), 16=>8, sigmoid),
    MaxPool((2,2)),
    flatten,
    Dense(288, size(y_train,1)), softmax)

file_name = joinpath("data", "mnist_sigmoid.bson")
train_or_load!(file_name, m, X_train, y_train)




ii1 = findall(onecold(y_train, 0:9) .== 1)[1:5]
ii2 = findall(onecold(y_train, 0:9) .== 9)[1:5]


for qwe = 0:9
    ii0 = findall(onecold(y_train, 0:9) .== qwe)[1:5]

    p0 = [plot_image(X_train[:,:,:,i:i][:,:,1,1]) for i in ii0]
    p1 = [plot_image((m[1:2](X_train[:,:,:,i:i]))[:,:,1,1]) for i in ii0]
    p2 = [plot_image((m[1:4](X_train[:,:,:,i:i]))[:,:,1,1]) for i in ii0]

    p = plot(p0..., p1..., p2...; layout=(3,5))
    display(p)
end

p0 = [plot_image(X_train[:,:,:,i:i][:,:,1,1]) for i in ii1]
p1 = [plot_image((m[1:2](X_train[:,:,:,i:i]))[:,:,1,1]) for i in ii1]
p2 = [plot_image((m[1:4](X_train[:,:,:,i:i]))[:,:,1,1]) for i in ii1]

plot(p0..., p1..., p2...; layout=(3,5))


p0 = [plot_image(X_train[:,:,:,i:i][:,:,1,1]) for i in ii2]
p1 = [plot_image((m[1:2](X_train[:,:,:,i:i]))[:,:,1,1]) for i in ii2]
p2 = [plot_image((m[1:4](X_train[:,:,:,i:i]))[:,:,1,1]) for i in ii2]

plot(p0..., p1..., p2...; layout=(3,5))

for i in 1:length(m)
    println(size(m[1:i](X_train[:,:,:,1:1])))
end
