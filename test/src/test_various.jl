using PackageMaker: get_file_inp_id, create_gh_repo, gh_installed

using Test

@testset "various_tests" begin

@test get_file_inp_id("BlaBla_button") == :BlaBla
@test_throws ErrorException get_file_inp_id("BlaBla")

if (get(ENV, "CI", nothing) == "true") && ! gh_installed() # double insurance against actually creating a GitHub repo in test
    @test_warn r"On attempt to create remote repo, following error message was returned." create_gh_repo("Repo2BeDeleted", false)
end

end # testset