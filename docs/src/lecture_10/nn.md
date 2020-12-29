```@example
using Pkg

using MLDatasets
using Flux
using LinearAlgebra
using ImageCore

using Flux: onehotbatch, onecold, crossentropy, throttle

using CUDA
using Random
using Base.Iterators: partition
using ProgressMeter
using Statistics

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



typeof(X_train)
i = 1
dataset.convert2image(X_train[:,:,1,i])
print(y_train[:,i])


plot_image(x::AbstractArray{T, 4}) where T = Gray.(x[:,:,1,1])
plot_image(x::AbstractArray{T, 3}) where T = Gray.(x[:,:,1])
plot_image(x::AbstractArray{T, 2}) where T = Gray.(x[:,:])


# Create the network and parameters for training



accuracy(x, y) = mean(onecold(cpu(m(x))) .== onecold(cpu(y)))


function train_model!(m, X, y;
        opt=ADAM(0.001),
        batch_size=128,
        n_epochs=10,
        filename="")

    batches_train = map(partition(randperm(size(y, 2)), batch_size)) do inds
        return (gpu(X[:, :, :, inds]), gpu(y[:, inds]))
    end

    loss(x, y) = crossentropy(m(x), y)

    @showprogress for i in 1:n_epochs
        Flux.train!(loss, params(m), batches_train, opt)
        if mod(i, 2) == 0
            i_eval = min(size(X_train,4), 1000)
            println("Epoch = $i. Estimated accuracy = " * string(accuracy(gpu(X[:,:,:,1:i_eval]), gpu(y[:,1:i_eval]))))
        end
    end

    if !isempty(filename)
        save_model(m |> cpu, filename)
    end

    return
end


function train_or_load!(filename, m, X, y; force=false, kwargs...)

    if !isdir(dirname(filename))
        mkpath(dirname(filename))
    end

    if force || !isfile(filename)
        train_model!(m, X, y; filename=filename, kwargs...)
    else
        m_loaded = load_model(filename)
        Flux.loadparams!(m, params(m_loaded))
    end
end

n_epochs = 10
opt = ADAM(0.001)
m = Chain(
    Conv((2,2), 1=>16, relu),
    MaxPool((2,2)),
    Conv((2,2), 16=>8, relu),
    MaxPool((2,2)),
    flatten,
    Dense(288, size(y_train,1)), softmax) |> gpu


train_or_load!("", m, X_train, y_train; force=true, n_epochs=n_epochs, opt=opt)



train_model!(m, X_train, y_train)




m2 = Chain(
    Conv((2,2), 1=>16, sigmoid),
    MaxPool((2,2)),
    Conv((2,2), 16=>8, sigmoid),
    MaxPool((2,2)),
    flatten,
    Dense(288, size(y_train,1)), softmax) |> gpu

train_model!(m2, X_train, y_train)


# Print the testing accuracy
n_test = 1000
println("Test accuracy = " * string(accuracy(gpu(X_test[:,:,:,1:n_test]), gpu(y_test[:,1:n_test]))))
```

