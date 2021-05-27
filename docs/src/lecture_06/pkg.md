# Package management

Julia provides a simple and intuitive built-in package manager that handles installing, updating and removing packages. The package manager offers an interactive Pkg REPL, which simplifies the package management process. We enter the Pkg REPL from the Julia REPL by pressing `]`. To return to the Julia REPL, press backspace or `^C`. After entering the Pkg REPL, a screen similar to the following one will appear:

```julia
(@v1.5) pkg>
```

Registered packages can be installed by the `add` keyword.

```julia
(@v1.5) pkg> add JSON BSON
```

It is possible to install multiple packages by entering their names separated by spaces. The `add` keyword can also install unregistered packages by specifying the URL of a git repository.

```julia
(@v1.5) pkg> add https://github.com/JuliaLang/Example.jl
```

We can use both absolute and relative path to a local git repository.

```julia
(@v1.5) pkg> add /absolute/or/relative/path/MyPackage
```

The `status` keyword, abbreviated as `st`, can be used to list all installed packages.

```julia
(@v1.5) pkg> st
Status `~/.julia/environments/v1.5/Project.toml`
  [fbb218c0] BSON v0.2.6
  [7876af07] Example v0.5.4 `https://github.com/JuliaLang/Example.jl#master`
  [682c06a0] JSON v0.21.1
```

```@raw html
<div class = "info-body">
<header class = "info-header">Adding specific version</header><p>
```

The syntax above installs the latest stable version of packages. In some cases, we may want to use an older or a not-yet-released package version. We can install such a specific version by appending the version number after the `@` symbol.

```julia
(@v1.5) pkg> add BSON@0.2.1

(@v1.5) pkg> st
Status `~/.julia/environments/v1.5/Project.toml`
  [fbb218c0] BSON v0.2.1
  [7876af07] Example v0.5.4 `https://github.com/JuliaLang/Example.jl#master`
  [682c06a0] JSON v0.21.1
```

If a branch (or a certain commit) is not yet included in a registered version, we can explicitly track it by appending `#branchname` (or `#commitSHA1`) to the package name.

```julia
(@v1.5) pkg> add BSON#master

(@v1.5) pkg> add JSON#1231b521196de6697d682940b963167fbe4d5cd8

(@v1.5) pkg> st
Status `~/.julia/environments/v1.5/Project.toml`
  [fbb218c0] BSON v0.3.2 `https://github.com/JuliaIO/BSON.jl.git#master`
  [7876af07] Example v0.5.4 `https://github.com/JuliaLang/Example.jl#master`
  [682c06a0] JSON v0.21.1+ `https://github.com/JuliaIO/JSON.jl.git#1231b52`
```

```@raw html
</p></div>
```

We use the `update` keyword to update for registered and unregistered packages. If we do not provide a package name, all installed packages will be updated.

```julia
(@v1.5) pkg> update Example
```

Sometimes it is helpful to disallow updating a package. This is done by the `pin` command.

```julia
(@v1.5) pkg> pin Example BSON

(@v1.5) pkg> st
Status `~/.julia/environments/v1.5/Project.toml`
  [fbb218c0] BSON v0.3.2 ⚲
  [7876af07] Example v0.5.4 `https://github.com/JuliaLang/Example.jl#master` ⚲
  [682c06a0] JSON v0.21.1
```

The pin symbol `⚲` shows that the package is pinned. The keyword `free` removes the pin.

```julia
(@v1.5) pkg> free BSON

(@v1.5) pkg> st
Status `~/.julia/environments/v1.5/Project.toml`
  [fbb218c0] BSON v0.3.2
  [7876af07] Example v0.5.4 `https://github.com/JuliaLang/Example.jl#master` ⚲
  [682c06a0] JSON v0.21.1
```

To remove a package, we use the `rm` or `remove` keyword.

```julia
(@v1.5) pkg> rm Example
```

Like the help for functions, we can use `?` in the Pkg REPL to list all its available commands.

```julia
(@v1.5) pkg> ?
  Welcome to the Pkg REPL-mode. To return to the julia> prompt, either press backspace when
  the input line is empty or press Ctrl+C.

  Synopsis

  pkg> cmd [opts] [args]

  Multiple commands can be given on the same line by interleaving a ; between the commands.
  Some commands have an alias, indicated below.

  Commands

  activate: set the primary environment the package manager manipulates

  add: add packages to project

  build: run the build script for packages
[...]
```

```@raw html
<div class = "info-body">
<header class = "info-header">Non-interactive package manager</header><p>
```

We can also use the package manager in a non-interactive way from the Julia REPL by the `Pkg` package.

```julia
using Pkg
Pkg.add(["JSON", "BSON"])
Pkg.add(url = "https://github.com/JuliaLang/Example.jl")
```

```@raw html
</p></div>
```

!!! warning "JuliaHub"
    [JuliaHub](https://juliahub.com) is a web service provided by [Julia Computing](https://juliacomputing.com/) that allows to explore the Julia ecosystem, build packages, and run code in the cloud. It allows for exploring packages, documentation, repositories and code written by other users.

## Environments

So far, we have dealt with the basic package management: adding, updating, or removing packages. However, Julia package manager offers significant advantages over traditional package managers by organizing dependencies into environments. Environments should be familiar to people who use Python. The difference from Python is that Julia provides an effortless way to create and manage environments. Even though some utilities, such as Conda, simplify working with Python environments, Julia handles environments natively within Julia itself.

You may have noticed the `(v1.5)` in the REPL prompt. It indicates the name of the active environment.  The active environment is the environment modified by `Pkg` commands such as `add`, `rm`, or `update`. We can set up a new environment by the `activate` command, followed by the absolute or relative path.

```julia
julia> mkdir("./tutorial") # create a folder named tutorial
"./tutorial"

julia> cd("./tutorial") # change the working directory to tutorial

(@v1.5) pkg> activate . # alternatively we can specify full path
 Activating new environment at `path/to/the/tutorial/Project.toml`

(tutorial) pkg>
```

The example above creates an empty directory `tutorial` and activates a new environment inside it. The prompt in the package REPL changed from `@v1.5` to `tutorial`. It indicates that `tutorial` is the active environment, and Pkg commands will modify it. Since it is a new environment, it has no installed packages.

```julia
(tutorial) pkg> status
Status `path/to/the/tutorial/Project.toml` (empty project)
```

The path printed by the `status` command (`path/to/the/tutorial/Project.toml`) is the location of the `Project.toml` file, where the package manager stores metadata for the environment.

Since `tutorial` is an environment, we can use the same commands as before.

```julia
(tutorial) pkg> add JSON BSON

(tutorial) pkg> st
Status `path/to/the/tutorial/Project.toml`
  [fbb218c0] BSON v0.2.6
  [682c06a0] JSON v0.21.1
```

Since we added two new packages, this information is stored in the files `Project.toml` and `Manifest.toml`.

```julia
julia> readdir("./tutorial")
2-element Vector{String}:
 "Manifest.toml"
 "Project.toml"
```

The `Project.toml` file describes the project on a high level. It contains the package/project dependencies and compatibility constraints. On the other hand, the `Manifest.toml` file is an absolute record of the state of packages used in the environment. It includes exact information about (direct and indirect) dependencies of the project. Given `Project.toml` and `Manifest.toml`, it is possible to [instantiate](https://julialang.github.io/Pkg.jl/v1/api/#Pkg.instantiate) the same package environment.

```julia
(tutorial) pkg> instantiate
```

Different users may use different package versions. Since updated packages provide different functionality for some functions, instantiating is extremely useful for reproducing code across multiple computers.
