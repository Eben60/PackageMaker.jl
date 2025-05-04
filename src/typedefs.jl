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
    const default_val:: Union{Bool, String, Vector{String}, VersionNumber, Nothing} = nothing
    meaning::String

    "Raw value as returned from GUI, with a bit post-cleaning."
    returned_rawval::Union{Bool, String, Nothing} = nothing

    "Parsed returned value. Set it to missing to indicate the value is unchanged from default."
    returned_val = nothing
    changed::Bool = false
    "options field may contain some field-specific data"
    const options = (;)

end

# options = (;url = "https://github.com/JuliaCI/PkgTemplates.jl/tree/master/templates/licenses", enabled = false, hidden = true, 
#                             menuoptions = (; opt_list = get_licences(), show_first = true, menulabel = "Show licenses"))
# options = (; menuoptions = (; opt_list = String[], show_first = false, menulabel = ""))
# options = (; button_args = (; reason="saveprefs_finished", reasoneach="intermed_input"))


makeout_argtype(x) = isnothing(x) ? String : typeof(x)

PluginArg(x::Tuple{AbstractString, Any, AbstractString}) = 
    PluginArg(; type=makeout_argtype(x[2]), name=x[1], default_val=x[2], meaning=x[3])
PluginArg(x::Tuple{AbstractString, Any, AbstractString, AbstractString}) = 
    PluginArg(; type=makeout_argtype(x[2]), name=x[1], default_val=x[2], meaning=x[3], options = (;url=x[4]))
PluginArg(x::Tuple{Union{Type, Symbol}, AbstractString, Any, AbstractString}) = 
    PluginArg(; type=x[1], name=x[2], default_val=x[3], meaning=x[4])

PluginArg(nt::NamedTuple) = PluginArg(; nt...)
PluginArg(x::PluginArg) = update_struct(x; )

@kwdef mutable struct PluginInfo
    const name::String
    const shown_name::String
    const purpose::String = ""
    const args::OrderedDict{String, PluginArg}
    checked::Bool = false
    const url::String = ""
    const is_general_info::Bool = false
end

function pi_shown_name(name, is_general_info)
    shown_name = replace(name, "_" => " ")
    plugin_word = is_general_info ? "" : "plugin"
    return join((shown_name, plugin_word), " ")
end

function pluginarg_od(v::Vector{T}) where T
    ar = [PluginArg(x) for x in v]
    return OrderedDict(x.name => x for x in ar)
end

Base.convert(::Type{OrderedDict{String, PluginArg}}, v::Vector) = pluginarg_od(v)

PluginInfo(x::Tuple{AbstractString, AbstractString, Vector{T}}) where T = 
    PluginInfo(x[1], pi_shown_name(x[1], false), x[2], x[3], false, "", false)
PluginInfo(x::Tuple{AbstractString, AbstractString, Vector{T}, AbstractString}) where T <: Union{Tuple, NamedTuple} = 
    PluginInfo(x[1], pi_shown_name(x[1], false), x[2], x[3], false, x[4], false)
PluginInfo(x::Tuple{AbstractString, AbstractString, Vector{T}, Bool}) where T = 
    PluginInfo(x[1], pi_shown_name(x[1], x[4]), x[2], x[3], false, "", x[4])
PluginInfo(x::Tuple) = PluginInfo(x...)

function Base.show(io::IO, pi::PluginInfo) 
    println(io, "$(pi.name): checked=$(pi.checked)")
    for arg in values(pi.args)
        show(io, arg)
    end
end

Base.show(io::IO, pa::PluginArg) = show(io, (; name = pa.name, type = pa.type, raw_val=pa.returned_rawval, pa.returned_val, changed=pa.changed))

Base.getindex(pi::PluginInfo, key::String) = pi.args[key]

"create a copy of a struct with correspondingly updated fields"
function update_struct(h; kwargs...)
    pns = propertynames(h)
    d = Dict(pn => getproperty(h, pn) for pn in pns)
    for (k, v) in pairs(kwargs)
        d[k] = v
    end
    return typeof(h)(; d...)
end
