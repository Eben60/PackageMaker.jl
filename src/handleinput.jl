function handleinput(win, el::HtmlElem, prevvals)
    # (; newvals, initvals) = prevvals
    el.parentformid == :use_purpose_form && return handle_purpose(win, el)
    el.id == :GeneralOptions_is_package && return (enable_for_package(win, el.checked); setsubmitbutton(win, el.checked))
    "FolderDialogButton" in el.elclass && return set_file_from_dialog(win, el, prevvals; selectdir=true)
    "FileDialogButton" in el.elclass && return set_file_from_dialog(win, el, prevvals; selectdir=false)
    el.id == :GeneralOptions_proj_name && return check_projname(win, el.value)
    el.id == :GeneralOptions_project_dir && return check_projdir(win, el.value)
    el.id == :Use_Save_Configuration && return check_manageconfig_done(win, el.checked)
    el.id == :GeneralOptions_makerepo && return enable_repo_options(win, el.checked)
    el.id == :Tests_aqua && return enable_html_elem(win, "Tests_aqua_kwargs", el.checked) 
    return nothing
end

function handle_purpose(win, el)
    val = el.value
    startswith(val, "SavedConfigTag_") && return handle_savedconfig(win, val)
    is_package = (val  != "Project")
    checkelem(win, "GeneralOptions_is_package", is_package)
    enable_for_package(win, is_package)
    setsubmitbutton(win, is_package)

    haskey(pgins_sets, val) || return nothing
    pgins_to_show = pgins_sets[val]
    for (pgname, v) in pgins_to_show
        showhidepgin(win, pgname, v)
    end
    return nothing
end

function enable_for_package(win, is_package)
    enable_docstring(win, is_package)
    enable_add_using(win, is_package)
    return nothing  
end

function enable_docstring(win, is_package)
    is_package || setelemval(win, "GeneralOptions_docstring", "")
    enable_html_elem(win, "GeneralOptions_docstring", is_package)
end

enable_add_using(win, is_package) = enable_html_elem(win, "GeneralOptions_add_imports", is_package)

enable_repo_options(win, makerepo) = enable_html_elem(win, "GeneralOptions_repopublic", makerepo) 

function set_file_from_dialog(win, el, prevvals; selectdir)
    (; newvals, initvals) = prevvals
    inp_id = get_file_inp_id(el)

    path = get_def_path(inp_id, prevvals)

    fl = selectdir ? pick_folder(path) : pick_file(path)
    (isnothing(fl) || isempty(fl)) && return nothing

    setelemval(win, inp_id, fl)

    v = current_val(inp_id, prevvals)
    vnew = update_struct(v; value=fl)
    newvals[inp_id] = vnew
    el.id == :GeneralOptions_project_dir_button && check_projdir(win, fl)
    
    return nothing
end

function check_projname(win, projname)
    ok = Base.isidentifier(projname)
    set_checkfield(win, "checkfield_ProjName", ok)
    val_form.ProjName = ok
    enable_submit(win)
    return nothing
end

function check_projdir(win, projdir)
    ok = ispath(projdir) && isabspath(projdir)
    set_checkfield(win, "checkfield_ProjDir", ok)
    val_form.ProjDir = ok
    enable_submit(win)
    return nothing
end

function check_manageconfig_done(win, checked)
    ok = ! checked
    set_checkfield(win, "checkfield_SaveConfig", ok)
    val_form.SaveConfig = ok
    enable_submit(win)
    return nothing
end

function setfields_saved(win, config; pgins=def_plugins)
    for (pgname, pgdict) in config
        for (fldname, val) in pgdict
            if haskey(pgins, pgname) && haskey(pgins[pgname].args, fldname)
                fldtype = pgins[pgname].args[fldname].type
                if fldtype ∈ (Vector{String}, :ExcludedPlugins)
                    val = val |> multiline2csv
                end

                setelemval(win, pgname, fldname, val)
            end
        end
    end
    if haskey(config, "GeneralOptions") && haskey(config["GeneralOptions"], "is_package")
        is_package = config["GeneralOptions"]["is_package"]
        enable_for_package(win, is_package)
        setsubmitbutton(win, is_package)
    end
end

function setsubmitbutton(win, is_package)
    if is_package
        setelemtext(win, "subm1", "Create package")
    else
        setelemtext(win, "subm1", "Create project")
    end
    return nothing
end

function handle_savedconfig(win, val)
    (; config) = read_config(val)
    showhide_saved(win, config)
    setfields_saved(win, config)
    haskey(config, "GeneralOptions") && haskey(config["GeneralOptions"], "project_dir") && check_projdir(win, config["GeneralOptions"]["project_dir"])
    return nothing
end

function showhide_saved(win, config)
    for (pgname, pgdict) in config
        checked = pgdict["checked" ]
        showhidepgin(win, pgname, checked)
    end
    return nothing
end

function showhidepgin(win, pgin_name, show=true) 
    divid="$(pgin_name)_inputs"
    checkid = "Use_$(pgin_name)"
    checkelem(win, checkid, show)
    showhide(win, divid, show) 
end

function set_checkfield(win, id, ok)
    if ok
        setelemtext(win, id, "✓")
        setelemclass(win, id, "checkfield_OK")
    else
        setelemtext(win, id, "🞫")
        setelemclass(win, id, "checkfield_NOK")
    end
    return nothing
end

function enable_submit(win)
    valid = form_valid(val_form)
    enable_html_elem(win, "subm1", valid)
    return nothing
end

get_file_inp_id(el::HtmlElem) = get_file_inp_id(el.id |> String)

function get_file_inp_id(button_id)
    re = r"(.+)_button"
    m = match(re, button_id)
    isnothing(m) && error("Button must have an id ending with `_button` ")
    return Symbol(m[1])
end

function current_val(inp_id, prevvals)
    (; newvals, initvals) = prevvals
    vals = haskey(newvals, inp_id) ? newvals : initvals 
    return vals[inp_id]
end

get_def_path(inp_id, prevvals) = current_val(inp_id, prevvals).value |> get_base_path

function get_base_path(p)
    p = p |> strip
    (isempty(p) || p == "nothing") && return ""

    path = ""
    if isfile(p)
        path = dirname(p)
    elseif isdir(p)
        path = p
    else
        p = dirname(p)
        isdir(p) && (path = p)
    end
    return path
end

function openurl(url)
    if hasdesktop()
        browse_url(url)
    else
        @info("No desktop environment available.")
    end
    return nothing
end

# function pgin_and_field(inp_id)
#     re = r"(.+)_(.+)"
#     m = match(re, string(inp_id))
#     isnothing(m) && return (; pgin=nothing, field=nothing)
#     return (; pgin=m[1], field=m[2])
# end
