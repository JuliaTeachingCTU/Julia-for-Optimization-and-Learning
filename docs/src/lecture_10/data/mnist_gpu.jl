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

    for i in 1:n_epochs
        println("Iteration " * string(i))
        Flux.train!(loss, params(m), batches_train, opt)
    end

    if !isempty(filename)
        save_model(m |> cpu, filename)
    end

    return
end
