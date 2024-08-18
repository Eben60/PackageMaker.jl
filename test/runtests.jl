using PackageInABlink

using PackageInABlink: HtmlElem, conv, trunkformname, listchecked, filterchecked, PluginInfo, PluginArg, 
    sortedprocvals, collect_plugin_infos, nondefault, kwval

using Aqua, Suppressor
using Test
using JLD2, OrderedCollections

@testset "processvals" begin

@test conv(Val{:ExcludedPlugins}, " piracy \n ambiguities")== (;piracy = false, ambiguities = false)
@test conv(Val{:VersionNumber}, "v\"1.6.7\"") ==  v"1.6.7"
@test trunkformname(:SrcDir_form) == "SrcDir"

valscache_dir = joinpath(@__DIR__, "..", "data")
@test isdir(valscache_dir)
valscache_file = joinpath(valscache_dir, "valscache-34.jld2")
@test isfile(valscache_file)
fv = load_object(valscache_file)
@test fv isa Dict{Symbol, HtmlElem} 

pv = procvals(fv)
@test HtmlElem(:Tests_aqua, :input, :checkbox, :Tests_form, "on", true) in pv[:Tests_form]

lc = listchecked(fv)
@test  lc == Dict{String, Bool}(
"CompatHelper"  => 1,
"Tests"         => 1,
"SrcDir"        => 1,
"Readme"        => 1,
"TagBot"        => 1,
"License"       => 1,
"Git"           => 1,
"Dependabot"    => 1,
"Secret"        => 0,
"GitHubActions" => 1,
"ProjectFile"   => 1,)

fc = filterchecked(lc)
@test fc["Git"] isa PluginInfo
@test !haskey(fc, "Secret")

sp = sortedprocvals(fv)

@test sp["GitHubActions"] isa Vector{HtmlElem}
@test length(sp["GitHubActions"]) == 10

cpi = collect_plugin_infos(fv)
@test cpi isa OrderedDict{String, PluginInfo}
@test length(cpi) == 10
@test cpi["Dependabot"].name == "Dependabot"

@test PluginArg(("project", false, "Whether or not?")) |> nondefault
@test PluginArg((Vector{String}, "ignore",  String[], "Patterns to add ")) |> x -> !nondefault(x)
@test !nondefault(PluginArg(("name", "nothing ", "Your real name"))) 
@test PluginArg(("aim", " ", "Your real aim.")) |> x -> !nondefault(x)
@test PluginArg(("claim", "claim", "Your real claim.")) |> nondefault

@test ! kwval(PluginArg(("project", false, "Whether or not?")))
@test kwval(PluginArg(("name", "nothing ", "Your real name"))) |> isnothing
@test kwval(PluginArg(("claim", "game", "Your real claim."))) == "game"




end

;
