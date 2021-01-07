```@setup iris
n_digits = 4
round_a(x::Number) = round(x, digits=n_digits)
round_a(x) = round_a.(x)
```


# Introduction to Flux

Flux is a library for using neural networks. This part will present the basics of Flux on the Iris dataset from the previous lecture. We include the auxiliary functions from the previous lesson into the ```utilities.jl``` file, which we include by
```@example iris
include("utilities.jl")

nothing # hide
```

We set the seed and load the data in the same way as during the last lecture.
```@example iris
using Random
using BSON: @load

Random.seed!(666)

file_name = joinpath("data", "iris.bson")
@load file_name X y y_name

X_train, y_train, X_test, y_test, classes = prepare_data(X, y)

nothing # hide
```

We start by creating the same network.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Find the documentation of Flux.jl online and create the same network as in the previous lecture.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
 To create the neural network, Flux uses ```Chain(???, ???, ...)```, where ```???``` are individual layers. Dense layers are created by ```Dense``` with the correct number of input and output neurons. We also need to specify the activation functions.
```@example iris
using Flux

n_hidden = 5
m = Chain(
    Dense(size(X_train,1), n_hidden, relu),
    Dense(n_hidden, size(y_train,1), identity),
    softmax,
    )

nothing # hide
```
Since ```identity``` is the default argument, it is possible to remove it. However, we recommend to keep it for clarity.
```@raw html
</p></details>
```

To evaluate the whole dataset, we call
```@example iris
m(X_train)
```
Because there are ``3`` classes and ``120`` samples, it returns an array of size ``3\times 120``. Note that the columns are probabilities.

We can access the neural network parameters by using ```params(m)```. At the same time, we can select the second layer of ```m``` by ```m[2]```. This can be naturally combined, so that
```@example iris
params(m[2])
```
returns the parameters of the second layer. Since the second layer has ``5 `` input and ``3`` output neurons, the matrix is of size ``3\times 5`` and the bias is a vector of length ``3``. The parameters ```params(m[2])``` are a tuple of the matrix and the vector. This also implies that the parameters are initialized randomly, and we do not need to take care of it. If for any reason, we need to use a special initialization, we can assign to parameters via
```@example iris
params(m[2])[2] .= [-1;0;1]

nothing # hide
```
Here, we assigned to the bias of the second layer.

To train the model, we first need to specify the loss function. Since it is the cross-entropy between the prediction and the label, it can be done via
```@example iris
import Flux: crossentropy

loss(x,y) = crossentropy(m(x), y)

nothing # hide
```
The ```loss``` function does not have ```m``` as input. Even though there could be an additional input parameter, it is customary to write it without it. To evaluate the loss function, we simply write
```@example iris
loss(X_train, y_train)
```
This computes the loss function on the whole training set. Since Flux is (unlike our implementation from the last lecture) smart, there is no need to take care of individual samples.


```@raw html
<div class = "info-body">
<header class = "info-header">Notation</header><p>
```
While the [standard definition](https://en.wikipedia.org/wiki/Cross_entropy) of cross-entropy is ``\operatorname{loss}(y,\hat y)``, [Flux](https://fluxml.ai/Flux.jl/stable/models/losses/) uses ``\operatorname{loss}(\hat y,y)``.
```@raw html
</p></div>
```

Since we have the model and the loss function, the only remaining required thing for training is the gradient. This can be done in a simple way by
```@example iris
gs = gradient(() -> loss(X_train, y_train), params(m))

nothing # hide
```
The function ```gradient``` takes two inputs. The first one is the function we want to differentiate, and the second one are the parameters. The ```loss``` function needs to be evaluated at the correct points ```X_train``` and ```y_train```. In some applications (adversarial learning), we may need to differentiate with respect to other parameters such as ```X_train```. This can be achieved by changing the second parameters of the ```gradient``` function
```@example iris
gs = gradient(() -> loss(X_train, y_train), params(X_train))

size(gs[X_train])
```
Since ```X_train``` is of shape ``4\times 120``, the gradient needs to have the same size.

```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Use the documentation of Flux.jl once again and train the neural network for 250 iterations with ```ADAM(0.01)``` optimizer and no minibatches. You may want to use the Flux ```update!``` function.

Plot the accuracy on the testing set in every iteration.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
We first create the ```accuracy ``` function as before
```@example iris
accuracy(x, y) = mean(onecold(m(x), classes) .== onecold(y, classes))

nothing # hide
```
To compute the gradient, we first save ```ps = params(m)``` so that we do not need to call ```params``` all the time. The gradient can be computed by ```gs = gradient(() -> loss(X_train, y_train), ps)```. Finally, the update takes the optimizer, the parameters and the gradient and performs the update. The whole code is
```@example iris
ps = params(m)
opt = ADAM(0.01)
max_iter = 250

acc_test = zeros(max_iter)
for i in 1:max_iter
    gs = gradient(() -> loss(X_train, y_train), ps)
    Flux.Optimise.update!(opt, ps, gs)
    acc_test[i] = accuracy(X_test, y_test)
end

nothing # hide
```
```@raw html
</p></details>
```

```@example iris
using Plots # hide

plot(acc_test, xlabel="Iteration", ylabel="Test accuracy", label="", ylim=(-0.01,1.01)) # hide

savefig("Iris_acc.svg") # hide
```

![](Iris_acc.svg)
