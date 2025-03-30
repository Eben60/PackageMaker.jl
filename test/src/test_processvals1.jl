module Processvals1

using PackageMaker: is_known_pkg, split_pkg_list, stdlib_packages, is_in_registry, 
    check_packages, type2str, parse_v_string, tidystring, initialize, multiline2csv

using Test

initialize()

pkglist =
""" Plots.jl

Makie
 UUIDs  
suRE_no_such_ackaje
"""

excl_pgins =
"""GitHubActions
Tests
"""

module Foo
module Baz
struct Bar
    x
end
end
end

@testset "Processvals1" begin
    @test is_known_pkg("Plots").found
    @test is_known_pkg("UUIDs").found
    @test !is_known_pkg("suRE_no_such_ackaje").found


    @test split_pkg_list(pkglist) == ["Plots", "Makie", "UUIDs", "suRE_no_such_ackaje"]
    @test "UUIDs" in stdlib_packages()
    @test is_in_registry("Plots")
    (;known_pkgs, unknown_pkgs) = check_packages(pkglist)
    @test known_pkgs ==["Makie", "Plots", "UUIDs"]
    @test unknown_pkgs == ["suRE_no_such_ackaje"]

    @test type2str("s") == "String"

    b = Foo.Baz.Bar(0)
    @test type2str(b) == "Bar"

    @test parse_v_string("v1.0.0") == 
        parse_v_string("1.0") == 
        parse_v_string("v\"1.0\"") ==
        v"1.0.0"

    @test_throws ErrorException parse_v_string("beta.3")

end # testset

###########

using PackageMaker: conv, PluginArg

pa1 = PluginArg(; type = Vector{String}, name="ignore", meaning="meaningless")
val1 = pkglist

pa2 = PluginArg(; type = Int, name="ignore", meaning="meaningless")
val2 = "12"

pa3 = PluginArg(; type = :file, name="ignore", meaning="meaningless")
val3 = "abc/def.jhl"

s1 = "  abc \n\r def \t \n\n hig\r"
s2 = "abcdef"
s3 = """
ajd
cde, fgh,dek, 

xyz""";

s4 = """
using P1, P2
import P3,
P4,
P5
P6""";

s5 = """
using P1, P2
import P3,
P4.jl, P4a, P4b.jl
P5
P6""";


@testset "conv" begin

    @test conv(Val{:file}, " abc/def ") == "abc/def"
    @test conv(Val{:dir}, "abc/def ") == "abc/def"
    @test conv(Val{:menu}, " bla bla ") == "bla bla"
#     @test conv(Val{:VersionNumber}, "v1.0.0") == v"1.0.0"
    @test conv(Val{:ExcludedPlugins}, excl_pgins) == (GitHubActions = false, Tests = false) 

    @test conv(pa1, val1) == [ "Plots.jl", "Makie", "UUIDs", "suRE_no_such_ackaje"]
    @test conv(pa2, val2) == 12
    @test conv(pa3, val3) == "abc/def.jhl"
    @test tidystring(s1) == "abc\ndef\nhig"
    @test tidystring(s2) == "abcdef"

    @test multiline2csv(s3) == "ajd, cde, fgh, dek, xyz"

    @test split_pkg_list(s4) == ["P1", "P2", "P3", "P4", "P5", "P6",] 
    @test split_pkg_list(s5) == ["P1", "P2", "P3", "P4", "P4a", "P4b", "P5", "P6",] 

end # testset

# using PackageMaker: PluginArg
# @testset "PluginArg" begin
#     @test PluginArg(("project", false, "Whether or not?")) |> nondefault
#     @test PluginArg((Vector{String}, "ignore",  String[], "Patterns to add ")) |> x -> !nondefault(x)
#     @test !nondefault(PluginArg(("name", "nothing ", "Your real name"))) 
#     @test PluginArg(("aim", " ", "Your real aim.")) |> x -> !nondefault(x)
#     @test PluginArg(("claim", "claim", "Your real claim.")) |> nondefault

#     # @test ! kwval(PluginArg(("project", false, "Whether or not?")))
#     # @test kwval(PluginArg(("name", "nothing ", "Your real name"))) |> isnothing
#     # @test kwval(PluginArg(("claim", "game", "Your real claim."))) == "game"
# end # testset

end # module

["P1", "P2", "P3", "P4", "P5", "P6",]