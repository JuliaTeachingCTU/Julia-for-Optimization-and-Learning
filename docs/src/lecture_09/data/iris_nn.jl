using BSON: @load
using LinearAlgebra


file_name = joinpath("src", "lecture_09", "data", "iris.bson")
@load file_name X y y_name


function m(x, y, W1, b1, W2, b2; ϵ=1e-10)
    z1 = W1*x .+ b1
    a1 = 1 ./ (1 .+ exp.(-z1))
    z2 = W2*a1 .+ b2
    a2 = exp.(z2) ./ sum(exp.(z2))
    return -sum(y .* log.(a2 .+ ϵ))
end


function grad(x, y, W1, b1, W2, b2; ϵ=1e-10)
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


function onehot(y, i_class)
    y_onehot = zeros(length(i_class), length(y))
    for i in 1:length(i_class)
        y_onehot[i, y.==i_class[i]] .= 1
    end
    return y_onehot
end


X = Matrix(X')
y = onehot(y, unique(y))

n1 = size(X,1)
n2 = 5
n3 = size(y,1)
W1 = randn(n2,n1)
b1 = randn(n2)
W2 = randn(n3,n2)
b2 = randn(n3)

k = 1
m(X[:,k], y[:,k], W1, b1, W2, b2)



grad1 = grad(X[:,k], y, W1, b1, W2, b2)[2]
grad2 = zero(W1)


[(W_pert=zero(W1); W_pert[i,j] = ϵ; (m_grad(x,y,W1.+W_pert,b1,W2,b2)[1] - m_grad(x,y,W1,b1,W2,b2)[1]) / ϵ) for i in 1:size(W1,1), j in 1:size(W1,2)]

m_grad(x, y, W1, b1, W2, b2)[4]
[(W_pert=zero(W2); W_pert[i,j] = ϵ; (m_grad(x,y,W1,b1,W2.+W_pert,b2)[1] - m_grad(x,y,W1,b1,W2,b2)[1]) / ϵ) for i in 1:size(W2,1), j in 1:size(W2,2)]



m_grad()
