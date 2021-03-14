# Files and modules

When writing a code, especially in large projects, it is essential to organize code in a meaningful way. There are three main ways how to do it. The first one is to split code into multiple files. The second one is to use modules to create global scopes. The last and most advanced is to extract parts of the code that can be generalized into separate packages. All these three approaches can be (and usually are) used together to get even more readable code. In this lecture, we describe how to use these three approaches in Julia.

## Files

The first and most basic approach is to split the code into multiple files. Such files have to be of an appropriate type, i.e., Julia files with `.jl` extension. The code inside the Julia files can be loaded into global scope using the `include` function.

```julia
include("/absolute/path/to/the/file/filename.jl")
include("../relative/path/to/the/file/filename.jl")
```

The  `include` function evaluates the input source file's contents in the global scope of the module where the `include` call occurs. If some file is included multiple times, the file is also evaluated multiple times.

Using separate files to organize code can be very useful. However, this approach also has many disadvantages. We have to pay attention to avoid clashing of the variable/function names from different files since all files are evaluated in the same global scope. This problem can be solved by using modules as described in the following section.

## Modules

Modules allow users to specify what names of variables/functions/types can be visible outside of the module. As we briefly mentioned in the section [Scope of variables](@ref Scope-of-variables), modules in Julia introduce a new global scope. In other words, modules in Julia are separate variable workspaces and provide the following key features:

- defining top-level definitions (aka global variables) without worrying about name conflicts when your code is used together with somebody else's,
- control of the visibility of variables/functions/types outside of the module via exporting,
- control visibility of variables/functions/types from other modules inside the module via importing.

The basic syntax for defining modules is the following. Modules are created using the `module` keyword.

```@example modules
module Points

using LinearAlgebra
import Base: show

export Point, distance

struct Point{T <: Real}
    x::T
    y::T
end

coordinates(p::Point) = (p.x, p.y)
show(io::IO, p::Point) = print(io, coordinates(p))
distance(p::Point, q::Point) = norm(coordinates(q) .- coordinates(p), 2)

end
nothing # hide
```

In the example above, we define module `Points` in which we define custom type `Point` representing a point in two-dimensional Euclidean space. We also define three functions: `coordinates`, `show`, and `distance`. The `coordinates` function is only an auxiliary function that extracts point coordinates and returns them as a tuple. The `show` function defines a custom show for the `Point` type. Note that we use `import Base: show` to add methods to the `show` function. Finally, the `distance` function computes the euclidian distance using the `norm` function from the `LinearAlgebra` module. Note that we have to use the `using` or `import` keyword to import other modules. Also, note that we use the `export` keyword to specify which functions/variables/types names are exported.

## `using` and `import`

All functions and types defined inside the `Points` module are defined and accessible in the module's global scope, i.e., inside the module, we can use them without any restrictions. If we want to use the functionality outside the module, we must use the `using` or `import` keyword. The following table shows some possible ways to use the `using` and` import` keywords.

```@raw html
<table>
    <tbody>
        <tr>
            <th style="text-align: left; vertical-align: middle" vertical-align:middle rowspan="2">Import command</th>
            <th style="text-align: center" colspan="2">Available in global scope via</th>
            <th style="text-align: center" colspan="2">Available for method extension via</th>
        </tr>
        <tr>
            <th style="text-align: left; vertical-align: middle"><code>&lt;name&gt;</code></th>
            <th style="text-align: left; vertical-align: middle"><code>Points.&lt;name&gt;</code></th>
            <th style="text-align: left; vertical-align: middle"><code>&lt;name&gt;</code></th>
            <th style="text-align: left; vertical-align: middle"><code>Points.&lt;name&gt;</code></th>
        </tr>
        <tr>
            <td style="text-align: left; vertical-align: middle"><code>using Points</code></td>
            <td style="text-align: left; vertical-align: middle"><code>Point</code>, <code>distance</code></br> (all exported names)</td>
            <td style="text-align: left; vertical-align: middle"><b><p style="color:#399746">everything</p></b></td>
            <td style="text-align: left; vertical-align: middle"><b><p style="color:#ca3c32">nothing</p></b></td>
            <td style="text-align: left; vertical-align: middle"><b><p style="color:#399746">everything</p></b></td>
        </tr>
        <tr>
            <td style="text-align: left; vertical-align: middle"><code>import Points</code></td>
            <td style="text-align: left; vertical-align: middle"><b><p style="color:#ca3c32">nothing</p></b></td>
            <td style="text-align: left; vertical-align: middle"><b><p style="color:#399746">everything</p></b></td>
            <td style="text-align: left; vertical-align: middle"><b><p style="color:#ca3c32">nothing</p></b></td>
            <td style="text-align: left; vertical-align: middle"><b><p style="color:#399746">everything</p></b></td>
        </tr>
        <tr>
            <td style="text-align: left; vertical-align: middle"><code>using Points: </br> Point, coordinates</code></td>
            <td style="text-align: left; vertical-align: middle"><code>Point</code>, <code>coordinates</code></td>
            <td style="text-align: left; vertical-align: middle"><b><p style="color:#ca3c32">nothing</p></b></td>
            <td style="text-align: left; vertical-align: middle"><b><p style="color:#ca3c32">nothing</p></b></td>
            <td style="text-align: left; vertical-align: middle"><b><p style="color:#ca3c32">nothing</p></b></td>
        </tr>
        <tr>
            <td style="text-align: left; vertical-align: middle"><code>import Points: </br> Point, coordinates</code></td>
            <td style="text-align: left; vertical-align: middle"><code>Point</code>, <code>coordinates</code></td>
            <td style="text-align: left; vertical-align: middle"><b><p style="color:#ca3c32">nothing</p></b></td>
            <td style="text-align: left; vertical-align: middle"><code>Point</code>, <code>coordinates</code></td>
            <td style="text-align: left; vertical-align: middle"><b><p style="color:#ca3c32">nothing</p></b></td>
        </tr>
    </tbody>
</table>
```

```@setup modules1
module Points

using LinearAlgebra
import Base: show

export Point, distance

struct Point{T <: Real}
    x::T
    y::T
end

coordinates(p::Point) = (p.x, p.y)
show(io::IO, p::Point) = print(io, coordinates(p))
distance(p::Point, q::Point) = norm(coordinates(q) .- coordinates(p), 2)

end
```

```@setup modules2
module Points

using LinearAlgebra
import Base: show

export Point, distance

struct Point{T <: Real}
    x::T
    y::T
end

coordinates(p::Point) = (p.x, p.y)
show(io::IO, p::Point) = print(io, coordinates(p))
distance(p::Point, q::Point) = norm(coordinates(q) .- coordinates(p), 2)

end
```

```@setup modules3
module Points

using LinearAlgebra
import Base: show

export Point, distance

struct Point{T <: Real}
    x::T
    y::T
end

coordinates(p::Point) = (p.x, p.y)
show(io::IO, p::Point) = print(io, coordinates(p))
distance(p::Point, q::Point) = norm(coordinates(q) .- coordinates(p), 2)

end
```

```@setup modules4
module Points

using LinearAlgebra
import Base: show

export Point, distance

struct Point{T <: Real}
    x::T
    y::T
end

coordinates(p::Point) = (p.x, p.y)
show(io::IO, p::Point) = print(io, coordinates(p))
distance(p::Point, q::Point) = norm(coordinates(q) .- coordinates(p), 2)

end
```

Consider the following example to help us describe the differences in the use of the `using` and` import` keywords. The goal is to import the `Points` module in one of the ways described in the table above and perform the following four steps.

1. Create an instance `p` of the `Point` type representing point `(4,2)`.
2. Redefine the `coordinates` function to return an array instead of a tuple. Note that this step will change how the `Point` is printed.
3. Create an instance `q` of the `Point` type representing point `(2,2)`.
4. Compute the distance between points `p` and `q` using the `distance` function.

The most common way to import modules is to use the `using` keyword and the module's name. Note that packages are imported in the same way as modules. The reason is that each package's core is a module, as will be described later in this lecture.  As can be seen in the table above, if we use `using .Points` only the exported names are brought to the global scope, i.e., we can call the `Point` type and the `distance` by their names. However, to redefine the `coordinates` function, we have to use `Points.coordinates` syntax.

```@repl modules1
using .Points

p = Point(4,2)

Points.coordinates(p::Point) = [p.x, p.y]

q = Point(2,2)

distance(p, q)
```

Note that we use a dot before the name of the module after the `using` keyword. The reason for that is described [later](@ref Relative-and-absolute-module-paths). Also, note that the print style changed after the redefinition of the `coordinates` function since the `show` function for the `Point` type uses the `coordinates` function.

If we use `import .Points`, no names from the `Points` module are brought into the global scope. However, all names are available for usage and extension via `Points.<name>` syntax. The previous example can be rewritten as follows.

```@repl modules2
import .Points

p = Points.Point(4,2)

Points.coordinates(p::Points.Point) = [p.x, p.y]

q = Points.Point(2,2)

Points.distance(p, q)
```

If we want to use only some functions from the module and do not import all of them, we can use the `using` keyword and specify which names should be imported. In such a case, these names can be used directly. However, it is not possible to extend functions using this approach.

```@repl modules3
using .Points: Point, distance

p = Point(4,2)
q = Point(2,2)

distance(p, q)
```

Similarly, we can also use the `import` keyword that also allows method extension for imported names.

```@repl modules4
import .Points: Point, coordinates, distance

p = Point(4,2)

coordinates(p::Point) = [p.x, p.y]

q = Point(2,2)

distance(p, q)
```

To summarize the above examples, we can say that it is sufficient to use the `using` keyword with the name of the module in most cases. The `import` keyword followed by a module's name and a list of names that should be imported is usually used when we want to extend functions.

## Relative and absolute module paths

In the previous section, we added dots before the module name when used after the `using` or `import` keyword. The reason is that if we try to import a module, the system consults an internal table of top-level modules to look for the given module name. If the module does not exist, the system attempts to `require(:ModuleName)`, which typically results in loading code from an installed package.

If we evaluate a code in the REPL, the code is actually evaluated in the `Main` module, which serves as the default global scope. We can check it using the `@__MODULE__` macro that returns the module in which the macro is evaluated.

```julia
julia> @__MODULE__
Main
```

It means that the `Points` module is actually a submodule of the `Main` module, i.e., it is not a top-level module. It can be seen if we type `Points` in the REPL or if we use the `parentmodule` function that returns a `Module` in which the given module is defined.

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
<div class = "info-body">
<header class = "info-header">Modules and files</header><p>
```

Files and file names are mostly unrelated to modules. Modules are associated only with module expressions. One can have multiple files per module.

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
