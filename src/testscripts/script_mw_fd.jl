using PackageInABlink, Blink

isdefined(Main, :win) && close(win)

(;win, initvals, newvals, finalvals, changeeventhandle) = initwin("html/mw_fd2c.html")
@show finalvals
;

# TODO generate GitHubActions / Extra Julia versions to test, as strings as <textarea>

