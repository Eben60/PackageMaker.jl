t = "PlugIns"
inp = "InputType"
inp_val = "InputValue"
packagename = "PackageName"

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

module PluginDefs
ArgTypes = Union{String, Bool, Nothing, }
struct PluginArg
    name::String
    default::ArgTypes
    meaning::String
end

PluginArg(x::Tuple{String, Any, String}) = PluginArg(x[1], x[2], x[3])

struct PluginInfo
    name::String
    args::Vector{PluginArg}
end

PluginInfo(name::String, x::Vector{Tuple{String, Any, String}}) = PluginInfo(name, PluginArg.(x))
PluginInfo(t::Tuple{String, Vector{Tuple{String, Any, String}}}) = PluginInfo(t[1], PluginArg.(t[2]))
PluginInfo(t::Tuple{String, Vector{Tuple{String, String, String}}}) = PluginInfo(t[1], PluginArg.(t[2]))

PluginInfo(t::Tuple{String, Vector{PluginArg}}) = PluginInfo(t[1], t[2])



end #module

PluginArg = PluginDefs.PluginArg
PluginInfo = PluginDefs.PluginInfo

# plugins = PluginInfo("ProjectFile", PluginArg.( [("version", "v", "The initial version of created packages")]))

  #  ("SrcDir", [("file", "module.jl", "Template ")]))

  plugins = PluginInfo.([
    ("ProjectFile", [("version", "v\"1.0.0-DEV\"", "The initial version of created packages")]),]);

plugins = PluginInfo.([
    ("ProjectFile", [("version", "v\"1.0.0-DEV\"", "The initial version of created packages")]),
    ("SrcDir", [("file", "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/src/module.jl", "Template file for src/$(packagename).jl")]),
    ("Tests", [("file", "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/test/runtests.jl", "Template file for runtests.jl")
                ("project", false, "Whether or not to create a new project for tests (test/Project.toml).")]),
    ("Readme", [("file", "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/README.md", ""), 
                ("destination", "README.md", ""), 
                ("inline_badges", false, "Whether or not to put the badges on the same line as the package name.")]),
    ("License", [("name", "MIT", "Name of a license supported by PkgTemplates. Dropdown menu to be added here!"), 
                ("path", nothing, "Path to a custom license file. This keyword takes priority over name."), 
                ("destination", "LICENSE", "File destination, relative to the repository root. For example, \"LICENSE.md\" might be desired.")]),
    ("Git", [("ignore", "", ""), 
                ("name", "nothing", "Your real name, if you have not set user.name with Git."), 
                ("email", "nothing", "Your email address, if you have not set user.email with Git."), 
                ("branch", "LibGit2.getconfig(\"init.defaultBranch\", \"main\")", "The desired name of the repository's default branch."), 
                ("ssh", false, "Whether or not to use SSH for the remote. If left unset, HTTPS is used."), 
                ("jl", true, "Whether or not to add a .jl suffix to the remote URL."), 
                ("manifest", false, "Whether or not to commit Manifest.toml."), 
                ("gpgsign", false, "Whether or not to sign commits with your GPG key. This option requires that the Git CLI is installed, and for you to have a GPG key associated with your committer identity.")]),

]);


;
