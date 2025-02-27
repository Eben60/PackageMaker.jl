using PackageMaker
using Aqua

Aqua.test_all(PackageMaker)

include("src/test_dropdown_menus.jl")
include("src/test_processvals1.jl")
include("src/test_processvals2.jl")
include("src/test_typedefs.jl")

