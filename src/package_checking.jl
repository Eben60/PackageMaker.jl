function this_upgradable()
    current_v = pkgversion(@__MODULE__)
    latest_v = try
        latest_version(@__MODULE__)
    catch
        @warn "Error determining latest version for $(@__MODULE__)"
        nothing
    end
    isnothing(latest_v) && return UpdateInfo(false, current_v, current_v)

    not_latest = latest_v > current_v
    return UpdateInfo(not_latest, current_v, latest_v)
end

function check_for_update()
    global update_info = this_upgradable()
    return update_info
end
