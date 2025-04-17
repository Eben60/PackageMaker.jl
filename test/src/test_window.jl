# module TestWindow
using Blink
using Test
using PackageMaker
using PackageMaker: mainwin, @unsafe

# Sys.islinux() && @unsafe # doesn't help

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
    w = mainwin(; test=true);
    el = shell() # reference to the Electron process
    @test active(w)
    close(w)
    @test ! active(w)
    close(w)
    try
        close(el)
    catch
    end
end

# end
;