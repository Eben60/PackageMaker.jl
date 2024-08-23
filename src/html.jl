checked(b) = b ? "checked" : ""

esc_qm(s::String) = replace(s, "\""=>"&quot;", ">" => "&gt;", "<" => "&lt;", "&" => "&amp;")
esc_qm(x) = x

make_html(pgins) = replace(
    html_head() * 
    html_use_purpose() *
    html_general_options() *
    htmp_default_env_pkg() *
    html_proj_env_pkg() *
    html_plugins(pgins) *
    html_submit() *
    js_scripts() *
    html_tail(), 
    r" +\n" => "\n")
    
function make_html(pgins, file) # plugins - see file "Plugins-and-default-arguments.jl"
    file = abspath(joinpath("html", file))
    html = make_html(pgins)
    open(file, "w") do f
        write(f, html)
    end
    return file
end

make_html(file::AbstractString) = make_html(def_plugins, file)
# make_html("mw28a.html")

export make_html

