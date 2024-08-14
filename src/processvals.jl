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
            # if el.inputtype == :checkbox
            #     val = el.checked
            # else 
            #     val = el.value
            # end 

            val = (el.inputtype == :checkbox) ? el.checked : val = el.value
            nm = match(re, String(el.id))[1]
            p.args[nm].value = val
        end
    end
    return fc
end
export collect_plugin_infos

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

    # for (k, v) in args 
    #     if  nondefault(v)
    #         try
    #             kwval(v)
    #         catch
    #             println("---")
    #             @show p.name
    #             @show k
    #             @show v
    #             error("sorry")
    #         end
    #     end
    # end

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
    pgins = PkgTemplates.Plugin[]
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

# Cannot `convert` an object of type SubString{String} to an object of type VersionNumber
