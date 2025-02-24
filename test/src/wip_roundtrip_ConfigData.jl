using PackageMaker
using PackageMaker: PluginArg, PluginInfo, pg2od, write_config, read_config
using DataStructures
using JSON3

include("ConfigData.jl")

using PackageMaker: checked_names, get_pgins_changed!, get_checked_pgins!

fv = TestData.fv
pgins = TestData.pgins

pgins = get_checked_pgins!(fv; pgins)
checked_names(pgins)

get_pgins_changed!(pgins)

ogcpg = pg2od(pgins)


pa = pgins["Tests"].args["aqua_kwargs"]
ogcpg

# jsw = JSON3.write(ogcpg)
# jsr = JSON3.read(jsw);

write_config("Pref1", ogcpg)
jsr = read_config("Pref1")