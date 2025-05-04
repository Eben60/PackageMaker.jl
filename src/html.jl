checked(b) = b ? "checked" : ""

esc_qm(x) = x
esc_qm(s::AbstractString) = occursin(r"(</span>)|(</code>)|(</sup>)|(<br>)", s) ? s :
     replace(s, "\""=>"&quot;", ">" => "&gt;", "<" => "&lt;", "&" => "&amp;", "#" => "&#35;")

function insert_url(s, url)
    isempty(url) && return s |> esc_qm
    re = r"(.*)<a>(.+)(</a>.*)"
    m0 = match(re, s)
    isnothing(m0) && error("string $s doesn't contain proper link precursor")
    m = m0 |> collect
    a = """<a href="javascript:sendurl('$url')" >"""
    return m[1] * a * m[2] * m[3]
end

make_html(pgins=def_plugins) = replace(
    html_head() * 
    html_use_purpose() *
    html_plugins(pgins) *
    html_submit() *
    js_scripts() *
    html_tail(), 
    r" +\n" => "\n")
    
function make_html(pgins, file) # plugins - see file "Plugins-and-default-arguments.jl"
    html = make_html(pgins)
    open(file, "w") do f
        write(f, html)
    end
    return file
end

"if provided a file name without suffix, will add .html and save generated file into default directory"
function make_html(file::AbstractString)
    initialize()
    defaultpath = "html_tests"
    if endswith(file, ".html")
        f = file
    else
        f = joinpath(defaultpath, "$(file).html")
    end
    return make_html(def_plugins, f)
end

