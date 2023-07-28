module PackageIABlink
using Blink

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
    body!(win, wincontent; async=false)
    return win
end

export mainwin

getelemval(win, id) = js(win, Blink.JSString("""document.getElementById("$id").value"""))
export getelemval

setelemval(win, id, newval) = js(win, Blink.JSString("""el = document.getElementById("$id"); el.value = "$newval";"""))
export setelemval

end # module PackageIABlink
