using Revise
using PackageIABlink, Blink
# https://developer.mozilla.org/en-US/docs/Web/HTML/Element/input/radio

isdefined(Main, :win) && close(win)

(;win, initvals, newvals, finalvals, changeeventhandle) = initwin("html/mws25.html");




