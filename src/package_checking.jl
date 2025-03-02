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

# currently not used; suggested by AI, probably not working as intended
function get_importing_module(m::Module)
    parent = parentmodule(m)
    if parent === @__MODULE__
        return "Module was not imported from another module"
    else
        return parent
    end
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
    current_v = PkgVersion.@Version
    latest_v = latest_version(pkg)
    not_latest = latest_v > current_v
    return (;not_latest, current_v, latest_v)
end

const UPDATE_CHECK_PREF_KEY = "UpdateCheckingPrefs"

function default_checking_settings()
    Dict(
        "enabled" => true,
        "default_frequency" => 7, # days
        "last_check" => "1914-07-28", # Date
        "next_check" => 7, # days
        "newest_version" => "0.0.1",
        "skip" => false,
      )
  end

filter_prefs!(prefs) = filter!(x->x[1] in keys(default_checking_settings()), prefs)

function getprefs()
    key = UPDATE_CHECK_PREF_KEY
    if @has_preference(key)
        prefs = merge(default_checking_settings(), @load_preference(key))
    else
        prefs = default_checking_settings()
    end
    return prefs
end


function pester_user_about_updates(pkg=@__MODULE__)
    prefs = getprefs()

    prefs["enabled"] ||  return nothing

    prev_check = prefs["last_check"] |> Date

    haskey(prefs, "check_frequency") && (prefs["next_check"] = prefs["check_frequency"]) # old keys -> new

    Dates.days(today() - prev_check) < prefs["next_check"] && return nothing

    prefs["last_check"] = (today() |> string)
    prev_version = prefs["newest_version"] |> VersionNumber
    filter_prefs!(prefs) # old keys -> new

    (;not_latest, current_v, latest_v) = upgradable(pkg)
    prefs["skip"] && latest_v == prev_version && (@set_preferences!(key => prefs); return nothing)  

    prefs["newest_version"] = latest_v |> string
    if not_latest 
        (; choice , update_pkg, update_env) = dialogue!(prefs, pkg, current_v, latest_v)
    else 
        update_pkg = update_env = false
    end

    @set_preferences!(key => prefs)
    perform_update(pkg, update_pkg, update_env)
end

function perform_update(pkg, update_pkg, update_env)
    update_pkg || update_env || return nothing
    update_env && Pkg.update()
    pkg = pkg|>string
    if update_pkg
        (; shared_pkgs, current_pr) = ShareAdd.check_packages(pkg)
        pkg in current_pr.pkgs && Pkg.update(pkg)
        pkg in keys(shared_pkgs) && ShareAdd.update(pkg)
    end
    return nothing
end

function dialogue!(prefs, pkg, current_v, latest_v)
    options = OrderedDict([
        1 => "Skip this version",
        2 => "Don't check for updates anymore",
        3 => "Remind me again in 1 week",
        4 => "Remind me again in 2 weeks",
        5 => "Remind me again in 4 weeks",
        6 => "Update $pkg now",
        7 => "Update now current environment and $pkg"
    ])

    @info "Version $latest_v of package $pkg became available.\nYou are currently using $current_v. Upgrading?"
    println()

    menu = RadioMenu(options |> values |> collect)

    println("Use the arrow keys to move the cursor. Press Enter to select.")

    menu_idx = request(menu)

    update_pkg = update_env = false

    if menu_idx == 1
        prefs["skip"] = true
    elseif menu_idx == 2
        prefs["enabled"] = false
    elseif menu_idx == 3
        prefs["next_check"] = 7
    elseif menu_idx == 4
        prefs["next_check"] = 14
    elseif menu_idx == 5
        prefs["next_check"] = 28
    elseif menu_idx == 6
        prefs["skip"] = false
        prefs["next_check"] = prefs["default_frequency"]
        update_pkg = true
    elseif menu_idx == 7
        prefs["skip"] = false
        prefs["next_check"] = prefs["default_frequency"]
        update_pkg = true
        update_env = true
    else
        throw("invalid index returned")
    end
    return (; choice = (menu_idx => options[menu_idx]), update_pkg, update_env)
end

function updatecheck_settings(; kwargs...)
    prefs = getprefs()
    filter_prefs!(prefs)
    for (k, v) in kwargs
        k = k |> string
        k in keys(prefs) || error("$k is a wrong key")
        conv = typeof(prefs[k])
        conv == String && (conv = string) # more flexible conversion
        prefs[k] = conv(v)
    end
    @show prefs
end