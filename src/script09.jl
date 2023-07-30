using Revise
using PackageIABlink, Blink
# https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/radio

isdefined(Main, :win) && close(win)
win = mainwin("html/mw09.html");


newvals = Dict{Symbol, HtmlElem}()


handle(win, "change") do arg
    # @show arg
    id = Symbol(arg["elid"])
    parentid = Symbol(arg["parentid"])
    checked = arg["elchecked"]
    v = arg["elval"]
    el = HtmlElem(id, parentid, v, checked)
    push!(newvals, id => el)
end