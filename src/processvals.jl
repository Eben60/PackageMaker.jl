# WIP

"(pre-)process values returned by form"
function procvals(vals)
    d = Dict{Symbol, Vector{HtmlElem}}()
    for v in values(vals)
        form = v.parentformid
        if ! haskey(d, form)
            d[form] = [v]
        else
            push!(d[form], v)
        end
    end
    return d
end
export procvals

function trunkformname(s)
    s = String(s)
    re = r"^(.+)_form"
    m = match(re, s)
    isnothing(m) && return nothing
    return m[1] 
end

"list checked forms"
function listchecked(d::AbstractDict{Symbol, Vector{HtmlElem}}; pgin_only=true)
    re = r"(.+)(_form)"
    lc = Dict{Symbol, Union{Nothing, Bool}}()
    for (k, v) in pairs(d)
        lc[k] = nothing
        m = match(re, string(k))
        if ! isnothing(m)
            formname = m.captures[1]
            usagekey = Symbol("Use_$formname")
            for he in v
                if he.id == usagekey
                    lc[k] = he.checked
                    break
                end
            end
        end
    end

    pgin_only && return Dict(trunkformname(k) => v for (k, v) in lc if !isnothing(v))

    return lc
end

listchecked(vals; pgin_only=true) = listchecked(procvals(vals); pgin_only)
export listchecked

function filterchecked(checkedforms, pgins=def_plugins) 
    pgc = deepcopy(pgins)
    for (k, v) in checkedforms
        v || pop!(pgc, k)
    end
    return pgc
end

export filterchecked

function sortedprocvals(fv) # -> Dict{String, Vector{HtmlElem}}
    lc = listchecked(fv; pgin_only=true)
    fms = Dict(k => Any[] for (k, v) in lc if v)
    for (_, v) in fv
        k = v.parentformid |> trunkformname
        haskey(fms, k) && push!(fms[k], v)
    end
    return fms
end
export sortedprocvals

function collect_plugin_infos(fv) # -> OrderedDict{String, PluginInfo}
    lc = listchecked(fv)
    fc = filterchecked(lc) # selected plugins
    sp = sortedprocvals(fv) # returned values

    for (k, v) in sp
        p = fc[k]
        re = Regex("^$(k)_(.+)")
        for el in v
            startswith(String(el.id), "Use_") && continue
            nm = match(re, String(el.id))[1]
            pg_arg = p.args[nm]
            val = (el.inputtype == :checkbox) ? el.checked : val = el.value
            pg_arg.value = val
        end
    end
    return fc
end
export collect_plugin_infos

function nondefault(pa::PluginArg) 
    # TODO make proper checking later
    pa.type == Bool && return true
    try
        isempty(pa.value) && return false
        strip(pa.value) == "nothing" && return false
    catch
        return true
    end
    return true
end
export nondefault

function kwval(pa::PluginArg)
    nondefault(pa::PluginArg) || return nothing
    pa.type isa Symbol && return conv(Val{pa.type}, pa.value)
    pa.type == Bool && return Bool(pa.value)
    pa.type <: AbstractString && return strip(pa.value)
    pa.type <: Vector{String} && return split(pa.value, r"[\n\r]+") .|> strip .|> String
    pa.type <: Number && return parse(pa.type, pa.value)
    error("unsupported type $(pa.type)")
end
export kwval

function plugin_kwargs(p::PluginInfo)
    args = p.args
    return Dict(Symbol(k) => kwval(v) for (k, v) in args if nondefault(v))
end
export plugin_kwargs

collect_plugin_kwargs(od::OrderedDict{String, PluginInfo}) = OrderedDict(k => plugin_kwargs(v) for (k, v) in od) # if k in list_deflt_pgins())

export collect_plugin_kwargs

function plugin_obj(name, activ, kwargs)
    pgin = eval(Symbol(name))
    @assert pgin <: PkgTemplates.Plugin
    activ || return ! pgin
    return pgin(; kwargs...)
end

export plugin_obj

jldcache() = joinpath(dirname(@__DIR__), "data", "valscache.jld2")

recall_fv() = load_object(jldcache())
export recall_fv
cache_fv(fv) = jldsave(jldcache(); fv)
export cache_fv

# cache_fv(finalvals)
# fv = recall_fv()

list_deflt_pgins() = PkgTemplates.default_plugins() .|> type2str
export list_deflt_pgins

function type2str(x)
    t = x |>typeof |> Symbol |> String
    occursin(".", t) || return t
    re=r".*\.(.+)"
    return match(re, t)[1]
end
export type2str

function initialized_pgins(fv)
    od = collect_plugin_infos(fv)
    pgc = collect_plugin_kwargs(od)
    ck = listchecked(fv)
    pgins = []
    for p in PkgTemplates.default_plugins()
        s = type2str(p)
        obj = eval(Symbol(s))
        if !get(ck, s, false)
            push!(pgins, !obj)
        else
            @show s
            p = obj(; pgc[s]...)
            @show p
            push!(pgins, p)
        end
    end
    return pgins
end
export initialized_pgins

function parse_v_string(s)
    re = r"v\"(.+)\""
    s = strip(s)
    m = match(re, s)
    isnothing(m) && error("$s doesn't look like a valid version string ")
    return VersionNumber(m[1])
end
export parse_v_string

conv(::Type{Val{:VersionNumber}}, s::AbstractString) = return parse_v_string(s)

function conv(::Type{Val{:ExcludedPlugins}}, s) 
    ks = split(s, "\n") .|> strip .|> Symbol
    return NamedTuple(k => false for k in ks)
end

export conv
# julia> conv(Val{:VersionNumber}, "v\"1.0.0-DEV\"")
# v"1.0.0-DEV"

# Cannot `convert` an object of type SubString{String} to an object of type VersionNumber


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

"""
using PkgTemplates
pgins=initialized_pgins(fv)
(;proj_name, templ_kwargs) = general_options(fv)
t = Template(; plugins=pgins, templ_kwargs...)
t(proj_name)

"""