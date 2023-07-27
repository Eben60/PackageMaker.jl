using Blink

realpath(@__FILE__)
isfile("html/mainwin.html")
winpath = realpath("html/mainwin.html")
@assert isfile(winpath)

winpathurl = "file://$(winpath)"
w = Window();
# db_url = "https://www.dropbox.com/s/1b7hrp5cbum252z/mainwin.html?dl=0"
# gh_url = "https://eben60.github.io/PackageIABlink.jl/html/mainwin.html"


# loadurl(w, winpathurl)
bd = String(read(winpath))
body!(w, bd; async=false)

# # js(w, Blink.JSString("""document.getElementById("box02").style.color"""))
# body!(w, """<div id="box" style="color:red;">text goes here</div>""", async=false);
# div_id = "box";
# js(w, Blink.JSString("""document.getElementById("$div_id").style.color"""))

# js(w, Blink.JSString("""document.getElementById("$div_id").innerText"""))
# sleep(0.5)
p_id = "p01"
bf = js(w, Blink.JSString("""document.getElementById("$p_id").innerText"""))

tc = js(w, Blink.JSString("""document.getElementById("$p_id").textContent"""))

inp_id="input1" 
vl = js(w, Blink.JSString("""document.getElementById("$inp_id").value""")) # OK
# vl1 = js(w, Blink.JSString("""document.getElementById("input1").value"""))

inp2_id = "input2"
# ta = js(w, Blink.JSString("""document.getElementById("$inp2_id").innerText"""))
tv = js(w, Blink.JSString("""document.getElementById("$inp2_id").textContent""")) # old text
tv2 = js(w, Blink.JSString("""document.getElementById("$inp2_id").value""")) # OK

@show bf tc vl ta tv2 ;

