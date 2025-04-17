using PackageMaker
using Aqua

Aqua.test_all(PackageMaker)

include("src/test_dropdown_menus.jl")
include("src/test_processvals1.jl")
include("src/test_processvals2.jl")
include("src/test_typedefs.jl")

if ! Sys.islinux() # for some reason, errors on CI server on Ubuntu, but is OK on Windows. OK on local Mac.
    include("src/test_window.jl")
end

