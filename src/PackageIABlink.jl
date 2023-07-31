module PackageIABlink
using Blink

include("packages.jl")

winpath = realpath("html/mainwin.html")
@assert isfile(winpath)

function initcontents(fpath=winpath)
    contents = open(fpath, "r") do file
        read(file)
    end
    return String(contents)
end

function mainwin(fpath=winpath)
    win = Window();
    wincontent = initcontents(fpath)
    content!(win, "html", wincontent; async=false)
    return win
end
export mainwin

getelemval(win, id) = js(win, Blink.JSString("""document.getElementById("$id").value"""))
export getelemval

setelemval(win, id, newval) = js(win, Blink.JSString("""el = document.getElementById("$id"); el.value = "$newval";"""))
export setelemval

checkelem(win, id, newval::Bool) = js(win, Blink.JSString("""el = document.getElementById("$id"); el.checked = $newval;"""))
export checkelem

disableinputelem(win, id) = js(win, Blink.JSString("""el = document.getElementById("$id"); el.disabled = true;"""))
export disableinputelem



export default_env_packages

struct HtmlElem
    id::Symbol
    parentformid::Symbol
    value::Union{String, Float64}
    checked::Union{Bool, Nothing}
end

HtmlElem(id, parentformid, value::Real, checked) = HE(id, parentformid, Float64(value), checked)
export HtmlElem

getforminputs(d, form) = filter(e -> (e.second.parentformid == Symbol(form)), d) 
export getforminputs





function getpkgid(d, pkname)
    for (_, el) in d
        el.value == pkname && return el.id => pkname
    end
    return nothing
end

function getpkgids(d, pknames)
    items = [getpkgid(d, pkname) for pkname in pknames]
    return Dict([item for item in items if ! isnothing(item) ])
end

function check_entries_def_installed(win, initvals)
    pkgs = default_env_packages()
    form1 = getforminputs(initvals, :deflt_pkg)
    installed_pks = getpkgids(form1, pkgs)
    for item in keys(installed_pks)
        checkelem(win, item, true)
        disableinputelem(win, item)
    end
    return nothing
end
export check_entries_def_installed

handleinput(x) = nothing # 
handleinit_input() = nothing # println("init_input finished")
handlefinalinput(win) = close(win)

function handlechangeevents(win, newvals, initvals, finalvals)
    handle(win, "change") do arg
        # @show arg
        if arg["reason"] in ["newinput", "init_input", "finalinput"]
            id = Symbol(arg["elid"])
            parentformid = Symbol(arg["parentformid"])
            checked = arg["elchecked"]
            v = arg["elval"]
            el = HtmlElem(id, parentformid, v, checked)
            arg["reason"] == "newinput" && push!(newvals, id => el)
            arg["reason"] == "init_input" && push!(initvals, id => el)
            arg["reason"] == "finalinput" && push!(finalvals, id => el)
        end
        arg["reason"] == "newinput" && handleinput(el)
        arg["reason"] == "init_inputfinished" && handleinit_input()
        arg["reason"] == "finalinputfinished" && handlefinalinput(win)
    end
end
export handlechangeevents

function initwin(wpath)
    win = mainwin(wpath);

    initvals = Dict{Symbol, HtmlElem}()
    newvals = deepcopy(initvals)
    finalvals = deepcopy(initvals)

    changeeventhandle = handlechangeevents(win, newvals, initvals, finalvals)
    js(win, Blink.JSString("""sendfullstate(false)"""))
    check_entries_def_installed(win, initvals)
    return (;win, initvals, newvals, finalvals, changeeventhandle)
end
export initwin









end # module PackageIABlink
