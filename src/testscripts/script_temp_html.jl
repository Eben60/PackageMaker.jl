using Pkg
# currently working
pkg_dir = joinpath(@__DIR__, "..", "..") |> normpath
Pkg.activate(pkg_dir)

using StartYourPk, Blink

isdefined(Main, :win) && close(win)

html_templ = make_html()

(;win, initvals, newvals, finalvals, changeeventhandle) = initwin(html_templ)
@show finalvals
;


