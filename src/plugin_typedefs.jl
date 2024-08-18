mutable struct PluginArg
    const type::Union{Type, Symbol}
    const name::String
    value
    const meaning::String
end

PluginArg(x::Tuple{AbstractString, Any, AbstractString}) = PluginArg(typeof(x[2]), String(x[1]), x[2], String(x[3]))
PluginArg(x::Tuple{Union{Type, Symbol}, AbstractString, Any, AbstractString}) = PluginArg(x[1], String(x[2]), x[3], String(x[4]))

struct PluginInfo
    name::String
    purpose::String
    args::OrderedDict{String, PluginArg} 
end

function pluginarg_od(v::Vector{T}) where T <: Tuple
    ar = [PluginArg(x) for x in v]
    return OrderedDict(v.name => v for v in ar)
end

PluginInfo(x::Tuple{AbstractString, AbstractString, Vector{T}}) where T <: Tuple = PluginInfo(x[1], x[2], pluginarg_od(x[3]))
