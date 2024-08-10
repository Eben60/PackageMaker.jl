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
    <input id="Use_$(pgin_name)" value="Use_$(pgin_name)" $(checked(show)) onchange="oncng(this)" type="checkbox"> 
    <label for="Use_$(pgin_name)">$(pgin_name) plugin </label>
    <div class="Plugin_Purpose">$(purpose).</div>
    <div class="Plugin_Inputs" id="$(pgin_name)_inputs" style = $(disp_style(show)) >
"""

tmpl_inp(pgin_name, arg, arg_val, arg_mean, color_no) =
"""
    <div class="pgin_inp_margins pgin_inp_col$(color_no)">
    $(tmpl_input_field(pgin_name, arg, arg_val))
    <span class="plugin_arg_meaning" id="argmeaning_$(pgin_name)_$(arg)">$(arg_mean)</span><br>
    </div>
"""

tmpl_input_field(pgin_name, arg, arg_val) =
"""
<input size="70" id="$(pgin_name)_$(arg)" name="$(arg)" value="$(arg_val)" onchange="oncng(this)" type="text"><br>
"""

tmpl_input_field(pgin_name, arg, arg_val::Bool) =
"""
<input id="$(pgin_name)_$(arg)" name="$(arg)" $(checked(arg_val)) onchange="oncng(this)" type="checkbox">
"""

vec2string(x::Vector) = isempty(x) ? "" : string.(x)

tmpl_input_field(pgin_name, arg, arg_val::Vector) =
"""
<textarea id="$(pgin_name)_$(arg)" name="$(arg)" rows="3" cols="70" onchange="oncng(this)" >$(vec2string(arg_val)) </textarea> <br>
<label for="project_packages_input" class="comment">A vector of strings is expected. Put each string onto a newline</label>
"""



tmpl_end() =
"""
</div>
</form>
</div>
"""

disp_style(show::Bool) = show ? "\"display:block\"" : "\"display:none\""


ArgTypes = Union{String, Bool, Nothing, Vector{<:AbstractString}}

struct PluginArg
    name::String
    isvector::Bool
    value::ArgTypes
    meaning::String
end

PluginArg(x::Tuple{AbstractString, Bool, Any, AbstractString}) = PluginArg(String(x[1]), x[2], x[3], String(x[4]))
struct PluginInfo
    name::String
    purpose::String
    args::Vector{PluginArg}
end

# PluginInfo(tobe_used::Bool, name::String, purpose::String, x::Vector{Tuple{String, Bool, Any, String}}) = 
#     PluginInfo(tobe_used::Bool, String(name), String(purpose), PluginArg.(x))

PluginInfo(t::Tuple{AbstractString, AbstractString, Vector{Tuple{String, Bool, Any, String}}}) = 
    PluginInfo(String(t[1]), String(t[2]), PluginArg.(t[3]))

# PluginInfo(t::Tuple{Bool, String, String, Vector{Tuple{String, Bool, String, String}}}) = PluginInfo(t[1], t[2], t[3], PluginArg.(t[4]))

# PluginInfo(t::Tuple{Bool, String, String, Vector{PluginArg}}) = PluginInfo(t[1], t[2], t[3], t[4])
# PluginInfo(t::Tuple{Bool, String, String, Vector{PluginArg}}) = PluginInfo(t[1], t[2], t[3], t[4])

PluginInfo(t::Tuple{String, String, Vector{Tuple{String, Bool, String, String}}}) = PluginInfo(t[1], t[2], PluginArg.(t[3]))

ischecked(p::PluginInfo, selected_pgins=pgins_package) = selected_pgins[p.name]

pgin_form(p::PluginInfo, selected_pgins=pgins_package) = tmpl_beg(p.name, p.purpose, ischecked(p, selected_pgins)) * 
    join([tmpl_inp(p.name, a.name, esc_qm(a.value), esc_qm(a.meaning), (i%2+1)) for (i, a) in pairs(p.args)], " ") *
    tmpl_end()

html_plugins(ps) = tmpl_section_beg() * join([pgin_form(p) for p in ps], " \n") * tmpl_section_end()

export html_plugins, PluginArg, PluginInfo