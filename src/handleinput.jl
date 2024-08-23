function handleinput(win, el::HtmlElem)

    el.parentformid == :use_purpose_form && return handle_purpose(win, el)
    "FolderDialogButton" in el.elclass && return set_file_from_dialog(win, el; selectdir=true)
    "FileDialogButton" in el.elclass && return set_file_from_dialog(win, el; selectdir=false)
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

function set_file_from_dialog(win, el; selectdir)
    inp_id = get_file_inp_id(el)
    k = string(inp_id)
    path = ""
    (; pgin, field) = pgin_and_field(inp_id)
    if haskey(def_plugins, pgin) && haskey(def_plugins[pgin].args, field)
        p = def_plugins[pgin].args[field].default_val
        if isfile(p)
            path = dirname(p)
        elseif isdir(p)
            path = p
        else
            p = dirname(p)
            isdir(p) && (path = p)
        end
    end
    fl = selectdir ? pick_folder(path) : pick_file(path)
    isnothing(fl) && return nothing
    setelemval(win, inp_id, fl)
    
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