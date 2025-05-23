function finalize_prj(gen_options)
    (; ispk, proj_name, templ_kwargs, versioned_man, jl_suffix, makerepo, repopublic) = gen_options
    (;dir, ) = templ_kwargs
    proj_dir = joinpath(dir, proj_name) |> normpath
    versioned_man && make_vers_mnfs(proj_dir)
    ispk && finalize_pkg(gen_options)
    if jl_suffix 
        proj_dir = add_jl_suffix(proj_dir)
        proj_name *= ".jl"
    end
    makerepo && create_gh_repo(proj_name, repopublic)
end

function finalize_pkg(gen_options)
    (;dependencies, docstring, add_imports, ) = gen_options
    add_imports &= !isempty(dependencies)
    add_docstr = !isempty(docstring)
    add_docstr || add_imports || return nothing
    (;file_content, proj_main_file) = read_src_file(gen_options)
    if add_docstr
        new_content = add_docstring(file_content, gen_options)
        if !isnothing(new_content)
            file_content = new_content
            add_imports && (file_content = add_usinglines(file_content, gen_options))
            write_contents(proj_main_file, file_content)
            return true
        end
    end
    global may_exit_julia = false
    return false
end


function make_vers_mnfs(proj_dir)
    testpath = joinpath(proj_dir, "test")
    docspath = joinpath(proj_dir, "docs")

    for d in (proj_dir, testpath, docspath)
        isenv(d) && make_current_mnf(d)
    end

    return nothing
end

isenv(dir) = isdir(dir) && isfile(joinpath(dir, "Project.toml"))

function add_jl_suffix(proj_dir)
    if endswith(proj_dir, "/")
        proj_dir = proj_dir[begin:end-1]
    end
    isdir(proj_dir) || error("$proj_dir is not a directory")
    newpath = proj_dir * ".jl"
    mv(proj_dir, newpath)
    return newpath
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
    if isempty(docstring)
        @warn "The package docstring is empty."
        return nothing
    end

    docslink = get_docslink(gen_options)
    full_docstring = make_docstring(proj_name, docstring, docslink)
    insertion_point = module_firstline(file_content, proj_name)

    isnothing(insertion_point) && return nothing

    new_content = insert(file_content, insertion_point, full_docstring)
    return new_content
end

function module_firstline(file_content, proj_name)
    pattern = "module $proj_name"
    fl = findfirst(x -> startswith(x, pattern), file_content)
    if isnothing(fl)
        @warn "Pattern \"$pattern\" not found in the source file. Cannot add package docstring."
        return nothing
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

function create_gh_repo(proj_name, public::Bool)
    global may_exit_julia
    stderr_buffer = IOBuffer()
    visibility = public ? "public" : "private"
    cmd = Cmd(`gh repo create $proj_name --$visibility`)

    rslt = run(pipeline(cmd; stderr=stderr_buffer); wait=false)
    wait(rslt)
    rslt.exitcode == 0 && return nothing # everything OK, nothing to speak about

    may_exit_julia = false # do not exit so as to be able to show warning
    seek(stderr_buffer, 0)
    errinfo = readchomp(stderr_buffer)

    warntext = "On attempt to create remote repo, following error message was returned: \n$errinfo"
    @warn warntext
    return nothing
end
