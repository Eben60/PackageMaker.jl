module TestTypedefs

using Test
using PackageMaker
using PackageMaker: PluginArg, PluginInfo, update_struct
using StructEqualHash

@struct_equal_hash PluginArg
@struct_equal_hash PluginInfo

@testset "TestTypedefs" begin

p1 = PluginArg(;
    type = Bool,
    name = "project",
    default_val = false,
    meaning = "Whether or not?",
    returned_rawval = nothing,
    returned_val = nothing ,
    url = "",
    options = (; opt_list = String[], show_first = false),
    menulabel = "",
    changed = false,
)

p2 = PluginArg(Vector{String}, "ignore", String[], "Patterns to add ", nothing, nothing, "", (; opt_list = String[], show_first = false), "", false)
p3 = PluginArg(String, "name", "nothing", "Your real name", nothing, nothing, "", (; opt_list = String[], show_first = false), "", false)
p4 = PluginArg(String, "aim", nothing, "Your real aim.", nothing, nothing, "", (; opt_list = String[], show_first = false), "", false)
nt5 = (;
    type = String,
    name = "project",
    default_val = "false",
    meaning = "Whether or not?",
    returned_rawval = "a value",
    returned_val = nothing ,
    url = "https://abc.de/efg.html",
    options = (; opt_list = ["option 1", "option2"], show_first = false),
    menulabel = "This is menu",
    changed = false,
)

nt6 = (;
    type = String,
    name = "claim",
    default_val = "false",
    meaning = "Whether or not?",
    returned_rawval = "a value",
    returned_val = nothing ,
    url = "https://abc.de/efg.html",
    options = (; opt_list = ["option 1", "option2"], show_first = false),
    menulabel = "This is menu",
    changed = true,
)

p5 = PluginArg(String, "project", "false", "Whether or not?", "a value", nothing, "https://abc.de/efg.html", (; opt_list = ["option 1", "option2"], show_first = false), "This is menu", false)
p5c = PluginArg(String, "claim", "false", "Whether or not?", "a value", nothing, "https://abc.de/efg.html", (; opt_list = ["option 1", "option2"], show_first = false), "This is menu", false)
p6 = PluginArg(; nt6...)

pi1 = PluginInfo(("AName", "A purpose", [p1, p2, p3, p4]))
pi2 = PluginInfo(("BName", "B purpose", [nt5], "https://abc.de/efg.html"))
pi3 = PluginInfo(("CName", "C purpose", [("project", false, "Whether or not?"), (Vector{String}, "item",  String[], "Patterns to add ")], "https://abc.de/efg.html"))

    @testset "PluginArg" begin
        @test isequal(PluginArg(("project", false, "Whether or not?")), PluginArg(("project", false, "Whether or not?")),)

        @test isequal(PluginArg(("project", false, "Whether or not?")), p1)
        @test isequal(PluginArg((Vector{String}, "ignore",  String[], "Patterns to add ")), p2)
        @test isequal(PluginArg(("name", "nothing", "Your real name")), p3)
        @test isequal(PluginArg(("aim", nothing, "Your real aim.")), p4)

        @test isequal(PluginArg(nt5), p5)
        @test p6.changed
        @test update_struct(p6; changed=false) == p5c

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