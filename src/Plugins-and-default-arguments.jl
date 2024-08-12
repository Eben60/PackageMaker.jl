packagename :: String = "MyPackage"

dfp = PluginInfo.([
    ("ProjectFile", "Creates a Project.toml", [("version",  false, "v\"1.0.0-DEV\"", "The initial version of created packages")]),
    ("SrcDir", "Creates a module entrypoint", [("file",  false, "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/src/module.jl", "Template file for src/$(packagename).jl")]),
    ("Tests", "Sets up testing for packages", [("file",  false, "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/test/runtests.jl", "Template file for runtests.jl")
                ("project",  false, false, "Whether or not to create a new project for tests (test/Project.toml).")]),
    ("Readme", "Creates a README file that contains badges for other included plugins.", [("file",  false, "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/README.md", ""), 
                ("destination",  false, "README.md", ""), 
                ("inline_badges",  false, false, "Whether or not to put the badges on the same line as the package name.")]),
    ("License", "Creates a license file", [("name",  false, "MIT", "Name of a license supported by PkgTemplates. Dropdown menu to be added here!"), 
                ("path",  false, nothing, "Path to a custom license file. This keyword takes priority over name."), 
                ("destination",  false, "LICENSE", "File destination, relative to the repository root. For example, \"LICENSE.md\" might be desired.")]),
    ("Git", "Creates a Git repository and a .gitignore file", [("ignore",  true, String[], "Patterns to add to the .gitignore"), 
                ("name",  false, "nothing", "Your real name, if you have not set user.name with Git."), 
                ("email",  false, "nothing", "Your email address, if you have not set user.email with Git."), 
                ("branch",  false, "main", "The desired name of the repository's default branch."), 
                ("ssh",  false, false, "Whether or not to use SSH for the remote. If left unset, HTTPS is used."), 
                ("jl",  false, true, "Whether or not to add a .jl suffix to the remote URL."), 
                ("manifest",  false, false, "Whether or not to commit Manifest.toml."), 
                ("gpgsign",  false, false, "Whether or not to sign commits with your GPG key. This option requires that the Git CLI is installed, and for you to have a GPG key associated with your committer identity.")]),
    ("CompatHelper", "Integrates your packages with CompatHelper via GitHub Actions", [("file",  false, "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/github/workflows/CompatHelper.yml", "Template file for the workflow file"), 
                ("destination",  false, "CompatHelper.yml", "Destination of the workflow file, relative to .github/workflows"), 
                ("cron",  false, "0 0 * * *", "Cron expression for the schedule interval"), ]),
    ("TagBot", "Adds GitHub release support via TagBot", [("file",  false, "~/work/PkgTemplates.jl/PkgTemplates.jl/templates/github/workflows/TagBot.yml", "Template file for the workflow file."), 
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
                ("branches",  false, "nothing", "Whether not to enable the branches option"), 
                ("dispatch",  false, "nothing", "Whether or not to enable the dispatch option"), 
                ("dispatch_delay",  false, "nothing", "Number of minutes to delay for dispatch events"), ]),
                ]);

def_plugins :: OrderedDict{String, PluginInfo} = OrderedDict(v.name => v for v in dfp)

# export def_plugins
