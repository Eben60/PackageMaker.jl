html_dir() = mktempdir(; cleanup=false)
tmp_html() = joinpath(html_dir(), "package_maker.html") |> normpath

checked(b) = b ? "checked" : ""

esc_qm(s::String) = replace(s, "\""=>"&quot;", ">" => "&gt;", "<" => "&lt;", "&" => "&amp;")
esc_qm(x) = x

function insert_url(s, url)
    isempty(url) && return s |> esc_qm
    re = r"(.*)<a>(.+)(</a>.*)"
    m0 = match(re, s)
    isnothing(m0) && error("string $s doesn't contain proper link precursor")
    m = m0 |> collect
    a = """<a href="javascript:sendurl('$url')" >"""
    return m[1] * a * m[2] * m[3]
end

make_html(pgins) = replace(
    html_head() * 
    html_use_purpose() *
    html_general_options() *
    # htmp_default_env_pkg() *
    html_proj_env_pkg() *
    html_plugins(pgins) *
    html_submit() *
    js_scripts() *
    html_tail(), 
    r" +\n" => "\n")
    
function make_html(pgins, file) # plugins - see file "Plugins-and-default-arguments.jl"
    # @show file
    # file = abspath(joinpath("html", file))
    # @show file
    html = make_html(pgins)
    open(file, "w") do f
        write(f, html)
    end
    return file
end

"if provided a file name without suffix, will add .html and save generated file into default directory"
function make_html(file::AbstractString=tmp_html())
    defaultpath = "html_tests"
    if endswith(file, ".html")
        f = file
    else
        f = joinpath(defaultpath, "$(file).html")
    end
    return make_html(def_plugins(), f)
end

