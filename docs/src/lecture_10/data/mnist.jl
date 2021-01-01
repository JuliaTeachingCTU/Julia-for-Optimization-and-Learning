using Pkg

using MLDatasets
using Flux
using LinearAlgebra

using Flux: onehotbatch, onecold, crossentropy, throttle

using BSON
using CUDA
using Random
using Base.Iterators: partition
using Statistics

using Colors
using Plots


T = Float32
dataset = MLDatasets.MNIST

Random.seed!(666)


function reshape_data(X::AbstractArray{T, 3}, y::AbstractVector) where T
    s = size(X)
    return reshape(X, s[1], s[2], 1, s[3]), reshape(y, 1, :)
end

function reshape_data(X::AbstractArray{T, 4}, y::AbstractVector) where T
    return X, reshape(y, 1, :)
end

function load_data(dataset; onehot=false, T=Float32)
    classes = 0:9
    X_train, y_train = reshape_data(dataset.traindata(T)[1], dataset.traindata(T)[2])
    X_test, y_test = reshape_data(dataset.testdata(T)[1], dataset.testdata(T)[2])
    y_train = T.(y_train)
    y_test = T.(y_test)

    if onehot
        y_train = onehotbatch(y_train[:], classes)
        y_test = onehotbatch(y_test[:], classes)
    end

    return X_train, y_train, X_test, y_test
end

# Load the data
X_train, y_train, X_test, y_test = load_data(dataset; T=T, onehot=true);



plot_image(x::AbstractArray{T, 4}) where T = plot_image(x[:,:,1,1])
plot_image(x::AbstractArray{T, 3}) where T = plot_image(x[:,:,1])
plot_image(x::AbstractArray{T, 2}) where T = plot(Gray.(x[:,:]'))




i = 3
plot_image(X_train[:,:,:,i])
print(y_train[:,i])



accuracy(x, y) = mean(onecold(m(x)) .== onecold(y))

function train_model!(m, X, y;
        opt=ADAM(0.001),
        batch_size=128,
        n_epochs=10,
        file_name="")

    batches_train = map(partition(randperm(size(y, 2)), batch_size)) do inds
        return (X[:, :, :, inds], y[:, inds])
    end

    loss(x, y) = crossentropy(m(x), y)

    for i in 1:n_epochs
        Flux.train!(loss, params(m), batches_train, opt)
    end

    !isempty(file_name) && BSON.bson(file_name, m=m)

    return
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


m = Chain(
    Conv((2,2), 1=>16, relu),
    MaxPool((2,2)),
    Conv((2,2), 16=>8, relu),
    MaxPool((2,2)),
    flatten,
    Dense(288, size(y_train,1)), softmax)

file_name = joinpath("data", "nn_mnist.bson")
train_or_load!(file_name, m, X_train, y_train)





n_test = 1000
println("Test accuracy = " * string(accuracy(X_test[:,:,:,1:n_test], y_test[:,1:n_test])))


welfpwefkpowe


efklwoefoiwhefoiwefio



a = 1
X = reshape(1:10, 1, :)
batch_size = 3
y = randn(3,10)
opt = Descent(1)

batches_train = map(partition(randperm(size(y, 2)), batch_size)) do inds
    return (X[:, inds], y[:, inds])
end


batches_train = [(X[:, inds], y[:, inds]) for inds in partition(randperm(size(y, 2)), batch_size)]


function loss(x)
    println(x)
    return 0
end


for i in 1:n_epochs
    Flux.train!(loss, params(a), batches_train, opt)
end



m2 = Chain(
    Conv((2,2), 1=>16, sigmoid),
    MaxPool((2,2)),
    Conv((2,2), 16=>8, sigmoid),
    MaxPool((2,2)),
    flatten,
    Dense(288, size(y_train,1)), softmax) |> gpu

train_model!(m2, X_train, y_train)


# Print the testing accuracy



p = []
for i in 1:5
    #p = plot_image(X_train[:,:,:,i:i])
    p[i] = plot_image(m[1:4](X_train[:,:,:,ii[i]:ii[i]] |> gpu) |> cpu)
    #display(p)
end


p1 = plot(Gray.(m[1:4](X_train[:,:,:,ii[1]:ii[1]] |> gpu) |> cpu)[:,:,1,1])
p2 = plot(Gray.(m[1:4](X_train[:,:,:,ii[2]:ii[2]] |> gpu) |> cpu)[:,:,1,1])
p3 = plot_image(m[1:4](X_train[:,:,:,ii[3]:ii[3]] |> gpu) |> cpu)
p4 = plot_image(m[1:4](X_train[:,:,:,ii[4]:ii[4]] |> gpu) |> cpu)

plot(p1, p2)


ii0 = findall(onecold(y_train, 0:9) .== 0)[1:5]
ii1 = findall(onecold(y_train, 0:9) .== 1)[1:5]
ii2 = findall(onecold(y_train, 0:9) .== 9)[1:5]

p0 = [plot(Gray.(m[1:3](X_train[:,:,:,i:i] |> gpu) |> cpu)[:,:,1,1], axis=([], false)) for i in ii0]
p1 = [plot(Gray.(m[1:3](X_train[:,:,:,i:i] |> gpu) |> cpu)[:,:,1,1]) for i in ii1]
p2 = [plot(Gray.(m[1:4](X_train[:,:,:,i:i] |> gpu) |> cpu)[:,:,1,1]) for i in ii2]

plot(p0..., p1..., p2...; layout=(3,5))

plot(p0...)

qwe = plot_image(X_train[:,:,:,i:i])





plot(p1, p2)



p1 = plot(Gray.(X_train[:,:,1,1]), axis=([], false))
p2 = plot(Gray.(X_train[:,:,1,2]), axis=([], false))
plot(p1, p2; layout = (2,1))