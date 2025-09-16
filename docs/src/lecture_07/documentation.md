# Documentation


## Docstrings

Writing documentation is a good coding practice. It helps others to understand your code. It may even help the author after working on the code after an extended break. The most used documentation type is the [docstring](https://docs.julialang.org/en/v1/manual/documentation/), a multiline string describing the functionality.

````julia
# /src/ImageInspector.jl
"""
    image(x::AbstractMatrix{T}; flip = true)

Converts a matrix of real numbers to a matrix of `Gray` points. If the keyword argument
`flip` is true, the matrix is transposed.

# Example

```julia-repl
julia> x = [0.1 0.25; 0.4 0.6]
2×2 Matrix{Float64}:
 0.1  0.25
 0.4  0.6

julia> image(x)
2×2 Array{Gray{Float64},2} with eltype Gray{Float64}:
 Gray{Float64}(0.1)   Gray{Float64}(0.4)
 Gray{Float64}(0.25)  Gray{Float64}(0.6)

julia> image(x; flip = false)
2×2 Array{Gray{Float64},2} with eltype Gray{Float64}:
 Gray{Float64}(0.1)  Gray{Float64}(0.25)
 Gray{Float64}(0.4)  Gray{Float64}(0.6)
```
"""
function image(x::AbstractMatrix{T}; flip = true) where {T <: Real}
    xx = flip ? PermutedDimsArray(x, (2, 1)) : x
    return Gray.(xx)
end
````

We first wrote a function header, and then we used one tab as an indentation. Then we wrote a short description of the function. Finally, we wrote usage examples. To get a well-looking format of the docstring, we use [markdown](https://en.wikipedia.org/wiki/Markdown) `# Example` to represent a title. We use the `julia-repl` block to write code. Now we type the function name into the Julia help.


```julia
help?> image
search: image imag

  image(x::AbstractMatrix{T}; flip = true)

  Converts a matrix of real numbers to a matrix of `Gray` points. If the keyword argument
  `flip` is true, the matrix is transposed.

  Example
  ≡≡≡≡≡≡≡≡≡

  julia> x = [0.1 0.25; 0.4 0.6]
  2×2 Matrix{Float64}:
   0.1  0.25
   0.4  0.6

  julia> image(x)
  2×2 Array{Gray{Float64},2} with eltype Gray{Float64}:
   Gray{Float64}(0.1)   Gray{Float64}(0.4)
   Gray{Float64}(0.25)  Gray{Float64}(0.6)

  julia> image(x; flip = false)
  2×2 Array{Gray{Float64},2} with eltype Gray{Float64}:
   Gray{Float64}(0.1)  Gray{Float64}(0.25)
   Gray{Float64}(0.4)  Gray{Float64}(0.6)
```

## Creating reports

Reports may be written externally in Latex. However, when we want to show some code, it may be advantageous to write them directly in Julia and export them to [Jupyter notebooks](https://jupyter.org/). The [Literate](https://fredrikekre.github.io/Literate.jl/v2/) package allows combining Julia code with the [Markdown syntax](https://www.markdownguide.org/cheat-sheet) in a script. We mention the following code, which should be read with the soft wrapping on, as an example:

```julia
# # ImageInspector
#
# ImageInspector is a small package for educational purposes. Its main goal is not presenting functionality, but presenting package structure. This is its short documentation created in the package [Literate](https://fredrikekre.github.io/Literate.jl/v2) which uses the [Markdown](https://www.markdownguide.org/cheat-sheet) syntax.
#
# To use the package, we need to load first the required packages.

using ImageInspector
using Plots


# ## Grayscale images
#
# As a test example, we create the real matrix `img1` representing a circle. We first discretize the domain $[-1,1]$ in `xs`. We assign black colour whenever $x^2 + y^2 \le 1$. Since the white colour is represented by `[1; 1; 1]` and the black colour by `[0; 0; 0]`, we can do it by the following code:

xs = -1:0.001:1
img1 = [x^2 + y^2 > 1 for x in xs, y in xs];

# This is a two-dimensional matrix, which represents a grayscale image. We convert it to an image by calling `image` and then we plot it.

plot(image(img1); axis=nothing, border=:none)
```

The Markdown syntax starts with `#`. Among others, it allows you to use:
- Links such as `[Literate](https://fredrikekre.github.io/Literate.jl/v2)`.
- Variables or latex syntax such as `$[-1,1]$`.

Exporting the script into a notebook is simple.

```julia
julia> import Literate

julia> Literate.notebook("report.jl"; execute=true)
```

The resulting notebook can be found at our [Github](https://github.com/JuliaTeachingCTU/ImageInspector.jl/blob/master/reports/report.ipynb). All required data are in the [reports folder](https://github.com/JuliaTeachingCTU/ImageInspector.jl/tree/master/reports).

# Adding content

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
        nrows*h + (nrows + 1)*sep, # height of the resulting image
        ncols*w + (ncols + 1)*sep, # width of the resulting image
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

!!! warning "Exercise:"
    Add docstrings for all functions in the ImageInspector package.