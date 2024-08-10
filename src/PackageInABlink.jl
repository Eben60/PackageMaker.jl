module PackageInABlink

using Blink, LibGit2, OrderedCollections

include("git.jl")
include("defaults.jl")
include("packages.jl")
include("html.jl")
include("blink_interactions.jl")
include("handleinput.jl")
include("processvals.jl")
include("Plugins-and-default-arguments.jl")

end # module PackageInABlink
