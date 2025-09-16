# Package structure

The cool thing about Julia is the simplicity of creating packages and sharing them with others. This section contains a step-by-step tutorial on how to build a package from scratch. Moreover, we will use this package later in the course.

## Built-in package generator

We first generate an empty package `PackageName` by the built-in function `generate` in the Pkg REPL.

```julia
(@v1.10) pkg> generate PackageName
 Generating  project PackageName:
    PackageName/Project.toml
    PackageName/src/PackageName.jl
```

This command generates the new package in the working directory. However, we may also specify an absolute or relative path to generate it elsewhere. The `generate` function creates a new folder (with the name matching the package name) with the following content.

```julia
├── Project.toml
└── src
    └── PackageName.jl
```

The new package consists of the `Project.toml` file and the `src` folder with one `.jl` file. The `src/PackageName.jl` file contains a module `PackageName`. The package, the `.jl` file, and the module share the same name. **Since we will modify multiple files during this lecture, we will often specify which file we work with.**

```julia
# /src/PackageName.jl
module PackageName

greet() = print("Hello World!")

end # module
```

Since the `generate` function creates an empty package, the `Project.toml` contains only information describing the package name, its unique UUID, version, and author list.

```toml
name = "PackageName"
uuid = "fa38fd22-11d6-48c8-ae38-ef06258216d8"
authors = ["Author Name"]
version = "0.1.0"
```

Since the `Project.toml` file `src/*.jl` files are sufficient for defining a package, packages are modules with their own environment.

## PkgTemplates

The built-in `generate` function provides only basic functionality for generating packages. Even though it is sufficient in many cases, the [PkgTemplates](https://github.com/invenia/PkgTemplates.jl) package offers a straightforward and customizable way to create packages.

!!! warning "Exercise:"
    The goal of this exercise is to create a new package by the PkgTemplates package. Install PkgTemplates and then use the following code to generate a new package template.

    ```julia
    using PkgTemplates

    template = Template(;
        user="GithubUserName", # github user name
        authors=["Author1", "Author2"], # list of authors
        dir="/Path/To/Dir/", # dir in which the package will be created
        host="github.com", # URL to the code hosting service where packages will reside
        julia=v"1.10", # compat version of Julia
        plugins=[
            ProjectFile(; version=v"0.1.0"), # Add version
            Readme(; inline_badges=true), # add readme file with badges
            Tests(; project=false, aqua=true), # add unit test deps and Aqua
            Git(; manifest=false), # add manifest.toml to .gitignore
            License(; name="MIT"), # add MIT licence
            # disable other plugins
            !GitHubActions,
            !CompatHelper,
            !TagBot,
            !Dependabot,
        ],
    )
    ```

    Do not forget to change `user`, `authors` and `dir`.

    In the rest of the lecture, we will write code to visualize grayscale and colour images. Choose an appropriate package name and use the following code to generate a new package.

    ```julia
    template("PackageName")
    ```

    For naming conventions, see the official [package naming guidelines](https://julialang.github.io/Pkg.jl/v1/creating-packages/#Package-naming-guidelines). Finally, create the folder `examples` in the main package folder.

!!! details "Solution:"
    There is no best way to choose the correct package name. We decided to use `ImageInspector` and create the package by the following code:

    ```julia
    template("ImageInspector")
    ```

    After creating the `ImageInspector` package, we can add the `examples` folder manually or use the `mkdir` function to create it. For the latter, we use the `joinpath` function to specify the correct path.

    ```julia
    mkdir(joinpath("/Path/To/Dir/", "ImageInspector", "examples"))
    ```

    The generated folder contains more files than the folder created by the built-in `generate` function.

    ```julia
    ├── .git
    ├── .gitignore
    ├── LICENSE
    ├── Manifest.toml
    ├── Project.toml
    ├── README.md
    ├── examples
    ├── src
    │   └── ImageInspector.jl
    └── test
        └── runtests.jl
    ```

!!! compat "Interactive package generation:"
    PkgTemplates package also provides an interactive way to generate a template using the following command:

    ```julia
    Template(; interactive=true)
    ```

    The exercise above used a simple template. However, PkgTemplates provides many additional features to simplify the package generation process. Some plugins add documentation or integration with GitHub features. See the official [PkgTemplates documentation](https://invenia.github.io/PkgTemplates.jl/stable/) for more information.