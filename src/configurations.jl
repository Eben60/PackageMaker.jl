checked_names(pgins) = [pgin.name for (_, pgin) in pgins if pgin.checked]

function get_pgin_changed!(pgin)
    for (_, pa) in pgin.args
        if pa.type == :ExcludedPlugins
            def_val = conv(Val{:ExcludedPlugins}, pa.default_val)
            pa.changed = def_val != pa.returned_val
        else
            pa.changed = pa.default_val != pa.returned_val
        end
    end
    return pgin
end

function get_pgins_changed!(plugins)
    for (_, pgin) in plugins
        get_pgin_changed!(pgin)
    end
    return plugins
end

pg2od(pgin::PluginInfo) = OrderedDict([k => pa.returned_rawval for (k, pa) in pgin.args if pa.changed])
pg2od(pgins::OrderedDict{String, PluginInfo}) = OrderedDict([k => pg2od(pgin) for (k, pgin) in pgins if !isempty(pg2od(pgin))])


write_config(configname, config::Union{AbstractDict, NamedTuple}) = @set_preferences!(configname => JSON3.write(config))
write_config(configname, config::Vector{<:Pair}) = write_config(configname, Dict(config)) # not that I need it

Vector{<:Pair}
read_config(configname) = @load_preference(configname) |> JSON3.read


