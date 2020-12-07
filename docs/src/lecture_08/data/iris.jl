using MLDatasets
using BSON
using BSON: @load
using Plots
using Statistics

function prepare_data(file_name)
    X = Iris.features()
    y_orig = Iris.labels()

    y_name = unique(y_orig)
    y = zeros(length(y_orig))
    for i in 1:length(y_name)
        y[y_orig .== y_name[i]] .= i
    end

    X = Matrix(X')
    y = Int64.(y[:])

    BSON.bson(file_name, X=X, y=y, y_name=y_name)
end


function modify_data(X, y, y_name)
    ii = y .>= 2
    return X[ii,3:4], y[ii] .>= 2.5, y_name[2:3]
end


function normalize_data(X)
    col_mean = mean(X, dims=1)
    col_std = std(X, dims=1)
    return (X .- col_mean) ./ col_std
end


file_name = joinpath("src", "lecture_08", "data", "iris.bson")

BSON.load(file_name)
@load file_name X y y_name

X, y, y_name = modify_data(X, y, y_name)



#X = normalize_data(X)


#scatter(X[y.==0,1], X[y.==0,2], label=y_name[1], legend=:topleft, xlabel="Petal length (normalized)", ylabel="Petal width (normalized)")
#scatter!(X[y.==1,1], X[y.==1,2], label=y_name[2])





X = hcat(X, repeat([1], size(X,1)))





n = size(X,1)





X_mult = [row*row' for row in eachrow(X)]

w = zeros(size(X,2))

α = 1

for i in 1:10
    y_hat = 1 ./(1 .+exp.(-X*w))
    grad = X'*(y_hat.-y) / n
    hess = y_hat.*(1 .-y_hat).*X_mult |> mean
    #println(w)
    #println(grad)
    #println(hess)
    w -= hess \ grad
    #w -= α*grad
end

y_hat = 1 ./(1 .+exp.(-X*w))

sum((y_hat.>0.5) .==y)


scatter(X[y.==0,1], X[y.==0,2], label=y_name[1], legend=:topleft, xlabel="Petal length", ylabel="Petal width")
scatter!(X[y.==1,1], X[y.==1,2], label=y_name[2])

# Hyperplane w[1]*x[1] + w[2]*x[2] + w[3] = 0

f_hyper = x -> (-w[3]-w[1]*x)/w[2]

x_lim = [minimum(X[:,1])-0.1; maximum(X[:,1])+0.1]


plot!(x_lim, f_hyper.(x_lim), label="Separating hyperplane", line=(:black,3), ylim=(minimum(X[:,2])-0.1,maximum(X[:,2])+0.1))

