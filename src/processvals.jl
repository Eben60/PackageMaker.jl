function get_checked_pgins!(fv; pgins=def_plugins)
    for (k, pgin) in def_plugins
        box_id = Symbol("Use_$k")
        pgin.checked = fv[box_id].checked
    end
    return pgins
end

export get_checked_pgins!

function parse_v_string(s)
    re = r"v\"(.+)\""
    s = strip(s)
    m = match(re, s)
    isnothing(m) && error("$s doesn't look like a valid version string ")
    return VersionNumber(m[1])
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
    get_checked_pgins!(fv)
    get_pgins_vals!(fv)
    # def_plugins["TagBot"].checked = false
    in_pgins = []
    for p in PkgTemplates.default_plugins()
        s = type2str(p)
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

"""
using PackageInABlink
using PkgTemplates

fv = recall_fv()

pgins=initialized_pgins(fv)
(;proj_name, templ_kwargs) = general_options(fv)
t = Template(; plugins=pgins, templ_kwargs...)
t(proj_name);

"""