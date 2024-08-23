tmpl_section_beg() = 
"""
<div  id="tmpl_section_div">
<h2>Plugins and their parameter</h2>
    <p class="comment">Most of the functionalities of <code>PkgTemplates</code> is provided by plugins. 
    The following section provides access to those plugins which are included in the default installation of <code>PkgTemplates</code></p>
"""

tmpl_section_end() = 
"""
</div>
"""


# create one for per plugin
tmpl_beg(pgin_name, purpose, show=true) =
"""
<div class="plugin_form_div" id="plugin_form_div_$(pgin_name)">
<form class="plugin_form" name="$(pgin_name)_form" id="$(pgin_name)_form" action="javascript:void(0)">
    <input id="Use_$(pgin_name)" value="Use_$(pgin_name)" $(checked(show)) onchange="oncng(this)" type="checkbox" class="TogglePlugin">
    <label for="Use_$(pgin_name)">$(pgin_name) plugin </label>
    <div class="Plugin_Purpose">$(purpose).</div>
    <div class="Plugin_Inputs" id="$(pgin_name)_inputs" style=$(disp_style(show)) >
"""

function tmpl_inp(pgin, arg, arg_meaning, color_no) 
    pgin_name = pgin.name
    arg_type = arg.type
    arg_name = arg.name
    return """
    <div class="pgin_inp_margins pgin_inp_col$(color_no)">
    $(tmpl_input_field(pgin, arg, arg_type))
    <span class="plugin_arg_meaning" id="argmeaning_$(pgin_name)_$(arg_name)">$(arg_meaning)</span><br>
    </div>
"""
end

function tmpl_path_input_field(pgin, arg, folderdialog=false)
    button_class = folderdialog ? "FolderDialogButton" : "FileDialogButton"
    pgin_name = pgin.name
    arg_name = arg.name
    arg_val = esc_qm(arg.default_val)
    return """
<input size="65" id="$(pgin_name)_$(arg_name)" name="$(arg_name)" value="$(arg_val)" onchange="oncng(this)" type="text">
<button id="$(pgin_name)_$(arg_name)_button" onclick="oncng(this)" type="button" class="$button_class">Select</button><br>
"""
end

function tmpl_input_field(pgin, arg)
    pgin_name = pgin.name
    arg_name = arg.name
    arg_val = esc_qm(arg.default_val)
    return """
<input size="70" id="$(pgin_name)_$(arg_name)" name="$(arg_name)" value="$(arg_val)" onchange="oncng(this)" type="text"><br>
"""
end

tmpl_input_field(pgin, arg, ::Type{T}) where T <: AbstractString = tmpl_input_field(pgin, arg)

function tmpl_input_field(pgin, arg, arg_type) 
    arg.default_val isa AbstractArray && return tmpl_input_arrfield(pgin, arg)
    arg_type == :file && return tmpl_path_input_field(pgin, arg, false)
    arg_type == :dir && return tmpl_path_input_field(pgin, arg, true)
    return tmpl_input_field(pgin, arg)
end

function tmpl_input_field(pgin, arg,  ::Type{Bool}) 
    pgin_name = pgin.name
    arg_name = arg.name
    arg_val = esc_qm(arg.default_val)
    return """
<input id="$(pgin_name)_$(arg_name)" name="$(arg_name)" $(checked(arg_val)) onchange="oncng(this)" type="checkbox">
"""
end

vec2string(x::Vector) = isempty(x) ? "" : join(string.(x), "\n") |> esc_qm

tmpl_input_field(pgin, arg, ::Type{T}) where T <: AbstractArray = tmpl_input_arrfield(pgin, arg)

function tmpl_input_arrfield(pgin, arg)
    pgin_name = pgin.name
    arg_name = arg.name
    arg_val = arg.default_val
    id="$(pgin_name)_$(arg_name)"

    return """
<textarea id="$id" name="$(arg_name)" rows="3" cols="70" onchange="oncng(this)" >$(vec2string(arg_val)) </textarea> <br>
<label for="$id" class="comment">A vector of strings is expected. Put each string onto a newline<br></label>
"""
end

tmpl_end() =
"""
</div>
</form>
</div>
"""

disp_style(show::Bool) = show ? "\"display:block\"" : "\"display:none\""

ischecked(p::PluginInfo, selected_pgins=pgins_package) = selected_pgins[p.name]

pgin_form(p::PluginInfo, selected_pgins=pgins_package) = tmpl_beg(p.name, esc_qm(p.purpose), ischecked(p, selected_pgins)) * 
    join([tmpl_inp(p, a, esc_qm(a.meaning), (i%2+1)) for (i, a) in pairs(collect(values(p.args)))], " ") *
    tmpl_end()

html_plugins(ps) = tmpl_section_beg() * join([pgin_form(p) for (_, p) in ps], " \n") * tmpl_section_end()

export html_plugins, PluginArg, PluginInfo