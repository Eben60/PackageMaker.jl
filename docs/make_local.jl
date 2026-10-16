using Pkg
main_pkg_path = (joinpath(@__DIR__, "../") |> normpath)
Pkg.activate(@__DIR__)

include("makedocs.jl")

# return back to the main package environment
Pkg.activate(main_pkg_path)
;
