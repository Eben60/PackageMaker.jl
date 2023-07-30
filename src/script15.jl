using Revise
using PackageIABlink, Blink
# https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/radio

isdefined(Main, :win) && close(win)
win = mainwin("html/mw14.html");

initvals = Dict{Symbol, HtmlElem}()
newvals = deepcopy(initvals)
finalvals = deepcopy(initvals)

handlechangeevents(win, newvals, initvals, finalvals)


js(win, Blink.JSString("""sendinitstate()"""))

def_installed = ["Revise", "BenchmarkTools", "Test", "Unitful", "StaticArrays"]

check_entries_def_installed(win, initvals, def_installed)

# checkelem(win, "defpkg2", false)
# checkelem(win, "defpkg5", true)
# disableinputelem(win, "defpkg7")
# disableinputelem(win, :defpkg5)



