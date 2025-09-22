using MLDatasets
using Flux
using JLD2
using Random
using Statistics
using Base.Iterators: partition
using Flux: crossentropy, onehotbatch, onecold
using Plots
using Pkg

if haskey(Pkg.project().dependencies, "CUDA")
    using CUDA
else
    gpu(x) = x
end

evaldir(args...) = joinpath(dirname(@__FILE__), args...)

accuracy(model, x, y) = mean(onecold(cpu(model(x))) .== onecold(cpu(y)))

function reshape_data(X::AbstractArray{T,3}, y::AbstractVector) where {T}
    s = size(X)
    return reshape(X, s[1], s[2], 1, s[3]), reshape(y, 1, :)
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

function train_model!(
    model,
    X,
    y;
    opt=Adam(0.001),
    batch_size=128,
    n_epochs=10,
    file_name="",
)

    loss(x, y) = crossentropy(model(x), y)

    batches_train = map(partition(randperm(size(y, 2)), batch_size)) do inds
        return (gpu(X[:, :, :, inds]), gpu(y[:, inds]))
    end

    for epoch in 1:n_epochs
        @show epoch
        Flux.train!(loss, Flux.params(model), batches_train, opt)
    end

    !isempty(file_name) && jldsave(file_name; model_state=Flux.state(model) |> cpu)

    return
end

function train_or_load!(file_name, model, args...; force=false, kwargs...)

    !isdir(dirname(file_name)) && mkpath(dirname(file_name))

    if force || !isfile(file_name)
        train_model!(model, args...; file_name=file_name, kwargs...)
    else
        model_state = JLD2.load(file_name, "model_state")
        Flux.loadmodel!(model, model_state)
    end
end

plot_image(x::AbstractArray{T,2}) where {T} = plot(Gray.(x'), axis=nothing)

function plot_image(x::AbstractArray{T,4}) where {T}
    @assert size(x, 4) == 1
    plot_image(x[:, :, :, 1])
end

function plot_image(x::AbstractArray{T,3}) where {T}
    @assert size(x, 3) == 1
    plot_image(x[:, :, 1])
end
