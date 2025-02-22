using Pkg, TOML

prev_proj = Base.active_project()
curr_proj = joinpath(@__DIR__ , "..")
Pkg.activate(curr_proj)
path = joinpath(curr_proj , "..") |> normpath

project_toml_path = joinpath(path, "Project.toml")
project_toml = TOML.parsefile(project_toml_path)
parent_proj_name = project_toml["name"]

using Suppressor
@suppress begin
Pkg.develop(;path)
end


complete_tests = false
# include("test_typedefs.jl")
include("test_processvals2.jl")

@suppress begin
Pkg.rm(parent_proj_name)
Pkg.activate(prev_proj)
end