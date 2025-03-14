# checked_names(pgins) = [pgin.name for (_, pgin) in pgins if pgin.checked]

function get_pgin_changed!(pgin)
    pgin.checked || return pgin
    for (_, pa) in pgin.args
        if pa.type == :ExcludedPlugins
            def_val = conv(Val{:ExcludedPlugins}, pa.default_val)
            pa.changed = def_val != pa.returned_val
        else
            pa.changed = (! ismissing(pa.returned_val)) && (pa.default_val != pa.returned_val)
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

function pg2od(pgin::PluginInfo)
    pgin.name == "Save_Configuration" && return OrderedDict{String, Any}() # nothing saveable to config

    od = OrderedDict{String, Any}([k => pa.returned_rawval for (k, pa) in pgin.args if pa.changed])
    od["checked"] = (pgin.name == "GeneralOptions") ? true : pgin.checked
    return od
end


function pg2od(pgins::OrderedDict{String, PluginInfo}) 
    od = OrderedDict([k => pg2od(pgin) for (k, pgin) in pgins if !isempty(pg2od(pgin))])
    remove_inapplicable!(od)
end

function remove_key!(od, pi, arg) 
    if haskey(od, pi) 
        delete!(od[pi], arg)
        isempty(od[pi]) && delete!(od, pi)
    end
    return od
end

remove_key!(od, p::Pair) = remove_key!(od, p.first, p.second)

function remove_key!(od, ps::Vector{<:Pair})
    for p in ps 
        remove_key!(od, p)
    end
    return od
end

function remove_inapplicable!(od)
    not_config_saved = [
        "GeneralOptions" => "proj_name",
        "GeneralOptions" => "docstring",
        "GeneralOptions" => "proj_pkg",
        ]
    return remove_key!(od, not_config_saved)
end

const SAVEDCONFIGS = "SavedConfigurations"

function write_config(configname, config::Union{AbstractDict, NamedTuple})

    configdict = @load_preference(SAVEDCONFIGS) |> JSON3.read |> Dict{String, Dict{String, Any}}


 @set_preferences!(SAVEDCONFIGS => JSON3.write(configdict))

end

 #write_config(configname, config::Vector{<:Pair}) = write_config(configname, Dict(config)) # not that I need it

read_config(configname) = @load_preference(configname)

dsym2dstr(d::Dict{Symbol, Any}) = Dict{String, Any}(string(k) => v for (k, v) in d)

json2dstr(x) = x |> JSON3.read |> Dict{Symbol, Any} |> dsym2dstr

function json2dict(x)
    d = x |> json2dstr
    d0 = Dict{String, Any}()
    for (k, v) in d
        d0[k] = v |> Dict |> dsym2dstr
    end
    return d0
end
export json2dict