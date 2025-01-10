function get_checked_pgins!(fv; pgins=def_plugins)
    for (k, pgin) in def_plugins
        box_id = Symbol("Use_$k")
        pgin.checked = fv[box_id].checked
    end
    return pgins
end

function parse_v_string(s)
    s1 = replace(s, "\"" => "")
    s1 = strip(s1)
    v = tryparse(VersionNumber, s1)
    isnothing(v) && error("$s doesn't look like a valid version string")
    return v
end

# conv(::Symbol, s::AbstractString) 
conv(::Type{Val{:file}}, s) = strip(s) 
conv(::Type{Val{:dir}}, s) = strip(s)
conv(::Type{Val{:menu}}, s) = strip(s) 
conv(::Type{Val{:VersionNumber}}, s::AbstractString) = parse_v_string(s)

function conv(pa::PluginArg, val)
    pa.type isa Symbol && return conv(Val{pa.type}, val)
    pa.type <: Vector{String} && return split(val, r"[\n\r]+") .|> strip .|> String
    pa.type <: Number && return parse(pa.type, val)
    pa.type <: AbstractString && return strip(val)
    error("unsupported type $(pa.type)")
end

function conv(::Type{Val{:ExcludedPlugins}}, s) 
    ks = split(s, "\n") .|> strip
    filter!(x -> !isempty(x), ks)
    ks = Symbol.(ks)
    return NamedTuple(k => false for k in ks)
end

function get_pgin_vals!(pgin, fv)
    for (k, pa) in pgin.args
        input_id = Symbol("$(pgin.name)_$(pa.name)")
        el = fv[input_id]
        if pa.type == Bool
            pa.nondefault = true
            pa.returned_val = el.checked
        else
            s = strip(el.value)
            if (isempty(s) || s == "nothing")
                pa.nondefault = false
            else
                pa.nondefault = true
                pa.returned_val = conv(pa, el.value)
            end              
        end
    end
    return pgin
end

function get_pgins_vals!(fv; pgins=def_plugins)
    for (_, pgin) in pgins
        get_pgin_vals!(pgin, fv)
    end
    return pgins
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

function initialized_pgins(fv; pgins=def_plugins)
    str_checked_pgins = get_checked_pgins!(fv) |> keys
    get_pgins_vals!(fv)
    in_pgins = []
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
            push!(in_pgins, p)
        else
            println(s)
            p = obj()
            push!(in_pgins, !obj)
        end
    end
    return in_pgins
end

function split_pkg_list(x)
    jl_re = r"(?i)\.jl$"
    v = readlines(IOBuffer(x)) .|> strip 
    v = filter(!isempty, v)
    v = replace.(v, jl_re => "")
    return v
end

# list packages in the standard environment @stdlib
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

Takes a multiline string, check if packages all exits and returns a vector of package names.
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
    pgins=initialized_pgins(fv)
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

function make_docstring(proj_name, docstring, docslink)

    pre_header = "# should you ask why the last line of the docstring looks like that:\n" *
        "# it will show the package path when help on the package is invoked like     help?> $(proj_name)\n" *
        "# but will interpolate to an empty string on CI server, preventing appearing the path in the documentation built there"
    header = "    Package $(proj_name) v\$(pkgversion($(proj_name)))"
    footer = """\$(isnothing(get(ENV, "CI", nothing)) ? ("\\n" * "Package local path: " * pathof($(proj_name))) : "") """

    linkline = isnothing(docslink) ? "" : "\n\nDocs under $(docslink)"

    fulldocstring = "$pre_header

\"\"\"
$(header)

$(docstring)$(linkline)

$(footer)
\"\"\"
"
    return fulldocstring
end

function extract_docslink(docsfile)
    file_content = read(docsfile, String)
    file_content = replace(file_content, "\r\n" => "\n")
    re_canon = r"\n\s*canonical=\"(.+)\",\s*\n"
    canonical = match(re_canon , file_content)
    isnothing(canonical) || return canonical[1]

    re_repo = r"\n\s*repo=\"(.+)\",\s*\n"
    repo = match(re_repo , file_content)
    isnothing(repo) && return nothing
    return "https://$(repo[1])"
end


function add_docstring(gen_options)
    (;proj_name, templ_kwargs, docstring) = gen_options

    isempty(docstring) && return nothing

    (;dir, user, host) = templ_kwargs
    proj_main_file = joinpath(dir, proj_name, "src", proj_name * ".jl")
    isfile(proj_main_file) || error("file $proj_main_file not found")

    docsfile = joinpath(dir, proj_name, "docs", "make.jl")
    if isfile(docsfile)
        docslink = extract_docslink(docsfile)
    else
        docslink = nothing
    end

    full_docstring = make_docstring(proj_name, docstring, docslink)

    file_content = read(proj_main_file, String)
    insertion_range = findfirst("module", file_content)
    isnothing(insertion_range) && error("module not found in file $proj_main_file")
    insertion_point = insertion_range.start
    header = insertion_point == 1 ? "" : file_content[1:(insertion_point-1)] * "\n"

    new_content = header * full_docstring * file_content[insertion_point:end]

    open(proj_main_file, "w") do f
        write(f, new_content)
    end

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
    @unsafe

A workaround for an upstream bug on Ubuntu 24. It disables sandboxing in Electron. 
Run this macro before calling `gogui()`.

The recommended way of using PackageMaker on Ubuntu 24 is however to use from VSCode, as 
in this case it works OK without calling `@unsafe`

# Examples
```julia-repl
julia> @unsafe;
julia> gogui()
``` 
"""
macro unsafe() # https://github.com/JuliaGizmos/Blink.jl/issues/325#issuecomment-2252670794
    return @eval AtomShell begin
            function init(; debug = false)
                electron() # Check path exists
                p, dp = port(), port()
                debug && inspector(dp)
                dbg = debug ? "--debug=$dp" : []
                proc = (debug ? run_rdr : run)(
                    `$(electron()) --no-sandbox $dbg $mainjs port $p`; wait=false)
                conn = try_connect(ip"127.0.0.1", p)
                shell = Electron(proc, conn)
                initcbs(shell)
                return shell
            end
        end
    end
export @unsafe



startyourpk(args...; kwargs...) = @warn "Function startyourpk is deprecated as of v.0.0.9. Please use gogui instead"
export startyourpk


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