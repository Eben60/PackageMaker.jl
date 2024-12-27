function get_checked_pgins!(fv; pgins=def_plugins)
    for (k, pgin) in def_plugins
        box_id = Symbol("Use_$k")
        pgin.checked = fv[box_id].checked
    end
    return pgins
end

export get_checked_pgins!

function parse_v_string(s)
    s1 = replace(s, "\"" => "")
    s1 = strip(s1)
    v = tryparse(VersionNumber, s1)
    isnothing(v) && error("$s doesn't look like a valid version string")
    return v
    # re = r"v\"(.+)\""
    # s = strip(s)
    # m = match(re, s)
    # isnothing(m) && error("$s doesn't look like a valid version string ")
    # return VersionNumber(m[1])
end
export parse_v_string

# conv(::Symbol, s::AbstractString) 
conv(::Type{Val{:file}}, s)= strip(s) 
conv(::Type{Val{:dir}}, s)= strip(s) 
conv(::Type{Val{:VersionNumber}}, s::AbstractString) = parse_v_string(s)

function conv(pa::PluginArg, val)
    pa.type isa Symbol && return conv(Val{pa.type}, val)
    pa.type <: AbstractString && return strip(val)
    pa.type <: Vector{String} && return split(val, r"[\n\r]+") .|> strip .|> String
    pa.type <: Number && return parse(pa.type, val)
    error("unsupported type $(pa.type)")
end
export kwval

function conv(::Type{Val{:ExcludedPlugins}}, s) 
    ks = split(s, "\n") .|> strip
    filter!(x -> !isempty(x), ks)
    ks = Symbol.(ks)
    return NamedTuple(k => false for k in ks)
end

export conv

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
export get_pgin_vals!

function get_pgins_vals!(fv; pgins=def_plugins)
    for (_, pgin) in pgins
        get_pgin_vals!(pgin, fv)
    end
    return pgins
end
export get_pgins_vals!

pgin_kwargs(pgin::PluginInfo) = NamedTuple(Symbol(pa.name) => pa.returned_val for (_, pa) in pgin.args if pa.nondefault)
export pgin_kwargs

function type2str(x)
    t = x |>typeof |> Symbol |> String
    occursin(".", t) || return t
    re=r".*\.(.+)"
    return match(re, t)[1]
end
export type2str

function initialized_pgins(fv; pgins=def_plugins)
    str_checked_pgins = get_checked_pgins!(fv) |> keys
    get_pgins_vals!(fv)
    # def_plugins["TagBot"].checked = false
    in_pgins = []
    str_default_pgins = [type2str(p) for p in PkgTemplates.default_plugins()]
    str_all_pgins = union(str_checked_pgins, str_default_pgins)
    for s in str_all_pgins
        obj = eval(Symbol(s))
        if haskey(pgins, s) && pgins[s].checked
            # TODO this p should be different from p in for p in PkgTemplates...
            p = obj(; pgin_kwargs(pgins[s])...) 
            push!(in_pgins, p)
        else
            println(s)
            p = obj()
            push!(in_pgins, !obj)
        end
    end
    return in_pgins
end
export initialized_pgins

function general_options(fv)
    proj_name = fv[:proj_name].value
    user = fv[:user_name].value
    authors = fv[:authors].value
    dir = fv[:project_dir].value
    host = fv[:host].value
    julia = fv[:julia_min_version].value |> parse_v_string
    return (;proj_name, templ_kwargs = (; interactive=false, user, authors, dir, host,julia))
end
export general_options

jldcache() = joinpath(dirname(@__DIR__), "data", "valscache.jld2")

recall_fv() = load_object(jldcache())
export recall_fv
cache_fv(fv) = jldsave(jldcache(); fv)
export cache_fv

function is_a_package(fv)
    isproj = fv[:Project_Choice].checked
    islocal = fv[:LocalPackage_Choice].checked
    isregistered = fv[:RegisteredPackage_Choice].checked

    @assert isproj + islocal + isregistered == 1
    return (;ispk = !isproj, isproj, islocal, isregistered)
end

function create_proj(fv)
    global processing_finished
    processing_finished = false
    pgins=initialized_pgins(fv)
    (;ispk, ) = is_a_package(fv)
    (;proj_name, templ_kwargs) = general_options(fv)
    (;dir, ) = templ_kwargs
    t = Template(; plugins=pgins, templ_kwargs...)
    t(proj_name)
    is_a_package(fv).isproj && depackagize(proj_name, dir)
    processing_finished = true
    return t
end

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
export depackagize


function startyourpk(exitjulia=true; make_prj = true)
    (;win, initvals, newvals, finalvals, changeeventhandle) = initwin(; make_prj)
    if exitjulia
        println("Project created, exiting julia")
        exit()
    end
    return (;win, initvals, newvals, finalvals, changeeventhandle)
end
export startyourpk

"""
using StartYourPk
fv = recall_fv() # if working with saved data

fv = finalvals # else
using PkgTemplates

pgins=initialized_pgins(fv)
(;proj_name, templ_kwargs) = general_options(fv)
t = Template(; plugins=pgins, templ_kwargs...)
t(proj_name);
;

"""