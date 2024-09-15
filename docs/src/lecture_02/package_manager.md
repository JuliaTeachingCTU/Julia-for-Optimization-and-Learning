## Package Manager

Julia provides a large package library. To add a package, we enter the package REPL by pressing `]` and install a package by the keyword `add`.

```julia
(@v1.10) pkg> add Plots
```

Another option is to use the `Pkg` package to add it directly from the standard REPL.

```julia
julia> using Pkg

julia> Pkg.add("Plots")
```

We return from the package REPL `(@v1.10) pkg>` to the standard REPL `julia>` by pressing escape.