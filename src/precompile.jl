@compile_workload begin

    key = UPDATE_CHECK_PREF_KEY
    global debug_update_checking = @has_preference(key) && get(@load_preference(key), "debug", false)
    try
        pester_user_about_updates(; precompile=true)
    catch e
        println("catching")
        @warn "error on precompile"
        debug_update_checking && sprint(showerror, e, catch_backtrace()) |> println
    end

end