include("css.jl")
include("js_scripts.jl")
include("html_sections.jl")
include("html_plugins.jl")

checked(show) = show ? "checked" : ""

esc_qm(s::String) = replace(s, "\""=>"&quot;")
esc_qm(x) = x

make_html(pgins) = html_head() * 
    # css_styles() * 
    html_use_purpose() *
    html_general_options() *
    htmp_default_env_pkg() *
    html_proj_env_pkg() *
    html_plugins(pgins) *
    html_submit() *
    js_scripts() *
    html_tail()

# function write_html(pgins, file)
#     file = abspath(joinpath("html", file))
#     html = make_html(pgins)
#     open(file, "w") do f
#         write(f, html)
#     end
#     return file
# end

# make_html(pgins, file) = write_html(pgins, file)

function make_html(pgins, file)
    file = abspath(joinpath("html", file))
    html = make_html(pgins)
    open(file, "w") do f
        write(f, html)
    end
    return file
end


export make_html, write_html

