using DataStructures

"Default plugins for a package to be registered"
pgins_registered = DefaultDict(false, Dict{String, Bool}([
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
]))

"Default plugins for non-registered package"
pgins_package = DefaultDict(false, Dict{String, Bool}([
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
]))

"Default plugins for project"
pgins_project = DefaultDict(false, Dict{String, Bool}([
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
    "Tests" => 1,    
]))

pgins_sets = Dict(["Project" => pgins_project,
    "LocalPackage" => pgins_package,
    "RegisteredPackage" => pgins_registered,
])