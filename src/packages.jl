const recommended ::Vector{String} = ["Revise", "OhMyREPL", "BenchmarkTools", "Plots", "DataFrames", "Unitful", "Makie", "FileIO", "CSV"]

function check_entries_def_installed(win, initvals)
    pkgs = default_env_packages()
    form1 = getforminputs(initvals, :deflt_pkg)
    installed_pks = getpkgids(form1, pkgs)
    for item in keys(installed_pks)
        checkelem(win, item, true)
        # disableinputelem(win, item)
    end
    return nothing
end

addable_default_packages() = sort!(setdiff(recommended, default_env_packages(), ))

function default_env_packages()
    julia_version_string = "v$(VERSION.major).$(VERSION.minor)"

    default_proj_path = abspath(joinpath("$(homedir())", ".julia/environments/", julia_version_string, "Project.toml"))
    isfile(default_proj_path) || return String[]

    packages = collect(keys(TOML.parsefile(default_proj_path)["deps"]))
    sort!(packages)
    return packages
end


function getpkgids(d, pknames)
    items = [getpkgid(d, pkname) for pkname in pknames]
    return Dict([item for item in items if ! isnothing(item) ])
end

function getpkgid(d, pkname)
    for (_, el) in d
        el.value == pkname && return el.id => pkname
    end
    return nothing
end
