using PackageMaker
using PackageMaker: PluginArg, PluginInfo, pg2od, write_config, read_config, get_pgins_vals!, savedconfignames
using DataStructures
using JSON3

include("ConfigData.jl")
fv = ConfigData.fv
# include("TestData.jl")
# fv = TestData.fv

using PackageMaker: get_pgins_changed!, get_checked_pgins!, def_plugins_original, remove_key!, remove_inapplicable!


pgins = get_pgins_vals!(fv; plugins=deepcopy(def_plugins_original))

get_checked_pgins!(fv; pgins)


get_pgins_changed!(pgins)

ogcpg = pg2od(pgins)


# pa = pgins["Tests"].args["aqua_kwargs"]
ogcpg

###

# jsw = JSON3.write(ogcpg)
# jsr = JSON3.read(jsw);

# write_config("Pref1", ogcpg)
# write_config("Pref2a", ogcpg)
write_config("This_is, whay- bekauze + .", ogcpg)
jsr2a = read_config("Pref2a")
jsr1 = read_config("Pref1") 

# cnames = savedconfignames()




;