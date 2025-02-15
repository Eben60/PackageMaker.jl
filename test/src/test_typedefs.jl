module TestTypedefs

using Test
using PackageMaker
using PackageMaker: PluginArg, PluginInfo, update_struct
using StructEqualHash

@struct_equal_hash PluginArg
@struct_equal_hash PluginInfo

@testset "TestTypedefs" begin

p1 = PluginArg(
    type = Bool,
    name = "project",
    default_val = false,
    meaning = "Whether or not?",
    html_val = nothing,
    returned_val = nothing ,
    nondefault = false,
    url = "",
    options = String[],
    menulabel = ""
)

p2 = PluginArg(Vector{String}, "ignore", String[], "Patterns to add ", nothing, nothing, false, "", String[], "")
p3 = PluginArg(String, "name", "nothing", "Your real name", nothing, nothing, false, "", String[], "")
p4 = PluginArg(Nothing, "aim", nothing, "Your real aim.", nothing, nothing, false, "", String[], "")
nt5 = (;
    type = String,
    name = "project",
    default_val = "false",
    meaning = "Whether or not?",
    html_val = "a value",
    returned_val = nothing ,
    nondefault = true,
    url = "https://abc.de/efg.html",
    options = ["option 1", "option2"],
    menulabel = "This is menu"
)
p5 = PluginArg(String, "project", "false", "Whether or not?", "a value", nothing, true, "https://abc.de/efg.html", ["option 1", "option2"], "This is menu")
p5c = PluginArg(String, "claim", "false", "Whether or not?", "a value", nothing, true, "https://abc.de/efg.html", ["option 1", "option2"], "This is menu")

pi1 = PluginInfo(("AName", "A purpose", [p1, p2, p3, p4]))
pi2 = PluginInfo(("BName", "B purpose", [nt5], "https://abc.de/efg.html"))
pi3 = PluginInfo(("CName", "C purpose", [("project", false, "Whether or not?"), (Vector{String}, "item",  String[], "Patterns to add ")], "https://abc.de/efg.html"))

    @testset "PluginArg" begin
        @test isequal(PluginArg(("project", false, "Whether or not?")), p1)
        @test isequal(PluginArg((Vector{String}, "ignore",  String[], "Patterns to add ")), p2)
        @test isequal(PluginArg(("name", "nothing", "Your real name")), p3)
        @test isequal(PluginArg(("aim", nothing, "Your real aim.")), p4)
        @test isequal(PluginArg(nt5), p5)
        @test update_struct(p5; name="claim") == p5c
    end

    @testset "PluginInfo" begin
        @test pi1.args |> keys |> collect == ["project", "ignore", "name", "aim"]
        @test pi1.name == "AName"
        @test pi1.purpose == "A purpose"
        @test pi1.args["project"] == p1
        @test pi1.args["ignore"] == p2
        @test pi1.args["name"] == p3
        @test pi1.args["aim"] == p4
        @test pi1.checked == false
        @test pi1.url == ""

        @test pi2.name == "BName"
        @test pi2.purpose == "B purpose"
        @test pi2.args["project"] == p5
        @test pi2.checked == false
        @test pi2.url == "https://abc.de/efg.html"
        
        @test pi3.args |> keys |> collect == ["project", "item"]
    end
end

end # module