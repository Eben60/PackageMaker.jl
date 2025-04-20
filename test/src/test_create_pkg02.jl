using PackageMaker
using PackageMaker: create_proj, get_pgins_vals!, general_options, def_plugins, initialize

using Test, TOML

include("TestData_CreatePackage02.jl")
fv = TestData_CreatePackage.fv;
initialize()
get_pgins_vals!(fv; plugins=def_plugins)

gen_options = general_options(fv; plugins=def_plugins)
dir = gen_options.templ_kwargs.dir
proj_name = gen_options.proj_name


proj_dir = joinpath(dir, (proj_name * ".jl")) |> normpath
@show proj_dir

if isdir(proj_dir)
    rm(proj_dir; force=true, recursive=true)
end

create_proj(fv)
proj_toml = joinpath(proj_dir, "Project.toml")
proj_mnf = joinpath(proj_dir, "Manifest.toml")
proj_toml_dict = TOML.parsefile(proj_toml)

@testset "create_proj" begin

@test proj_name == "LokalTestProjNotPkg919459"
@test isdir(proj_dir)
@test isfile(proj_toml)
@test isfile(proj_mnf)
@test haskey(proj_toml_dict["deps"], "Dates")
@test proj_toml_dict["compat"]["julia"] == "1.6"


end #testset
