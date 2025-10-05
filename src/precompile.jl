using PrecompileTools: @compile_workload

@compile_workload begin

    k = UPDATE_CHECK_PREF_KEY
    global debug_update_checking = has_preference(@__MODULE__, k) && get(load_preference(@__MODULE__, k), "debug", false)
    try
        pester_user_about_updates(; precompile=true)
    catch e
        println("catching")
        @warn "error on precompile"
        debug_update_checking && sprint(showerror, e, catch_backtrace()) |> println
    end

    wincontent = make_html()

    # w = mainwin(; test=true);
    # el = shell()

    # close(w)
    # close(el)

# # │  [pid 8323] waiting for IO to finish:
# # │   Handle type        uv_handle_t->data
# # │   tcp[13]            0x149ff6af0->0x14f77b7c0
# # │  This means that a package has started a background task or event source that has not finished running. For precompilation to complete successfully, the event source needs to be closed explicitly.
# #    See the developer documentation on fixing precompilation hangs for more help.




end