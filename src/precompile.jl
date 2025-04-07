@compile_workload begin

    key = UPDATE_CHECK_PREF_KEY
    @has_preference(key) && get(@load_preference(key), "debug", false)
    
    pester_user_about_updates(; precompile=true)

end