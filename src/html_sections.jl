html_head(title = "Create Julia Project/Package") = 
"""
<!DOCTYPE html>
<html>
  <head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8">
    $(css_styles())
    <title>$(title)</title>
  </head>
  <body>

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
    </fieldset>
</form>
</div>

"""

html_general_options() = 
"""
<div id="general_options_div">
<h2>General options (to be completed)</h2>        
</div>

"""

htmp_default_env_pkg() = 
"""
<div id="default_env_div">
<h2>What packages to install into your default environment?</h2>
  <form name="default_packages" id="deflt_pkg" action="javascript:void(0)">
    <input id="defpkg1" value="Revise" checked="checked" onchange="oncng(this)"
      type="checkbox"> <label for="defpkg1">Revise</label><br>
    <input id="defpkg2" value="Test" checked="checked" onchange="oncng(this)"
      type="checkbox"> <label for="defpkg2">Test</label><br>
    <input id="defpkg3" value="BenchmarkTools" checked="checked" onchange="oncng(this)"
      type="checkbox"> <label for="defpkg3">BenchmarkTools</label><br>
    <input id="defpkg4" value="Plots" checked="checked" onchange="oncng(this)"
      type="checkbox"> <label for="defpkg4">Plots</label><br>
    <input id="defpkg5" value="Dates" onchange="oncng(this)" type="checkbox">
    <label for="defpkg5">Dates</label><br>
    <input id="defpkg6" value="Unitful" onchange="oncng(this)" type="checkbox">
    <label for="defpkg6">Unitful</label><br>
    <input id="defpkg7" value="DataFrames" onchange="oncng(this)" type="checkbox">
    <label for="defpkg7">DataFrames</label><br>
    <input id="defpkg8" value="CSV" onchange="oncng(this)" type="checkbox">
    <label for="defpkg8">CSV</label><br>
    <input id="defpkg9" value="Makie" onchange="oncng(this)" type="checkbox">
    <label for="defpkg9">Makie</label><br>
    <input id="defpkg10" value="FileIO" onchange="oncng(this)" type="checkbox">
    <label for="defpkg10">FileIO</label><br>
    <input id="defpkg11" value="OhMyREPL" onchange="oncng(this)" type="checkbox">
    <label for="defpkg11">OhMyREPL</label><br>
  </form>
</div>

"""

html_proj_env_pkg() = 
"""
<div id="project_env_div">
<h2>What packages to add to your project?</h2>
<p class="comment">you can of course always add packages later on using <code>Pkg</code></p>
  <form name="project_packages" id="proj_pkg" action="javascript:void(0)">
    <input size="50" id="proj_pkg_1" name="project_package" value="" type="text"><br>
    <input size="50" id="proj_pkg_2" name="project_package" value="" type="text"><br>
    <input size="50" id="proj_pkg_3" name="project_package" value="" type="text">
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

