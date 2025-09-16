# Files and modules

When writing code, it is essential to organize it effectively. There are three main ways of achieving this:
1. Split code into multiple files.
2. Use modules to create global scopes.
3. Create separate packages by extracting code with general functionality.
These three approaches are often used together. This lecture describes how to use them in Julia.

## Files

The first and most basic approach is to split code into multiple files. Such files have to be of an appropriate type, i.e., Julia files with the `.jl` extension. These files can be loaded into the global scope by the `include` function.

```julia
include("/absolute/path/to/the/file/filename.jl")
include("../relative/path/to/the/file/filename.jl")
```

The `include` function evaluates the source file content in the global scope of the module, where the `include` call occurs. If a file is included multiple times, it is also evaluated multiple times.

Even though using separate files to organize code can be very useful, this approach also has several disadvantages. For example, since all files are evaluated in the same global scope, we have to avoid clashes of variable/function names from different files.  This problem can be solved by using modules as described in the following section.

!!! info "Main module:"
    If we run a code in the REPL, the code is evaluated in the `Main` module, which serves as the default global scope. We can check this by the `@__MODULE__` macro that returns the module in which the macro is evaluated.

    ```julia
    julia> @__MODULE__
    Main
    ```

    The `parentmodule` function determines the module containing the (first) definition of a generic function.

    ```julia
    julia> foo() = 1
    foo (generic function with 1 method)

    julia> parentmodule(foo)
    Main
    ```

## Modules

Modules allow users to specify which data from the module is visible outside of the module. In the section [Scope of variables](@ref Scope-of-variables), we briefly mentioned that modules in Julia introduce a new global scope. In other words, modules in Julia are separate variable workspaces that provide three key features. They all help to prevent unexpected name clashes.

- They define top-level definitions (global variables) without worrying about name conflicts.
- They control the visibility of variables/functions/types outside of the module via exporting.
- They control the visibility of variables/functions/types from other modules via importing.

The following example defines the module `Points`. We create it with the `module` keyword and load the `LinearAlgebra` package by the `using` keyword. Then we use the `export` keyword to export the `Point` type and the `distance` function. Finally, we write the actual content of the module.

```@example modules
module Points

using LinearAlgebra

export Point, distance

struct Point{T <: Real}
    x::T
    y::T
end

coordinates(p::Point) = (p.x, p.y)
Base.show(io::IO, p::Point) = print(io, coordinates(p))
distance(p::Point, q::Point) = norm(coordinates(q) .- coordinates(p), 2)

end
nothing # hide
```

Assume now that we want to load this module from a different file. Since each package core is a module, packages are loaded in the same way as modules. We need to specify `using Main.Points` or `using .Points` because we defined the package in the `Main` scope. If we loaded an external package `Points`, we would use `using Points`. After loading a package, we can directly access all the exported data.

```@repl modules
using .Points # alternatively using Main.Points

p = Point(4,2)
q = Point(2,2)
distance(p, q)
```

It is also possible to access all non-exported functions and types. To do so, we need to specify which module they are defined in. For example, we can call the non-exported `coordinates` function by the following syntax:

```@repl modules
Points.coordinates(p)
Points.coordinates(q)
```

When writing a module, we have to decide which functions and types we want to export. The rule of thumb is to export only the data end-users should use.

To redefine or extend an imported function, we need to specify the module. We can use the following way to redefine the `distance` function:

```@example modules
using .Points: coordinates

function Points.distance(p::Point, q::Point)
    d = sqrt(sum(abs2, coordinates(q) .- coordinates(p)))
    return "Distance is $d"
end

nothing # hide
```

We can see the same syntax in the `Points` module, where we extend the `show` function from the `Base` module. We used the `using .Points: coordinates` syntax to call the `coordinates` function without specifying the module name.

```@repl modules
p = Point(4,2)
q = Point(2,2)
distance(p, q)
```

Besides the `using` keyword, Julia also provides the `import` keyword to import modules and packages. Its behaviour is slightly different; for more information, see the [official documentation](https://docs.julialang.org/en/v1/manual/modules/#Summary-of-module-usage).

!!! compat "Relative and absolute module paths:"
    In the previous section, we added a dot before the module name in the `using` keyword. The reason is that if we import a module, the system consults an internal table of top-level modules to find the given module name. If the module does not exist, the system attempts to `require(:ModuleName)`, which typically results in loading code from an installed package.
    However, if we evaluate code in the REPL, the code is evaluated in the `Main` module. Then `Points` are not in a top-level module but in a submodule of `Main`.

    ```julia
    julia> Points
    Main.Points

    julia> parentmodule(Points)
    Main
    ```

    Non-top-level modules can be loaded by both absolute and relative paths.

    ```julia
    using Main.Points
    using .Points
    ```

    Adding one more leading dot moves the path one additional level up in the module hierarchy. For example, `using ..Points` would look for `Points` in the enclosing module for `Main` rather than `Main` itself.

!!! compat "Modules and files:"
    Since modules are associated only with module expressions, files are largely unrelated to modules. One can have multiple files in a module.

    ```julia
    module MyModule

    include("file1.jl")
    include("file2.jl")

    end
    ```

    It is also possible to have multiple modules in a file.

    ```julia
    module MyModule1
    ...
    end

    module MyModule2
    ...
    end
    ```