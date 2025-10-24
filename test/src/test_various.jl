using PackageMaker: get_file_inp_id, create_gh_repo, gh_installed, THIS_PKG
using PackageMaker
using TOML, UUIDs

using Test

function current_package_info(m=PackageMaker)
    p = pathof(m)
    name = m |> Symbol |> string
    pkg_dir = p |> dirname |> dirname
    project_file = joinpath(pkg_dir, "Project.toml")
    project_data = TOML.parsefile(project_file)
    uuid_str = project_data["uuid"]
    return (UUID(uuid_str), name)
end
@testset "various_tests" begin

@test get_file_inp_id("BlaBla_button") == :BlaBla
@test_throws ErrorException get_file_inp_id("BlaBla")

if (get(ENV, "CI", nothing) == "true") && ! gh_installed() # double insurance against actually creating a GitHub repo in test
    @test_warn r"On attempt to create remote repo, following error message was returned." create_gh_repo("Repo2BeDeleted", false)
end

@test THIS_PKG == current_package_info()

end # testset

