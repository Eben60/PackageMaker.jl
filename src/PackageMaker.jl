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
using DataStructures
# using StartupCustomizer # "1.0.2"
# using NativeFileDialog
include("FileDialogWorkAround.jl")
using .FileDialogWorkAround
using .FileDialogWorkAround: posixpathstring

processing_finished::Bool = false
may_exit_julia::Bool = false

include("git.jl")
include("defaults.jl")
include("typedefs.jl")
include("processvals.jl")
include("make_docstrings.jl")
include("Plugins-and-default-arguments.jl")
# include("packages.jl")

include("css.jl")
include("js_scripts.jl")
include("html_dropdownmenu.jl")
include("html_plugins.jl")
include("html_sections.jl")
include("html.jl")

include("blink_interactions.jl")
include("handleinput.jl")

include("configurations.jl")

include("macro_unsafe.jl")
using .MacroUnsafe
export @unsafe

include("jld2_to_extend.jl")

export gogui

end # module PackageMaker

# TODO refactor: move caller functions to the top, and callees to the bottom