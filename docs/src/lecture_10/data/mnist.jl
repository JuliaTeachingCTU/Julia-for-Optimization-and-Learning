using MLDatasets
using Flux
using LinearAlgebra
using ImageCore


dataset = MLDatasets.MNIST
train = dataset.traindata(Float32)
test = dataset.testdata(Float32)

typeof(train)

i = 1
dataset.convert2image(train[1][:,:,i])
print(train[2][i])


softmax(x; dims=1) = exp.(x) ./ sum(exp.(x), dims=dims)



function m_fun(x, y_hat, W1, b1; ϵ=1e-6)
    z = W1*x .+ b1
    y = exp.(z) ./ sum(exp.(z))
    return -sum(y .* log.(y_hat .+ ϵ))
end



function m_grad(x, y, W1, b1, W2, b2; ϵ=1e-10)
    z1 = W1*x .+ b1
    a1 = 1 ./ (1 .+ exp.(-z1))
    z2 = W2*a1 .+ b2
    a2 = exp.(z2) ./ sum(exp.(z2))
    l = -sum(y .* log.(a2 .+ ϵ))

    e_z2 = exp.(z2)
    l_part = (- e_z2 * e_z2' + Diagonal(e_z2 .* sum(e_z2))) / sum(e_z2)^2

    l_a2 = - y ./ (a2 .+ ϵ)
    l_z2 = l_part * l_a2 
    l_a1 = W2' * l_z2
    l_z1 = a1 .* (1 .-a1) .* l_a1
    l_x = W1' * l_z1

    l_W2 = l_z2 * a1'
    l_b2 = l_z2
    l_W1 = l_z1 * x'
    l_b1 = l_z1

    return l, l_W1, l_b1, l_W2, l_b2
end

T = Float64
n = 10
m = 5
k = 3
x = T.(randn(n,6))
W1 = T.(randn(m,n))
b1 = T.(randn(m))
W2 = T.(randn(k,m))
b2 = T.(randn(k))
y = T.(rand(k))
y = y./sum(y)

m_grad(x, y, W1, b1, W2, b2)[2]
[(W_pert=zero(W1); W_pert[i,j] = ϵ; (m_grad(x,y,W1.+W_pert,b1,W2,b2)[1] - m_grad(x,y,W1,b1,W2,b2)[1]) / ϵ) for i in 1:size(W1,1), j in 1:size(W1,2)]

m_grad(x, y, W1, b1, W2, b2)[4]
[(W_pert=zero(W2); W_pert[i,j] = ϵ; (m_grad(x,y,W1,b1,W2.+W_pert,b2)[1] - m_grad(x,y,W1,b1,W2,b2)[1]) / ϵ) for i in 1:size(W2,1), j in 1:size(W2,2)]



m_grad()
