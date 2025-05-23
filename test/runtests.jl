using SafeTestsets

@safetestset "Aqua" include("src/test_aqua.jl")

@safetestset "Various tests" include("src/test_various.jl")
@safetestset "Dropdown menus" include("src/test_dropdown_menus.jl")

@safetestset "HTML generation" include("src/test_html.jl")

@safetestset "Process values 1" include("src/test_processvals1.jl")
@safetestset "Process values 2" include("src/test_processvals2.jl")
@safetestset "Type definitions" include("src/test_typedefs.jl")
@safetestset "Create package 1" include("src/test_create_pkg01.jl")
@safetestset "Create project 2" include("src/test_create_pkg02.jl")

if  ! Sys.islinux() # for some reason, errors on Ubuntu both on CI server and on local computer, but is OK on Windows. OK on local Mac.
    @safetestset "Blink window" include("src/test_window.jl")
end