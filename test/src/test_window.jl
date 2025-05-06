# Sys.islinux() && @unsafe # doesn't help

using Blink
using Test
using PackageMaker
using PackageMaker: mainwin, initwin, initialize, getelemval, setelemval, read_config, handle_savedconfig, GUI_RETURNED #, @unsafe

TEST_SETTING::String = "z2test_TestSetting_1681796"
@testset "size Tests" begin
    w = Window(Blink.Dict(:show => false, :width=>150, :height=>100), async=false);
    @test active(w)
    @test size(w) == [150,100]

    size(w, 200,200)
    @test size(w) == [200,200]
    close(w)
    @test ! active(w)
end

initialize()
include("TestData_CreatePackage02.jl")
fv = TestData_CreatePackage.fv;
@testset "Window with full content and interaction" begin
    (;win, initvals, newvals, changeeventhandle) = initwin(; debug=true);
    ks = keys(initvals) |> collect |> sort!
    ks = filter(x->!startswith(string(x), "SavedConfigTag"), ks)
    ks = filter(x->!startswith(string(x), "Save_Configuration"), ks)  
    # @show length(ks)
    @test length(ks) == 95
    # @show ks

    @test initvals[:GeneralOptions_julia_min_version].value == "1.10.0"
    @test initvals[:License_name_1].value == "MIT"
    el = shell() # reference to the Electron process
    @test active(win)

    @test getelemval(win, "Readme_destination") == "README.md"
    @test getelemval(win, "Use_Readme") 

    for v in values(fv)
        if v.inputtype == :checkbox
            val = v.checked
        else
            val = v.value
        end
        setelemval(win, v.id, val)
    end
    sleep(0.05)

    @test getelemval(win, "Readme_destination") == "README.txt"
    @test getelemval(win, "GeneralOptions_authors") == "Eben007 <E007@nowhere.org>"
    @test ! getelemval(win, "Use_Readme")

    setelemval(win, "Save_Configuration_config_name", TEST_SETTING)
    sleep(0.05)

    @test getelemval(win, "Save_Configuration_config_name") == TEST_SETTING
    js(win, Blink.JSString("""subm('saveprefs_finished', 'intermed_input')"""); callback=false)

    js(win, Blink.JSString("""subm('finalinputfinished', 'finalinput')"""); callback=false)
    (;finalvals, cancelled) = take!(GUI_RETURNED)

    @test !cancelled
    @test finalvals[:Readme_destination].value == "README.txt"
    @test finalvals[:GeneralOptions_authors].value == "Eben007 <E007@nowhere.org>"

    @test ! active(win)

    initialize()
    @test read_config(TEST_SETTING).name == TEST_SETTING
    (;win, initvals, newvals, changeeventhandle) = initwin(; debug=true);
    sleep(0.05)
    handle_savedconfig(win, TEST_SETTING)
    setelemval(win, "Save_Configuration_config_name", TEST_SETTING)
    sleep(0.05)

    js(win, Blink.JSString("""subm('deleteprefs_finished', 'intermed_input')"""); callback=false)
    @test getelemval(win, "GeneralOptions_authors") == "Eben007 <E007@nowhere.org>"
    @test ! getelemval(win, "Use_Readme")

    js(win, Blink.JSString("""subm('finalinputfinished', 'finalinput')"""); callback=false)
    (;finalvals, cancelled) = take!(GUI_RETURNED)

    @test !cancelled
    # @test finalvals[:Readme_destination].value == "README.txt"
    @test finalvals[:GeneralOptions_authors].value == "Eben007 <E007@nowhere.org>"

    initialize()
    @test_throws KeyError read_config(TEST_SETTING)
end
;
