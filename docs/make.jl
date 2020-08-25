using JuliaCourseFNSPE
using Documenter

makedocs(;
    modules=[JuliaCourseFNSPE],
    authors="Václav Mácha",
    repo="https://github.com/VaclavMacha/JuliaCourseFNSPE.jl/blob/{commit}{path}#L{line}",
    sitename="JuliaCourseFNSPE.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://VaclavMacha.github.io/JuliaCourseFNSPE.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/VaclavMacha/JuliaCourseFNSPE.jl",
)
