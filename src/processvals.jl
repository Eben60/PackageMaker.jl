function get_checked_pgins!(fv; pgins=def_plugins)
    for (k, pgin) in pgins
        box_id = Symbol("Use_$k")
        pgin.checked = haskey(fv, box_id) && fv[box_id].checked
    end
    return pgins
end

function get_pgin_vals!(pgin, fv; plugins=def_plugins)
    for (k, pa) in pgin.args
        pa.type == :button && continue
        input_id = Symbol("$(pgin.name)_$(pa.name)")
        el = fv[input_id]

        if pa.type == Bool
            # pa.nondefault = true
            pa.returned_val = pa.returned_rawval = el.checked
        else
            s = el.value |> tidystring
            default_val = plugins[pgin.name].args[pa.name].default_val
            is_all_nothing = (s == "nothing") && isnothing(default_val)
            pa.returned_rawval = s

            if is_all_nothing
                # pa.nondefault = false
                pa.returned_val = missing
            elseif pa.type == :file
                returned = conv(pa, s)
                default = (default_val == returned)
                # pa.nondefault = ! default
                # pa.returned_val = returned
                pa.returned_val = default ? missing : returned
                #(default_val != pa.returned_val)
            else
                # pa.nondefault = true
                pa.returned_val = conv(pa, s)
            end
        end
    end
    return pgin
end

function get_pgins_vals!(fv; plugins=def_plugins)
    for (_, pgin) in plugins
        get_pgin_vals!(pgin, fv; plugins)
    end
    return plugins
end

pgin_kwargs(pgin::PluginInfo) = NamedTuple(Symbol(pa.name) => pa.returned_val for (_, pa) in pgin.args if !ismissing(pa.returned_val)) # pa.nondefault)

function type2str(x)
    t = x |>typeof |> Symbol |> String
    occursin(".", t) || return t
    re=r".*\.(.+)"
    return match(re, t)[1]
end

function init_documenter(nt)
    deploy = nt.deploy
    otherkwargs = [k => v for (k, v) in pairs(nt) if k != :deploy]
    deploy_pgin = deploy ? GitHubActions : NoDeploy
    return Documenter{deploy_pgin}(; otherkwargs...)
end

function initialized_ptpgins(fv; pgins=def_plugins)
    str_checked_pgins = get_checked_pgins!(fv) |> checked_names
    in_ptpgins = []
    str_default_pgins = [type2str(p) for p in PkgTemplates.default_plugins()]
    str_all_pgins = union(str_checked_pgins, str_default_pgins)
    for s in str_all_pgins
        pgins[s].is_general_info && continue
        obj = eval(Symbol(s))
        if haskey(pgins, s) && pgins[s].checked
         # TODO this p should be different from p in for p in PkgTemplates...
            if s == "Documenter" 
                p = init_documenter(pgin_kwargs(pgins[s]))
            else
                p = obj(; pgin_kwargs(pgins[s])...)
            end
            push!(in_ptpgins, p)
        else
            p = obj()
            push!(in_ptpgins, !obj)
        end
    end
    return in_ptpgins
end

"""
    check_packages(x) -> ::String[]

Takes a multiline string, check if packages all exist and returns a vector of package names.
"""
function check_packages(x)
    v0 = split_pkg_list(x)
    unknown_pkgs = filter(x -> !is_known_pkg(x).found, v0)
    v = setdiff(v0, unknown_pkgs)
    return (;known_pkgs = v, unknown_pkgs)
end

function general_options(fv; plugins=def_plugins)
    gargs = def_plugins["GeneralOptions"].args

    (;known_pkgs, unknown_pkgs) = check_packages(gargs["proj_pkg"].returned_rawval)
    proj_name = gargs["proj_name"].returned_val
    user = gargs["user_name"].returned_val
    authors = gargs[:"authors"].returned_val
    dir = gargs["project_dir"].returned_val
    host = gargs["host"].returned_val
    julia = gargs["julia_min_version"].returned_val # |> parse_v_string
    docstring = tidystring(gargs["docstring"].returned_rawval; remove_empty_lines=false)
    ispk = gargs["is_package"].returned_val
    return (;
        ispk,
        proj_name, 
        templ_kwargs = (; interactive=false, user, authors, dir, host,julia), 
        dependencies=known_pkgs,
        unknown_pkgs,
        docstring,
        )
end

function create_proj(fv; plugins=def_plugins)
    global processing_finished = false
    global may_exit_julia
    get_pgins_vals!(fv; plugins)
    pgins=initialized_ptpgins(fv)
    gen_options = general_options(fv; plugins)
    (;ispk, proj_name, templ_kwargs, dependencies, unknown_pkgs) = gen_options
    (;dir, ) = templ_kwargs
    t = Template(; plugins=pgins, templ_kwargs...)
    t(proj_name)
    ispk || depackagize(proj_name, dir)

    isempty(dependencies) || add_dependencies(proj_name, dir, dependencies)
    if !isempty(unknown_pkgs) 
        @info "Unknown package(s): $(unknown_pkgs) were ignored. Check the spelling, and add the package(s) manually, if needed."
    else 
        may_exit_julia = true
    end
    ispk && add_docstring(gen_options)
    processing_finished = true
    return t
end

function add_dependencies(proj_name, dir, dependencies)
    pr = Base.active_project()
    curr_pr_path = dirname(pr)
    new_proj_path = joinpath(dir, proj_name)
    @assert isdir(new_proj_path)
    Pkg.activate(new_proj_path)
    Pkg.add(dependencies)
    Pkg.activate(curr_pr_path)
    return nothing
end

"converts (degrades) a package into a project"
function depackagize(proj_name, dir)
    proj_filename = endswith(proj_name, ".jl") ? proj_name : proj_name * ".jl"
    file = joinpath(dir, proj_name, "src", proj_filename) |> normpath
    rm(file; force = true)

    toml_file = joinpath(dir, proj_name, "Project.toml")
    toml_content = read(toml_file, String)
    toml_dict = TOML.parse(toml_content)
    delete!(toml_dict, "name")
    delete!(toml_dict, "uuid")
    delete!(toml_dict, "version")
    open(toml_file, "w") do f
        TOML.print(f, toml_dict, sorted=true)
    end
    return nothing
end

function cleanup(wpath) 
    isfile(wpath) || return nothing # whatever the reason, it's a temporary dir, nothing bad if not deleted
    d = dirname(wpath)
    rm(d; force = true, recursive = true)
    return nothing 
end

function initialize()
    global val_form = ValidateForm()
    println("TODO finalize initialize function")
end

function _gogui(exitjulia=false; make_prj = true, saveconfig = true)
    global may_exit_julia
    initialize()
    (;finalvals, wpath) = initwin(; make_prj)
    cleanup(wpath)
    if saveconfig 
        configsaved = save_config(finalvals)
    else 
        configsaved = false
    end
    if exitjulia && may_exit_julia
        println("Project created, exiting julia")
        exit()
    elseif configsaved
        global savedconfigs = get_saved_configs() # re-read the global
    end
    return (;finalvals)
end

"""
    gogui(exitjulia=true)

Starts the GUI. If `exitjulia` is `true`, then after the GUI is exited and the project is created, julia will exit.
"""
gogui(exitjulia=true) = (_gogui(exitjulia); return nothing)

"""
using PackageMaker
fv = recall_fv() # if working with saved data

fv = finalvals # else
using PkgTemplates

pgins=initialized_pgins(fv)
(;proj_name, templ_kwargs) = general_options(fv)
t = Template(; plugins=pgins, templ_kwargs...)
t(proj_name);
;

"""