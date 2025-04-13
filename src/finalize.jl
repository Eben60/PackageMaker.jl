function finalize_pkg(gen_options)
    (;proj_name, dependencies, docstring, add_imports, templ_kwargs, versioned_man, ) = gen_options
    (;dir, ) = templ_kwargs
    proj_dir = joinpath(dir, proj_name)
    versioned_man && make_vers_mnfs(proj_dir)
    add_imports &= !isempty(dependencies)
    add_docstr = !isempty(docstring)
    add_docstr || add_imports || return nothing
    (;file_content, proj_main_file) = read_src_file(gen_options)
    add_docstr && (file_content = add_docstring(file_content, gen_options))
    add_imports && (file_content = add_usinglines(file_content, gen_options))
    write_contents(proj_main_file, file_content)
end

function make_vers_mnfs(dir)
    return make_current_mnf(dir) # TODO also for test and docs
end

function read_src_file(gen_options)
    (;proj_name, templ_kwargs, ) = gen_options

    (;dir, ) = templ_kwargs
    proj_main_file = joinpath(dir, proj_name, "src", proj_name * ".jl")
    isfile(proj_main_file) || error("file $proj_main_file not found")

    file_content = readlines(proj_main_file)
    return (;file_content, proj_main_file)
end

function write_contents(fl, file_content)
    open(fl, "w") do f
        for l in file_content
            println(f, l)
        end
    end
end

function add_usinglines(file_content, gen_options)
    (;dependencies, proj_name, ) = gen_options
    usinglines = "using " .* dependencies
    pushfirst!(usinglines, "")
    insertion_point = module_firstline(file_content, proj_name) + 1
    new_content = insert(file_content, insertion_point, usinglines)
    return new_content
end

insert(a1, i, a2) = [a1[begin:i-1]; a2; a1[i:end]]
# (a0=copy(a1); splice!(a0, i:i-1, a2); a0) # is not better

function add_docstring(file_content, gen_options)
    (;proj_name, docstring) = gen_options
    @assert !isempty(docstring)
    docslink = get_docslink(gen_options)
    full_docstring = make_docstring(proj_name, docstring, docslink)
    insertion_point = module_firstline(file_content, proj_name)
    new_content = insert(file_content, insertion_point, full_docstring)
    return new_content
end

function module_firstline(file_content, proj_name)
    pattern = "module $proj_name"
    fl = findfirst(x -> startswith(x, pattern), file_content)
    if isnothing(fl) 
        @show file_content
        error("pattern \"$pattern\" not found in the source file")
    end
    return fl
end

function get_docslink(gen_options)
    (;proj_name, templ_kwargs, ) = gen_options
    (;dir, ) = templ_kwargs

    docsfile = joinpath(dir, proj_name, "docs", "make.jl")
    if isfile(docsfile)
        docslink = extract_docslink(docsfile)
    else
        docslink = nothing
    end
    return docslink
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

function make_docstring(proj_name, docstring, docslink)

    pre_header = 
        "# In case you want to know, why the last line of the docstring below looks like it is:\n" *
        "# It will show the package (local) path when help on the package is invoked like     help?> $(proj_name)\n" *
        "# but it will interpolate to an empty string on CI server, \n" *
        "# preventing appearing the server local path in the documentation built there."
        
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
    docstringlines = split(fulldocstring, "\n")

return docstringlines
end
