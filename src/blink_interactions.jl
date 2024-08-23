try
    winpath = realpath("html/mainwin.html")
    @assert isfile(winpath)
catch
    @warn "The default file mainwin.html cannot be found."
end

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

# may not work if called during interaction
getelemval(win, id) = js(win, Blink.JSString("""document.getElementById("$id").value"""))
export getelemval

setelemval(win, id, newval) = js(win, Blink.JSString("""el = document.getElementById("$id"); el.value = "$newval";"""); callback=false)
export setelemval

checkelem(win, id, newval::Bool) = js(win, Blink.JSString("""el = document.getElementById("$id"); el.checked = $newval;"""); callback=false)
export checkelem

disableinputelem(win, id) = js(win, Blink.JSString("""el = document.getElementById("$id"); el.disabled = true;"""); callback=false)
export disableinputelem


export default_env_packages

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
        # disableinputelem(win, item)
    end
    return nothing
end
export check_entries_def_installed


# handleinput(x) = nothing # 
handleinit_input() = nothing # println("init_input finished")
handlefinalinput(win) = close(win)

function handlechangeevents(win, newvals, initvals, finalvals)
    handle(win, "change") do arg
        # arg["reason"] == "newinput" && @show arg
        if arg["reason"] in ["newinput", "init_input", "finalinput"]
            id = Symbol(arg["elid"])
            eltype = Symbol(arg["eltype"])
            elclass = arg["elclass"] |> split .|> String
            inputtype = Symbol(arg["inputtype"])
            parentformid = Symbol(arg["parentformid"])
            checked = arg["elchecked"]
            v = arg["elval"]
            el = HtmlElem(id, eltype, elclass, inputtype, parentformid, v, checked)
            arg["reason"] == "newinput" && push!(newvals, id => el)
            arg["reason"] == "init_input" && push!(initvals, id => el)
            arg["reason"] == "finalinput" && push!(finalvals, id => el)
        end
        arg["reason"] == "newinput" && handleinput(win, el, (; newvals, initvals))
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

function showhide(win, id, show=true, duration=100) 
    jqselector = "#$(id)"
    jqaction = show ? "show($(duration))" : "hide($(duration))"
    js(win, Blink.JSString("""jQuery("$(jqselector)").$(jqaction)"""); callback=false)
    return nothing
end