module TestData

using PackageMaker: HtmlElem, def_plugins_original, def_plugins, get_pgins_vals!
using PackageMaker: PluginArg, PluginInfo
using DataStructures

fv = Dict{Symbol, HtmlElem}(
    :Use_SrcDir => HtmlElem(:Use_SrcDir, :input, ["TogglePlugin"], :checkbox, :SrcDir_form, "Use_SrcDir", true), 
    :Documenter_make_jl => HtmlElem(:Documenter_make_jl, :input, String[], :text, :Documenter_form, "DEFAULT_FILE", false), 
    :Project_Choice => HtmlElem(:Project_Choice, :input, String[], :radio, :use_purpose_form, "Project", false), 
    :TagBot_changelog => HtmlElem(:TagBot_changelog, :input, String[], :text, :TagBot_form, "nothing", false), 
    :Tests_aqua_kwargs => HtmlElem(:Tests_aqua_kwargs, :textarea, String[], :textarea, :Tests_form, "ambiguities ", nothing), 
    :user_name => HtmlElem(:user_name, :input, String[], :text, :general_options_form, "Eben60", false), 
    :TagBot_branches => HtmlElem(:TagBot_branches, :input, String[], :checkbox, :TagBot_form, "on", false), 
    :Use_Codecov => HtmlElem(:Use_Codecov, :input, ["TogglePlugin"], :checkbox, :Codecov_form, "Use_Codecov", false), 
    :License_name_10 => HtmlElem(:License_name_10, :input, String[], :radio, :License_form, "LGPL-2.1+", false), 
    :License_name_11 => HtmlElem(:License_name_11, :input, String[], :radio, :License_form, "LGPL-3.0+", false), 
    :SrcDir_file => HtmlElem(:SrcDir_file, :input, String[], :text, :SrcDir_form, "DEFAULT_FILE", false), 
    :TagBot_gpg => HtmlElem(:TagBot_gpg, :input, String[], :text, :TagBot_form, "nothing", false), 
    :License_name_7 => HtmlElem(:License_name_7, :input, String[], :radio, :License_form, "GPL-2.0+", false), 
    :Tests_project => HtmlElem(:Tests_project, :input, String[], :checkbox, :Tests_form, "on", false), 
    :GitHubActions_osx => HtmlElem(:GitHubActions_osx, :input, String[], :checkbox, :GitHubActions_form, "on", false), 
    :GitHubActions_extra_versions => HtmlElem(:GitHubActions_extra_versions, :textarea, String[], :textarea, :GitHubActions_form, "", nothing), 
    :Git_email => HtmlElem(:Git_email, :input, String[], :text, :Git_form, "nothing", false), 
    :License_name_8 => HtmlElem(:License_name_8, :input, String[], :radio, :License_form, "GPL-3.0+", false), 
    :docstring => HtmlElem(:docstring, :textarea, String[], :textarea, :general_options_form, "Info for TestConfigSaving package", nothing), 
    :Use_Documenter => HtmlElem(:Use_Documenter, :input, ["TogglePlugin"], :checkbox, :Documenter_form, "Use_Documenter", false), 
    :save_defaults => HtmlElem(:save_defaults, :input, String[], :checkbox, :submit_form, "save_defaults", false), 
    :RegisteredPackage_Choice => HtmlElem(:RegisteredPackage_Choice, :input, String[], :radio, :use_purpose_form, "RegisteredPackage", true), 
    :License_name_9 => HtmlElem(:License_name_9, :input, String[], :radio, :License_form, "ISC", false), 
    :julia_min_version => HtmlElem(:julia_min_version, :input, String[], :text, :general_options_form, "v\"1.11\"", false), 
    :project_dir => HtmlElem(:project_dir, :input, String[], :text, :general_options_form, "/Users/elk/Julia/GUITests/tmp", false), 
    :Git_ignore => HtmlElem(:Git_ignore, :textarea, String[], :textarea, :Git_form, "**/.DS_Store\n/docs/Manifest.toml\n/docs/build/\nManifest-*.toml\nManifest.toml\ndocs/build/\ndocs/site/", nothing), 
    :License_name => HtmlElem(:License_name, :input, ["menu_target"], :text, :License_form, "ASL", false), 
    :GitHubActions_x64 => HtmlElem(:GitHubActions_x64, :input, String[], :checkbox, :GitHubActions_form, "on", true), 
    :GitHubActions_windows => HtmlElem(:GitHubActions_windows, :input, String[], :checkbox, :GitHubActions_form, "on", true), 
    :GitHubActions_destination => HtmlElem(:GitHubActions_destination, :input, String[], :text, :GitHubActions_form, "CI_special.yml", false), 
    :License_name_2 => HtmlElem(:License_name_2, :input, String[], :radio, :License_form, "AGPL-3.0+", false), 
    :authors => HtmlElem(:authors, :input, String[], :text, :general_options_form, "Eben60 <not_a_mail@nowhere.org>", false), 
    :Git_ssh => HtmlElem(:Git_ssh, :input, String[], :checkbox, :Git_form, "on", false), 
    :License_name_3 => HtmlElem(:License_name_3, :input, String[], :radio, :License_form, "ASL", true), 
    :LocalPackage_Choice => HtmlElem(:LocalPackage_Choice, :input, String[], :radio, :use_purpose_form, "LocalPackage", false), 
    :Use_CompatHelper => HtmlElem(:Use_CompatHelper, :input, ["TogglePlugin"], :checkbox, :CompatHelper_form, "Use_CompatHelper", true), 
    :License_name_12 => HtmlElem(:License_name_12, :input, String[], :radio, :License_form, "MPL", false), 
    :Tests_jet => HtmlElem(:Tests_jet, :input, String[], :checkbox, :Tests_form, "on", false), 
    :TagBot_file => HtmlElem(:TagBot_file, :input, String[], :text, :TagBot_form, "DEFAULT_FILE", false), 
    :License_destination => HtmlElem(:License_destination, :input, String[], :text, :License_form, "LICENSE.md", false), 
    :Codecov_file => HtmlElem(:Codecov_file, :input, String[], :text, :Codecov_form, "nothing", false), 
    :Use_Tests => HtmlElem(:Use_Tests, :input, ["TogglePlugin"], :checkbox, :Tests_form, "Use_Tests", true), 
    :Git_jl => HtmlElem(:Git_jl, :input, String[], :checkbox, :Git_form, "on", true), 
    :TagBot_changelog_ignore => HtmlElem(:TagBot_changelog_ignore, :input, String[], :text, :TagBot_form, "nothing", false), 
    :Documenter_deploy => HtmlElem(:Documenter_deploy, :input, String[], :checkbox, :Documenter_form, "on", false), 
    :Tests_aqua => HtmlElem(:Tests_aqua, :input, String[], :checkbox, :Tests_form, "on", true), 
    :proj_name => HtmlElem(:proj_name, :input, String[], :text, :general_options_form, "TestConfigSaving", false), 
    :CompatHelper_file => HtmlElem(:CompatHelper_file, :input, String[], :text, :CompatHelper_form, "DEFAULT_FILE", false), 
    :Readme_inline_badges => HtmlElem(:Readme_inline_badges, :input, String[], :checkbox, :Readme_form, "on", false), 
    :License_name_5 => HtmlElem(:License_name_5, :input, String[], :radio, :License_form, "BSD3", false), 
    :ProjectFile_version => HtmlElem(:ProjectFile_version, :input, String[], :text, :ProjectFile_form, "v\"0.0.1\"", false), 
    :TagBot_ssh => HtmlElem(:TagBot_ssh, :input, String[], :text, :TagBot_form, "nothing", false), 
    :TagBot_dispatch => HtmlElem(:TagBot_dispatch, :input, String[], :checkbox, :TagBot_form, "on", false), 
    :project_packages_input => HtmlElem(:project_packages_input, :textarea, String[], :textarea, :proj_pkg, "TOML", nothing), 
    :TagBot_ssh_password => HtmlElem(:TagBot_ssh_password, :input, String[], :text, :TagBot_form, "nothing", false), 
    :TagBot_destination => HtmlElem(:TagBot_destination, :input, String[], :text, :TagBot_form, "TagBot.yml", false), 
    :License_name_4 => HtmlElem(:License_name_4, :input, String[], :radio, :License_form, "BSD2", false), 
    :Readme_file => HtmlElem(:Readme_file, :input, String[], :text, :Readme_form, "DEFAULT_FILE", false), 
    :Git_manifest => HtmlElem(:Git_manifest, :input, String[], :checkbox, :Git_form, "on", true), 
    :Use_Dependabot => HtmlElem(:Use_Dependabot, :input, ["TogglePlugin"], :checkbox, :Dependabot_form, "Use_Dependabot", true), 
    :License_name_1 => HtmlElem(:License_name_1, :input, String[], :radio, :License_form, "MIT", false), 
    :Use_Git => HtmlElem(:Use_Git, :input, ["TogglePlugin"], :checkbox, :Git_form, "Use_Git", true), 
    :Use_TagBot => HtmlElem(:Use_TagBot, :input, ["TogglePlugin"], :checkbox, :TagBot_form, "Use_TagBot", true), 
    :CompatHelper_destination => HtmlElem(:CompatHelper_destination, :input, String[], :text, :CompatHelper_form, "CompatHelper.yml", false), 
    :Git_gpgsign => HtmlElem(:Git_gpgsign, :input, String[], :checkbox, :Git_form, "on", false), 
    :CompatHelper_cron => HtmlElem(:CompatHelper_cron, :input, String[], :text, :CompatHelper_form, "0 0 * * *", false), 
    :License_name_6 => HtmlElem(:License_name_6, :input, String[], :radio, :License_form, "EUPL-1.2+", false), 
    :Use_License => HtmlElem(:Use_License, :input, ["TogglePlugin"], :checkbox, :License_form, "Use_License", true), 
    :Tests_file => HtmlElem(:Tests_file, :input, String[], :text, :Tests_form, "DEFAULT_FILE", false), 
    :GitHubActions_linux => HtmlElem(:GitHubActions_linux, :input, String[], :checkbox, :GitHubActions_form, "on", false), 
    :GitHubActions_x86 => HtmlElem(:GitHubActions_x86, :input, String[], :checkbox, :GitHubActions_form, "on", true), 
    :Use_ProjectFile => HtmlElem(:Use_ProjectFile, :input, ["TogglePlugin"], :checkbox, :ProjectFile_form, "Use_ProjectFile", true), 
    :Use_Readme => HtmlElem(:Use_Readme, :input, ["TogglePlugin"], :checkbox, :Readme_form, "Use_Readme", true), 
    :Git_name => HtmlElem(:Git_name, :input, String[], :text, :Git_form, "nothing", false), 
    :TagBot_registry => HtmlElem(:TagBot_registry, :input, String[], :text, :TagBot_form, "nothing", false), 
    :TagBot_trigger => HtmlElem(:TagBot_trigger, :input, String[], :text, :TagBot_form, "JuliaTagBot", false), 
    :Dependabot_file => HtmlElem(:Dependabot_file, :input, String[], :text, :Dependabot_form, "DEFAULT_FILE", false), 
    :Use_GitHubActions => HtmlElem(:Use_GitHubActions, :input, ["TogglePlugin"], :checkbox, :GitHubActions_form, "Use_GitHubActions", true), 
    :host => HtmlElem(:host, :input, String[], :text, :general_options_form, "github.com", false), 
    :Readme_destination => HtmlElem(:Readme_destination, :input, String[], :text, :Readme_form, "README.md", false), 
    :GitHubActions_coverage => HtmlElem(:GitHubActions_coverage, :input, String[], :checkbox, :GitHubActions_form, "on", false), 
    :Documenter_index_md => HtmlElem(:Documenter_index_md, :input, String[], :text, :Documenter_form, "DEFAULT_FILE", false), 
    :TagBot_token => HtmlElem(:TagBot_token, :input, String[], :text, :TagBot_form, "nothing", false), 
    :License_path => HtmlElem(:License_path, :input, String[], :text, :License_form, "nothing", false), 
    :Git_branch => HtmlElem(:Git_branch, :input, String[], :text, :Git_form, "master", false), 
    :GitHubActions_file => HtmlElem(:GitHubActions_file, :input, String[], :text, :GitHubActions_form, "DEFAULT_FILE", false), 
    :TagBot_gpg_password => HtmlElem(:TagBot_gpg_password, :input, String[], :text, :TagBot_form, "nothing", false), 
    :TagBot_dispatch_delay => HtmlElem(:TagBot_dispatch_delay, :input, String[], :text, :TagBot_form, "nothing", false),
)

# str_checked_pgins = get_checked_pgins!(fv) |> keys
# get_pgins_vals!(fv)

pgins = get_pgins_vals!(fv; pgins=deepcopy(def_plugins_original))

od(pgin::PluginInfo) = OrderedDict([k => pa.returned_val for (k, pa) in pgin.args])

od(pgins::OrderedDict{String, PluginInfo}) = OrderedDict([k => od(pgin) for (k, pgin) in pgins])

ogpg = od(pgins)


end # module