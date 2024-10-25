# Adding content 2

We will add more functions to the `ImageInspector` package. To plot multiple images at once, we will define two functions. The first one computes an optimal grid size for a given number of images.

```julia
# /src/ImageInspector.jl
function gridsize(n::Int; nrows::Int = -1, ncols::Int = - 1)
    if nrows < 1
        if ncols < 1
            nrows = round(Int, sqrt(n))
            ncols = ceil(Int, n / nrows)
        else
            nrows = ceil(Int, n / ncols)
        end
    else
        ncols = ceil(Int, n / nrows)
    end
    return nrows, ncols
end
```

The second function consists of two methods and converts an array of real numbers to one big image of the appropriate colour type.

```julia
# /src/ImageInspector.jl
imagegrid(x, ind::Int; flip = true, kwargs...) = image(x, ind; flip)

function imagegrid(x, inds; flip = true, sep = 1, kwargs...)
    imgs = image(x, inds; flip)
    n = length(imgs)
    nrows, ncols = gridsize(n; kwargs...)

    h, w = size(imgs[1])
    A = fill(
        eltype(imgs[1])(1), # white color in proper color type
        nrows*h + (nrows + 1)*sep, # height of the reculting image
        ncols*w + (ncols + 1)*sep, # width of the reculting image
    )

    for i in 1:nrows, j in 1:ncols
        k = j + (i - 1) * ncols
        k > n && break

        rows = (1:h) .+ (i - 1)*h .+ i*sep
        cols = (1:w) .+ (j - 1)*w .+ j*sep
        A[rows, cols] = imgs[k]
    end
    return A
end
```

We use the `sep` keyword argument to specify the separator width between images. With all functions defined, we can test them.

```julia
# /examples/example.jl
X = MLDatasets.FashionMNIST(Float64, :train)[:][1];

plot(imagegrid(X, 1:10; nrows = 2, sep = 2); axis = nothing, border = :none)
```

![](image_5.svg)

!!! compat "Optional dependencies:"
    We used the same settings for the `plot` function in all previous examples. Therefore, it makes sense to write an auxiliary function setting attributes for the `plot` function. However, this function will depend on the `Plots` package, and if we add `Plots` to `ImageInspector`, it will significantly slow the loading time. The `Requires` package prevents explicit dependencies (and long load times) by allowing conditional code loading. In our case, we first add `Requires` to the `ImageInspector`.

    ```julia
    julia> pwd()
    ".../ImageInspector"

    (examples) pkg> activate .
    Activating environment at `/path/ImageInspector/Project.toml`

    (ImageInspector) pkg> add Requires
    [...]

    (ImageInspector) pkg> activate

    (examples)
    ```

    Then we create a new file `/src/imageplot.jl` with the following content:

    ```julia
    # /src/imageplot.jl
    using .Plots

    export imageplot

    imageplot(x; flip = true, kwargs...) =  imageplot(image(x; flip); kwargs...)

    function imageplot(x, ind; flip = true, nrows = -1, ncols = -1, sep = 1, kwargs...)
        img = imagegrid(x, ind; flip, nrows, ncols, sep)
        return imageplot(img; kwargs...)
    end

    function imageplot(
        x::AbstractMatrix{<:Color};
        legend = false,
        axis = nothing,
        border = :none,
        kwargs...
    )
        return plot(x; legend, axis, border, kwargs...)
    end
    ```

    We only defined a wrapper function for the `plot` function and exported this function. We use a relative path to the `Plots` package. Then we specify on which package the code depends by defining the `__init__()` function in the `/src/ImageInspector.jl` file.

    ```julia
    # /src/ImageInspector.jl
    using Requires

    function __init__()
        @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" include("imageplot.jl")
    end
    ```

    The `__init__` function has to contain the `@require` macro followed by the package name and its unique UUID (can be found in the [JuliaRegistries](https://github.com/JuliaRegistries/General) for public packages) and the code that should be included.

    Now we can start a new Julia session and test if the loading works properly. If we do not load `Plots`, the `imageplot` function will not be available, as can be seen below.

    ```julia
    julia> x = MLDatasets.CIFAR10(Float64, :train)[1:10][1]

    julia> imageplot(x, 1:10; nrows = 2, sep = 2)
    ERROR: UndefVarError: imageplot not defined
    ```

    After loading the `Plots` package, the `imageplot` function will start working.

    ```julia
    julia> using Plots

    julia> imageplot(x, 1:10; nrows = 2, sep = 1)
    ```

    ![](image_6.svg)
