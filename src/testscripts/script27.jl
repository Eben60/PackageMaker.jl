using PackageInABlink, Blink

isdefined(Main, :win) && close(win)

(;win, initvals, newvals, finalvals, changeeventhandle) = initwin("html/mw27.html")
@show finalvals
;



