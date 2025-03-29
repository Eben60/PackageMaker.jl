module TestData_TestPackage01

using PackageMaker
using PackageMaker: HtmlElem


fv = Dict{Symbol, HtmlElem}(
    :Codecov_file => HtmlElem(:Codecov_file, :input, String[], :text, :Codecov_form, "nothing", false),
    :CompatHelper_cron => HtmlElem(:CompatHelper_cron, :input, String[], :text, :CompatHelper_form, "0 0 * * *", false),
    :CompatHelper_destination => HtmlElem(:CompatHelper_destination, :input, String[], :text, :CompatHelper_form, "CompatHelper.yml", false),
    :CompatHelper_file => HtmlElem(:CompatHelper_file, :input, String[], :text, :CompatHelper_form, "<DEFAULT_FILE>", false),
    :Dependabot_file => HtmlElem(:Dependabot_file, :input, String[], :text, :Dependabot_form, "<DEFAULT_FILE>", false),
    :Documenter_deploy => HtmlElem(:Documenter_deploy, :input, String[], :checkbox, :Documenter_form, "on", true),
    :Documenter_index_md => HtmlElem(:Documenter_index_md, :input, String[], :text, :Documenter_form, "<DEFAULT_FILE>", false),
    :Documenter_make_jl => HtmlElem(:Documenter_make_jl, :input, String[], :text, :Documenter_form, "<DEFAULT_FILE>", false),
    :GeneralOptions_add_imports => HtmlElem(:GeneralOptions_add_imports, :input, String[], :checkbox, :GeneralOptions_form, "on", true),
    :GeneralOptions_authors => HtmlElem(:GeneralOptions_authors, :input, String[], :text, :GeneralOptions_form, "Eben60 <not_a_mail@nowhere.org>", false),
    :GeneralOptions_docstring => HtmlElem(:GeneralOptions_docstring, :textarea, String[], :textarea, :GeneralOptions_form, "This is a TestPackage01 for PackageMaker testing.", nothing),
    :GeneralOptions_host => HtmlElem(:GeneralOptions_host, :input, String[], :text, :GeneralOptions_form, "github.com", false),
    :GeneralOptions_is_package => HtmlElem(:GeneralOptions_is_package, :input, String[], :checkbox, :GeneralOptions_form, "on", true),
    :GeneralOptions_julia_min_version => HtmlElem(:GeneralOptions_julia_min_version, :input, String[], :text, :GeneralOptions_form, "1.10.9", false),
    :GeneralOptions_proj_name => HtmlElem(:GeneralOptions_proj_name, :input, String[], :text, :GeneralOptions_form, "TestPackage01", false),
    :GeneralOptions_proj_pkg => HtmlElem(:GeneralOptions_proj_pkg, :textarea, String[], :textarea, :GeneralOptions_form, "TOML.jl\nUnicode", nothing),
    :GeneralOptions_project_dir => HtmlElem(:GeneralOptions_project_dir, :input, String[], :text, :GeneralOptions_form, "/Users/Shared", false),
    :GeneralOptions_user_name => HtmlElem(:GeneralOptions_user_name, :input, String[], :text, :GeneralOptions_form, "Eben60", false),
    :GitHubActions_coverage => HtmlElem(:GitHubActions_coverage, :input, String[], :checkbox, :GitHubActions_form, "on", false),
    :GitHubActions_destination => HtmlElem(:GitHubActions_destination, :input, String[], :text, :GitHubActions_form, "CI_new.yml", false),
    :GitHubActions_extra_versions => HtmlElem(:GitHubActions_extra_versions, :textarea, String[], :textarea, :GitHubActions_form, "1.10", nothing),
    :GitHubActions_file => HtmlElem(:GitHubActions_file, :input, String[], :text, :GitHubActions_form, "<DEFAULT_FILE>", false),
    :GitHubActions_linux => HtmlElem(:GitHubActions_linux, :input, String[], :checkbox, :GitHubActions_form, "on", true),
    :GitHubActions_osx => HtmlElem(:GitHubActions_osx, :input, String[], :checkbox, :GitHubActions_form, "on", false),
    :GitHubActions_windows => HtmlElem(:GitHubActions_windows, :input, String[], :checkbox, :GitHubActions_form, "on", true),
    :GitHubActions_x64 => HtmlElem(:GitHubActions_x64, :input, String[], :checkbox, :GitHubActions_form, "on", true),
    :GitHubActions_x86 => HtmlElem(:GitHubActions_x86, :input, String[], :checkbox, :GitHubActions_form, "on", false),
    :Git_branch => HtmlElem(:Git_branch, :input, String[], :text, :Git_form, "master", false),
    :Git_email => HtmlElem(:Git_email, :input, String[], :text, :Git_form, "Eben60a@mailto.org", false),
    :Git_gpgsign => HtmlElem(:Git_gpgsign, :input, String[], :checkbox, :Git_form, "on", false),
    :Git_ignore => HtmlElem(:Git_ignore, :textarea, String[], :textarea, :Git_form, "/LocalPreferences.toml\n**/.DS_Store", nothing),
    :Git_jl => HtmlElem(:Git_jl, :input, String[], :checkbox, :Git_form, "on", true),
    :Git_manifest => HtmlElem(:Git_manifest, :input, String[], :checkbox, :Git_form, "on", false),
    :Git_name => HtmlElem(:Git_name, :input, String[], :text, :Git_form, "Eben60a", false),
    :Git_ssh => HtmlElem(:Git_ssh, :input, String[], :checkbox, :Git_form, "on", false),
    :License_destination => HtmlElem(:License_destination, :input, String[], :text, :License_form, "LICENSE.txt", false),
    :License_name => HtmlElem(:License_name, :input, ["menu_target"], :text, :License_form, "ASL", false),
    :License_name_1 => HtmlElem(:License_name_1, :input, String[], :radio, :License_form, "MIT", false),
    :License_name_10 => HtmlElem(:License_name_10, :input, String[], :radio, :License_form, "LGPL-2.1+", false),
    :License_name_11 => HtmlElem(:License_name_11, :input, String[], :radio, :License_form, "LGPL-3.0+", false),
    :License_name_12 => HtmlElem(:License_name_12, :input, String[], :radio, :License_form, "MPL", false),
    :License_name_2 => HtmlElem(:License_name_2, :input, String[], :radio, :License_form, "AGPL-3.0+", false),
    :License_name_3 => HtmlElem(:License_name_3, :input, String[], :radio, :License_form, "ASL", false),
    :License_name_4 => HtmlElem(:License_name_4, :input, String[], :radio, :License_form, "BSD2", false),
    :License_name_5 => HtmlElem(:License_name_5, :input, String[], :radio, :License_form, "BSD3", false),
    :License_name_6 => HtmlElem(:License_name_6, :input, String[], :radio, :License_form, "EUPL-1.2+", false),
    :License_name_7 => HtmlElem(:License_name_7, :input, String[], :radio, :License_form, "GPL-2.0+", false),
    :License_name_8 => HtmlElem(:License_name_8, :input, String[], :radio, :License_form, "GPL-3.0+", false),
    :License_name_9 => HtmlElem(:License_name_9, :input, String[], :radio, :License_form, "ISC", false),
    :License_path => HtmlElem(:License_path, :input, String[], :text, :License_form, "nothing", false),
    :LocalPackage_Choice => HtmlElem(:LocalPackage_Choice, :input, String[], :radio, :use_purpose_form, "LocalPackage", false),
    :ProjectFile_version => HtmlElem(:ProjectFile_version, :input, String[], :text, :ProjectFile_form, "1.2.3", false),
    :Project_Choice => HtmlElem(:Project_Choice, :input, String[], :radio, :use_purpose_form, "Project", false),
    :Readme_destination => HtmlElem(:Readme_destination, :input, String[], :text, :Readme_form, "READMEplease.md", false),
    :Readme_file => HtmlElem(:Readme_file, :input, String[], :text, :Readme_form, "/Users/Shared/tmp/template01.md", false),
    :Readme_inline_badges => HtmlElem(:Readme_inline_badges, :input, String[], :checkbox, :Readme_form, "on", true),
    :RegisteredPackage_Choice => HtmlElem(:RegisteredPackage_Choice, :input, String[], :radio, :use_purpose_form, "RegisteredPackage", false),
    :Save_Configuration_config_name => HtmlElem(:Save_Configuration_config_name, :input, ["menu_target"], :text, :Save_Configuration_form, "TestPackage01", false),
    :Save_Configuration_config_name_1 => HtmlElem(:Save_Configuration_config_name_1, :input, String[], :radio, :Save_Configuration_form, "! Dep / ! Doc v#0.1.0", false),
    :Save_Configuration_config_name_10 => HtmlElem(:Save_Configuration_config_name_10, :input, String[], :radio, :Save_Configuration_form, "1.10.9d", false),
    :Save_Configuration_config_name_11 => HtmlElem(:Save_Configuration_config_name_11, :input, String[], :radio, :Save_Configuration_form, "1.11.4", false),
    :Save_Configuration_config_name_12 => HtmlElem(:Save_Configuration_config_name_12, :input, String[], :radio, :Save_Configuration_form, "is a project", false),
    :Save_Configuration_config_name_13 => HtmlElem(:Save_Configuration_config_name_13, :input, String[], :radio, :Save_Configuration_form, "is pkg ProjFile only", false),
    :Save_Configuration_config_name_2 => HtmlElem(:Save_Configuration_config_name_2, :input, String[], :radio, :Save_Configuration_form, "1.10.3", false),
    :Save_Configuration_config_name_3 => HtmlElem(:Save_Configuration_config_name_3, :input, String[], :radio, :Save_Configuration_form, "1.10.4", false),
    :Save_Configuration_config_name_4 => HtmlElem(:Save_Configuration_config_name_4, :input, String[], :radio, :Save_Configuration_form, "1.10.5", false),
    :Save_Configuration_config_name_5 => HtmlElem(:Save_Configuration_config_name_5, :input, String[], :radio, :Save_Configuration_form, "1.10.8", false),
    :Save_Configuration_config_name_6 => HtmlElem(:Save_Configuration_config_name_6, :input, String[], :radio, :Save_Configuration_form, "1.10.9", false),
    :Save_Configuration_config_name_7 => HtmlElem(:Save_Configuration_config_name_7, :input, String[], :radio, :Save_Configuration_form, "1.10.9a", false),
    :Save_Configuration_config_name_8 => HtmlElem(:Save_Configuration_config_name_8, :input, String[], :radio, :Save_Configuration_form, "1.10.9b", false),
    :Save_Configuration_config_name_9 => HtmlElem(:Save_Configuration_config_name_9, :input, String[], :radio, :Save_Configuration_form, "1.10.9c", false),
    :SavedConfigTag_1 => HtmlElem(:SavedConfigTag_1, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_1", false),
    :SavedConfigTag_10 => HtmlElem(:SavedConfigTag_10, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_10", true),
    :SavedConfigTag_11 => HtmlElem(:SavedConfigTag_11, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_11", false),
    :SavedConfigTag_12 => HtmlElem(:SavedConfigTag_12, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_12", false),
    :SavedConfigTag_13 => HtmlElem(:SavedConfigTag_13, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_13", false),
    :SavedConfigTag_2 => HtmlElem(:SavedConfigTag_2, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_2", false),
    :SavedConfigTag_3 => HtmlElem(:SavedConfigTag_3, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_3", false),
    :SavedConfigTag_4 => HtmlElem(:SavedConfigTag_4, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_4", false),
    :SavedConfigTag_5 => HtmlElem(:SavedConfigTag_5, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_5", false),
    :SavedConfigTag_6 => HtmlElem(:SavedConfigTag_6, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_6", false),
    :SavedConfigTag_7 => HtmlElem(:SavedConfigTag_7, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_7", false),
    :SavedConfigTag_8 => HtmlElem(:SavedConfigTag_8, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_8", false),
    :SavedConfigTag_9 => HtmlElem(:SavedConfigTag_9, :input, String[], :radio, :use_purpose_form, "SavedConfigTag_9", false),
    :SrcDir_file => HtmlElem(:SrcDir_file, :input, String[], :text, :SrcDir_form, "/Users/Shared/tmp/template01.jl", false),
    :TagBot_branches => HtmlElem(:TagBot_branches, :input, String[], :checkbox, :TagBot_form, "on", false),
    :TagBot_changelog => HtmlElem(:TagBot_changelog, :input, String[], :text, :TagBot_form, "nothing", false),
    :TagBot_changelog_ignore => HtmlElem(:TagBot_changelog_ignore, :input, String[], :text, :TagBot_form, "nothing", false),
    :TagBot_destination => HtmlElem(:TagBot_destination, :input, String[], :text, :TagBot_form, "TagBot.yml", false),
    :TagBot_dispatch => HtmlElem(:TagBot_dispatch, :input, String[], :checkbox, :TagBot_form, "on", false),
    :TagBot_dispatch_delay => HtmlElem(:TagBot_dispatch_delay, :input, String[], :text, :TagBot_form, "nothing", false),
    :TagBot_file => HtmlElem(:TagBot_file, :input, String[], :text, :TagBot_form, "<DEFAULT_FILE>", false),
    :TagBot_gpg => HtmlElem(:TagBot_gpg, :input, String[], :text, :TagBot_form, "nothing", false),
    :TagBot_gpg_password => HtmlElem(:TagBot_gpg_password, :input, String[], :text, :TagBot_form, "nothing", false),
    :TagBot_registry => HtmlElem(:TagBot_registry, :input, String[], :text, :TagBot_form, "nothing", false),
    :TagBot_ssh => HtmlElem(:TagBot_ssh, :input, String[], :text, :TagBot_form, "nothing", false),
    :TagBot_ssh_password => HtmlElem(:TagBot_ssh_password, :input, String[], :text, :TagBot_form, "nothing", false),
    :TagBot_token => HtmlElem(:TagBot_token, :input, String[], :text, :TagBot_form, "nothing", false),
    :TagBot_trigger => HtmlElem(:TagBot_trigger, :input, String[], :text, :TagBot_form, "JuliaTagBot", false),
    :Tests_aqua => HtmlElem(:Tests_aqua, :input, String[], :checkbox, :Tests_form, "on", true),
    :Tests_aqua_kwargs => HtmlElem(:Tests_aqua_kwargs, :textarea, String[], :textarea, :Tests_form, "ambiguities", nothing),
    :Tests_file => HtmlElem(:Tests_file, :input, String[], :text, :Tests_form, "<DEFAULT_FILE>", false),
    :Tests_jet => HtmlElem(:Tests_jet, :input, String[], :checkbox, :Tests_form, "on", false),
    :Tests_project => HtmlElem(:Tests_project, :input, String[], :checkbox, :Tests_form, "on", true),
    :Use_Codecov => HtmlElem(:Use_Codecov, :input, ["TogglePlugin"], :checkbox, :Codecov_form, "Use_Codecov", false),
    :Use_CompatHelper => HtmlElem(:Use_CompatHelper, :input, ["TogglePlugin"], :checkbox, :CompatHelper_form, "Use_CompatHelper", false),
    :Use_Dependabot => HtmlElem(:Use_Dependabot, :input, ["TogglePlugin"], :checkbox, :Dependabot_form, "Use_Dependabot", false),
    :Use_Documenter => HtmlElem(:Use_Documenter, :input, ["TogglePlugin"], :checkbox, :Documenter_form, "Use_Documenter", true),
    :Use_GeneralOptions => HtmlElem(:Use_GeneralOptions, :input, ["TogglePlugin"], :checkbox, :GeneralOptions_form, "Use_GeneralOptions", true),
    :Use_Git => HtmlElem(:Use_Git, :input, ["TogglePlugin"], :checkbox, :Git_form, "Use_Git", true),
    :Use_GitHubActions => HtmlElem(:Use_GitHubActions, :input, ["TogglePlugin"], :checkbox, :GitHubActions_form, "Use_GitHubActions", true),
    :Use_License => HtmlElem(:Use_License, :input, ["TogglePlugin"], :checkbox, :License_form, "Use_License", true),
    :Use_ProjectFile => HtmlElem(:Use_ProjectFile, :input, ["TogglePlugin"], :checkbox, :ProjectFile_form, "Use_ProjectFile", true),
    :Use_Readme => HtmlElem(:Use_Readme, :input, ["TogglePlugin"], :checkbox, :Readme_form, "Use_Readme", true),
    :Use_Save_Configuration => HtmlElem(:Use_Save_Configuration, :input, ["TogglePlugin"], :checkbox, :Save_Configuration_form, "Use_Save_Configuration", false),
    :Use_SrcDir => HtmlElem(:Use_SrcDir, :input, ["TogglePlugin"], :checkbox, :SrcDir_form, "Use_SrcDir", true),
    :Use_TagBot => HtmlElem(:Use_TagBot, :input, ["TogglePlugin"], :checkbox, :TagBot_form, "Use_TagBot", false),
    :Use_Tests => HtmlElem(:Use_Tests, :input, ["TogglePlugin"], :checkbox, :Tests_form, "Use_Tests", true),
    )

end # module

fv = TestData_TestPackage01.fv
