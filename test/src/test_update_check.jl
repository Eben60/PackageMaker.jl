import PackageMaker
using Test

@testset "latest_version" begin
    v = PackageMaker.latest_version("PackageMaker")
    @test v isa VersionNumber
    @test !isnothing(v)
    @test v >= v"1.4.1"

    # non-existent package should return nothing without throwing
    @test isnothing(PackageMaker.latest_version("ThisPackageDefinitelyDoesNotExist_xyz"))
end

@testset "check_for_update" begin
    # must complete without error and return a valid UpdateInfo
    info = PackageMaker.check_for_update()
    @test info isa PackageMaker.UpdateInfo
    @test info.current_v isa VersionNumber
    @test info.latest_v isa VersionNumber
end
