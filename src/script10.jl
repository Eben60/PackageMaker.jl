using Revise
using PackageIABlink, Blink
# https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/radio

isdefined(Main, :win) && close(win)
win = mainwin("html/mw10.html");


newvals = Dict{Symbol, HtmlElem}()


handle(win, "change") do arg
    id = Symbol(arg["elid"])
    parentformid = Symbol(arg["parentformid"])
    checked = arg["elchecked"]
    v = arg["elval"]
    el = HtmlElem(id, parentformid, v, checked)
    push!(newvals, id => el)
end