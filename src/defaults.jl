using DataStructures

pgins_registered = DefaultDict(false, Dict{String, Bool}([
    "CompatHelper" => 1,
    "Git"          => 1,
    "License"      => 1,
    "ProjectFile"  => 1,
    "Readme"       => 1,
    "SrcDir"       => 1, 
    "TagBot"       => 1,
    "Tests"        => 1,    
]))

pgins_package = DefaultDict(false, Dict{String, Bool}([
    "CompatHelper" => 0,
    "Git"          => 1,
    "License"      => 1,
    "ProjectFile"  => 1,
    "Readme"       => 1,
    "SrcDir"       => 1, 
    "TagBot"       => 0,
    "Tests"        => 1,    
]))

pgins_project = DefaultDict(false, Dict{String, Bool}([
    "CompatHelper" => 0,
    "Git"          => 1,
    "License"      => 0,
    "ProjectFile"  => 1,
    "Readme"       => 1,
    "SrcDir"       => 1, 
    "TagBot"       => 0,
    "Tests"        => 1,    
]))
