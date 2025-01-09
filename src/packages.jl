using TOML

function default_env_packages()
    julia_version_string = "v$(VERSION.major).$(VERSION.minor)"

    default_proj_path = abspath(joinpath("$(homedir())", ".julia/environments/", julia_version_string, "Project.toml"))
    isfile(default_proj_path) || return String[]

    packages = collect(keys(TOML.parsefile(default_proj_path)["deps"]))
    sort!(packages)
    return packages
end

# const
recommended ::Vector{String} = ["Revise", "OhMyREPL", "BenchmarkTools", "Plots", "DataFrames", "Unitful", "Makie", "FileIO", "CSV"]

addable_default_packages() = sort!(setdiff(recommended, default_env_packages(), ))


