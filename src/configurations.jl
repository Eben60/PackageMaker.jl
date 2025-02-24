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