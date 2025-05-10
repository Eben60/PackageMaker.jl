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

html_submit() = 
"""
<div id="submit_div">
<form class="submit_form" name="submit_form" id="submit_form" action="javascript:void(0)">
<br>
<span class="checkfield_NOK" id="checkfield_ProjName">🞫</span>&nbsp;Project name OK <br>
<span class="checkfield_NOK" id="checkfield_ProjDir">🞫</span>&nbsp;Project directory OK <br>
<span class="checkfield_OK" id="checkfield_SaveConfig">✓</span>&nbsp;"Manage Configuration" checkbox unselected (if desired, save config prior to creating project)<br><br>
<button type="submit" id="subm0" value="Cancel_0" onclick="subm('finalinputcancelled', false)">Cancel</button>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
<button type="submit" id="subm2" value="Reload_3" onclick="reload_window()" >Reset form</button>
&nbsp; &nbsp; &nbsp; &nbsp; &nbsp;
<button type="submit" id="subm1" value="Submit_1" onclick="subm('finalinputfinished', 'finalinput')" disabled>Create package</button>
</form>
</div>
"""

function html_configs()
    isempty(savedconfigs) && return ""
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