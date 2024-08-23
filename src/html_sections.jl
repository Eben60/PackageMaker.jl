html_head(title = "Initialize Julia Project/Package") = 
"""
<!DOCTYPE html>
<html lang="">
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    $(css_styles())
    <title>$(title)</title>
  </head>
  <body>
  <h2>Setting up a Julia Project or Package</h2>
  <p class="comment">This is mostly a GUI for the Julia package <a href="https://juliaci.github.io/PkgTemplates.jl/stable/" target="_blank">PkgTemplates</a><br>
  here place for some explanations about environments</p>

"""

html_tail() =
"""
</body>
</html>
"""

html_use_purpose() = 
"""
<div  id="use_purpose_div">
<form class="use_purpose_form" name="use_purpose_form" id="use_purpose_form" action="javascript:void(0)">
    <fieldset id="use_purpose_fieldset"> 
    <legend>What do you want to do? </legend>
      <div id="use_purpose_inputs_div"> 
        <input id="Project_Choice" name="Choice" value="Project" onchange="oncng(this)" type="radio"> 
        <label for="Project_Choice">Initialize a Julia project</label><br>
        <input id="LocalPackage_Choice" name="Choice" value="LocalPackage" onchange="oncng(this)" type="radio" checked> 
        <label for="LocalPackage_Choice">Initialize a package for local use</label> <br>
        <input id="RegisteredPackage_Choice" name="Choice" value="RegisteredPackage" onchange="oncng(this)" type="radio"> 
        <label for="RegisteredPackage_Choice">Initialize a package with all CI bells and Documentation whistles </label> 
       </div>
       <p class="comment"> Depending on your choice, a different set of options will be selected, which you however can override manually</p>
    </fieldset>
</form>
</div>

"""

function html_general_options()
    i = 1
    function onetwo() 
        i += 1
        return (i%2+1)
    end

    h =    
"""
<div id="general_options_div">
<h2>General options</h2>
<form class="general_options_form" name="general_options_form" id="general_options_form" action="javascript:void(0)">
    <div class="pgin_inp_margins gen_opt_col$(onetwo())">
        <input size="70" id="proj_name" name="proj_name" value="" onchange="oncng(this)" type="text"><br>
        <span class="plugin_arg_meaning" id="argmeaning_proj_name">Project/Package name. Required input.</span><br>
    </div>

    <div class="pgin_inp_margins gen_opt_col$(onetwo())">
        <input size="70" id="user_name" name="user_name" value="$(githubuser())" onchange="oncng(this)" type="text"><br>
        <span class="plugin_arg_meaning" id="argmeaning_user_name">User name. Required for many plugins.</span><br>
    </div>

    <div class="pgin_inp_margins gen_opt_col$(onetwo())">
        <input size="70" id="authors" name="authors" value="$(username()) <$(usermail())>" onchange="oncng(this)" type="text"><br>
        <span class="plugin_arg_meaning" id="argmeaning_authors">Authors. Will be an entry in <code>Project.toml</code>. </span><br>
    </div>
    
    <div class="pgin_inp_margins gen_opt_col$(onetwo())">
        <input size="65" id="project_dir" name="project_dir" value="" onchange="oncng(this)" type="text">
        <button id="project_dir_button" onclick="oncng(this)" type="button" class="FolderDialogButton">Select</button><br>
        <span class="plugin_arg_meaning" id="argmeaning_project_dir">Directory to place project in. Required input.</span><br>
    </div>

    <div class="pgin_inp_margins gen_opt_col$(onetwo())">
        <input size="70" id="host" name="host" value="github.com" onchange="oncng(this)" type="text"><br>
        <span class="plugin_arg_meaning" id="argmeaning_host">URL to the code hosting service where the project will reside.</span><br>
    </div>
    
    <div class="pgin_inp_margins gen_opt_col$(onetwo())">
        <input size="70" id="julia_min_version" name="julia_min_version" value="v&quot;1.6&quot;" onchange="oncng(this)" type="text"><br>
        <span class="plugin_arg_meaning" id="argmeaning_julia_min_version">Minimum allowed Julia version for this package.</span><br>
    </div>

</form>   
</div>

"""
    return h
end

function default_env_checkbox(no, pkg_name; 
    installed = default_env_packages())
    checked = pkg_name in installed ? "checked" : ""

cb = """
    <input id="defpkg$no" value="$pkg_name" $checked onchange="oncng(this)"
    type="checkbox"> <label for="defpkg$no">$pkg_name</label><br>
"""
    return cb
end

function htmp_default_env_pkg()
    installed = default_env_packages()
    available = addable_default_packages() 
    dp = vcat(installed, available)
    checkboxes = join([default_env_checkbox(no, pkg_name; installed) for (no, pkg_name) in pairs(dp)])
    htm = """
<div id="default_env_div">
<h2>What packages to add to / uninstall from your default environment?</h2>
  <p class="comment">The packages installed into the default environment are always available. 
  It is however recommended to keep them at minimum to keep out of 
  <a href="https://en.wikipedia.org/wiki/Dependency_hell" target="_blank">"Dependency Hell"</a>.
  Though we list some commonly used packages, don't see it as recommendation to check the box. 
  Keep in mind that e.g. plotting packages come with a lot of dependencies which may later conflict 
  with some packages in your projects. 
  </p>
  <p class="comment">Initially, packages already installed there are shown ckecked.</p>
  <form name="default_packages" id="deflt_pkg" action="javascript:void(0)">
$checkboxes
  </form>
</div>
"""

    return htm
end

html_proj_env_pkg() = 
"""
<div id="project_env_div">
<h2>What packages to add to your project?</h2>
<p class="comment">you can of course always add packages later on by using <code>Pkg</code></p>
  <form name="project_packages" id="proj_pkg" action="javascript:void(0)">
    <textarea id="project_packages_input" name="project_packages_input" rows="6" cols="40" onchange="oncng(this)" > </textarea> <br>
    <label for="project_packages_input">Put each package name onto a newline</label>
  </form>
</div>

"""

html_submit() = 
"""
<div id="submit_div">
<form class="submit_form" name="submit_form" id="submit_form" action="javascript:void(0)">
<input id="save_defaults" value="save_defaults" onchange="oncng(this)" type="checkbox">
<label for="save_defaults" >Save choices as default if applicable</label><br>
<button type="submit" id="subm0" value="Cancel_0" onclick="sendfullstate(true)">Cancel</button> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
<button type="submit" id="subm1" value="Submit_1" onclick="sendfullstate(true)">Submit</button>
</form>
</div>
"""

