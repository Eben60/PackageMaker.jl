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
    fms = Dict(k => Any[] for k in keys(lc))
    for (_, v) in fv
        k = v.parentformid |> trunkformname
        haskey(fms, k) && push!(fms[k], v)
    end
    return fms
end
export sortedprocvals
