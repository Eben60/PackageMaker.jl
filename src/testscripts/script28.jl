using PackageInABlink, Blink

isdefined(Main, :win) && close(win)

(;win, initvals, newvals, finalvals, changeeventhandle) = initwin("html/mw28.html")
@show finalvals
;



