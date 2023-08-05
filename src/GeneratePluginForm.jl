t = "PlugIns"
inp = "InputType"
inp_val = "InputValue"
packagename = "PackageName"

module PluginDefs

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


ArgTypes = Union{String, Bool, Nothing, }
struct PluginArg
    name::String
    default::ArgTypes
    meaning::String
end

PluginArg(x::Tuple{String, Any, String}) = PluginArg(x[1], x[2], x[3])

struct PluginInfo
    tobe_used::Bool
    name::String
    purpose::String
    args::Vector{PluginArg}
end

PluginInfo(tobe_used::Bool, name::String, purpose::String, x::Vector{Tuple{String, Any, String}}) = PluginInfo(tobe_used::Bool, name, purpose, PluginArg.(x))
PluginInfo(t::Tuple{Bool, String, String, Vector{Tuple{String, Any, String}}}) = PluginInfo(t[1], t[2], t[3], PluginArg.(t[4]))
PluginInfo(t::Tuple{Bool, String, String, Vector{Tuple{String, String, String}}}) = PluginInfo(t[1], t[2], t[3], PluginArg.(t[4]))

PluginInfo(t::Tuple{Bool, String, String, Vector{PluginArg}}) = PluginInfo(t[1], t[2], t[3], t[4])
PluginInfo(t::Tuple{Bool, String, String, Vector{PluginArg}}) = PluginInfo(t[1], t[2], t[3], t[4])

esc_qm(s::AbstractString) = replace(s, "\""=>"&quot;")
esc_qm(x) = x

pgin_form(p::PluginInfo) = tmpl_beg(p.name, p.purpose, p.tobe_used) * 
    join([tmpl_inp(p.name, a.name, esc_qm(a.default), esc_qm(a.meaning), (i%2+1)) for (i, a) in pairs(p.args)], " ") *
    tmpl_end()

pgins_all_forms(ps) = join([pgin_form(p) for p in ps], " \n")

end #module

PluginArg = PluginDefs.PluginArg
PluginInfo = PluginDefs.PluginInfo
pgin_form = PluginDefs.pgin_form
esc_qm = PluginDefs.esc_qm
pgins_all_forms = PluginDefs.pgins_all_forms



plugins = PluginInfo.([
    (true, "ProjectFile", "Creates a Project.toml", [("version", "v\"1.0.0-DEV\"", "The initial version of created packages")]),
    (true, "SrcDir", "Creates a module entrypoint", [("file", "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/src/module.jl", "Template file for src/$(packagename).jl")]),
    (true, "Tests", "Sets up testing for packages", [("file", "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/test/runtests.jl", "Template file for runtests.jl")
                ("project", false, "Whether or not to create a new project for tests (test/Project.toml).")]),
    (false, "Readme", "Creates a README file that contains badges for other included plugins.", [("file", "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/README.md", ""), 
                ("destination", "README.md", ""), 
                ("inline_badges", false, "Whether or not to put the badges on the same line as the package name.")]),
    (true, "License", "Creates a license file", [("name", "MIT", "Name of a license supported by PkgTemplates. Dropdown menu to be added here!"), 
                ("path", nothing, "Path to a custom license file. This keyword takes priority over name."), 
                ("destination", "LICENSE", "File destination, relative to the repository root. For example, \"LICENSE.md\" might be desired.")]),
    (true, "Git", "Creates a Git repository and a .gitignore file", [("ignore", "", "Patterns to add to the .gitignore"), 
                ("name", "nothing", "Your real name, if you have not set user.name with Git."), 
                ("email", "nothing", "Your email address, if you have not set user.email with Git."), 
                ("branch", "LibGit2.getconfig(\"init.defaultBranch\", \"main\")", "The desired name of the repository's default branch."), 
                ("ssh", false, "Whether or not to use SSH for the remote. If left unset, HTTPS is used."), 
                ("jl", true, "Whether or not to add a .jl suffix to the remote URL."), 
                ("manifest", false, "Whether or not to commit Manifest.toml."), 
                ("gpgsign", false, "Whether or not to sign commits with your GPG key. This option requires that the Git CLI is installed, and for you to have a GPG key associated with your committer identity.")]),
    (true, "CompatHelper", "Integrates your packages with CompatHelper via GitHub Actions", [("file", "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/github/workflows/CompatHelper.yml", "Template file for the workflow file"), 
                ("destination", "CompatHelper.yml", "Destination of the workflow file, relative to .github/workflows"), 
                ("cron", "0 0 * * *", "Cron expression for the schedule interval"), ]),
    (true, "TagBot", "Adds GitHub release support via TagBot", [("file", "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/github/workflows/TagBot.yml", "Template file for the workflow file."), 
                ("destination", "TagBot.yml", "Destination of the workflow file, relative to .github/workflows"), 
                ("trigger", "JuliaTagBot", "Username of the trigger user for custom registries"), 
                ("token", "Secret(\"GITHUB_TOKEN\")", "Name of the token secret to use"), 
                ("ssh", "Secret(\"DOCUMENTER_KEY\")", "Name of the SSH private key secret to use"), 
                ("ssh_password", "nothing", "Name of the SSH key password secret to use"), 
                ("changelog", "nothing", "Custom changelog template"), 
                ("changelog_ignore", "nothing", "Issue/pull request labels to ignore in the changelog"), 
                ("gpg", "nothing", "Name of the GPG private key secret to use"), 
                ("gpg_password", "nothing", "Name of the GPG private key password secret to use"), 
                ("registry", "nothing", "Custom registry, in the format owner/repo"), 
                ("branches", "nothing", "Whether not to enable the branches option"), 
                ("dispatch", "nothing", "Whether or not to enable the dispatch option"), 
                ("dispatch_delay", "nothing", "Number of minutes to delay for dispatch events"), ]),
                ]);


;
