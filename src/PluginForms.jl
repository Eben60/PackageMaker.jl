checked(show) = show ? "checked" : ""

# create one for per plugin
tmpl_beg(pgin_name, purpose, show) =
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
<input size="70" id="$(pgin_name)_$(arg)" name="$(arg)" value="$(arg_val)" onchange="oncng(this)"type="text"><br>
"""

tmpl_input_field(pgin_name, arg, arg_val::Bool) =
"""
<input id="$(pgin_name)_$(arg)" name="$(arg)" $(checked(arg_val)) onchange="oncng(this)" type="checkbox">
"""


tmpl_end() =
"""
</div>
</form>
</div>
"""

disp_style(show::Bool) = show ? "\"display:block\"" : "\"display:none\""


ArgTypes = Union{String, Bool, Nothing, Vector{String}}

struct PluginArg
    name::String
    isvector::Bool
    default::ArgTypes
    meaning::String
end

PluginArg(x::Tuple{AbstractString, Bool, Any, AbstractString}) = PluginArg(String(x[1]), x[2], x[3], String(x[4]))

struct PluginInfo
    tobe_used::Bool
    name::String
    purpose::String
    args::Vector{PluginArg}
end

# PluginInfo(tobe_used::Bool, name::String, purpose::String, x::Vector{Tuple{String, Bool, Any, String}}) = 
#     PluginInfo(tobe_used::Bool, String(name), String(purpose), PluginArg.(x))

PluginInfo(t::Tuple{Bool, AbstractString, AbstractString, Vector{Tuple{String, Bool, Any, String}}}) = 
    PluginInfo(t[1], String(t[2]), String(t[3]), PluginArg.(t[4]))

# PluginInfo(t::Tuple{Bool, String, String, Vector{Tuple{String, Bool, String, String}}}) = PluginInfo(t[1], t[2], t[3], PluginArg.(t[4]))

# PluginInfo(t::Tuple{Bool, String, String, Vector{PluginArg}}) = PluginInfo(t[1], t[2], t[3], t[4])
# PluginInfo(t::Tuple{Bool, String, String, Vector{PluginArg}}) = PluginInfo(t[1], t[2], t[3], t[4])

PluginInfo(t::Tuple{Bool, String, String, Vector{Tuple{String, Bool, String, String}}}) = PluginInfo(t[1], t[2], t[3], PluginArg.(t[4]))


esc_qm(s::String) = replace(s, "\""=>"&quot;")
esc_qm(x) = x

pgin_form(p::PluginInfo) = tmpl_beg(p.name, p.purpose, p.tobe_used) * 
    join([tmpl_inp(p.name, a.name, esc_qm(a.default), esc_qm(a.meaning), (i%2+1)) for (i, a) in pairs(p.args)], " ") *
    tmpl_end()

pgins_all_forms(ps) = join([pgin_form(p) for p in ps], " \n")

export pgins_all_forms, PluginArg, PluginInfo