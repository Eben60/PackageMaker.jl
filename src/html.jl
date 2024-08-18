include("css.jl")
include("js_scripts.jl")
include("plugin_typedefs.jl")
include("html_sections.jl")
include("html_plugins.jl")

checked(b) = b ? "checked" : ""

esc_qm(s::String) = replace(s, "\""=>"&quot;", ">" => "&gt;", "<" => "&lt;", "&" => "&amp;")
esc_qm(x) = x

make_html(pgins) = rstrip(html_head() * 
    html_use_purpose() *
    html_general_options() *
    htmp_default_env_pkg() *
    html_proj_env_pkg() *
    html_plugins(pgins) *
    html_submit() *
    js_scripts() *
    html_tail(), ' ') #TODO looks like stripping doesn't work. why?

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

