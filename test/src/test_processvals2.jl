# module Processvals2

using PackageMaker: PluginInfo
using PackageMaker: get_checked_pgins!, get_pgins_vals!, pgin_kwargs, init_documenter, initialized_ptpgins, general_options, make_docstring
using PkgTemplates
using PkgTemplates: Disabled

using Test

include("TestData_TestPackage01.jl")
@testset "Processvals2" begin

pgins = get_checked_pgins!(fv)
@test pgins["ProjectFile"].checked
@test ! pgins["Codecov"].checked
@test ! pgins["Save_Configuration"].checked
@test pgins["Codecov"] isa PluginInfo

pgins_vals = get_pgins_vals!(fv)
@test ! pgins_vals["GeneralOptions"].args["jl_suffix"].returned_val
@test pgins_vals["GitHubActions"].args["destination"].returned_val == "CI_new.yml"
@test pgins_vals["License"].args["destination"].returned_val == "LICENSE.txt"
@test pgins_vals["License"].args["name"].returned_val == "ASL"
@test pgins_vals["Documenter"].args["deploy"].returned_val
@test pgins_vals["Documenter"].args["deploy"].returned_rawval
@test pgins_vals["Tests"].args["aqua_kwargs"].returned_rawval == "ambiguities"

@test pgin_kwargs(pgins_vals["License"]) == (; name = "ASL", destination = "LICENSE.txt")

pgins_vals["Documenter"].args["deploy"].returned_val = true
documenter2 =  init_documenter(pgin_kwargs(pgins_vals["Documenter"]))
@test pgin_kwargs(pgins_vals["Documenter"]) == (;deploy = true,)

@test documenter2 isa Documenter{PkgTemplates.GitHubActions}

ipg = initialized_ptpgins(fv) .|> typeof

@test Set(ipg) == Set{DataType}([
    License,
    Readme,
    ProjectFile,
    Disabled{CompatHelper}, 
    Git, 
    Disabled{Dependabot},
    Disabled{TagBot},
    Documenter{GitHubActions},
    # Codecov,
    GitHubActions,
    SrcDir,
    Tests,])

go = general_options()
@test go == (ispk = true,
    proj_name = "TestPackage01",
    jl_suffix = false,
    templ_kwargs = (interactive = false, user = "Eben60", authors = "Eben60 <not_a_mail@nowhere.org>", dir = "/Users/Shared", host = "github.com", julia = v"1.10.9"),
    dependencies = ["TOML", "Unicode"],
    unknown_pkgs = String[],
    docstring = "This is a TestPackage01 for PackageMaker testing.",
    add_imports = true,
    versioned_man = true,
    makerepo = true,
    repopublic = false,
    remote_suffix_jl = true,
    ) 

@test go.ispk
@test go.proj_name == "TestPackage01"
@test go.add_imports 
@test go.dependencies == ["TOML", "Unicode"]
@test go.unknown_pkgs == String[]
@test go.docstring == "This is a TestPackage01 for PackageMaker testing."

@test go.templ_kwargs == (;interactive = false, user = "Eben60", authors = "Eben60 <not_a_mail@nowhere.org>", dir = "/Users/Shared", host = "github.com", julia = v"1.10.9")

docstr = [
    "# In case you want to know, why the last line of the docstring below looks like it is:", 
    "# It will show the package (local) path when help on the package is invoked like     help?> TestPackage01", 
    "# but it will interpolate to an empty string on CI server, ", 
    "# preventing appearing the server local path in the documentation built there.", 
    "", 
    "\"\"\"", 
    "    Package TestPackage01 v\$(pkgversion(TestPackage01))", 
    "", "This is a TestPackage01 for PackageMaker testing.", 
    "", "Docs under https://github.com/Eben60/PackageMakerTestPackage.jl", 
    "", 
    "\$(isnothing(get(ENV, \"CI\", nothing)) ? (\"\\n\" * \"Package local path: \" * pathof(TestPackage01)) : \"\") ", "\"\"\"",
    "",
]

mdoctsr = make_docstring(go.proj_name, go.docstring, "https://github.com/Eben60/PackageMakerTestPackage.jl")
@test mdoctsr == docstr

pgins_vals["Documenter"].args["deploy"].returned_val = true
documenter2 =  init_documenter(pgin_kwargs(pgins_vals["Documenter"]))
@test pgin_kwargs(pgins_vals["Documenter"]) == (;deploy = true,)

pgins_vals["Documenter"].args["deploy"].returned_val = false
nt = pgin_kwargs(pgins_vals["Documenter"])
documenter1 =  init_documenter(nt)
@test documenter1 isa Documenter{PkgTemplates.NoDeploy}

end # testset

nothing
# end # module
