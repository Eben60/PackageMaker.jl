using YAArguParser

using YAArguParser: AbstractArgumentParser, get_value, set_value!, positional_args, args2vec, 
    sort_args, canonicalname, getnestedparsers, throw_on_exception, generate_usage!

using Aqua, Suppressor


using Test


@testset "Positional args" begin
    generated_usage = "\nUsage: $PROGRAM_FILE [ <Int64>] [ <Int64>] [ <Int64>] [-f|--foo <String>] [-g|--goo <String>] [-i|--int <Int64>] [-a|--abort]\n\n\n\nOptions:\n  --pos1 <Int64>\tinteger1\t (positional arg)\n  --pos2 <Int64>\tinteger2\t (positional arg)\n  --pos3 <Int64>\tinteger3\t (positional arg)\n  -f, --foo <String>\tFff\n  -g, --goo <String>\tGgg\n  -i, --int <Int64>\tinteger\n  -a, --abort\t\tabort\n\nExamples:\n  \$ 1 2 3 -f \"string 1\" -int 4\n  \$ 4 5 6 -goo \"string 2\" -i 7\n"
    @suppress_out begin
        p0 = ArgumentParser();
        add_argument!(p0, "-f", "--foo", type=String, default="fff", description="Fff");
        add_argument!(p0, "-g", "--goo", type=String, default="ggg", description="Ggg");
        add_argument!(p0, "-i", "--int", type=Int, default=0, description="integer");
        add_argument!(p0, "-a", "--abort", type=Bool, default=false, description="abort");
        generate_usage!(p0);

        p = deepcopy(p0);
        add_argument!(p, "", "--posn", type=Int, default=0, positional=true, description="integer")

        @test length(positional_args(p)) == 1
        @test length(args_pairs(p)) == 5

        cli_args = ["3", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]

        parse_args!(p; cli_args)
        @test get_value(p, "--foo") == "Ffff"
        @test get_value(p, "--goo") == "Gggg"
        @test get_value(p, "--int") == 1
        @test get_value(p, "--abort") == false
        @test get_value(p, "--posn") == 3                

        p = deepcopy(p0)
        add_argument!(p, "", "--posn", type=Int, default=0, positional=true, description="integer")
        cli_args = ["1.5", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        @test_throws ArgumentError parse_args!(p; cli_args)

        p = deepcopy(p0)
        rvl = RealValidator{Int}(;incl_vals=[3, 4, 6]);
        add_argument!(p, "", "--posn", type=Int, positional=true, description="integer", validator=rvl);
        cli_args = ["2", "-goo", "Gggg", "-f", "Ffff", "-i", "1"];
        @test_throws ArgumentError parse_args!(p; cli_args)
        cli_args = ["3", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        parse_args!(p; cli_args)
        @test get_value(p, "--posn") == 3 

        p1 = deepcopy(p0)
        add_argument!(p1, "", "--pos1", type=Int, default=0, positional=true, description="integer1");
        add_argument!(p1, "", "--pos2", type=Int, default=0, positional=true, description="integer2");
        add_argument!(p1, "", "--pos3", type=Int, default=0, positional=true, description="integer3");
        add_example!(p1, "1 2 3 -f \"string 1\" -int 4");
        add_example!(p1, "4 5 6 -goo \"string 2\" -i 7");
        generate_usage!(p1);
        @test p1.usage == generated_usage

        p = deepcopy(p1)
        cli_args = ["1", "2", "3", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        parse_args!(p; cli_args)

        @test get_value(p, "--foo") == "Ffff"
        @test get_value(p, "--goo") == "Gggg"
        @test get_value(p, "--int") == 1
        @test get_value(p, "--abort") == false
        @test get_value(p, "--pos1") == 1 
        @test get_value(p, "--pos2") == 2 
        @test get_value(p, "--pos3") == 3

        p1 = deepcopy(p0)
        add_argument!(p1, "", "pos1", type=Int, default=0, positional=true, description="integer")
        add_argument!(p1, "", "pos2", type=Int, default=0, positional=true, description="integer")
        add_argument!(p1, "", "pos3", type=Int, default=0, positional=true, description="integer")

        p = deepcopy(p1)
        cli_args = ["1", "2", "3", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        parse_args!(p; cli_args)

        @test get_value(p, "--foo") == "Ffff"
        @test get_value(p, "--goo") == "Gggg"
        @test get_value(p, "--int") == 1
        @test get_value(p, "--abort") == false
        @test get_value(p, "pos1") == 1 
        @test get_value(p, "pos2") == 2 
        @test get_value(p, "pos3") == 3

        @test args_pairs(p) == [:foo => "Ffff", :goo => "Gggg", :int => 1, :abort => false, :pos1 => 1, :pos2 => 2, :pos3 => 3]

        p = deepcopy(p1)
        cli_args = ["1", "-goo", "Gggg", "-f", "Ffff", "-i", "1"]
        parse_args!(p; cli_args)

        @test get_value(p, "--foo") == "Ffff"
        @test get_value(p, "--goo") == "Gggg"
        @test get_value(p, "--int") == 1
        @test get_value(p, "--abort") == false
        @test get_value(p, "--pos1") == 1 
        @test get_value(p, "--pos2") == 0 
        @test get_value(p, "--pos3") == 0

        p1 = deepcopy(p0);
        add_argument!(p1, "", "--pos1", type=Int, default=0, positional=true, description="integer");
        add_argument!(p1, "", "--pos2", type=Int, positional=true, description="integer");
        add_argument!(p1, "", "--pos3", type=Int, positional=true, description="integer");

        p = deepcopy(p1);
        cli_args = ["1", "-goo", "Gggg", "-f", "Ffff", "-i", "1"];

        @test_throws ArgumentError parse_args!(p; cli_args)
    end # suppress
end


;