# Automatically disable PackageMaker update checking during local testing
# by writing directly to LocalPreferences.toml before tests are loaded.
if get(ENV, "CI", nothing) != "true" 
    import TOML
    let
        lp_path = joinpath(@__DIR__, "LocalPreferences.toml")
        lp = isfile(lp_path) ? TOML.parsefile(lp_path) : Dict{String, Any}()
        prefs = get!(Dict{String, Any}, get!(Dict{String, Any}, lp, "PackageMaker"), "UpdateCheckingPrefs")
        if get(prefs, "enabled", true)
            prefs["enabled"] = false
            open(io -> TOML.print(io, lp; sorted=true), lp_path, "w")
        end
    end
end

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