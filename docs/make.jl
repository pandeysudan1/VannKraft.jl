using VannKraft
using Documenter

DocMeta.setdocmeta!(VannKraft, :DocTestSetup, :(using VannKraft); recursive=true)

makedocs(;
    modules=[VannKraft],
    authors="pandeysudan1 <pandeysudan1@gmail.com> and contributors",
    sitename="VannKraft.jl",
    format=Documenter.HTML(;
        canonical="https://pandeysudan1.github.io/VannKraft.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/pandeysudan1/VannKraft.jl",
    devbranch="master",
)
