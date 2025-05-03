function initwin(; debug=false)
    global may_exit_julia = false
    win = mainwin(; debug);

    initvals = Dict{Symbol, HtmlElem}()
    newvals = deepcopy(initvals)
    intermvals = deepcopy(initvals)
    finalvals = deepcopy(initvals)

    changeeventhandle = handlechangeevents(win, newvals, initvals, intermvals, finalvals)
    js(win, Blink.JSString("""subm("init_inputfinished", "init_input")"""))
    return (;win, initvals, newvals, finalvals, changeeventhandle)
end


function mainwin(fpath=nothing; debug=false)
    info_unsafe = """There is a bug on Ubuntu 24, which may have caused this error. 
You may want to run `PackageMaker` from VSCode, 
or run the macro `@unsafe` before calling `gogui()`.
See docstring of `@unsafe`, or `PackageMaker` documentation. """

    try
        global win = Window(Blink.Dict(:show => !debug, ); async=false);
    catch e
        if e isa Base.IOError
            @info info_unsafe
            error("IO error on calling Blink.Window()")
        else
            rethrow(e)
        end
    end
    if !isnothing(fpath) 
        wincontent = initcontents(fpath)
    else
        wincontent = make_html()
    end
    content!(win, "html", wincontent; async=false)
    return win
end

function initcontents(fpath)
    contents = open(fpath, "r") do file
        read(file)
    end
    return String(contents)
end

function handlechangeevents(win, newvals, initvals, intermvals, finalvals)
    handle(win, "change") do arg
        if arg["reason"] == "external_link"
            openurl(arg["url"])
        else
            if arg["reason"] in ["newinput", "init_input", "finalinput", "saveprefs", "retrieve1value"]
                haskey(arg, "elid") || @show arg
                id = Symbol(arg["elid"])
                eltype = Symbol(arg["eltype"])
                elclass = arg["elclass"] |> split .|> String
                inputtype = Symbol(arg["inputtype"])
                parentformid = Symbol(arg["parentformid"])
                checked = arg["elchecked"]
                v = arg["elval"]
                el = HtmlElem(id, eltype, elclass, inputtype, parentformid, v, checked)
                arg["reason"] == "newinput" && push!(newvals, id => el)
                arg["reason"] == "saveprefs" && push!(intermvals, id => el)
                arg["reason"] == "init_input" && push!(initvals, id => el)
                arg["reason"] == "finalinput" && push!(finalvals, id => el)
                arg["reason"] == "retrieve1value" && put_newval(el)
            end
            arg["reason"] == "newinput" && handleinput(win, el, (; newvals, initvals))
            # arg["reason"] == "init_inputfinished" && handleinit_input()
            arg["reason"] == "saveprefs_finished" && handle_saveconfig(win, intermvals)
            arg["reason"] == "finalinputfinished" && handlefinalinput(win, finalvals, true)
            arg["reason"] == "finalinputcancelled" && handlefinalinput(win, finalvals, false)
        end
    end
end

function put_newval(el)
    empty_channel!(VAL_RETURNED)
    put!(VAL_RETURNED, el)
end

function getelemval(win, id) # actually not used except in tests, but nice to have
    js(win, Blink.JSString("""send1el("$id")"""); callback=false)
    el = take!(VAL_RETURNED)
    el.inputtype == :checkbox && return el.checked
    return el.value
end

function handlefinalinput(win, finalvals, submit::Bool) 
    close(win)
    cancelled = !submit
    cancelled && (finalvals = nothing)
    put!(GUI_RETURNED, (;cancelled, finalvals))
    return nothing
end

setelemval(win, id, newval::AbstractString) = js(win, Blink.JSString("""el = document.getElementById("$id"); el.value = "$newval";"""); callback=false)
setelemval(win, id, newval::Bool) = checkelem(win, id, newval::Bool) 
setelemval(win, pgname, fldname, newval) = setelemval(win, "$(pgname)_$(fldname)", newval)

checkelem(win, id, newval::Bool) = js(win, Blink.JSString("""el = document.getElementById("$id"); el.checked = $newval;"""); callback=false)

setelemtext(win, id, newval::AbstractString) = 
    js(win, Blink.JSString("""document.getElementById("$id").textContent = "$newval";"""); callback=false)

setelemclass(win, id, newval::AbstractString) = 
    js(win, Blink.JSString("""document.getElementById("$id").className = "$newval";"""); callback=false)

handleinit_input() = nothing # println("init_input finished")

function showhide(win, id, show_tag=true, duration=100) 
    jqselector = "#$(id)"
    jqaction = show_tag ? "show($(duration))" : "hide($(duration))"
    js(win, Blink.JSString("""jQuery("$(jqselector)").$(jqaction)"""); callback=false)
    return nothing
end

enable_html_elem(win, id, enable=true) = js(win, Blink.JSString("""el = document.getElementById("$id"); el.disabled = $(! enable);"""); callback=false)


# # may not work if called during interaction / currently unused
# getelemval(win, id) = js(win, Blink.JSString("""document.getElementById("$id").value"""))