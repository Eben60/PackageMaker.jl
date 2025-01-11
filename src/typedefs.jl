@kwdef struct HtmlElem
    id::Symbol
    eltype::Symbol
    elclass::Vector{String}
    inputtype::Symbol
    parentformid::Symbol
    value::String
    checked::Union{Bool, Nothing}
end

@kwdef mutable struct PluginArg
    const type::Union{Type, Symbol} = Any
    const name::String
    default_val = nothing
    meaning::String 
    html_val::Union{Bool, String, Nothing} = nothing
    returned_val = nothing # parsed and returned value
    nondefault::Bool = false
    const url::String = ""
    const options::Vector{String} = String[]
    const menulabel::String = "Show licenses"
end

PluginArg(x::Tuple{AbstractString, Any, AbstractString}) = 
    PluginArg(typeof(x[2]), string(x[1]), x[2], string(x[3]), nothing, nothing, false, "", [], "")
PluginArg(x::Tuple{AbstractString, Any, AbstractString, AbstractString}) = 
    PluginArg(typeof(x[2]), string(x[1]), x[2], string(x[3]), nothing, nothing, false, x[4], [], "")
PluginArg(x::Tuple{Union{Type, Symbol}, AbstractString, Any, AbstractString}) = 
    PluginArg(x[1], string(x[2]), x[3], string(x[4]), nothing, nothing, false, "", [], "")
PluginArg(nt::NamedTuple) = PluginArg(; nt...)

mutable struct PluginInfo
    const name::String
    const purpose::String
    const args::OrderedDict{String, PluginArg}
    checked::Bool
    const url::String
end

function pluginarg_od(v::Vector{T}) where T
    ar = [PluginArg(x) for x in v]
    return OrderedDict(x.name => x for x in ar)
end

PluginInfo(x::Tuple{AbstractString, AbstractString, Vector{T}}) where T = PluginInfo(x[1], x[2], pluginarg_od(x[3]), false, "")
PluginInfo(x::Tuple{AbstractString, AbstractString, Vector{T}, AbstractString}) where T <: Union{Tuple, NamedTuple} = PluginInfo(x[1], x[2], pluginarg_od(x[3]), false, x[4])

"create a copy of a struct with correspondingly updated fields"
function update_struct(h; kwargs...)
    pns = propertynames(h)
    d = Dict(pn => getproperty(h, pn) for pn in pns)
    for (k, v) in pairs(kwargs)
        d[k] = v
    end
    return typeof(h)(; d...)
end
