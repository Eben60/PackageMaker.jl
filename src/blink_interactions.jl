function initwin(; make_prj = false)
    global may_exit_julia = false
    win = mainwin();

    initvals = Dict{Symbol, HtmlElem}()
    newvals = deepcopy(initvals)
    intermvals = deepcopy(initvals)
    finalvals = deepcopy(initvals)

    changeeventhandle = handlechangeevents(win, newvals, initvals, intermvals, finalvals; make_prj)
    js(win, Blink.JSString("""sendfullstate(false, false)"""))
    cancelled = wait_until_finished()
    return (;win, initvals, newvals, finalvals, changeeventhandle, cancelled)
end

function wait_until_finished()
    cancelled = ! take!(finished_ch) # 
    sleep(0.05)
    return cancelled
end

function mainwin(fpath=nothing)
    info_unsafe = """There is a bug on Ubuntu 24, which may have caused this error. 
You may want to run `PackageMaker` from VSCode, 
or run the macro `@unsafe` before calling `gogui()`.
See docstring of `@unsafe`, or `PackageMaker` documentation. """

    try
        global win = Window();
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

function handlechangeevents(win, newvals, initvals, intermvals, finalvals; make_prj = false)
    handle(win, "change") do arg
        if arg["reason"] == "external_link"
            openurl(arg["url"])
        else
            if arg["reason"] in ["newinput", "init_input", "finalinput", "intermediate_input"]
                id = Symbol(arg["elid"])
                eltype = Symbol(arg["eltype"])
                elclass = arg["elclass"] |> split .|> String
                inputtype = Symbol(arg["inputtype"])
                parentformid = Symbol(arg["parentformid"])
                checked = arg["elchecked"]
                v = arg["elval"]
                el = HtmlElem(id, eltype, elclass, inputtype, parentformid, v, checked)
                arg["reason"] == "newinput" && push!(newvals, id => el)
                arg["reason"] == "intermediate_input" && push!(intermvals, id => el)
                arg["reason"] == "init_input" && push!(initvals, id => el)
                arg["reason"] == "finalinput" && push!(finalvals, id => el)
            end
            arg["reason"] == "newinput" && handleinput(win, el, (; newvals, initvals))
            # arg["reason"] == "init_inputfinished" && handleinit_input()
            arg["reason"] == "intermediate_inputfinished" && handle_intermed_input(win, intermvals)
            arg["reason"] == "finalinputfinished" && handlefinalinput(win, finalvals, true; make_prj)
            arg["reason"] == "finalinputcancelled" && handlefinalinput(win, finalvals, false; make_prj)
        end
    end
end

function handlefinalinput(win, finalvals, submit::Bool; make_prj = false) 
    close(win)
    submit && make_prj && return create_proj(finalvals)
    put!(finished_ch, submit)
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


# may not work if called during interaction / currently unused
getelemval(win, id) = js(win, Blink.JSString("""document.getElementById("$id").value"""))