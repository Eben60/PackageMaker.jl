module Processvals2

using PackageMaker: PluginInfo
using PackageMaker: get_checked_pgins!, get_pgins_vals!, pgin_kwargs, init_documenter, initialized_pgins, general_options, is_a_package, make_docstring
using PkgTemplates

using Test

include("TestData.jl")
fv = TestData.fv

@testset "Processvals2" begin

pgins = get_checked_pgins!(fv)
@test pgins["ProjectFile"].checked
@test ! pgins["Codecov"].checked
@test pgins["Codecov"] isa PluginInfo

pgins_vals = get_pgins_vals!(fv)
@test pgins_vals["GitHubActions"].args["file"].returned_val == "/Users/eben60/.julia/packages/PkgTemplates/RSqQO/templates/github/workflows/CI.yml"
@test pgins_vals["License"].args["destination"].returned_val == "LICENSE.md"
@test pgins_vals["License"].args["name"].returned_val == "BSD3"
@test ! pgins_vals["Documenter"].args["deploy"].returned_val

@test pgin_kwargs(pgins_vals["License"]) == (; name = "BSD3", destination = "LICENSE.md")

nt = pgin_kwargs(pgins_vals["Documenter"])
documenter1 =  init_documenter(nt)
@test documenter1 isa Documenter{PkgTemplates.NoDeploy}

pgins_vals["Documenter"].args["deploy"].returned_val = true
documenter2 =  init_documenter(pgin_kwargs(pgins_vals["Documenter"]))

@test documenter2 isa Documenter{PkgTemplates.GitHubActions}
@test documenter2.make_jl ==  "/Users/eben60/.julia/packages/PkgTemplates/RSqQO/templates/docs/make.jlt"

ipg = initialized_pgins(fv) .|> typeof

@test Set(ipg) == Set([
    PkgTemplates.Disabled{Codecov},
    Documenter{NoDeploy},
    CompatHelper,
    Tests,
    SrcDir,
    Readme,
    TagBot,
    License,
    Git,
    GitHubActions,
    Dependabot,
    ProjectFile])

gen_options = general_options(fv)
@test gen_options == (proj_name = "PackageMakerTestPackage", 
    templ_kwargs = (interactive = false, user = "Eben60", authors = "Eben60 <not_a_mail@nowhere.org>", dir = "/Users/eben60/Julia/GUITests/tmp", host = "github.com", julia = v"1.10.0"), 
    dependencies = ["ShareAdd", "Plots", "DataFrames"], 
    unknown_pkgs = String[], 
    docstring = "This is a PackageMakerTestPackage for PackageMaker testing.")

@test is_a_package(fv) == (ispk = true, isproj = false, islocal = false, isregistered = true)

docstr = "# should you ask why the last line of the docstring looks like that:\n# it will show the package path when help on the package is invoked like     help?> PackageMakerTestPackage\n# but will interpolate to an empty string on CI server, preventing appearing the path in the documentation built there\n\n\"\"\"\n    Package PackageMakerTestPackage v\$(pkgversion(PackageMakerTestPackage))\n\nThis is a PackageMakerTestPackage for PackageMaker testing.\n\nDocs under https://github.com/Eben60/PackageMakerTestPackage.jl\n\n\$(isnothing(get(ENV, \"CI\", nothing)) ? (\"\\n\" * \"Package local path: \" * pathof(PackageMakerTestPackage)) : \"\") \n\"\"\"\n"
@test make_docstring(gen_options.proj_name, gen_options.docstring, "https://github.com/Eben60/PackageMakerTestPackage.jl") == docstr


end # testset

nothing
end # module
