module StartYourPk

using Blink, LibGit2, OrderedCollections, PkgTemplates, TOML, FilePathsBase
using DataStructures
using JLD2
# using StartupCustomizer # "1.0.2"
# using NativeFileDialog
include("FileDialogWorkAround.jl")
using .FileDialogWorkAround
using .FileDialogWorkAround: posixpathstring

processing_finished::Bool = false

include("git.jl")
include("defaults.jl")
include("typedefs.jl")
include("processvals.jl")
include("Plugins-and-default-arguments.jl")
include("packages.jl")

include("css.jl")
include("js_scripts.jl")
include("html_plugins.jl")
include("html_sections.jl")
include("html.jl")

include("blink_interactions.jl")
include("handleinput.jl")



end # module StartYourPk
