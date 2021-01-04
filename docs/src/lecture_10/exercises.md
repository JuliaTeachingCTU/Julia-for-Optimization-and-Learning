```@setup gpuu
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
    X_train, y_train = reshape_data(dataset.traindata(T)...)
    X_test, y_test = reshape_data(dataset.testdata(T)...)
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
```



# Exercises



```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise 1: Operations on GPUs</header><p>
```
While most operations in a computer are performed on CPUs (central processing unit), neural networks are trained on other hardware such as GPUs (graphics processing unit) or specialized hardware such as TPUs. 

To use GPUs, include packages Flux and CUDA. Then generate a radnom matrix ``A\in \mathbb{R}^{100\times 100}`` and a random vector ``b\in \mathbb{R}^{100}``. They will be stored in the memory and the computation will be performed on the CPU. To save them to the GPU memory and allow computations on the GPU, use ```gpu(A)``` or the more commonly used ```A |> gpu```.

Investigate how long it takes to perform multiplication ``Ab`` if both objects are on CPU, GPU or if they are saved differently. Check that both multiplications resulted in the same vector.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
The beginning is simple
```@example gpu
using Flux
using CUDA

A = randn(100,100)
b = randn(100)
A_g = A |> gpu
b_g = b |> gpu

nothing # hide
```
To test the time, we measure the time for multiplication
```julia
@time A*b;
@time A_g*b_g;
@time A_g*b;
```
```julia
0.069785 seconds (294.76 k allocations: 15.585 MiB, 14.75% gc time)
0.806913 seconds (419.70 k allocations: 22.046 MiB)
0.709140 seconds (720.01 k allocations: 34.860 MiB, 1.53% gc time)
```
We see that all three times are different. Can we infer anything from it? No! The problem is that during a first call to a function, some compilation usually takes place. We should always compare only the second time.
```julia
@time A*b;
@time A_g*b_g;
@time A_g*b;
```
```julia
0.000083 seconds (1 allocation: 896 bytes)
0.000154 seconds (11 allocations: 272 bytes)
0.475280 seconds (10.20 k allocations: 957.125 KiB)
```
We conclude that while the computation on CPU and GPU takes approximately the same time, when using the mixed types, it takes much longer. 

To compare the results, the first idea would be to run
```julia
norm(A*b - A_g*b_g)
```
which would result in an error. We cannot use any operations on arrays stored both on CPU and GPU. The correct way is to move the GPU array to CPU and only then to compute the norm
```@example gpu
using LinearAlgebra

norm(A*b - cpu(A_g*b_g))
```
The norm is surprisingly large. Checking the types
```@example gpu
(typeof(A), typeof(A_g))
```
we realize that one of the arrays is stored in ```Float64``` while the second one in ```Float32```. To to the different number of saved digits, the multiplication results in this error.
```@raw html
</p></details>
```








The previous exercise did not show any differences when performing a matrix-vector multiplication. The probable reason was that the running times were too short. The next exercise shows the time difference when applied to a larger problem.  









```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Load the MNIST dataset and the model saved in ```data/mnist.bson```. Compare the evaluation of all samples from the testing set when done on CPU and GPU. For the latter, you need to convert the model to GPU as well via ```m |> gpu```.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
We load the data, model and convert everything to GPU
```julia
using CUDA

m = Chain(
    Conv((2,2), 1=>16, relu),
    MaxPool((2,2)),
    Conv((2,2), 16=>8, relu),
    MaxPool((2,2)),
    flatten,
    Dense(288, size(y_train,1)), softmax)

file_name = joinpath("data", "mnist.bson")
train_or_load!(file_name, m, X_train, y_train)

m_g = m |> gpu
X_test_g = X_test |> gpu
```
Nowe we can measure the evaluation time. Remember that before doing so, we need to compile all the functions by evaluating at least one sample.
```julia
m(X_test[:,:,:,1:1])
m_g(X_test_g[:,:,:,1:1])

@time m(X_test);
@time m_g(X_test_g);
```
```julia
1.190033 seconds (40.24 k allocations: 1.069 GiB, 21.73% gc time)
0.071805 seconds (789 allocations: 27.641 KiB)
```
Using the GPU speeded the computation by more than ten times. 
```@raw html
</p></details>
```








```@raw html
<div class = "info-body">
<header class = "info-header">Computation on GPU</header><p>
```
Make sure that all computation is performed either on CPU or GPU. Do not mix them. When computing on GPU, make sure that all computations are fast. One important example is
```julia
accuracy(x, y) = mean(onecold(cpu(m(x))) .== onecold(cpu(y)))
```
Because ```onecold``` accesses individual elements of an array, it is extremely slow on GPU. For this reason, we need to move the arrays on CPU first.

Another thing to remember is to always convert all objects to CPU before saving them.
```@raw html
</p></div>
```















```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```
Load the network from ```data/mnist.bson```. Then create a ``10\times 10`` table, where the ``(i+1,j+1)`` entry is the number of samples, where digit ``i`` was wrongly classified as digit ``j``.

Convert the table into a dataframe and add labels.

Finally, plot all figures which are ``9`` but were classified as ``7``.
```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```
First, we load the data as many times before
```@example gpuu
m = Chain(
    Conv((2,2), 1=>16, relu),
    MaxPool((2,2)),
    Conv((2,2), 16=>8, relu),
    MaxPool((2,2)),
    flatten,
    Dense(288, size(y_train,1)), softmax)

file_name = joinpath("data", "mnist.bson")
train_or_load!(file_name, m, X_train, y_train)
```
To create the table, we specify that the entries are ```Int```. We save the labels and predictions. Since we do not use the second argument to ```onecold```, the entries of ```y``` and ```y_hat``` are between 1 and 10. Then we run a foor loop over all misclassified samples which adds to the error counts. 
```@example gpuu
y_hat = onecold(m(X_test))
y = onecold(y_test)

errors = zeros(Int, 10, 10)
for i in findall(y_hat .!= y)
    errors[y[i], y_hat[i]] += 1
end
```
To create the dataframe, we use ```df = DataFrame(errors)```. Note that it prints correctly integers and not strings. We change labels x1 to miss0, ... Similarly we add a first rows with the actual labels. 
```@example gpuu
using DataFrames

df = DataFrame(errors)

names!(df, [Symbol("miss$(i)") for i in 0:9])
insert!(df, 1, string.(0:9), :label)

nothing # hide
```
It is surprising that the largest number of misclassifications is 9 into 7. One would expect 8 to 0, 5 to 6 or 8 to 9. To plot all these images, we find the misclassified indices and use the function ```plot_image```. Since ```y``` are stored in the 1:10 format, we need to shift the indices by one. Since the number of 11 is a prime number, we cannot plot it in a ```layout```. We use a hack and add an empty plot ```p_empty```.
```@example gpuu
i1 = 9
i2 = 7

p = [plot_image(X_test[:,:,:,i]) for i in findall((y.==i1+1) .& (y_hat.==i2+1))]
p_empty = plot(legend=false,grid=false,foreground_color_subplot=:white) 

plot(p..., p_empty; layout=(6,2)) 

savefig("miss.svg") # hide
```

![](miss.svg)


???



```@raw html
</p></details>
```

The correct answer is
```@example gpuu
df # hide
```















```julia
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
```













```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Some text that describes the exercise

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Solution

```@raw html
</p></details>
```

















```@raw html
<div class = "exercise-body">
<header class = "exercise-header">Exercise:</header><p>
```

Some text that describes the exercise

```@raw html
</p></div>
<details class = "solution-body">
<summary class = "solution-header">Solution:</summary><p>
```

Solution

```@raw html
</p></details>
```

