using Documenter
using Downloads: download

# download and compile theme
assetsdir(args...) = joinpath(@__DIR__, "src", "assets", args...)
site = "https://github.com/JuliaTeachingCTU/JuliaCTUGraphics/raw/main/"
force = true

mv(download("$(site)logo/CTU-logo-dark.svg"), assetsdir("logo-dark.svg"); force)
mv(download("$(site)logo/CTU-logo.svg"), assetsdir("logo.svg"); force)
mv(download("$(site)icons/favicon.ico"), assetsdir("favicon.ico"); force)

# outline
installation = [
    "Installation" => "./installation/installation.md",
    "Quickstart guide" => "./installation/tutorial.md",
]

lecture_01 = [
    "Variables" => "./lecture_01/variables.md",
    "Elementary functions" => "./lecture_01/operators.md",
    "Strings" => "./lecture_01/strings.md",
    "Arrays" => "./lecture_01/arrays.md",
    "Data structures" => "./lecture_01/data_structures.md",
]

lecture_02 = [
    "Funcion basics" => "./lecture_02/functions.md",
    "Conditional evaluations" => "./lecture_02/conditions.md",
    "Loops and iterators" => "./lecture_02/loops.md",
    "Soft local scope" => "./lecture_02/scope.md",
    "Exercises" => "./lecture_02/exercises.md",
]

lecture_03 = [
    "Standard library" => "./lecture_03/standardlibrary.md",
    "Package manager" => "./lecture_03/pkg.md",
    "Plots.jl" => "./lecture_03/Plots.md",
    "DataFrames.jl" => "./lecture_03/DataFrames.md",
    "Other useful packages" => "./lecture_03/otherpackages.md",
    "Interaction with other languages" => "./lecture_03/interaction.md",
]

lecture_04 = [
    "Functions" => "./lecture_04/functions.md",
    "Methods" => "./lecture_04/methods.md",
    "Scope of variables" => "./lecture_04/scope.md",
    "Exception handling" => "./lecture_04/exceptions.md",
    "Exercises" => "./lecture_04/exercises.md",
]

lecture_05 = [
    "Abstract and composite types" => "./lecture_05/compositetypes.md",
    "Generic programming" => "./lecture_05/currencies.md",
]

lecture_06 = [
    "Files and modules" => "./lecture_06_07/modules.md",
    "Package development" => "./lecture_06_07/develop.md",
]

lecture_07 = [
]


lecture_08 = [
    "Introduction to continuous optimization" => "./lecture_08/theory.md",
    "Gradients" => "./lecture_08/gradients.md",
    "Unconstrained optimization" => "./lecture_08/unconstrained.md",
    "Constrained optimization" => "./lecture_08/constrained.md",
    "Exercises" => "./lecture_08/exercises.md",
]

lecture_09 = [
    "Introduction to regression and classification" => "./lecture_09/theory.md",
    "Linear regression" => "./lecture_09/linear.md",
    "Logistic regression" => "./lecture_09/logistic.md",
    "Exercises" => "./lecture_09/exercises.md",
]

lecture_10 = joinpath.("./lecture_10/", [
    "theory.md",
    "nn.md",
    "exercises.md",
])

lecture_11 = joinpath.("./lecture_11/", [
    "theory.md",
    "iris.md",
    "nn.md",
    "exercises.md",
])

lecture_12 = joinpath.("./lecture_12/", [
    "sparse.md",
    "monte.md",
    "glm.md",
])

lecture_13 = joinpath.("./lecture_13/", [
    "theory.md",
    "ode.md",
    "diff_eq.md",
    "optimal_control.md",
])

# make docs options
makedocs(;
    authors="JuliaTeachingCTU",
    sitename="Julia for Optimization and Learning",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        collapselevel=1,
        assets=[
            "assets/favicon.ico",
        ],
        ansicolor=true
    ),
    pages=[
        "Home" => "index.md",
        "Why Julia?" => "why.md",
        "Installation" => installation,
        "1: Basics I" => lecture_01,
        "2: Basics II" => lecture_02,
        "3: Packages" => lecture_03,
        "4: Functions and methods" => lecture_04,
        "5: Type system and generic programming" => lecture_05,
        "6: Code organization I" => lecture_06,
        "7: Code organization II" => lecture_07,
        "8: Optimization" => lecture_08,
        "9: Regression and classification" => lecture_09,
        "10: Neural networks I." => lecture_10,
        "11: Neural networks II." => lecture_11,
        "12: Statistics" => lecture_12,
    ],
)

deploydocs(;
    repo="github.com/JuliaTeachingCTU/Julia-for-Optimization-and-Learning.git"
)
