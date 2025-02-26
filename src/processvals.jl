function get_checked_pgins!(fv; pgins=def_plugins)
    for (k, pgin) in pgins
        box_id = Symbol("Use_$k")
        pgin.checked = fv[box_id].checked
    end
    return pgins
end

function get_pgin_vals!(pgin, fv; plugins=def_plugins)
    for (k, pa) in pgin.args
        input_id = Symbol("$(pgin.name)_$(pa.name)")
        el = fv[input_id]

        if pa.type == Bool
            pa.nondefault = true
            pa.returned_val = pa.returned_rawval = el.checked
        else
            s = el.value |> tidystring
            default_val = plugins[pgin.name].args[pa.name].default_val
            is_all_nothing = (s == "nothing") && isnothing(default_val)
            pa.returned_rawval = s

            if is_all_nothing
                pa.nondefault = false
                pa.returned_val = nothing
            elseif pa.type == :file
                pa.returned_val = conv(pa, s)
                pa.nondefault = (default_val != pa.returned_val)
            else
                pa.nondefault = true
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

pgin_kwargs(pgin::PluginInfo) = NamedTuple(Symbol(pa.name) => pa.returned_val for (_, pa) in pgin.args if pa.nondefault)

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
    get_pgins_vals!(fv)
    in_ptpgins = []
    str_default_pgins = [type2str(p) for p in PkgTemplates.default_plugins()]
    str_all_pgins = union(str_checked_pgins, str_default_pgins)
    for s in str_all_pgins
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

function split_pkg_list(x)
    jl_re = r"(?i)\.jl$"
    v = readlines(IOBuffer(x)) .|> strip 
    v = filter(!isempty, v)
    v = replace.(v, jl_re => "")
    return v
end

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
    pkg_name in stdlib_pkgs && return true
    registries = Pkg.Registry.reachable_registries() 
    for reg in registries
        if is_in_registry(pkg_name, reg)
            return true
        end
    end
    return false
end

"""
    check_packages(x) -> ::String[]

Takes a multiline string, check if packages all exist and returns a vector of package names.
"""
function check_packages(x)
    v0 = split_pkg_list(x)
    unknown_pkgs = filter(x -> !is_known_pkg(x), v0)
    v = setdiff(v0, unknown_pkgs)

    return (;known_pkgs = v, unknown_pkgs)
end

function general_options(fv)
    (;known_pkgs, unknown_pkgs) = check_packages(fv[:project_packages_input].value)
    proj_name = fv[:proj_name].value
    user = fv[:user_name].value
    authors = fv[:authors].value
    dir = fv[:project_dir].value
    host = fv[:host].value
    julia = fv[:julia_min_version].value |> parse_v_string
    docstring = fv[:docstring].value |> strip
    return (;
        proj_name, 
        templ_kwargs = (; interactive=false, user, authors, dir, host,julia), 
        dependencies=known_pkgs,
        unknown_pkgs,
        docstring,
        )
end

function is_a_package(fv)
    isproj = fv[:Project_Choice].checked
    islocal = fv[:LocalPackage_Choice].checked
    isregistered = fv[:RegisteredPackage_Choice].checked

    @assert isproj + islocal + isregistered == 1
    return (;ispk = !isproj, isproj, islocal, isregistered)
end

function create_proj(fv)
    global processing_finished = false
    global may_exit_julia
    pgins=initialized_ptpgins(fv)
    (;ispk, isproj) = is_a_package(fv)
    gen_options = general_options(fv)
    (;proj_name, templ_kwargs, dependencies, unknown_pkgs) = gen_options
    (;dir, ) = templ_kwargs
    t = Template(; plugins=pgins, templ_kwargs...)
    t(proj_name)
    isproj && depackagize(proj_name, dir)

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

function _gogui(exitjulia=false; make_prj = true)
    global may_exit_julia
    (;finalvals, wpath) = initwin(; make_prj)
    cleanup(wpath)
    if exitjulia && may_exit_julia
        println("Project created, exiting julia")
        exit()
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