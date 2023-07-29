using TOML

function default_env_packages()
    julia_version_string = "v$(VERSION.major).$(VERSION.minor)"

    default_proj_path = abspath(joinpath("$(homedir())", ".julia/environments/", julia_version_string, "Project.toml"))
    @assert isfile(default_proj_path)

    packages = keys(TOML.parsefile(default_proj_path)["deps"])
    return packages
end