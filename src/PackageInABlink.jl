module PackageInABlink

using Blink, LibGit2

include("git.jl")
include("defaults.jl")
include("packages.jl")
include("html.jl")
include("blink_interactions.jl")
include("handleinput.jl")
include("processvals.jl")
include("Plugins-and-default-arguments.jl")
@show length(def_plugins)


end # module PackageInABlink
