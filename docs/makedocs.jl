using Documenter, PackageMaker

makedocs(
    modules = [PackageMaker],
    format = Documenter.HTML(; prettyurls = (get(ENV, "CI", nothing) == "true")),
    authors = "Eben60",
    sitename = "PackageMaker.jl",
    pages = Any[
        "General Info" => "index.md", 
        # "Changelog, License etc." => "finally.md", 
        # "Internal functions and Index" => "docstrings.md",
        ],
    checkdocs = :exports, 
    warnonly = [:missing_docs],
)
