using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()

using Documenter
using Documenter.Writers: HTMLWriter
using DocumenterTools: Themes

# theme extension
for theme in ["light", "dark"]
    orig_theme = read(joinpath(HTMLWriter.ASSETS_THEMES, "documenter-$(theme).css"), String)
    details = read(joinpath(@__DIR__, "src/assets/theme-$(theme).scss"), String)

    tmp_theme = joinpath(@__DIR__, "theme-$(theme).scss")
    write(tmp_theme, orig_theme*"\n"*details)

    Themes.compile(tmp_theme, joinpath(@__DIR__, "src/assets/themes/documenter-$(theme).css"))
    rm(tmp_theme)
end

# outline
lecture_01 = [
    "./lecture_01/variables.md",
    "./lecture_01/numeric_types.md",
    "./lecture_01/operators.md",
    "./lecture_01/data_structures.md",
]

lecture_02 = [
#     "./lecture_02/functions.md",
#    "./lecture_02/methods.md",
]

lecture_03 = []

lecture_04 = []

lecture_05 = []

lecture_06 = [
    # "./lecture_06/DataFrames.md",
    # "./lecture_06/Plots.md",
]

lecture_07 = []

lecture_08 = []

lecture_09 = []

lecture_10 = []

lecture_11 = []

lecture_12 = []

lecture_13 = []

# make docs options
makedocs(;
    authors = "Václav Mácha",
    repo = "https://github.com/VaclavMacha/JuliaCourseFNSPE.jl/blob/{commit}{path}#L{line}",
    sitename = "Numerical computing in Julia",
    format = Documenter.HTML(;
        prettyurls = get(ENV, "CI", "false") == "true",
        canonical = "https://VaclavMacha.github.io/JuliaCourseFNSPE.jl",
        assets = String[],
        collapselevel = 1,
    ),
    pages = [
        "Home" => "index.md",
        "Why Julia?" => "why_julia.md",
        "1: Variables and basic operators" => lecture_01,
        "2: Functions and multiple-dispatch" => lecture_02,
        "3: Control flow" => lecture_03,
        "4: Composite types and constructors" => lecture_04,
        "5: Modules and enviroments" => lecture_05,
        "6: Useful packages" => lecture_06,
        "7: Optimization" => lecture_07,
        "8: Regression and classification" => lecture_08,
        "9: Neural networks I." => lecture_09,
        "10: Neural networks II." => lecture_10,
        "11: Ordinary differential equations" => lecture_11,
        "12: Statistics I." => lecture_12,
        "13: Statistics II." => lecture_13,
    ],
)

# deploydocs(;
#     repo="github.com/VaclavMacha/JuliaCourseFNSPE.jl",
# )
