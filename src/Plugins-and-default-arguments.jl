packagename :: String = "MyPackage"

function get_module_directory(module_name)
    for (pkg, mod) in Base.loaded_modules
        if pkg.name == String(module_name)
            return  pathof(mod) |> dirname |> dirname
        end
    end
    return nothing
end

const templ_dir = joinpath(get_module_directory("PkgTemplates"), "templates") |> posixpathstring
const default_branch = LibGit2.getconfig("init.defaultBranch", "main")

dfp = PluginInfo.([
    ("ProjectFile", "Creates a Project.toml", [
        (:VersionNumber, "version", "v\"0.0.1\"", "The initial version of created package (ignored for projects)."),
        ]),
    ("SrcDir", "Creates a module entrypoint", [
        (:file, "file", "$(templ_dir)/src/module.jlt", "Template file for src/$(packagename).jl"),
        ]),
    ("Tests", "Sets up testing for packages", [
        (:file, "file", "$(templ_dir)/test/runtests.jlt", "Template file for runtests.jl"),
        ("project", false, "Whether to create a new project for tests (test/Project.toml)."),
        ("aqua", false, "Whether to add quality tests with <a>Aqua.jl</a>.", "https://juliatesting.github.io/Aqua.jl"),
        (:ExcludedPlugins, "aqua_kwargs",  ["ambiguities"], "List of Aqua tests to skip. For full power of Aqua testing, edit your runtests.jl file manually."), 
        ("jet", false, "Whether to add a linting test with <a>JET.jl</a> (works best on type-stable code).", "https://aviatesk.github.io/JET.jl"),
        ]),
    ("Readme", "Creates a README file that contains badges for other included plugins", [
        (:file, "file", "$(templ_dir)/README.md", "Template file for the README."), 
        ("destination", "README.md", "File destination, relative to the repository root."), 
        ("inline_badges", false, "Whether to put the badges on the same line as the package name."),
        ]),
    ("License", "Creates a license file", [
        (; name="name", default_val = "MIT", 
            meaning = "Name of a <a>license supported</a> by PkgTemplates.", 
            url = "https://github.com/JuliaCI/PkgTemplates.jl/tree/master/templates/licenses"), 
        (:file, "path", "nothing", "Path to a custom license file. This keyword takes priority over name."), 
        ("destination", "LICENSE", "File destination, relative to the repository root. For example, \"LICENSE.md\" might be desired."),
        ]),
    ("Git", "Creates a Git repository and a .gitignore file", [
        (Vector{String}, "ignore",  String[], "Patterns to add to the .gitignore"), 
        ("name", "nothing", "Your real name, if you have not set user.name with Git."), 
        ("email", "nothing", "Your email address, if you have not set user.email with Git."), 
        ("branch", "$(default_branch)", "The desired name of the repository's default branch."), 
        ("ssh", false, "Whether to use SSH for the remote. If left unset, HTTPS is used."), 
        ("jl", true, "Whether to add a .jl suffix to the remote URL."), 
        ("manifest", false, "Whether to commit Manifest.toml."), 
        ("gpgsign", false, "Whether to sign commits with your GPG key. This option requires that the Git CLI is installed, and for you to have a GPG key associated with your committer identity."),
        ]),
    ("GitHubActions", "Creates a Git repository and a .gitignore file", [
        (:file, "file", "$(templ_dir)/github/workflows/CI.yml", "Template file for the workflow file"), 
        ("destination", "CI.yml", "Destination of the workflow file, relative to .github/workflows"), 
        ("linux", true, "Whether to run builds on Linux."), 
        ("osx", false, "Whether to run builds on OSX (MacOS)."), 
        ("windows", false, "Whether to run builds on Windows."), 
        ("x64", true, "Whether to run builds on 64-bit architecture."), 
        ("x86", false, "Whether to run builds on 32-bit architecture."), 
        ("coverage", false, "Whether to publish code coverage. If activating this option, activate also Codecov plugin. If using coverage plugins, don't forget to manually add your API tokens as secrets, as described in PkgTemplate manual."), 
        (Vector{String}, "extra_versions",  [julia_lts_str, "pre"], "Extra Julia versions to test, as strings."), 
        ]),
    ("CompatHelper", "Integrates your packages with <a>CompatHelper</a> via GitHub Actions", [
        (:file, "file", "$(templ_dir)/github/workflows/CompatHelper.yml", "Template file for the workflow file"), 
        ("destination", "CompatHelper.yml", "Destination of the workflow file, relative to .github/workflows"), 
        ("cron", "0 0 * * *", "Cron expression for the schedule interval"), 
        ], "https://juliaregistries.github.io/CompatHelper.jl"),
    ("TagBot", "Adds GitHub release support via <a>TagBot</a>", [
        (:file, "file", "$(templ_dir)/github/workflows/TagBot.yml", "Template file for the workflow file."), 
        ("destination", "TagBot.yml", "Destination of the workflow file, relative to .github/workflows"), 
        ("trigger", "JuliaTagBot", "Username of the trigger user for custom registries"), 
        ("token", "nothing", "Name of the token secret to use"), 
        ("ssh", "nothing", "Name of the SSH private key secret to use"), 
        ("ssh_password", "nothing", "Name of the SSH key password secret to use"), 
        ("changelog", "nothing", "Custom changelog template"), 
        ("changelog_ignore", "nothing", "Issue/pull request labels to ignore in the changelog"), 
        ("gpg", "nothing", "Name of the GPG private key secret to use"), 
        ("gpg_password", "nothing", "Name of the GPG private key password secret to use"), 
        ("registry", "nothing", "Custom registry, in the format owner/repo"), 
        ("branches", false, "Whether to enable the branches option"), 
        ("dispatch", false, "Whether to enable the dispatch option"), 
        (Int64, "dispatch_delay", "nothing", "Number of minutes to delay for dispatch events"), 
        ], "https://github.com/marketplace/actions/julia-tagbot"),
    ("Dependabot", "Setups <a>Dependabot</a> to create PRs whenever GitHub actions can be updated. This is very similar to CompatHelper, which performs the same task for Julia package dependencies", [
        (:file, "file", "$(templ_dir)/github/dependabot.yml", "Template file."), 
        ], "https://discourse.julialang.org/t/psa-use-dependabot-to-update-github-actions-automatically"),
    ("Documenter", "Sets up documentation generation via <a>Documenter.jl</a>. Only subset of options currently supported", [
        (:file, "make_jl", "$(templ_dir)/docs/make.jlt", "Template file for make.jl"), 
        (:file, "index_md", "$(templ_dir)/docs/src/index.md", "Template file for index.md"), 
        ("deploy", false, "Whether to deploy documentation using GitHubActions"), 
        ], "https://documenter.juliadocs.org"),
    ("Codecov", "Sets up code coverage submission from CI to <a>Codecov</a>.", [
        (:file, "file", "nothing", "Template file for .codecov.yml, or nothing to create no file (in the last case, check the corresponding option at GitHubActions plugin)."), 
        ], "https://about.codecov.io"),
    # ("Coveralls", "Sets up code coverage submission from CI to <a>Coveralls</a>.", [
    #     (:file, "file", "nothing", "Template file for .coveralls.yml, or nothing to create no file."), 
    #     ], "https://coveralls.io"),
    ]);

extra_plugins = ["Documenter", "Codecov", #="Coveralls"=#] # non-default templates of PkgTemplates, supported by PackageMaker
def_plugins::OrderedDict{String, PluginInfo} = OrderedDict(v.name => v for v in dfp)
this_def_plugins = setdiff(keys(def_plugins), extra_plugins)

pkgtmpl_def_plugins =  PkgTemplates.default_plugins() .|> type2str


sd1 = setdiff(this_def_plugins, pkgtmpl_def_plugins)
sd2 = setdiff(pkgtmpl_def_plugins, this_def_plugins)

isempty(sd1) || @warn "This package lists plugins $sd1, which are not among the default templates of PkgTemplates"
isempty(sd2) || @warn "This package does not list plugins $sd2, which are among the default templates of PkgTemplates"

function get_licences()
    pkgpath = abspath(dirname(pathof(PkgTemplates)))

    lic_dir = joinpath(pathof(PkgTemplates), "..", "..", "templates", "licenses") |> normpath #, "licenses")
    @assert isdir(lic_dir)
    licences = readdir(lic_dir)
    deleteat!(licences, findfirst(==("MIT"), licences))
    pushfirst!(licences, "MIT")
    return licences
end
# export get_licences

# gen_options::PluginInfo = PluginInfo(
#     ("GenOptions", "Defines general options", [
#         ("proj_name", "", "Project/Package name. Required input."), 
#         ("user_name", "$(githubuser())", "User name. Required for many plugins."), # was "user", probably wrong
#         ("authors", ["$(username()) <$(usermail())>"], "Authors. Will be an entry in Project.toml."), 
#         (:dir, "dir", "", "Directory to place project in. Required input."), 
#         ("host", "github.com", "URL to the code hosting service where the project will reside."), 
#         (:VersionNumber, "julia", "v\"$julia_lts_str\"", "Minimum allowed Julia version for this package."), 
#         ]),
#     )

# export def_plugins

