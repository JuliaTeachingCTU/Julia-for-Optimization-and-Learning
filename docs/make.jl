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
installation = [
    "Julia" => "./installation/julia.md",
    "Visual Studio Code" => "./installation/vscode.md",
    "Git" => "./installation/git.md",
    "Quick Start Guide" => "./installation/tutorial.md",
]

lecture_01 = [
    "Variables" => "./lecture_01/variables.md",
    "Elementary Functions" => "./lecture_01/operators.md",
    "Strings" => "./lecture_01/strings.md",
    "Arrays" => "./lecture_01/arrays.md",
    "Data Structures" => "./lecture_01/data_structures.md",
]

lecture_02 = [
    "Conditional Evaluations" => "./lecture_02/conditions.md",
    "Loops and Iterators" => "./lecture_02/loops.md",
    "Soft Local Scope" => "./lecture_02/scope.md",
    "Exercises" => "./lecture_02/exercises.md",
]

lecture_03 = [
    "Functions" => "./lecture_03/functions.md",
    "Methods" => "./lecture_03/methods.md",
    "Scope of Variables" => "./lecture_03/scope.md",
    "Exception Handling" => "./lecture_03/exceptions.md",
    "Exercises" => "./lecture_03/exercises.md",
]

lecture_04 = [
    "Package Management" => "./lecture_04/basics.md",
    "Standard Library" => "./lecture_04/standardlibrary.md",
    "Plots.jl" => "./lecture_04/Plots.md",
    "DataFrames.jl" => "./lecture_04/DataFrames.md",
    "Other Useful Packages" => "./lecture_04/otherpackages.md",
]

lecture_05 = [
    "Abstract and composit types" => "./lecture_05/compositetypes.md",
    "Generic Programming" => "./lecture_05/currencies.md",
]

lecture_06 = []

finalproject = joinpath.("./final_project/", [
    "homeworks.md",
    "project.md",
])

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

lecture_12 = joinpath.("./lecture_12/", [
    "theory.md",
    "ode.md",
    "diff_eq.md",
    "optimal_control.md",
])

# make docs options
makedocs(;
    authors = "Václav Mácha",
    sitename = "Julia for Machine Learning",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        collapselevel = 1,
        assets = ["assets/favicon.ico"],
    ),
    pages = [
        "Home" => "index.md",
        #"How to..." => "howto.md",
        "Why Julia?" => "why.md",
        "Installation" => installation,
        "1: Variables and basic operators" => lecture_01,
        "2: Control flow" => lecture_02,
        "3: Functions and methods" => lecture_03,
        "4: Packages" => lecture_04,
        "5: Type system and generic programming" => lecture_05,
        "6: Modules and packages" => lecture_06,
        "Course requirements" => finalproject,
        "7: Optimization" => lecture_07,
        "8: Regression and classification" => lecture_08,
        "9: Neural networks I." => lecture_09,
        "10: Neural networks II." => lecture_10,
        "11: Statistics" => lecture_11,
        "12: Ordinary differential equations" => lecture_12,
    ],
)

deploydocs(;
    repo="github.com/VaclavMacha/JuliaCourse.git",
)
