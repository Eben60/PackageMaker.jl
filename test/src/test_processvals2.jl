module Processvals2

using PackageMaker: PluginInfo
using PackageMaker: get_checked_pgins!, get_pgins_vals!, pgin_kwargs, init_documenter, initialized_ptpgins, general_options, is_a_package, make_docstring
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
@test ! pgins_vals["GitHubActions"].args["file"].nondefault
@test pgins_vals["GitHubActions"].args["destination"].returned_val == "CI_new.yml"
@test pgins_vals["License"].args["destination"].returned_val == "LICENSE.md"
@test pgins_vals["License"].args["name"].returned_val == "BSD3"
@test ! pgins_vals["Documenter"].args["deploy"].returned_val
@test ! pgins_vals["Documenter"].args["deploy"].returned_rawval
@test pgins_vals["Tests"].args["aqua_kwargs"].returned_rawval == "ambiguities"

@test pgin_kwargs(pgins_vals["License"]) == (; name = "BSD3", destination = "LICENSE.md")

nt = pgin_kwargs(pgins_vals["Documenter"])
documenter1 =  init_documenter(nt)
@test documenter1 isa Documenter{PkgTemplates.NoDeploy}

pgins_vals["Documenter"].args["deploy"].returned_val = true
documenter2 =  init_documenter(pgin_kwargs(pgins_vals["Documenter"]))
@test pgin_kwargs(pgins_vals["Documenter"]) == (;deploy = true,)

@test documenter2 isa Documenter{PkgTemplates.GitHubActions}

ipg = initialized_ptpgins(fv) .|> typeof

@test Set(ipg) == Set{DataType}([
    License,
    Readme,
    ProjectFile,
    Git,
    TagBot,
    Dependabot,
    Documenter{NoDeploy},
    CompatHelper,
    GitHubActions,
    SrcDir,
    Tests,])

gen_options = general_options(fv)
@test gen_options == (proj_name = "PackageMakerTestPackage", 
    templ_kwargs = (interactive = false, user = "Eben60", authors = "Eben60 <not_a_mail@nowhere.org>", dir = "/Users/Eben60/Julia/GUITests/tmp", host = "github.com", julia = v"1.10.0"), 
    dependencies = ["ShareAdd", "Plots", "DataFrames"], 
    unknown_pkgs = String[], 
    docstring = "This is a PackageMakerTestPackage for PackageMaker testing.") 

@test is_a_package(fv) == (ispk = true, isproj = false, islocal = false, isregistered = true)

docstr = "# should you ask why the last line of the docstring looks like that:\n# it will show the package path when help on the package is invoked like     help?> PackageMakerTestPackage\n# but will interpolate to an empty string on CI server, preventing appearing the path in the documentation built there\n\n\"\"\"\n    Package PackageMakerTestPackage v\$(pkgversion(PackageMakerTestPackage))\n\nThis is a PackageMakerTestPackage for PackageMaker testing.\n\nDocs under https://github.com/Eben60/PackageMakerTestPackage.jl\n\n\$(isnothing(get(ENV, \"CI\", nothing)) ? (\"\\n\" * \"Package local path: \" * pathof(PackageMakerTestPackage)) : \"\") \n\"\"\"\n"
@test make_docstring(gen_options.proj_name, gen_options.docstring, "https://github.com/Eben60/PackageMakerTestPackage.jl") == docstr


end # testset

nothing
end # module
