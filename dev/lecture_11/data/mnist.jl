using Flux
using Flux: onecold
using MLDatasets

include(joinpath(dirname(@__FILE__), "utilities.jl"))

T = Float32
dataset = MLDatasets.MNIST

X_train, y_train, X_test, y_test = load_data(dataset; T=T, onehot=true)

model = Chain(
    Conv((2, 2), 1 => 16, sigmoid),
    MaxPool((2, 2)),
    Conv((2, 2), 16 => 8, sigmoid),
    MaxPool((2, 2)),
    Flux.flatten,
    Dense(288, size(y_train, 1)),
    softmax,
)

file_name = joinpath("data", "mnist_sigmoid.jld2")
train_or_load!(file_name, model, X_train, y_train)

ii1 = findall(onecold(y_train, 0:9) .== 1)[1:5]
ii2 = findall(onecold(y_train, 0:9) .== 9)[1:5]

for qwe = 0:9
    ii0 = findall(onecold(y_train, 0:9) .== qwe)[1:5]

    p0 = [plot_image(X_train[:, :, :, i:i][:, :, 1, 1]) for i in ii0]
    p1 = [plot_image((model[1:2](X_train[:, :, :, i:i]))[:, :, 1, 1]) for i in ii0]
    p2 = [plot_image((model[1:4](X_train[:, :, :, i:i]))[:, :, 1, 1]) for i in ii0]

    p = plot(p0..., p1..., p2...; layout=(3, 5))
    display(p)
end

p0 = [plot_image(X_train[:, :, :, i:i][:, :, 1, 1]) for i in ii1]
p1 = [plot_image((model[1:2](X_train[:, :, :, i:i]))[:, :, 1, 1]) for i in ii1]
p2 = [plot_image((model[1:4](X_train[:, :, :, i:i]))[:, :, 1, 1]) for i in ii1]

plot(p0..., p1..., p2...; layout=(3, 5))


p0 = [plot_image(X_train[:, :, :, i:i][:, :, 1, 1]) for i in ii2]
p1 = [plot_image((model[1:2](X_train[:, :, :, i:i]))[:, :, 1, 1]) for i in ii2]
p2 = [plot_image((model[1:4](X_train[:, :, :, i:i]))[:, :, 1, 1]) for i in ii2]

plot(p0..., p1..., p2...; layout=(3, 5))

for i in 1:length(model)
    println(size(model[1:i](X_train[:, :, :, 1:1])))
end
