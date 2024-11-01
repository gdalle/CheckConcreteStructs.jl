using Documenter
using CheckConcreteStructs

cp(joinpath(@__DIR__, "..", "README.md"), joinpath(@__DIR__, "src", "index.md"); force=true)

makedocs(;
    modules=[CheckConcreteStructs],
    authors="Guillaume Dalle and Cédric Belmant",
    sitename="CheckConcreteStructs.jl",
    format=Documenter.HTML(),
    pages=["Home" => "index.md", "api.md"],
)

deploydocs(; repo="github.com/gdalle/CheckConcreteStructs.jl", devbranch="main")
