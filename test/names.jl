using PackageMaker
ns = filter(x -> !(String(x)[1] == '#'), names(PackageMaker; all=true))

ns = filter(x -> (isdefined(PackageMaker, x) && (getfield(PackageMaker, x) isa Function)), ns)

for n in ns
    println(n)
end

"""
@unsafe
_gogui
add_dependencies
add_docstring
cache_fv
check_packages # tested
checked
checkelem
checkonload
cleanup
conv # tested
create_proj
css_styles
current_val
default_env_checkbox
depackagize
disableinputelem
disp_style
esc_qm
eval
extract_docslink
general_options
get_base_path
get_checked_pgins!
get_def_path
get_file_inp_id
get_licences
get_module_directory
get_pgin_vals!
get_pgins_vals!
getelemval
getforminputs
getgitopt
githubuser
gogui
handle_purpose
handlechangeevents
handlefinalinput
handleinit_input
handleinput
html_dir
html_general_options
html_head
html_plugins
html_proj_env_pkg
html_submit
html_tail
html_use_purpose
htmp_default_env_pkg
include
init_documenter
initcontents
initialized_pgins
initwin
insert_url
is_a_package
is_in_registry # tested
is_known_pkg # tested
ischecked
jldcache
js_scripts
mainwin
make_dd_act_menu
make_dd_css
make_dd_js_sel_lic
make_dd_label
make_dd_menu
make_docstring
make_html
openurl
parse_v_string # tested
pgin_and_field
pgin_form
pgin_inputs
pgin_kwargs
pluginarg_od
recall_fv
set_file_from_dialog
setelemval
showhide
showhidepgin
split_pkg_list # tested
startyourpk # redundant
stdlib_packages # tested
tmp_html
tmpl_beg
tmpl_end
tmpl_inp
tmpl_input_arrfield
tmpl_input_field
tmpl_path_input_field
tmpl_section_beg
tmpl_section_end
type2str # tested
update_struct
usermail
username
vec2string
wait_until_finished
"""