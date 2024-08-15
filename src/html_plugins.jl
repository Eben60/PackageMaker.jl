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
<label for="project_packages_input" class="comment">A vector of strings is expected. Put each string onto a newline<br></label>
"""



tmpl_end() =
"""
</div>
</form>
</div>
"""

disp_style(show::Bool) = show ? "\"display:block\"" : "\"display:none\""


# ArgTypes = Union{String, Bool, Nothing, Vector{<:AbstractString}}

mutable struct PluginArg
    const type::Union{Type, Symbol}
    const name::String
    const isvector::Bool
    value
    const meaning::String
end

PluginArg(x::Tuple{AbstractString, Bool, Any, AbstractString}) = PluginArg(typeof(x[3]), String(x[1]), x[2], x[3], String(x[4]))
PluginArg(x::Tuple{Union{Type, Symbol}, AbstractString, Bool, Any, AbstractString}) = PluginArg(x[1], String(x[2]), x[3], x[4], String(x[5]))

struct PluginInfo
    name::String
    purpose::String
    args::OrderedDict{String, PluginArg} 
end

function pluginarg_od(v::Vector{T}) where T <: Tuple
    ar = [PluginArg(x) for x in v]
    return OrderedDict(v.name => v for v in ar)
end

PluginInfo(x::Tuple{AbstractString, AbstractString, Vector{T}}) where T <: Tuple = PluginInfo(x[1], x[2], pluginarg_od(x[3]))

ischecked(p::PluginInfo, selected_pgins=pgins_package) = selected_pgins[p.name]

pgin_form(p::PluginInfo, selected_pgins=pgins_package) = tmpl_beg(p.name, p.purpose, ischecked(p, selected_pgins)) * 
    join([tmpl_inp(p.name, a.name, esc_qm(a.value), esc_qm(a.meaning), (i%2+1)) for (i, a) in pairs(collect(values(p.args)))], " ") *
    tmpl_end()

html_plugins(ps) = tmpl_section_beg() * join([pgin_form(p) for (_, p) in ps], " \n") * tmpl_section_end()

export html_plugins, PluginArg, PluginInfo