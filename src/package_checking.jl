"list packages in the standard environment @stdlib"
function stdlib_packages()
    pkg_dirlist = readdir(Sys.STDLIB) 
    pkgs = [s for s in pkg_dirlist if isdir(joinpath(Sys.STDLIB, s)) && !endswith(s, "_jll")]
    return pkgs
end

const stdlib_pkgs = stdlib_packages()

function is_in_registry(pkname, reg=nothing)
    isnothing(reg) && (reg = Pkg.Registry.reachable_registries()[1])
    pkgs = reg.pkgs
    for (_, pkg) in pkgs
        pkg.name == pkname && return true
    end
    return false
end

function is_known_pkg(pkg_name)
    found=true
    registry=nothing
    pkg_name in stdlib_pkgs && return (;found, registry)
    registries = Pkg.Registry.reachable_registries() 
    for registry in registries
        if is_in_registry(pkg_name, registry)
            return (;found, registry)
        end
    end
    return (;found=false, registry=nothing)
end

function latest_version(pkg_name)
    pkg_name = pkg_name |> string
    registry = is_known_pkg(pkg_name).registry
    isnothing(registry) && return nothing
    ch1 = pkg_name[1] |> uppercase
    k = "$ch1/$pkg_name/Versions.toml"
    toml = registry.in_memory_registry[k]
    v = TOML.tryparse(toml) |> keys .|> VersionNumber |> maximum
end

function upgradable(pkg=@__MODULE__)
    current_v = pkgversion(pkg)
    latest_v = latest_version(pkg)
    not_latest = latest_v > current_v
    return (;not_latest, current_v, latest_v)
end
