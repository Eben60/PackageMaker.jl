using StartYourPk, Blink
# not currently working as is
isdefined(Main, :win) && close(win)

(;win, initvals, newvals, finalvals, changeeventhandle) = initwin("html/mw28.html")
@show finalvals
;



