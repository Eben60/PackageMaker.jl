using PrecompileTools: @compile_workload

@compile_workload begin

    check_for_update()

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