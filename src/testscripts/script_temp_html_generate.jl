using Pkg
# currently working
pkg_dir = joinpath(@__DIR__, "..", "..") |> normpath
Pkg.activate(pkg_dir)

using StartYourPk, Blink

isdefined(Main, :win) && close(win)

(;win, initvals, newvals, finalvals, changeeventhandle) = initwin(; make_prj = true)

;


