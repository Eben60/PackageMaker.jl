function handleinput(win, el::HtmlElem, prevvals)
    # (; newvals, initvals) = prevvals
    el.parentformid == :use_purpose_form && return handle_purpose(win, el)
    "FolderDialogButton" in el.elclass && return set_file_from_dialog(win, el, prevvals; selectdir=true)
    "FileDialogButton" in el.elclass && return set_file_from_dialog(win, el, prevvals; selectdir=false)
    return nothing

end

get_file_inp_id(el::HtmlElem) = get_file_inp_id(el.id |> String)

function get_file_inp_id(button_id)
    re = r"(.+)_button"
    m = match(re, button_id)
    isnothing(m) && error("Button must have an id ending with `_button` ")
    return Symbol(m[1])
end

function pgin_and_field(inp_id)
    re = r"(.+)_(.+)"
    m = match(re, string(inp_id))
    isnothing(m) && return (; pgin=nothing, field=nothing)
    return (; pgin=m[1], field=m[2])
end

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

function current_val(inp_id, prevvals)
    (; newvals, initvals) = prevvals
    vals = haskey(newvals, inp_id) ? newvals : initvals 
    return vals[inp_id]
end

get_def_path(inp_id, prevvals) = current_val(inp_id, prevvals).value |> get_base_path


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
    
    return nothing
end




function showhidepgin(win, pgin_name, show=true) 
    divid="$(pgin_name)_inputs"
    checkid = "Use_$(pgin_name)"
    checkelem(win, checkid, show)
    showhide(win, divid, show) 
end

function handle_purpose(win, el) 
    pgins_to_show = pgins_sets[el.value]
    for (pgname, v) in pgins_to_show
        showhidepgin(win, pgname, v)
    end
    return nothing
end