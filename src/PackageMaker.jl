"""
    Package PackageMaker v$(pkgversion(PackageMaker))

GUI for [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl): "Creating new Julia packages, the easy way" - made a bit simpler. 
This package allows you to create either a new package or a new project.
    
Type [gogui()](@ref) to start the GUI and create a new package or project.

Package site under https://github.com/Eben60/PackageMaker.jl

$(isnothing(get(ENV, "CI", nothing)) ? ("\n" * "Package local path: " * pathof(PackageMaker)) : "") 
"""
module PackageMaker

using Blink, LibGit2, PkgTemplates, TOML, FilePathsBase, Desktop, Pkg
using Preferences, JSON3
using REPL.TerminalMenus, Dates, ShareAdd, PkgVersion
using DataStructures
# using StartupCustomizer # "1.0.2"
# using NativeFileDialog
include("FileDialogWorkAround.jl")
using .FileDialogWorkAround
using .FileDialogWorkAround: posixpathstring

processing_finished::Bool = false
may_exit_julia::Bool = false
debug_update_checking::Bool = false

const UPDATE_CHECK_PREF_KEY = "UpdateCheckingPrefs"
const SAVEDCONFIGS_KEY = "SavedConfigurations"

include("defaults.jl")
include("typedefs.jl")
include("configurations.jl")
include("git.jl")
include("conversions.jl")
include("processvals.jl")
include("make_docstrings.jl")
include("package_checking.jl")

include("css.jl")
include("js_scripts.jl")
include("html_dropdownmenu.jl")
include("html_plugins.jl")
include("html_sections.jl")
include("html.jl")

include("blink_interactions.jl")
include("handleinput.jl")

include("Plugins-and-default-arguments.jl")
include("macro_unsafe.jl")
using .MacroUnsafe
export @unsafe

export gogui
VERSION >= v"1.11.0-DEV.469" && eval(Meta.parse("public updatecheck_settings"))

function __init__()
    if get(ENV, "CI", nothing) != "true"
        try
            key = UPDATE_CHECK_PREF_KEY
            global debug_update_checking = @has_preference(key) &&
                get(@load_preference(key), "debug", false)

            pester_user_about_updates()
        catch e
            @warn "failed to check for $(@__MODULE__) updates"
            debug_update_checking && rethrow(e)
        end
    end
end

end # module PackageMaker

# TODO refactor: move caller functions to the top, and callees to the bottom