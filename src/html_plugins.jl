tmpl_section_beg() = 
"""
<div  id="tmpl_section_div">
<h2>Options and Plugins</h2>
    <p class="comment">Most of the functionalities of <code>PkgTemplates</code> is provided by plugins.<br>
    The following section provides access to general options as well as to selected <code>PkgTemplates</code> plugins.</p>
"""

tmpl_section_end() = 
"""
</div>
"""

# create one for per plugin
function tmpl_beg(pgin, purpose, show=true)
    pgin_name = pgin.name
    shown_name = pgin.shown_name
"""
<div class="plugin_form_div" id="plugin_form_div_$(pgin_name)">
<form class="plugin_form" name="$(pgin_name)_form" id="$(pgin_name)_form" action="javascript:void(0)">
    <input id="Use_$(pgin_name)" value="Use_$(pgin_name)" $(checked(show)) onchange="oncng(this)" type="checkbox" class="TogglePlugin">
    <label for="Use_$(pgin_name)">$(shown_name) </label>
    <div class="Plugin_Purpose">$(purpose).</div>
    <div class="Plugin_Inputs" id="$(pgin_name)_inputs" style=$(disp_style(show)) >
"""
end

function tmpl_inp(pgin, arg, arg_meaning, color_no, css, arr_footnote=true)
    # css = "pgin_inp" : "gen_opt"
    pgin_name = pgin.name
    arg_type = arg.type
    arg_name = arg.name

    # <div class="$(css)_margins $(css)_col$(color_no)" id="div_$(pgin_name)_$(arg_name)"> # currently unnecessary
    return """
    <div class="$(css)_margins $(css)_col$(color_no) $(hidden(arg))">
    $(tmpl_input_field(pgin, arg, arg_type, arr_footnote))
    <span class="plugin_arg_meaning" id="argmeaning_$(pgin_name)_$(arg_name)">$(arg_meaning)</span><br>
    </div>
"""
end

enabled(arg) = get(arg.options, :enabled, true) ? "" : " disabled "
hidden(arg) = get(arg.options, :hidden, false) ? " hidden " : ""

function tmpl_path_input_field(pgin, arg, folderdialog=false)
    button_class = folderdialog ? "FolderDialogButton" : "FileDialogButton"
    pgin_name = pgin.name
    arg_name = arg.name
    arg_val = esc_qm(arg.default_val)
    return """
<input size="65" id="$(pgin_name)_$(arg_name)" name="$(arg_name)" value="$(arg_val)" onchange="oncng(this)" type="text">
<button id="$(pgin_name)_$(arg_name)_button" onclick="oncng(this)" type="button" class="$button_class" $(enabled(arg))>Select</button><br>
"""
end

function tmpl_input_field(pgin, arg)
    pgin_name = pgin.name
    arg_name = arg.name
    arg_val = esc_qm(arg.default_val)
    return """
<input size="70" id="$(pgin_name)_$(arg_name)" name="$(arg_name)" value="$(arg_val)" onchange="oncng(this)" type="text" $(enabled(arg))><br>
"""
end

function tmpl_button(pgin, arg)
    pgin_name = pgin.name
    arg_name = arg.name
    arg_val = esc_qm(arg.default_val)

    (; reason, reasoneach) = arg.options.button_args
    reason = "'$reason'"
    reasoneach != false && (reasoneach = "'$reasoneach'")

    return """
<button id="$(pgin_name)_$(arg_name)" name="$(arg_name)" value="$(arg_val)" onclick="subm($(reason), $(reasoneach))" type="button" $(enabled(arg))>$(arg_val)</button>
"""
end

tmpl_input_field(pgin, arg, ::Type{T}) where T <: AbstractString = tmpl_input_field(pgin, arg)

function tmpl_input_field(pgin, arg, arg_type, arr_footnote=true) 
    arg.default_val isa AbstractArray && return tmpl_input_arrfield(pgin, arg, arr_footnote)
    arg_type == :file && return tmpl_path_input_field(pgin, arg, false)
    arg_type == :dir && return tmpl_path_input_field(pgin, arg, true)
    arg_type == :menu && return make_dd_menu(pgin.name, arg)
    arg_type == :button && return tmpl_button(pgin, arg)
    return tmpl_input_field(pgin, arg)
end

function tmpl_input_field(pgin, arg,  ::Type{Bool}, arr_footnote=true) 
    pgin_name = pgin.name
    arg_name = arg.name
    arg_val = esc_qm(arg.default_val)
    return """
<input id="$(pgin_name)_$(arg_name)" name="$(arg_name)" $(checked(arg_val)) onchange="oncng(this)" type="checkbox" $(enabled(arg))>
"""
end

vec2string(x::Vector) = isempty(x) ? "" : join(x .|> string .|> strip, "\n") |> esc_qm

# tmpl_input_field(pgin, arg, ::Type{T}, arr_footnote=true) where T <: AbstractArray = tmpl_input_arrfield(pgin, arg, arr_footnote)

function tmpl_input_arrfield(pgin, arg, arr_footnote=true)
    pgin_name = pgin.name
    arg_name = arg.name
    arg_val = arg.default_val
    id="$(pgin_name)_$(arg_name)"
    label = """<label for="$id" class="comment">A vector of strings is expected, separated by newlines, commas, or combinations thereof.<br></label>"""
    label_source = arr_footnote ? label : ""

    return """
<textarea id="$id" name="$(arg_name)" rows="3" cols="70" onchange="oncng(this)" $(enabled(arg))>$(vec2string(arg_val))</textarea> <br>
$(label_source)
"""
end

tmpl_end() =
"""
</div>
</form>
</div>
"""

disp_style(show::Bool) = show ? "\"display:block\"" : "\"display:none\""

function shown_pgins()
    pgins = copy(pgins_package)
    pgins["GeneralOptions"] = true
    return pgins
end



ischecked(p::PluginInfo, selected_pgins=shown_pgins()) = selected_pgins[p.name]


geturl(a::PluginArg) = get(a.options, :url, "")

function pgin_inputs(p::PluginInfo, css, arr_footnote=true) 
    join([tmpl_inp(p, a, insert_url(a.meaning, geturl(a)), (i%2+1), css, arr_footnote) for (i, a) in pairs(collect(values(p.args)))], " ") 
end

pgin_form(p::PluginInfo, selected_pgins=shown_pgins(), css="pgin_inp") = 
    # url = get(p.options, :url, "")
    tmpl_beg(p, insert_url(p.purpose, p.url), ischecked(p, selected_pgins)) * 
    pgin_inputs(p, "pgin_inp") *
    tmpl_end()

html_plugins(ps) = tmpl_section_beg() * join([pgin_form(p) for (_, p) in ps #=if ! p.is_general_info=#], " \n") * tmpl_section_end()
