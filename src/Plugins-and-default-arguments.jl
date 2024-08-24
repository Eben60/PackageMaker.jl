packagename :: String = "MyPackage"

function get_module_directory(module_name)
    for (pkg, mod) in Base.loaded_modules
        if pkg.name == String(module_name)
            return  pathof(mod) |> dirname |> dirname
        end
    end
    return nothing
end
export get_module_directory

const templ_dir = joinpath(get_module_directory("PkgTemplates"), "templates")
const default_branch = LibGit2.getconfig("init.defaultBranch", "main")

dfp = PluginInfo.([
    ("ProjectFile", "Creates a Project.toml", [
        (:VersionNumber, "version", "v\"1.0.0-DEV\"", "The initial version of created packages"),
        ]),
    ("SrcDir", "Creates a module entrypoint", [
        (:file, "file", "$(templ_dir)/src/module.jl", "Template file for src/$(packagename).jl"),
        ]),
    ("Tests", "Sets up testing for packages", [
        (:file, "file", "$(templ_dir)/test/runtests.jl", "Template file for runtests.jl"),
        ("project", false, "Whether or not to create a new project for tests (test/Project.toml)."),
        ("aqua", false, "Controls whether or not to add quality tests with Aqua.jl."),
        (:ExcludedPlugins, "aqua_kwargs",  ["ambiguities"], "List of Aqua tests to skip. For full power of Aqua testing, edit your runtests.jl file manually."), 
        ("jet", false, "Controls whether or not to add a linting test with JET.jl (works best on type-stable code)."),
        ]),
    ("Readme", "Creates a README file that contains badges for other included plugins", [
        (:file, "file", "$(templ_dir)/README.md", "Template file for the README."), 
        ("destination", "README.md", "File destination, relative to the repository root."), 
        ("inline_badges", false, "Whether or not to put the badges on the same line as the package name."),
        ]),
    ("License", "Creates a license file", [
        ("name", "MIT", "Name of a license supported by PkgTemplates. Dropdown menu to be added here!"), 
        (:file, "path", "nothing", "Path to a custom license file. This keyword takes priority over name."), 
        ("destination", "LICENSE", "File destination, relative to the repository root. For example, \"LICENSE.md\" might be desired."),
        ]),
    ("Git", "Creates a Git repository and a .gitignore file", [
        (Vector{String}, "ignore",  String[], "Patterns to add to the .gitignore"), 
        ("name", "nothing", "Your real name, if you have not set user.name with Git."), 
        ("email", "nothing", "Your email address, if you have not set user.email with Git."), 
        ("branch", "$(default_branch)", "The desired name of the repository's default branch."), 
        ("ssh", false, "Whether or not to use SSH for the remote. If left unset, HTTPS is used."), 
        ("jl", true, "Whether or not to add a .jl suffix to the remote URL."), 
        ("manifest", false, "Whether or not to commit Manifest.toml."), 
        ("gpgsign", false, "Whether or not to sign commits with your GPG key. This option requires that the Git CLI is installed, and for you to have a GPG key associated with your committer identity."),
        ]),
    ("GitHubActions", "Creates a Git repository and a .gitignore file", [
        (:file, "file", "$(templ_dir)/github/workflows/CI.yml", "Template file for the workflow file"), 
        ("destination", "CI.yml", "Destination of the workflow file, relative to .github/workflows"), 
        ("linux", true, "Whether or not to run builds on Linux."), 
        ("osx", false, "Whether or not to run builds on OSX (MacOS)."), 
        ("windows", false, "Whether or not to run builds on Windows."), 
        ("x64", true, "Whether or not to run builds on 64-bit architecture."), 
        ("x86", false, "Whether or not to run builds on 32-bit architecture."), 
        ("coverage", false, "Whether or not to publish code coverage. Another code coverage plugin such as Codecov must also be included.If using coverage plugins, don't forget to manually add your API tokens as secrets, as described in PkgTemplate manual."), 
        (Vector{String}, "extra_versions",  ["1.6", "1.10", "pre"], "Extra Julia versions to test, as strings."), 
        ]),
    ("CompatHelper", "Integrates your packages with CompatHelper via GitHub Actions", [
        (:file, "file", "$(templ_dir)/github/workflows/CompatHelper.yml", "Template file for the workflow file"), 
        ("destination", "CompatHelper.yml", "Destination of the workflow file, relative to .github/workflows"), 
        ("cron", "0 0 * * *", "Cron expression for the schedule interval"), 
        ]),
    ("TagBot", "Adds GitHub release support via TagBot", [
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
        ("branches", false, "Whether not to enable the branches option"), 
        ("dispatch", false, "Whether or not to enable the dispatch option"), 
        (Int64, "dispatch_delay", "nothing", "Number of minutes to delay for dispatch events"), 
        ]),
    ("Dependabot", "Setups Dependabot to create PRs whenever GitHub actions can be updated. This is very similar to CompatHelper, which performs the same task for Julia package dependencies", [
        (:file, "file", "$(templ_dir)/github/dependabot.yml", "Template file."), 
        ]),
    ]);


def_plugins :: OrderedDict{String, PluginInfo} = OrderedDict(v.name => v for v in dfp)

pkgtmpl_def_plugins =  PkgTemplates.default_plugins() .|> type2str
this_def_plugins = keys(def_plugins)

sd1 = setdiff(this_def_plugins, pkgtmpl_def_plugins)
sd2 = setdiff(pkgtmpl_def_plugins, this_def_plugins)

isempty(sd1) || @warn "This package lists plugins $sd1, which are not among the default templates of PkgTemplates"
isempty(sd2) || @warn "This package does not list plugins $sd2, which are among the default templates of PkgTemplates"


# export def_plugins
def_plugins