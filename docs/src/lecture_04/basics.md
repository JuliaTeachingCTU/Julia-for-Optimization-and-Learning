# Package management

Julia provides a simple and intuitive built-in package manager [Pkg.jl](https://julialang.github.io/Pkg.jl/v1/), that handles operations such as installing, updating, and removing packages. The package manager provides an interactive Pkg REPL, which simplifies the package management process. The Pkg REPL can be entered from the Julia REPL simply by pressing `]`. To get back to the Julia REPL, press backspace or `^C`. After entering the Pkg REPL, the screen similar to the following one should appear

```julia
(@v1.5) pkg>
```

Registered packages can be installed using `add` keyword in the following way

```julia
(@v1.5) pkg> add JSON BSON
```

Note that it is possible to install multiple packages at once simply by entering their names separated by a space. It is also possible to install the unregistered package using `add` keyword. However, in this case, we have to specify the package URL

```julia
(@v1.5) pkg> add https://github.com/JuliaLang/Example.jl
```

To list all installed packages, we can use the `status` keyword or its shorthand `st`

```julia
(@v1.5) pkg> st
Status `~/.julia/environments/v1.5/Project.toml`
  [fbb218c0] BSON v0.2.6
  [7876af07] Example v0.5.4 `https://github.com/JuliaLang/Example.jl#master`
  [682c06a0] JSON v0.21.1
```

If we want to update some package (for example because the new version was released), we can do it using the `update` keyword followed by the package name

```julia
(@v1.5) pkg> update Example
```

If the package name is not provided, all installed packages will be updated. Note that, in this case, even the unregistered packages are update based on their name. In fact, the difference between managing the registered and the unregistered package is only during installation.

Any installed package can be removed using `rm` keyword in a similar way as the installation works

```julia
(@v1.5) pkg> rm Example
```

```@raw html
<div class = "info-body">
<header class = "info-header">Non-interactive package manager</header><p>
```

The package manager can be also used in a non-interactive way. For example, packages can be installed in the following way

```julia
using Pkg
Pkg.add(["JSON", "BSON"])
Pkg.add(url = "https://github.com/JuliaLang/Example.jl")
```

Updating and removing a package can be done in a similar way.

```@raw html
</p></div>
```

```@raw html
<div class = "info-body">
<header class = "info-header">JuliaHub</header><p>
```

[JuliaHub](https://juliahub.com) is a web service provided by [Julia Computing](https://juliacomputing.com/) that allows you to explore the ecosystem, build packages, and easily run code in the cloud on large machines and clusters on demand. The most important feature for beginners is the possibility to explore packages, documentation, repositories, or codes in a simple unified way.

```@raw html
</p></div>
```

## Enviroments

So far, we have dealt with the basic management of packages, i.e. how to add, update or remove a package. However, Julia's package manager offers significant advantages over traditional package managers by organizing dependencies into environments. Environments should be familiar to people who uses Python. The difference between python and Julia is, that it is extremely easy to create and manage environments in Julia. Of course, there are utilities, that simplify the work with environments in Python, such as Conda package manager. However, in Julia, it is still simpler, more convenient and the whole process of creating and managing environments can be done within Julia itself.

You may have noticed the (`v1.5`) in the REPL prompt. This lets us know `v1.5` is the active environment. The active environment is the environment that will be modified by `Pkg` commands such as add, rm and update. New enviroment can be set up using `activate` keyword followed by the absolute/relative path

```julia
julia> mkdir("./tutorial") # create an empty folder tutorial
"./tutorial"

(@v1.5) pkg> activate ./tutorial/
 Activating new environment at `/tutorial/Project.toml`

(tutorial) pkg>
```

In the example above, we create an empty directory `tutorial` and activate a new environment inside this directory. Note, that the prompt in the package REPL changed from `@v1.5` to `tutorial`. This lets us know `tutorial` is the active environment, i.e. this environment will be modified by Pkg commands. Now we can check the status of the environment using `st` keyword

```julia
(tutorial) pkg> st
Status `/tutorial/Project.toml` (empty project)
```

Note, that the path that is printed by the `st` command (`/tutorial/Project.toml`) is the location of the active environment's project file. A project file is where Pkg stores metadata for an environment. Because we have not yet added any packages to the environment, the environment is empty

```julia
julia> readdir("./tutorial") # returns and empty array since tutorial is an empty folder
String[]
```

But we can install a package to this environment in the same way as we did it in the section above

```julia
(tutorial) pkg> add JSON BSON

(tutorial) pkg> st
Status `/tutorial/Project.toml`
  [fbb218c0] BSON v0.2.6
  [682c06a0] JSON v0.21.1
```

We can see, that two packages were installed in the environment and we can also check, that the project file was created

```julia
julia> readdir("./tutorial")
2-element Array{String,1}:
 "Manifest.toml"
 "Project.toml"
```

The project file (`Project.toml`) describes the project on a high level, for example the package/project dependencies and compatibility constraints are listed in the project file. The file entries are described below. The manifest file (`Manifest.toml`) is an absolute record of the state of the packages in the environment. It includes exact information about (direct and indirect) dependencies of the project. Given a `Project.toml` + `Manifest.toml` pair, it is possible to [instantiate](https://julialang.github.io/Pkg.jl/v1/api/#Pkg.instantiate) the exact same package environment, which is very useful for reproducibility.
