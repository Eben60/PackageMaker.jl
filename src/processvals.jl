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

function sortedprocvals(fv)
    lc = listchecked(fv; pgin_only=true)
    fms = Dict(k => Any[] for (k, v) in lc if v)
    for (_, v) in fv
        k = v.parentformid |> trunkformname
        haskey(fms, k) && push!(fms[k], v)
    end
    return fms
end
export sortedprocvals

function setpluginvals(fv)
    lc = listchecked(fv)
    fc = filterchecked(lc) # selected plugins
    sp = sortedprocvals(fv) # returned values

    for (k, v) in sp
        p = fc[k]
        re = Regex("^$(k)_(.+)")
        for el in v
            startswith(String(el.id), "Use_") && continue
            val = el.value
            nm = match(re, String(el.id))[1]
            p.args[nm].value = val
        end
    end
    return fc
end
export setpluginvals

function nondefault(pa::PluginArg) 
    pa.type == Bool && return true
    isempty(pa.value) && return false
    strip(pa.value) == "nothing" && return false
    return true
end
export nondefault

function kwval(pa::PluginArg)
    nondefault(pa::PluginArg) || return nothing
    pa.type == Bool && return Bool(pa.value)
    pa.type <: AbstractString && return strip(pa.value)
    pa.type <: Vector{String} && return split(pa.value, r"[\n\r]+") .|> strip .|> String
    error("unsupported type $(pa.type)")
end
export kwval

function plugin_kwargs(p::PluginInfo)
    args = p.args
    return Dict(Symbol(k) => kwval(v) for (k, v) in args if nondefault(v))
end
export plugin_kwargs

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

# PkgTemplates.default_plugins()