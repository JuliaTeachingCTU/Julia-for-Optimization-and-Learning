using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using Documenter
using Documenter.Writers: HTMLWriter
using DocumenterTools.Themes: compile

# theme extension
for theme in ["light", "dark"]
    mktemp(@__DIR__) do path, io
        write(io, join([
            read(joinpath(HTMLWriter.ASSETS_THEMES, "documenter-$(theme).css"), String),
            read(joinpath(@__DIR__, "src/assets/theme-$(theme).css"), String)
        ], "\n"))
        compile(path, joinpath(@__DIR__, "src/assets/themes/documenter-$(theme).css"))
    end
end

# outline
installation = joinpath.("./installation/", [
    "julia.md",
    "vscode.md",
    "git.md",
])

lecture_01 = [
    "Variables" => "./lecture_01/variables.md",
    "Mathematical operations and Elementary functions" => "./lecture_01/operators.md",
    "Strings" => "./lecture_01/strings.md",
    "Arrays" => "./lecture_01/arrays.md",
    "Data structures" => "./lecture_01/data_structures.md",
]

lecture_02 = joinpath.("./lecture_02/", [
    "conditions.md",
    "loops.md",
    "exercises.md",
    ])

    lecture_03 = joinpath.("./lecture_03/", [
    "functions.md",
    "methods.md",
    "scope.md",
    "exceptions.md",
    "exercises.md",
])

lecture_04 = joinpath.("./lecture_04/", [
    "basics.md",
    "standardlibrary.md",
    "Plots.md",
    "DataFrames.md",
    "otherpackages.md",
    "exercises.md",
])

lecture_05 = []

lecture_06 = []

lecture_07 = joinpath.("./lecture_07/", [
    "theory.md",
    "unconstrained.md",
    "constrained.md",
    "exercises.md",
])

lecture_08 = joinpath.("./lecture_08/", [
    "theory.md",
    "linear.md",
    "logistic.md",
    "exercises.md",
])

lecture_09 = joinpath.("./lecture_09/", [
    "theory.md",
    "nn.md",
    "exercises.md",
])

lecture_10 = joinpath.("./lecture_10/", [
    "theory.md",
    "nn.md",
    "exercises.md",
])

lecture_11 = []

lecture_12 = []

lecture_13 = []

# make docs options
makedocs(;
    authors = "Václav Mácha",
    sitename = "Numerical computing in Julia",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        collapselevel = 1,
    ),
    pages = [
        "Home" => "index.md",
        "How to..." => "howto.md",
        "Installation" => installation,
        "1: Variables and basic operators" => lecture_01,
        "2: Control flow" => lecture_02,
        "3: Functions and methods" => lecture_03,
        "4: Packages" => lecture_04,
        "5: Composite types and constructors" => lecture_05,
        "6: Modules and enviroments" => lecture_06,
        "7: Optimization" => lecture_07,
        "8: Regression and classification" => lecture_08,
        "9: Neural networks I." => lecture_09,
        "10: Neural networks II." => lecture_10,
        "11: Ordinary differential equations" => lecture_11,
        "12: Statistics I." => lecture_12,
        "13: Statistics II." => lecture_13,
    ],
)

deploydocs(;
    repo="github.com/VaclavMacha/JuliaCourse.git",
)
