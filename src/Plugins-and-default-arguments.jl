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
        (:VersionNumber, "version",  false, "v\"1.0.0-DEV\"", "The initial version of created packages"),
        ]),
    ("SrcDir", "Creates a module entrypoint", [
        ("file",  false, "$(templ_dir)/src/module.jl", "Template file for src/$(packagename).jl"),
        ]),
    ("Tests", "Sets up testing for packages", [
        ("file",  false, "$(templ_dir)/test/runtests.jl", "Template file for runtests.jl"),
        ("project",  false, false, "Whether or not to create a new project for tests (test/Project.toml)."),
        ]),
    ("Readme", "Creates a README file that contains badges for other included plugins", [
        ("file",  false, "$(templ_dir)/README.md", "Template file for the README."), 
        ("destination",  false, "README.md", "File destination, relative to the repository root."), 
        ("inline_badges",  false, false, "Whether or not to put the badges on the same line as the package name."),
        ]),
    ("License", "Creates a license file", [
        ("name",  false, "MIT", "Name of a license supported by PkgTemplates. Dropdown menu to be added here!"), 
        ("path",  false, "nothing", "Path to a custom license file. This keyword takes priority over name."), 
        ("destination",  false, "LICENSE", "File destination, relative to the repository root. For example, \"LICENSE.md\" might be desired."),
        ]),
    ("Git", "Creates a Git repository and a .gitignore file", [
        (Vector{String}, "ignore",  true, String[], "Patterns to add to the .gitignore"), 
        ("name",  false, "nothing", "Your real name, if you have not set user.name with Git."), 
        ("email",  false, "nothing", "Your email address, if you have not set user.email with Git."), 
        ("branch",  false, "$(default_branch)", "The desired name of the repository's default branch."), 
        ("ssh",  false, false, "Whether or not to use SSH for the remote. If left unset, HTTPS is used."), 
        ("jl",  false, true, "Whether or not to add a .jl suffix to the remote URL."), 
        ("manifest",  false, false, "Whether or not to commit Manifest.toml."), 
        ("gpgsign",  false, false, "Whether or not to sign commits with your GPG key. This option requires that the Git CLI is installed, and for you to have a GPG key associated with your committer identity."),
        ]),
    ("GitHubActions", "Creates a Git repository and a .gitignore file", [
        ("file",  false, "$(templ_dir)/github/workflows/CI.yml", "Template file for the workflow file"), 
        ("destination",  false, "CI.yml", "Destination of the workflow file, relative to .github/workflows"), 
        ("linux",  false, true, "Whether or not to run builds on Linux."), 
        ("osx",  false, false, "Whether or not to run builds on OSX (MacOS)."), 
        ("windows",  false, false, "Whether or not to run builds on Windows."), 
        ("x64",  false, true, "Whether or not to run builds on 64-bit architecture."), 
        ("x86",  false, false, "Whether or not to run builds on 32-bit architecture."), 
        ("coverage",  false, false, "Whether or not to publish code coverage. Another code coverage plugin such as Codecov must also be included.If using coverage plugins, don't forget to manually add your API tokens as secrets, as described in PkgTemplate manual."), 
        (Vector{String}, "extra_versions",  true, ["1.6", "1.10", "pre"], "Extra Julia versions to test, as strings."), 
        ]),
    ("CompatHelper", "Integrates your packages with CompatHelper via GitHub Actions", [
        ("file",  false, "$(templ_dir)/github/workflows/CompatHelper.yml", "Template file for the workflow file"), 
        ("destination",  false, "CompatHelper.yml", "Destination of the workflow file, relative to .github/workflows"), 
        ("cron",  false, "0 0 * * *", "Cron expression for the schedule interval"), 
        ]),
    ("TagBot", "Adds GitHub release support via TagBot", [
        ("file",  false, "$(templ_dir)/github/workflows/TagBot.yml", "Template file for the workflow file."), 
        ("destination",  false, "TagBot.yml", "Destination of the workflow file, relative to .github/workflows"), 
        ("trigger",  false, "JuliaTagBot", "Username of the trigger user for custom registries"), 
        ("token",  false, "nothing", "Name of the token secret to use"), 
        ("ssh",  false, "nothing", "Name of the SSH private key secret to use"), 
        ("ssh_password",  false, "nothing", "Name of the SSH key password secret to use"), 
        ("changelog",  false, "nothing", "Custom changelog template"), 
        ("changelog_ignore",  false, "nothing", "Issue/pull request labels to ignore in the changelog"), 
        ("gpg",  false, "nothing", "Name of the GPG private key secret to use"), 
        ("gpg_password",  false, "nothing", "Name of the GPG private key password secret to use"), 
        ("registry",  false, "nothing", "Custom registry, in the format owner/repo"), 
        ("branches",  false, false, "Whether not to enable the branches option"), 
        ("dispatch",  false, false, "Whether or not to enable the dispatch option"), 
        (Int64, "dispatch_delay",  false, "nothing", "Number of minutes to delay for dispatch events"), 
        ]),
    ("Secret", "Represents a GitHub repository secret. When converted to a string, yields \${{ secrets.<name> }}", [
        ("name",  false, "", "Secrets name."), 
        ]),
    ("Dependabot", "Setups Dependabot to create PRs whenever GitHub actions can be updated. This is very similar to CompatHelper, which performs the same task for Julia package dependencies", [
        ("file",  false, "$(templ_dir)/github/dependabot.yml", "Template file."), 
        ]),
    ]);


def_plugins :: OrderedDict{String, PluginInfo} = OrderedDict(v.name => v for v in dfp)

# export def_plugins
