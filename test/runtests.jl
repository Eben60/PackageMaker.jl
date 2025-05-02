# using PackageMaker
using SafeTestsets

@safetestset "Aqua" include("src/test_aqua.jl")
@safetestset "Dropdown menus" include("src/test_dropdown_menus.jl") # ok
# Sys.isunix() &&
    @safetestset "HTML generation" include("src/test_html.jl") # OK

@safetestset "Process values 1" include("src/test_processvals1.jl") # OK
@safetestset "Process values 2" include("src/test_processvals2.jl") # OK
@safetestset "Type definitions" include("src/test_typedefs.jl") # OK
@safetestset "Create package 1" include("src/test_create_pkg01.jl") # broken 
@safetestset "Create project 2" include("src/test_create_pkg02.jl") # broken

if ! Sys.islinux() # for some reason, errors on CI server on Ubuntu, but is OK on Windows. OK on local Mac.
    @safetestset "Blink window" include("src/test_window.jl")
end

