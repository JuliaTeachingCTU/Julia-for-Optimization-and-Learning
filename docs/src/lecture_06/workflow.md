# Development workflow

In the previous section, we created a new empty package. In this section, we will fill the package with content. **Before we continue, open the main folder of the ImageInspector package in a new VS Code window.** One can access it from `File -> Open folder`.

## Development mode

The content of the `ImageInspector` folder can be divided into four parts:
- *Root folder* contains information about the package and git.
- *Folder src* contains the package source code.
- *Folder tests* contains the testing scripts for verifying the code correctness.
- *Folder examples* is used to run examples.
The first three are standard, while we added the last folder manually. We can add more folders, such as `data`.

We first activate a new environment in the `examples` folder.

```julia
(ImageInspector) pkg> activate ./examples

(examples) pkg>
```

Then we use the `dev` (or `develop`) command to tell Julia that the `ImageInspector` folder is a package, and we want to start its development. The important thing to realize is that the *working directory* is `.../ImageInspector`, while the *working environment* is `.../ImageInspector/examples`. Since the dot in `dev .` specifies the working directory, this command will add the package from the working directory into the working environment.

```julia
julia> pwd()
.../ImageInspector

(examples) pkg> dev . # or dev /absolute/or/relative/path/ImageInspector/

(examples) pkg> st
Status `.../ImageInspector/examples/Project.toml`
  [5c9991e7] ImageInspector v0.1.0 `..`
```

Like the `add` command, the `dev` command allows us to load the package by `using` or `import`. The difference between `add` and `dev` is that the `dev` command tracks the package current state and not a concrete git commit in some branch.

!!! warning "Default Julia enviroment in VS Code:"
    The VS Code allows setting a default Julia environment that is activated when Julia REPL is opened. We can do this by pressing `Julia env: ` located at the bottom info bar and selecting the desired environment.

## Revise.jl

We now create a script `/examples/example.jl` for testing the package functionality. In the rest of the lecture, we will use relative paths from the main folder of the `ImageInspector` package to specify the code location.

```julia
# /examples/example.jl
using ImageInspector
```

Julia can load a package only once per Julia session. If we load a package by the `using` or `import` commands and then make changes in the code, these changes will not be reloaded. This holds even if we try to reload the package by running `using` or `import` again. For example, we add the `greet` function to the `ImageInspector` package.

```julia
# /src/ImageInspector.jl
module ImageInspector

export greet

greet() = print("Hello World!")

end
```

Since we have already loaded the package, this change is not reloaded. If we call the `greet` function, we get the `UndefVarError` error.

```julia
julia> greet()
ERROR: UndefVarError: greet not defined
```

In this case, we have to restart Julia. There are two ways how to exit Julia interactive session: using keyword shortcut `ctrl + D` or using the `exit()` function. Even though we can use the `greet()` function after the restart, we will not do it yet. The reason is that we would have to restart Julia again after making any changes to the package. Since this is not a convenient way to code, we will use the [Revise](https://github.com/timholy/Revise.jl) package. Even though it provides lots of convenient features, we will present only its basic use. First, we install it.

```julia
(examples) pkg> add Revise
```

If we develop a package and load the Revise package first, all package changes will be reloaded without restarting Julia.

```julia
# /examples/example.jl
using Revise # this must come before `using ImageInspector`
using ImageInspector

greet()
```

```julia
Hello World!
```

We now add the `greet2` function.

```julia
# /src/ImageInspector.jl
module ImageInspector

export greet, greet2

greet() = print("Hello World!")
greet2() = print("Hello World!!!!")

end
```

Since we are using the `Revise` package, it should be possible to call the `greet2` function without restarting Julia session.

```julia
julia> greet2()
Hello World!!!!
```

!!! info "Automatic Revise loading"
    `Revise` package can be loaded automaticaly at the start of every Julia session. The easiest way how to achieve such behavior is to use `StartupCustomizer` package. Let's start with installing the package into the default Julia enviroment

    ```julia
    (@v1.10) pkg> add StartupCustomizer
    ```

    When the package is installed, we can run the following commands, that will install `Revise` into the default Julia enviroment and modify the Julia startup file, to load `Revise` at the beggining of every Julia session.

    ```julia
    julia> import StartupCustomizer

    julia> StartupCustomizer.add(StartupCustomizer.Revise())    
    ```

    We can check how the Julia startup file was modified

    ```shell
    > cat ~/.julia/config/startup.jl
    # begin StartupCustomizer.Revise()
    try
        using Revise
    catch e
        @warn "Error initializing Revise" exception=(e, catch_backtrace())
    end
    # end StartupCustomizer.Revise()
    ```

    `StartupCustomizer` also supports other plugins, such as `OhMyREPL`, that will enable code highlightning in your REPL. We can add this pluggin in the similar way as we added the Revise plugin.

    ```julia
    julia> StartupCustomizer.add(StartupCustomizer.OhMyREPL())
    ```