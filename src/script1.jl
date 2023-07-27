using Blink

realpath(@__FILE__)
isfile("html/mainwin.html")
winpath = realpath("html/mainwin.html")
@assert isfile(winpath)
opts = Dict(:url=>winpath)
# w = Window(shell(), opts)
# loadurl(w, winpath)
w = Window()
# db_url = "https://www.dropbox.com/s/1b7hrp5cbum252z/mainwin.html?dl=0"
gh_url = "https://raw.githubusercontent.com/Eben60/PackageIABlink.jl/main/html/mainwin.html"
loadurl(w, gh_url)