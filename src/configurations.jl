function handle_saveconfig(win, vals)
    save_config(vals)
    showhidepgin(win, "Save_Configuration", false)
    check_saveconfig_done(win, false)
end

function handle_deleteconfig(win, intermvals)
    config_name = intermvals[:Save_Configuration_config_name].value |> strip
    delete_config(config_name)
    @info "Configuration $(config_name) deleted from preferences."
    showhidepgin(win, "Save_Configuration", false)
end

function save_config(fv)
    pgins = get_pgins_vals!(fv)
    scpi = pgins["Save_Configuration"]
    get_checked_pgins!(fv; pgins)
    scpi.checked || return false
    config_name = scpi["config_name"].returned_val
    isempty(config_name) && return false
    get_pgins_changed!(pgins)
    ogcpg = pg2od(pgins)
    write_config(config_name, ogcpg)
    @info "Configuration $(config_name) saved to preferences."
    return true
end

function get_pgins_changed!(plugins)
    for (_, pgin) in plugins
        get_pgin_changed!(pgin)
    end
    return plugins
end

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
    if pgin.name == "GeneralOptions" 
        pgin.args["is_package"].changed = true
    end
    return pgin
end

function delete_config(configname)
    if ! haskey(savedconfigs, configname)
        @warn "Config $configname not found."
        return nothing
    end
    delete!(savedconfigs, configname)
    @set_preferences!(SAVEDCONFIGS_KEY => savedconfigs)
end

function write_config(configname, config::AbstractDict)
    if ! isempty(savedconfigs)
        configdict = savedconfigs
        configdict[configname] = odod2odjson(config)
    else
        configdict = Dict(configname => odod2odjson(config))
    end
    @set_preferences!(SAVEDCONFIGS_KEY => configdict)
end

function odod2odjson(od)
    od2 = OrderedDict{String, String}()
    for (k, v) in od
        od2[k] = v |> JSON3.write
    end
    return od2
end

function read_config(configname::AbstractString)
    i = savedconfig_tag_no(configname)
    isnothing(i) && return (; name=configname, config=(savedconfigs[configname] |> json2dict))
    return read_config(i)
end

read_config(i::Int) = read_config(collect(keys(savedconfigs))[i])

function savedconfig_tag_no(tag)
    re = r"SavedConfigTag_(\d+)"
    m = match(re, tag)
    isnothing(m) && return nothing
    return parse(Int, m[1])
end

function json2dict(x)
    d0 = Dict{String, Any}()
    for (k, v) in x
        d0[k] = v |> json2dstr
    end
    return d0
end

dsym2dstr(d::Dict{Symbol, Any}) = Dict{String, Any}(string(k) => v for (k, v) in d)

json2dstr(x) = x |> JSON3.read |> Dict{Symbol, Any} |> dsym2dstr

function remove_inapplicable!(od)
    not_config_saved = [
        "GeneralOptions" => "proj_name",
        "GeneralOptions" => "docstring",
        "GeneralOptions" => "proj_pkg",
        ]
    return remove_key!(od, not_config_saved)
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

SavedConfigsType = OrderedDict{String, Dict{String, String}}

function get_saved_configs() 
    if @has_preference(SAVEDCONFIGS_KEY) 
        return @load_preference(SAVEDCONFIGS_KEY) |> dict2od |> SavedConfigsType
    else
        return SavedConfigsType()
    end
end

checked_names(pgins) = [pgin.name for (_, pgin) in pgins if pgin.checked && !(pgin.name in ("GeneralOptions", "Save_Configuration")) ]

function dict2od(d)
    od = OrderedDict{String, Any}()
    ks = keys(d) |> collect |> sort!
    for k in ks
        od[k] = d[k]
    end
    return od
end

savedconfigs::SavedConfigsType = get_saved_configs()

savedconfignames() = isempty(savedconfigs) ? String[] : keys(savedconfigs) |> collect |> sort!
