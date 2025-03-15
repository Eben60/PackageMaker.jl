html_head(title = "PackageMaker: Initialize Julia Project/Package") = 
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
  <p class="comment"><a href="javascript:sendurl('https://github.com/Eben60/PackageMaker.jl')">PackageMaker</a> is mostly a GUI for the Julia package <a href="javascript:sendurl('https://juliaci.github.io/PkgTemplates.jl')">PkgTemplates</a><br>
  <!-- more explanations here? -->
  </p>

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
        <label for="RegisteredPackage_Choice">Initialize a package with more CI bells and a Documentation whistle. 
        If you plan to register the package later on, check 
        <a href="javascript:sendurl('https://juliaregistries.github.io/RegistryCI.jl/stable/guidelines/')" >
        Registration Guidelines</a> esp. relating to package naming. </label> 
       </div>
       <p class="comment"> Depending on your choice, a different set of options will be selected, which you however can override manually.</p>
       $(html_configs())
    </fieldset>
</form>
</div>

"""

general_inputs() = pgin_inputs(def_plugins["GeneralOptions"],  "gen_opt", false)


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
$(general_inputs())
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
  <a href="javascript:sendurl('https://en.wikipedia.org/wiki/Dependency_hell')" >
  "Dependency Hell"</a>.
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
    <textarea id="project_packages_input" name="project_packages_input" rows="6" cols="40" onchange="oncng(this)" ></textarea> <br>
    <label for="project_packages_input">Put each package name onto a newline. Suffix <code>.jl</code> is accepted, but not required. </label>
  </form>
</div>

"""

html_submit() = 
"""
<div id="submit_div">
<form class="submit_form" name="submit_form" id="submit_form" action="javascript:void(0)">
<button type="submit" id="subm0" value="Cancel_0" onclick="sendfullstate(true, false)">Cancel</button> &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; 
<button type="submit" id="subm1" value="Submit_1" onclick="sendfullstate(true, true)">Submit</button>
</form>
</div>
"""

function html_configs()
    isnothing(SAVEDCONFIGS) && return ""
    cfarr = String[]
    for (i, cn) in savedconfignames() |> pairs
        cftag = "SavedConfigTag_$i"
        cfsec = 
"""
    <input id="$(cftag)" name="Choice" value="$(cftag)" onchange="oncng(this)" type="radio">
    <label for="$(cftag)">$(cn)</label><br>
"""
        push!(cfarr, cfsec)
    end
    confsections = join(cfarr, "\n")
    htm = 
"""
    <p>Saved configurations:</p>
$(confsections)"""
    return htm

end