function split(X::AbstractMatrix, y::AbstractVector; ratio_train=0.8)
    @assert size(X,1) == size(y,1)
    
    n = size(X,1)
    n_train = Int.(round(ratio_train*n))
    i_rand = randperm(n)
    i_train = i_rand[1:n_train]
    i_test = i_rand[n_train+1:end]

    return X[i_train,:], y[i_train], X[i_test,:], y[i_test]
end

using Statistics

function normalize(X_train, X_test)
    col_means = [mean(X_col) for X_col in eachcol(X_train)]'
    col_std = [std(X_col) for X_col in eachcol(X_train)]'

    return (X_train .- col_means) ./ col_std, (X_test .- col_means) ./ col_std
end

function onehot(y, classes)
    y_onehot = zeros(length(classes), length(y))
    for i in 1:length(classes)
        y_onehot[i,y.==classes[i]] .= 1
    end
    return y_onehot
end

onecold(y, classes) = [classes[findmax(y_part)[2]] for y_part in eachcol(y)]

function prepare_data(X, y; do_normal=true, kwargs...)
    X_train, y_train, X_test, y_test = split(X, y; kwargs...)

    if do_normal
        X_train, X_test = normalize(X_train, X_test)
    end

    X_train = Matrix(X_train')
    X_test = Matrix(X_test')

    classes = unique(y)

    y_train = onehot(y_train, classes)
    y_test = onehot(y_test, classes)

    return X_train, y_train, X_test, y_test, classes
end
