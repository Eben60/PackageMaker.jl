tmpl_beg =
"""
<div>
<form name="$(t)" id="$(t)" action="javascript:void(0)"> <input
    id="Use_$(t)" value="Use_$(t)" checked="checked" onchange="oncng(this)"
    type="checkbox"> <label for="Use_$(t)">$(t) plugin </label>
  <div class="Plugin_Purpose">Create a <code>Project.toml</code>.</div>
  <br>
"""

tmpl_inp =
"""
<input size="100" id="$(t)_$(inp)" name="$(inp)" value="$(inp_val)"
type="text"><br>
"""

tmpl_end =
"""
</form>
</div>
"""

struct PluginArg
    name::String
    default::String
    meaning::String
end

PluginArg(x::Tuple{String, String, String}) = PluginArg(x[1], x[2], x[3])

struct PluginInfo
    name::String
    args::Vector{PluginArg}
end

PluginInfo(name::String, x::Vector{Tuple{String, String, String}}) = PluginInfo(name, PluginArg.(x))
PluginInfo(t::Tuple{String, Vector{Tuple{String, String, String}}}) = PluginInfo(t[1], t[2])

plugins = PluginInfo.([
    ("ProjectFile", [("version", "v\"1.0.0-DEV\"", "The initial version of created packages")]),
    ("SrcDir", [("file", "\"~/work/PkgTemplates.jl/PkgTemplates.jl/templates/src/module.jl\"", "Template file for src/<module>.jl")]),
    ("Tests", [("file", "\"~/work/PkgTemplates.jl/PkgTemplates.jl/templates/test/runtests.jl\"", "Template file for runtests.jl")
                ("project", "false", "Whether or not to create a new project for tests (test/Project.toml)")]),
 
    ("", [("", "", "")]),
    ("", [("", "", "")]),
    ("", [("", "", "")]),

]);


;
