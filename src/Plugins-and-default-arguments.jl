packagename :: String = "MyPackage"

# function get_module_directory(module_name)
#     for (pkg, mod) in Base.loaded_modules
#         if pkg.name == String(module_name)
#             return  pathof(mod) |> dirname |> dirname
#         end
#     end
#     return nothing
# end

# const templ_dir = joinpath(get_module_directory("PkgTemplates"), "templates") |> posixpathstring
const default_branch = LibGit2.getconfig("init.defaultBranch", "main")

function get_licences()
    pkgpath = abspath(dirname(pathof(PkgTemplates)))

    lic_dir = joinpath(pathof(PkgTemplates), "..", "..", "templates", "licenses") |> normpath #, "licenses")
    isdir(lic_dir) || error("Licenses directory $lic_dir not found.")
    licences = readdir(lic_dir)
    deleteat!(licences, findfirst(==("MIT"), licences))
    pushfirst!(licences, "MIT")
    return licences
end

package_info_descr = 
"""<b>Short package<sup>*</sup> info.</b><br> 
This will be put into the package docstring. If you plan to publish it on 
<a href="javascript:sendurl('https://github.com/')" >GitHub</a>, it is recommended to provide (the same) short info under "About", 
which will also be then shown on <a href="javascript:sendurl('https://juliahub.com/')" >juliahub.com</a> after the package registration.
<br><span class="comment"> <sup>*</sup>Projects have no docstrings</span>"""

function plugins_od()
    dfp = PluginInfo.([
        ("GeneralOptions", "General Options", [
            ("is_package", true, "Create a package (vs. a project)."), 
            ("proj_name", "", "Project/Package name. Required input."),
            ("user_name", "$(githubuser())", "User name. Required for many plugins."),
            ("authors", "$(username()) <$(usermail())>", "Authors. Will be an entry in <code>Project.toml</code>. "),
            (:dir, "project_dir", "", "Directory to place project in. Required input."),
            ("jl_suffix", false, "Add <code>.jl</code> suffix to the name of the project folder"), 
            ("versioned_man", true, "Use <a>version-named manifests</a>.", "https://pkgdocs.julialang.org/v1/toml-files/#Different-Manifests-for-Different-Julia-versions"),
            ("host", "github.com", "URL to the code hosting service where the project will reside."),
            (VersionNumber, "julia_min_version", v"1.10", "Minimum allowed Julia version for this package."),
            (:text, "docstring", [""], "$(package_info_descr)"),
            (Vector{String}, "proj_pkg", [""], "Packages to add to your project. Suffix <code>.jl</code> is accepted, but not required. You can of course always add packages later on using <code>Pkg</code>."),
            (; type = Bool, name="add_imports", default_val = false, meaning = "Add these packages to the source code like <code>using Foo</code>"), 
            (; type=Bool, name="makerepo", default_val=false, 
                meaning="""Create GitHub repo. <br><span class="comment">To use this feature, install and configure <a>GitHub CLI tools</a></span>""", 
                options=(; enabled=gh_installed(), url = "https://eben60.github.io/PackageMaker.jl/#Creating-remote-repository-on-GitHub") ), 
            (; type=Bool, name="repopublic", default_val = true, meaning="Created GitHub repo will be public", options=(; enabled=false, hidden=false) ),  
            ], true),
        ("ProjectFile", "Creates a Project.toml", [
            (VersionNumber, "version", v"0.0.1", "The initial version of created package (ignored for projects)."),
            ]),
        ("SrcDir", "Creates a module entrypoint", [
            (:file, "file", "<DEFAULT_FILE>", "Template file for src/$(packagename).jl"),
            ]),
        ("Tests", "Sets up testing for packages", [
            (:file, "file", "<DEFAULT_FILE>", "Template file for runtests.jl"),
            ("project", true, "Create a new project for tests (test/Project.toml)."),
            ("aqua", false, "Add quality tests with <a>Aqua.jl</a>.", "https://juliatesting.github.io/Aqua.jl"),
            (type=:ExcludedPlugins, name="aqua_kwargs",  default_val=["ambiguities"], 
                meaning="List of Aqua tests to skip. For full power of Aqua testing, edit your runtests.jl file manually.", 
                options=(; enabled=false, hidden=false)), 
            ("jet", false, "Add a linting test with <a>JET.jl</a> (works best on type-stable code).", "https://aviatesk.github.io/JET.jl"),
            ]),
        ("Git", "Creates a Git repository and a .gitignore file", [
            (Vector{String}, "ignore",  [""], "Patterns to add to the .gitignore"), 
            ("name", nothing, "Your real name, if you have not set user.name with Git."), 
            ("email", nothing, "Your email address, if you have not set user.email with Git."), 
            ("branch", "$(default_branch)", "The desired name of the repository's default branch."), 
            ("ssh", false, "Use SSH for the remote. If left unset, HTTPS is used."), 
            ("jl", true, "Add a .jl suffix to the remote URL."), 
            ("manifest", false, "Commit Manifest.toml."), 
            ("gpgsign", false, """Sign commits with your GPG key.<br><span class="comment">This option requires that the Git CLI is installed, and for you to have a GPG key associated with your committer identity.</span>"""),
            ]),
        ("Readme", "Creates a README file that contains badges for other included plugins", [
            (:file, "file", "<DEFAULT_FILE>", "Template file for the README."), 
            ("destination", "README.md", "File destination, relative to the repository root."), 
            ("inline_badges", false, "Put the badges on the same line as the package name."),
            ]),
        ("License", "Creates a license file", [
            (; type = :menu, name="name", default_val = "", # will be filled in from the options get_licences()[1], 
                meaning = "Name of a <a>license supported</a> by PkgTemplates.", 
                options = (;url = "https://github.com/JuliaCI/PkgTemplates.jl/tree/master/templates/licenses", 
                            menuoptions = (; opt_list = get_licences(), show_first = true, menulabel = "Show licenses")),
                ), 
            (:file, "path", nothing, "Path to a custom license file. This keyword takes priority over name."), 
            ("destination", "LICENSE", "File destination, relative to the repository root. For example, \"LICENSE.md\" might be desired."),
            ]),
        ("GitHubActions", "Integrates your packages with <a>GitHub Actions</a>.", [
            (:file, "file", "<DEFAULT_FILE>", "Template file for the workflow file"), 
            ("destination", "CI.yml", "Destination of the workflow file, relative to .github/workflows"), 
            ("linux", true, "Run builds on Linux."), 
            ("osx", false, "Run builds on OSX (MacOS)."), 
            ("windows", false, "Run builds on Windows."), 
            ("x64", true, "Run builds on 64-bit architecture."), 
            ("x86", false, "Run builds on 32-bit architecture."), 
            ("coverage", false, """Publish code coverage. If activating this option, activate also Codecov plugin. <br><span class="comment">If using coverage plugins, don't forget to manually add your API tokens as secrets, as described in PkgTemplate manual.</span>"""), 
            (Vector{String}, "extra_versions",  [julia_lts_str, "pre"], "Extra Julia versions to test, as strings."), 
            ], "https://github.com/features/actions"),
        ("CompatHelper", "Integrates your packages with <a>CompatHelper</a> via GitHub Actions", [
            (:file, "file", "<DEFAULT_FILE>", "Template file for the workflow file"), 
            ("destination", "CompatHelper.yml", "Destination of the workflow file, relative to .github/workflows"), 
            ("cron", "0 0 * * *", "Cron expression for the schedule interval"), 
            ], "https://juliaregistries.github.io/CompatHelper.jl"),
        ("TagBot", "Adds GitHub release support via <a>TagBot</a>", [
            (:file, "file", "<DEFAULT_FILE>", "Template file for the workflow file."), 
            ("destination", "TagBot.yml", "Destination of the workflow file, relative to .github/workflows"), 
            ("trigger", "JuliaTagBot", "Username of the trigger user for custom registries"), 
            ("token", nothing, "Name of the token secret to use"), 
            ("ssh", nothing, "Name of the SSH private key secret to use"), 
            ("ssh_password", nothing, "Name of the SSH key password secret to use"), 
            (:file, "changelog", nothing, "Custom changelog template"), 
            ("changelog_ignore", nothing, "Issue/pull request labels to ignore in the changelog"), 
            ("gpg", nothing, "Name of the GPG private key secret to use"), 
            ("gpg_password", nothing, "Name of the GPG private key password secret to use"), 
            ("registry", nothing, "Custom registry, in the format owner/repo"), 
            ("branches", false, "Enable the branches option"), 
            ("dispatch", false, "Enable the dispatch option"), 
            (Int64, "dispatch_delay", nothing, "Number of minutes to delay for dispatch events"), 
            ], "https://github.com/marketplace/actions/julia-tagbot"),
        ("Dependabot", "Setups <a>Dependabot</a> to create PRs whenever GitHub actions can be updated. This is very similar to CompatHelper, which performs the same task for Julia package dependencies", [
            (:file, "file", "<DEFAULT_FILE>", "Template file"), 
            ], "https://discourse.julialang.org/t/psa-use-dependabot-to-update-github-actions-automatically"),
        ("Documenter", "Sets up documentation generation via <a>Documenter.jl</a>. Only subset of options currently supported", [
            (:file, "make_jl", "<DEFAULT_FILE>", "Template file for make.jl"), 
            (:file, "index_md", "<DEFAULT_FILE>", "Template file for index.md"), 
            ("deploy", false, """Deploy documentation using GitHubActions. <br><span class="comment">Make sure GitHubActions pluging is activated.</span>"""), 
            ], "https://documenter.juliadocs.org"),
        ("Codecov", "Sets up code coverage submission from CI to <a>Codecov</a>.", [
            (:file, "file", nothing, "Template file for .codecov.yml, or nothing to create no file (in the last case, check the corresponding option at GitHubActions plugin)."), 
            ], "https://about.codecov.io"),
        # ("Coveralls", "Sets up code coverage submission from CI to <a>Coveralls</a>.", [
        #     (:file, "file", nothing, "Template file for .coveralls.yml, or nothing to create no file."), 
        #     ], "https://coveralls.io"),
        ("Save_Configuration", "Manage Configurations", "You can save the applicable parameter for later reuse. Excluded are: project name, description, and added dependencies", [ 
            (; type = :menu, name="config_name", default_val = "",  
                meaning = "Configuration name. You can select an existing config to update or delete it, or create a new one. <br><br> You can use alphanumeric characters, space, <br> and following characters: <code>.,!_+-*/#</code>", 
                options = (; menuoptions = (; opt_list = savedconfignames(), show_first = false, menulabel = "Show saved configurations")),
                ),
                (; type = :button, name = "SaveConfigButton", meaning = "", default_val = "Save Configuration", options = (; button_args = (; reason="saveprefs_finished", reasoneach="intermed_input"))), 
                (; type = :button, name = "DeleteConfigButton", meaning = "", default_val = "Delete Configuration", options = (; button_args = (; reason="deleteprefs_finished", reasoneach="intermed_input"))), 
    
             ], false, "", true),
        ]);
    
    # non-default templates of PkgTemplates, supported by PackageMaker, as well as pseudo-plugins
    
    
    return OrderedDict(v.name => v for v in dfp)
end

def_plugins_original::OrderedDict{String, PluginInfo} = OrderedDict{String, PluginInfo}()
def_plugins::OrderedDict{String, PluginInfo} = OrderedDict{String, PluginInfo}()# = deepcopy(def_plugins_original) 

const extra_plugins = ["Documenter", "Codecov", "GeneralOptions", "Save_Configuration", #="Coveralls"=#] 
const pkgtmpl_def_plugins =  PkgTemplates.default_plugins() .|> type2str

function check_default_pktplugins(def_plugins)
    this_def_plugins = setdiff(keys(def_plugins), extra_plugins)

    sd1 = setdiff(this_def_plugins, pkgtmpl_def_plugins)
    sd2 = setdiff(pkgtmpl_def_plugins, this_def_plugins)

    isempty(sd1) || @warn "This package lists plugins $sd1, which are not among the default templates of PkgTemplates"
    isempty(sd2) || @warn "This package does not list plugins $sd2, which are among the default templates of PkgTemplates"
end

