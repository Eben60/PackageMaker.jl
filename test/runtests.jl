using PackageMaker
using SafeTestsets

@safetestset "Aqua" include("src/test_aqua.jl")
@safetestset "Dropdown menus" include("src/test_dropdown_menus.jl")
if ! Sys.isunix() 
    @safetestset "HTML generation" include("src/test_html.jl")
end
@safetestset "Process values 1" include("src/test_processvals1.jl")
@safetestset "Process values 2" include("src/test_processvals2.jl")
@safetestset "Type definitions" include("src/test_typedefs.jl")
@safetestset "Create project" include("src/test_create_pkg.jl")

if ! Sys.islinux() # for some reason, errors on CI server on Ubuntu, but is OK on Windows. OK on local Mac.
    @safetestset "Blink window" include("src/test_window.jl")
end

