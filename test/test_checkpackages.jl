module Checkpackages

using PackageMaker: is_known_pkg, split_pkg_list, stdlib_packages, is_in_registry, check_packages, type2str, parse_v_string, conv

using Test

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

@testset "checkpackages" begin
    @test is_known_pkg("Plots")
    @test is_known_pkg("UUIDs")
    @test !is_known_pkg("suRE_no_such_ackaje")


    @test split_pkg_list(pkglist) == ["Plots", "Makie", "UUIDs", "suRE_no_such_ackaje"]
    @test "UUIDs" in stdlib_packages()
    @test is_in_registry("Plots")
    (;known_pkgs, unknown_pkgs) = check_packages(pkglist)
    @test known_pkgs == ["Plots", "Makie", "UUIDs"]
    @test unknown_pkgs == ["suRE_no_such_ackaje"]

    @test type2str("s") == "String"

    b = Foo.Baz.Bar(0)
    @test type2str(b) == "Bar"

    @test parse_v_string("v1.0.0") == 
        parse_v_string("1.0") == 
        parse_v_string("v\"1.0\"") ==
        v"1.0.0"

    @test_throws ErrorException parse_v_string("beta.3")

    @test conv(Val{:file}, " abc/def ") == "abc/def"
    @test conv(Val{:dir}, "abc/def ") == "abc/def"
    @test conv(Val{:menu}, " bla bla ") == "bla bla"
    @test conv(Val{:VersionNumber}, "v1.0.0") == v"1.0.0"
    @test conv(Val{:ExcludedPlugins}, excl_pgins) == (GitHubActions = false, Tests = false) 



end
end