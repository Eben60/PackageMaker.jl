# Sys.islinux() && @unsafe # doesn't help

using Blink
using Test
using PackageMaker
using PackageMaker: mainwin, initwin, @unsafe, initialize

initialize()



@testset "size Tests" begin
    w = Window(Blink.Dict(:show => false, :width=>150, :height=>100), async=false);
    @test active(w)
    @test size(w) == [150,100]

    size(w, 200,200)
    @test size(w) == [200,200]
    close(w)
    @test ! active(w)
end


@testset "Window with full contents" begin
    (;win, initvals, newvals, finalvals, changeeventhandle) = initwin(; debug=true);
    ks = keys(initvals) |> collect |> sort!
    ks = filter(x->!startswith(string(x), "SavedConfigTag"), ks)
    ks = filter(x->!startswith(string(x), "Save_Configuration"), ks)  
    # @show length(ks)
    @test length(ks) == 93
    # @show ks

    @test initvals[:GeneralOptions_julia_min_version].value == "1.10.0"
    @test initvals[:License_name_1].value == "MIT"
    el = shell() # reference to the Electron process
    @test active(win)
    close(win)
    @test ! active(win)
    close(win)
    try
        close(el)
    catch
    end
end
;
