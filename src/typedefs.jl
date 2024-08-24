function update_struct(h; kwargs...)
    pns = propertynames(h)
    d = Dict(pn => getproperty(h, pn) for pn in pns)
    for (k, v) in pairs(kwargs)
        d[k] = v
    end
    return typeof(h)(; d...)
end
export update_struct
@kwdef struct HtmlElem
    id::Symbol
    eltype::Symbol
    elclass::Vector{String}
    inputtype::Symbol
    parentformid::Symbol
    value::String
    checked::Union{Bool, Nothing}
end
export HtmlElem
mutable struct PluginArg
    const type::Union{Type, Symbol}
    const name::String
    default_val
    const meaning::String
    html_val::Union{Bool, String, Nothing}
    returned_val # parsed and returned value
    nondefault::Bool
end

PluginArg(x::Tuple{AbstractString, Any, AbstractString}) = 
    PluginArg(typeof(x[2]), string(x[1]), x[2], string(x[3]), nothing, nothing, false)
PluginArg(x::Tuple{Union{Type, Symbol}, AbstractString, Any, AbstractString}) = 
    PluginArg(x[1], string(x[2]), x[3], string(x[4]), nothing, nothing, false)

mutable struct PluginInfo
    const name::String
    const purpose::String
    const args::OrderedDict{String, PluginArg}
    checked::Bool
end

function pluginarg_od(v::Vector{T}) where T <: Tuple
    ar = [PluginArg(x) for x in v]
    return OrderedDict(v.name => v for v in ar)
end

PluginInfo(x::Tuple{AbstractString, AbstractString, Vector{T}}) where T <: Tuple = PluginInfo(x[1], x[2], pluginarg_od(x[3]), false)
