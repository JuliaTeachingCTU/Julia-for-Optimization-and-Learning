# Files and modules

When writing a code, especially in large projects, it is essential to organize code in a meaningful way. There are three main ways how to do it. The first one is to split code into multiple files. The second one is to use modules to create global scopes. The last and most advanced is to extract parts of the code that can be generalized into separate packages. These three approaches can be (and usually are) used together to get even more readable code. In this lecture, we describe how to use these three approaches in Julia.

## Files

The first and most basic approach is to split the code into multiple files. Such files have to be of an appropriate type, i.e., Julia files with `.jl` extension. The code inside the Julia files can be loaded into global scope using the `include` function.

```julia
include("/absolute/path/to/the/file/filename.jl")
include("../relative/path/to/the/file/filename.jl")
```

The  `include` function evaluates the input source file's contents in the module's global scope where the `include` call occurs. If some file is included multiple times, the file is also evaluated multiple times.

Using separate files to organize code can be very useful. However, this approach also has many disadvantages. For example, we have to avoid clashing the variable/function names from different files since all files are evaluated in the same global scope. This problem can be solved by using modules as described in the following section.

```@raw html
<div class = "info-body">
<header class = "info-header">Main module</header><p>
```

If we evaluate a code in the REPL, the code is actually evaluated in the `Main` module, which serves as the default global scope. We can check it using the `@__MODULE__` macro that returns the module in which the macro is evaluated.

```julia
julia> @__MODULE__
Main
```

It means that if we evaluate code in the REPL, it is actually evaluated in the Main module. It can be easily checked using the `parentmodule` function that determines the module containing the (first) definition of a generic function.

```julia
julia> foo() = 1
foo (generic function with 1 method)

julia> parentmodule(foo)
Main
```

```@raw html
</p></div>
```

## Modules

Modules allow users to specify what names of variables/functions/types can be visible outside of the module. As we briefly mentioned in the section [Scope of variables](@ref Scope-of-variables), modules in Julia introduce a new global scope. In other words, modules in Julia are separate variable workspaces and provide the following key features:

- defining top-level definitions (aka global variables) without worrying about name conflicts when your code is used together with somebody else's,
- control of the visibility of variables/functions/types outside of the module via exporting,
- control visibility of variables/functions/types from other modules inside the module via importing.

The basic syntax for defining modules is the following. Modules are created using the `module` keyword.

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

In the example above, we define module `Points`. Firstly we import the `LinearAlgebra` package using the `using` keyword, which is the most common way to import modules. Note that packages are imported in the same way as modules. The reason is that each package's core is a module, as we will be described later in this lecture.  If we use `using Points` only the exported names are brought to the global scope. In our example, we use the `export` keyword to export the `Point` type and the `distance` function.

```@repl modules
using .Points

p = Point(4,2)
q = Point(2,2)
distance(p, q)
```

It is also possible to use all other functions and types that are not exported from a module. However, in such a case, we have to specify in which module the functions/types are defined. For example, we can call the `coordinates` function, which is not exported using the following syntax.

```@repl modules
Points.coordinates(p)
Points.coordinates(q)
```

When writing a module, we have to decide which functions/types export. Generally, only the ones that are supposed to be used by the end-user should be exported.

When we want to redefine or extend some function from a module imported by the `using` keyword, we have to use the same syntax as in the example above. It means if we want to redefine the `distance` function, we can do it in the following way.

```@example modules
using .Points: coordinates

function Points.distance(p::Point, q::Point)
    d = sqrt(sum(abs2, coordinates(q) .- coordinates(p)))
    return "Distance is $d"
end

nothing # hide
```

Note that even if the function is exported, we have to specify in which module the function is defined. We can see the same syntax in the definition of the `Points` module, where we extend the `show` function from the `Base` module. Also, note that we used `using .Points: coordinates` syntax to allow calling the `coordinates` function without specifying the module name.

```@repl modules
p = Point(4,2)
q = Point(2,2)
distance(p, q)
```

Besides the `using` keyword, Julia also provides the `import` keyword to importing modules and packages. The behavior of the `import` keyword is slightly different. For more information, see the [official documentation](https://docs.julialang.org/en/v1/manual/modules/#Summary-of-module-usage).

```@raw html
<div class = "info-body">
<header class = "info-header">Relative and absolute module paths</header><p>
```

In the previous section, we added dots before the module name when used after the `using` keyword. The reason is that if we try to import a module, the system consults an internal table of top-level modules to look for the given module name. If the module does not exist, the system attempts to `require(:ModuleName)`, which typically results in loading code from an installed package.

However, if we evaluate code in the REPL, the code is evaluated in the `Main` module. It means that the `Points` in not a top-level module, but a submodule of the `Main` module. It can be seen if we type `Points` in the REPL or use the `parentmodule` function that returns a `Module` in which the given module is defined.

```julia
julia> Points
Main.Points

julia> parentmodule(Points)
Main
```

There are two possible ways how to load non-top-level modules: we can use the absolute or relative path to them. In our case, we have the following two options.

```julia
using Main.Points
using .Points
```

Adding more leading periods moves up additional levels in the module hierarchy. For example, `using ..Points` would look for `Points` in `Main`'s enclosing module rather than in `Main` itself. However, `Main` is its own parent, so that the result will be the same in this concrete example.

```@raw html
</p></div>
```

```@raw html
<div class = "info-body">
<header class = "info-header">Modules and files</header><p>
```

Files are mainly unrelated to modules, since modules are associated only with module expressions. One can have multiple files per module.

```julia
module MyModule

include("file1.jl")
include("file2.jl")

end
```

It is also perfectly fine to have multiple modules per file.

```julia
module MyModule1
...
end

module MyModule2
...
end
```

```@raw html
</p></div>
```
