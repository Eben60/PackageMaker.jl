"""
    Package PackageMaker v$(pkgversion(PackageMaker))

GUI for [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl): "Creating new Julia packages, the easy way" - made a bit simpler. 
This package allows you to create either a new package or a new project.
    
Type [gogui()](@ref) to start the GUI and create a new package or project.

Documentation under https://eben60.github.io/PackageMaker.jl/

$(isnothing(get(ENV, "CI", nothing)) ? ("\n" * "Package local path: " * pathof(PackageMaker)) : "") 
"""
module PackageMaker

using Blink, LibGit2, PkgTemplates, TOML, FilePathsBase, DefaultApplication, Pkg, UUIDs
using Preferences, JSON3
using REPL.TerminalMenus, Dates, ShareAdd, PkgVersion
using DataStructures
using ShareAdd: make_current_mnf
# using StartupCustomizer # "1.0.2"
# using NativeFileDialog
include("FileDialogWorkAround.jl")
using .FileDialogWorkAround
using .FileDialogWorkAround: posixpathstring

may_exit_julia::Bool = false
debug_update_checking::Bool = false
const GUI_RETURNED = Channel(1)
const VAL_RETURNED = Channel(1)

const UPDATE_CHECK_PREF_KEY = "UpdateCheckingPrefs"
const SAVEDCONFIGS_KEY = "SavedConfigurations"

include("defaults.jl")
include("typedefs.jl")
include("git.jl")
include("configurations.jl")

THIS_PROJ = current_package_info()

include("conversions.jl")
include("Plugins-and-default-arguments.jl")

include("css.jl")
include("js_scripts.jl")
include("html_dropdownmenu.jl")
include("html_plugins.jl")
include("html_sections.jl")
include("html.jl")

include("blink_interactions.jl")
include("handleinput.jl")

include("package_checking.jl")

include("processvals.jl")
include("finalize.jl")
include("macro_unsafe.jl")
using .MacroUnsafe
export @unsafe

export gogui
VERSION >= v"1.11.0" && eval(Meta.parse("public updatecheck_settings"))

include("precompile.jl")

function __init__()

    if get(ENV, "CI", nothing) != "true"
        try
            k = UPDATE_CHECK_PREF_KEY
            global debug_update_checking = has_preference(@__MODULE__, k) &&
                get(load_preference(@__MODULE__, k), "debug", false)

            pester_user_about_updates()
        catch e
            @warn "failed to check for $(@__MODULE__) updates"
            debug_update_checking && sprint(showerror, e, catch_backtrace()) |> println
        end
    end
    return nothing
end

end # module PackageMaker
