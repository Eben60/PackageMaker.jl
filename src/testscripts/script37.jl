using Pkg

pkg_dir = joinpath(@__DIR__, "..", "..") |> normpath
Pkg.activate(pkg_dir)

using PackageInABlink, Blink

isdefined(Main, :win) && close(win)

html_dir = joinpath(@__FILE__, "..", "..", "..", "html") |> normpath
@assert isdir(html_dir)
html_templ = joinpath(html_dir, "mw37.html")

(;win, initvals, newvals, finalvals, changeeventhandle) = initwin(html_templ)
@show finalvals
;

# TODO generate GitHubActions / Extra Julia versions to test, as strings as <textarea>

