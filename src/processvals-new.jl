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

conv(::Type{Val{:VersionNumber}}, s::AbstractString) = return parse_v_string(s)

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
