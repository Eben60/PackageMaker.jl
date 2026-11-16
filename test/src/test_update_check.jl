using Test

@testset "latest_version" begin
    using PackageMaker
    using PackageMaker: latest_version

    @test nameof(parentmodule(latest_version)) == :ShareAdd

    v = latest_version("PackageMaker")
    @test v isa VersionNumber
    @test v >= v"1.4.1"
    @test latest_version(PackageMaker) == v

    # non-existent package and non-package module should return nothing without throwing
    @test isnothing(latest_version("ThisPackageDefinitelyDoesNotExist_xyz"))
    @test isnothing(latest_version(Module()))
end

@testset "check_for_update" begin
    using PackageMaker
    using PackageMaker: check_for_update, this_upgradable, UpdateInfo

    u = this_upgradable()
    @test u isa UpdateInfo
    @test u.current_v == pkgversion(PackageMaker)
    @test u.latest_v isa VersionNumber

    info = check_for_update()
    @test info isa UpdateInfo
    @test info == u
    @test PackageMaker.update_info == info
end
