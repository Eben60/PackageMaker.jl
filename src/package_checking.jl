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

# currently unused. suggesstion by AI, probably wrong
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
    current_v = pkgversion(pkg)
    if isnothing(current_v) # TODO maybe pass the actuall path to the function or iterate upwards over directories
        project_file = joinpath(@__DIR__, "..", "Project.toml")
        parsed_toml = TOML.parsefile(project_file)
        current_v = parsed_toml["version"] |> VersionNumber
    end
    latest_v = latest_version(pkg)
    not_latest = latest_v > current_v
    return (;not_latest, current_v, latest_v)
end

const UPDATE_CHECK_PREF_KEY = "UpdateCheckingPrefs"

function default_checking_settings()
    Dict(
        "enabled" => true,
        "check_frequency" => 7, # days
        "last_check" => "1914-07-28", # Date
        "newest_version" => "0.0.1",
        "skip" => false,
      )
  end

function update_checking_settings(pkg=@__MODULE__; enabled=true, check_frequency=7, skip=false)
    key = UPDATE_CHECK_PREF_KEY
    (;not_latest, current_v, latest_v) = upgradable()
    last_check = (now() |> Date |> string)
    newest_version = latest_v

    if ! @has_preference(key)
        d = default_checking_settings()
    else
        d = @load_preference(key)
    end

    for (k, v) in pairs((; enabled, check_frequency, skip, last_check, newest_version))
        v isa Union{Real, AbstractString, Bool} || (v = string(v))
        d[k |> string] = v
    end

    @set_preferences!(key=>d)

end

function pester_user_about_updates(pkg=@__MODULE__)

    key = UPDATE_CHECK_PREF_KEY
    if @has_preference(key)
        prefs = @load_preference(key)
    else
        prefs = default_checking_settings()
    end

    prefs["enabled"] ||  return nothing

    prev_check = prefs["last_check"] |> Date

    Dates.days(today() - prev_check) < prefs["check_frequency"] && return nothing

    prefs["last_check"] = (today() |> string)
    prev_version = prefs["newest_version"] |> VersionNumber

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
        1 => "Remind me again in 1 week",
        2 => "Don't check for updates anymore",
        3 => "Skip this version",
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
        prefs["check_frequency"] = 7
    elseif menu_idx == 2
        prefs["enabled"] = false
    elseif menu_idx == 3
        prefs["skip"] = true
    elseif menu_idx == 4
        prefs["check_frequency"] = 14
    elseif menu_idx == 5
        prefs["check_frequency"] = 28
    elseif menu_idx == 6
        prefs["skip"] = false
        prefs["check_frequency"] = 7
        update_pkg = true
    elseif menu_idx == 7
        prefs["skip"] = false
        prefs["check_frequency"] = 7
        update_pkg = true
        update_env = true
    else
        throw("invalid index returned")
    end
    return (; choice = (menu_idx => options[menu_idx]), update_pkg, update_env)
end
