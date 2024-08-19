module PackageInABlink

using Blink, LibGit2, OrderedCollections, PkgTemplates
using JLD2

include("git.jl")
include("defaults.jl")
include("packages.jl")
include("html.jl")
include("blink_interactions.jl")
include("handleinput.jl")
include("processvals.jl")
include("Plugins-and-default-arguments.jl")
include("processvals-new.jl")

end # module PackageInABlink
