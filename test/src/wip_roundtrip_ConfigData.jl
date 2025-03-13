using PackageMaker
using PackageMaker: PluginArg, PluginInfo, pg2od, write_config, read_config, get_pgins_vals!
using DataStructures
using JSON3

# include("ConfigData.jl")
include("TestData.jl")

using PackageMaker: checked_names, get_pgins_changed!, get_checked_pgins!, def_plugins_original, remove_key!, remove_inapplicable!

fv = TestData.fv
pgins = get_pgins_vals!(fv; plugins=deepcopy(def_plugins_original))
# pgins = TestData.pgins

pgins = get_checked_pgins!(fv; pgins)
checked_names(pgins)

get_pgins_changed!(pgins)

ogcpg = pg2od(pgins)


pa = pgins["Tests"].args["aqua_kwargs"]
ogcpg

###

# jsw = JSON3.write(ogcpg)
# jsr = JSON3.read(jsw);

write_config("Pref1", ogcpg)
jsr = read_config("Pref1")
;