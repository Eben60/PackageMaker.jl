"Default plugins for a package to be registered"
const pgins_registered = DefaultDict(false, Dict{String, Bool}([
    "CompatHelper" => 1,
    "Dependabot" => 1,
    "Git" => 1,
    "GitHubActions" => 1,
    "License" => 1,
    "ProjectFile" => 1,
    "Readme" => 1,
    "Secret" => 1,
    "SrcDir" => 1,
    "TagBot" => 1,
    "Tests" => 1,
    "Documenter" => 1,
]))

"Default plugins for non-registered package"
const pgins_package = DefaultDict(false, Dict{String, Bool}([
    "CompatHelper" => 0,
    "Dependabot" => 0,
    "Git" => 1,
    "GitHubActions" => 0,
    "License" => 1,
    "ProjectFile" => 1,
    "Readme" => 1,
    "Secret" => 0,
    "SrcDir" => 1,
    "TagBot" => 0,
    "Tests" => 1,
    "Documenter" => 0,
]))

"Default plugins for project"
const pgins_project = DefaultDict(false, Dict{String, Bool}([
    "CompatHelper" => 0,
    "Dependabot" => 0,
    "Git" => 1,
    "GitHubActions" => 0,
    "License" => 0,
    "ProjectFile" => 1,
    "Readme" => 0,
    "Secret" => 0,
    "SrcDir" => 0,
    "TagBot" => 0,
    "Tests" => 0,
    "Documenter" => 0,  
]))

const pgins_sets = Dict(["Project" => pgins_project,
    "LocalPackage" => pgins_package,
    "RegisteredPackage" => pgins_registered,
])

julia_lts = v"1.10"
const julia_lts_str = "$(julia_lts.major).$(julia_lts.minor)"

@kwdef mutable struct ValidateForm
    ProjName::Bool = false
    ProjDir::Bool = false
    SaveConfig::Bool = true
end

function form_valid(v::ValidateForm)
    ns = propertynames(v)
    fs = getfield.(Ref(v), ns)
    return all(fs)
end

val_form::ValidateForm = ValidateForm()
