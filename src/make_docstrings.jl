
function make_docstring(proj_name, docstring, docslink)

    pre_header = "# should you ask why the last line of the docstring looks like that:\n" *
        "# it will show the package path when help on the package is invoked like     help?> $(proj_name)\n" *
        "# but will interpolate to an empty string on CI server, preventing appearing the path in the documentation built there"
    header = "    Package $(proj_name) v\$(pkgversion($(proj_name)))"
    footer = """\$(isnothing(get(ENV, "CI", nothing)) ? ("\\n" * "Package local path: " * pathof($(proj_name))) : "") """

    linkline = isnothing(docslink) ? "" : "\n\nDocs under $(docslink)"

    fulldocstring = "$pre_header

\"\"\"
$(header)

$(docstring)$(linkline)

$(footer)
\"\"\"
"
    return fulldocstring
end

function extract_docslink(docsfile)
    file_content = read(docsfile, String)
    file_content = replace(file_content, "\r\n" => "\n")
    re_canon = r"\n\s*canonical=\"(.+)\",\s*\n"
    canonical = match(re_canon , file_content)
    isnothing(canonical) || return canonical[1]

    re_repo = r"\n\s*repo=\"(.+)\",\s*\n"
    repo = match(re_repo , file_content)
    isnothing(repo) && return nothing
    return "https://$(repo[1])"
end


function add_docstring(gen_options)
    (;proj_name, templ_kwargs, docstring) = gen_options

    isempty(docstring) && return nothing

    (;dir, user, host) = templ_kwargs
    proj_main_file = joinpath(dir, proj_name, "src", proj_name * ".jl")
    isfile(proj_main_file) || error("file $proj_main_file not found")

    docsfile = joinpath(dir, proj_name, "docs", "make.jl")
    if isfile(docsfile)
        docslink = extract_docslink(docsfile)
    else
        docslink = nothing
    end

    full_docstring = make_docstring(proj_name, docstring, docslink)

    file_content = read(proj_main_file, String)
    insertion_range = findfirst("module", file_content)
    isnothing(insertion_range) && error("module not found in file $proj_main_file")
    insertion_point = insertion_range.start
    header = insertion_point == 1 ? "" : file_content[1:(insertion_point-1)] * "\n"

    new_content = header * full_docstring * file_content[insertion_point:end]

    open(proj_main_file, "w") do f
        write(f, new_content)
    end

end
