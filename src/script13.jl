using Revise
using PackageIABlink, Blink
# https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/radio

isdefined(Main, :win) && close(win)
win = mainwin("html/mw13.html");

initvals = Dict{Symbol, HtmlElem}()
newvals = deepcopy(initvals)
finalvals = deepcopy(initvals)

handleinput(x) = nothing # 
handleinit_input() = println("init_input finished")
handlefinalinput() = nothing

handle(win, "change") do arg
    # @show arg
    if arg["reason"] in ["newinput", "init_input", "finalinput"]
        id = Symbol(arg["elid"])
        parentformid = Symbol(arg["parentformid"])
        checked = arg["elchecked"]
        v = arg["elval"]
        el = HtmlElem(id, parentformid, v, checked)
        arg["reason"] == "newinput" && push!(newvals, id => el)
        arg["reason"] == "init_input" && push!(initvals, id => el)
        arg["reason"] == "finalinput" && push!(finalinput, id => el)
    end
    arg["reason"] == "newinput" && handleinput(el)
    arg["reason"] == "init_inputfinished" && handleinit_input()
    arg["reason"] == "finalinputfinished" && handlefinalinput()
end

js(win, Blink.JSString("""sendinitstate()"""))
# checkelem(win, "defpkg2", false)
# checkelem(win, "defpkg5", true)
# disableinputelem(win, "defpkg7")
# disableinputelem(win, :defpkg5)