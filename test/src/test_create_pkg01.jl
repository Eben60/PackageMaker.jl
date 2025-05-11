using PackageMaker
using PackageMaker: create_proj, get_pgins_vals!, general_options, def_plugins, initialize, get_base_path

using Test, TOML

include("TestData_CreatePackage01.jl")
fv = TestData_CreatePackage.fv;
initialize()
get_pgins_vals!(fv; plugins=def_plugins)

gen_options = general_options(fv; plugins=def_plugins)
dir = gen_options.templ_kwargs.dir
proj_name = gen_options.proj_name
proj_dir = joinpath(dir, proj_name) |> normpath

if isdir(proj_dir)
    rm(proj_dir; force=true, recursive=true)
end

create_proj(fv)
proj_src_file = joinpath(proj_dir, "src", proj_name * ".jl")
proj_toml = joinpath(proj_dir, "Project.toml")
proj_mnf = joinpath(proj_dir, "Manifest.toml")
mn_version = "$(VERSION.major).$(VERSION.minor)"
proj_mnf_v = joinpath(proj_dir, "Manifest-v$(mn_version).toml")
docs_src_file = joinpath(proj_dir, "docs", "src", "index.md")

ci_dir = joinpath(proj_dir, ".github", "workflows") |> normpath
ci_dir_slashed = ci_dir * "/"
ci_file = joinpath(ci_dir, "CI.yml") |> normpath
ci_not_a_file = joinpath(proj_dir,"not-a-dir","NotAfile-alsliue.tyt") |> normpath

proj_toml_dict = try
    TOML.parsefile(proj_toml)
catch
    Dict()
end

proj_src_content = try
    read(proj_src_file, String)
catch
    ""
end

docs_src_content = try
    read(docs_src_file, String)
catch
    ""
end

docstr = 
"""
\"\"\"
    Package LocalTestProj616523 v\$(pkgversion(LocalTestProj616523))

Short package info.
This will be put into the package docstring.

Docs under https://Eben007.github.io/LocalTestProj616523.jl

\$(isnothing(get(ENV, "CI", nothing)) ? ("\\n" * "Package local path: " * pathof(LocalTestProj616523)) : "") 
\"\"\"
"""


@testset "create_proj" begin

@test proj_name == "LocalTestProj616523"
@test isdir(proj_dir)
@test isfile(proj_toml)
@test isfile(proj_mnf_v) || isfile(proj_mnf)
@test isdir(joinpath(proj_dir, "src"))
@test isfile(proj_src_file)
@test proj_toml_dict["name"] == proj_name
@test proj_toml_dict["version"] == "1.2.3"
@test haskey(proj_toml_dict["deps"], "Unicode")
@test occursin(docstr, proj_src_content)
@test occursin("using Unicode", proj_src_content)   
@test occursin(r"module\s+LocalTestProj616523", proj_src_content)
@test isfile(docs_src_file)
@test occursin(r"#\s+LocalTestProj616523", docs_src_content)
@test isfile(ci_file)



end #testset

@testset "get base path" begin

@test get_base_path(ci_dir_slashed) == get_base_path(ci_dir) == get_base_path(ci_file)
@test get_base_path(ci_not_a_file) == get_base_path("") == get_base_path("nothing") == ""

end # testset