using Pkg, UUIDs, TOML

# function default_env_pkgs()
#     original_path = Pkg.project().path
#     Pkg.activate()

#     p = Pkg.project()
#     d = Pkg.dependencies()
#     deps = [d[last(k)].name for k in p.dependencies]
#     sort!(deps)
#     Pkg.activate(original_path)
#     return deps
# end

function default_env_pkgs()
    # https://discourse.julialang.org/t/how-to-see-all-installed-packages-a-few-other-pkg-related-questions/
    depot = DEPOT_PATH[1]
    mj = Int(VERSION.major)
    mn = Int(VERSION.minor)
    prj = joinpath(depot, "environments", "v$mj.$mn", "Project.toml")
    @assert isfile(prj)
    d = TOML.parsefile(prj)
    deps = collect(keys(d["deps"]))
    sort!(deps)
    return deps
end