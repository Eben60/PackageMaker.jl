css_styles() =
"""
<style>
.pgin_inp_col1 {
  background: hsl(226, 47%, 88%);
}
.pgin_inp_col2 {
  background: hsl(226, 45%, 95%);;
}

.pgin_inp_margins {
  padding-top: 10px;
  padding-right: 100px;
  padding-bottom: 5px;
  padding-left: 10px;
}
  
#GeneralOptions_form .pgin_inp_col1 {
  background: hsl(4, 47%, 88%);
}
#GeneralOptions_form .pgin_inp_col2 {
  background: hsl(4, 45%, 95%);;
}

.gen_opt_margins {
  padding-top: 10px;
  padding-right: 100px;
  padding-bottom: 5px;
  padding-left: 10px;
}


.plugin_form_div {
  margin: 5px 0px 5px 0px;
  padding: 20px;
  border-style: solid;
  border-width: 3px;
  border-color: rgb(107, 107, 107);
}

.comment {
  font-size: 80%;
}

h2 {
  font-family: Helvetica, Arial, sans-serif;
  color: #606060; 
}

#GeneralOptions_docstring {
  height: 7em;
}

#GeneralOptions_proj_pkg {
  height: 7em;
  width: 40ch;
  white-space: nowrap;
}

$(make_dd_css())

#GeneralOptions_form > label {
  display: none;
}

#Use_GeneralOptions {
  display: none;
}

#GeneralOptions_form div.Plugin_Purpose {
  font-weight: bold;
  font-family: sans-serif;
  font-size: 125%;
  color: #606060;
}

label[for="GeneralOptions_docstring"] {
  display: none;
}

div.plugin_form_div#plugin_form_div_Save_Configuration, #Save_Configuration_form .pgin_inp_col1, #Save_Configuration_form .pgin_inp_col2 {
  background: rgb(240, 240, 240);
}

.checkfield_OK {
  color: green;
  font-weight: bold;
}

.checkfield_NOK {
  color: rgb(247, 36, 36);
  font-weight: bold;
}

</style>
"""

make_dd_css() = """
.radio-container {
  display: none;
  position: absolute;
  margin-top: 10px;
  margin-left: 20px;
  padding: 10px;
  background-color: white;
  border: 1px solid black;
  box-shadow: 0 0 5px rgba(0, 0, 0, 0.3);
}

.activate_menu {
  font-weight: bold;
  background-color: white;
  transition: color 0.3s;
}

.activate_menu:hover {
  background-color: white;
  text-decoration: underline;
}
"""

make_dd_js_sel_lic() = """
function select_license(el) {
  var parentdiv = jQuery(el).closest("div");
  var granddad = jQuery(el).closest("div").parent().closest("div");
  var target = granddad.find(".menu_target");
  var lic = el.value;
  parentdiv.hide();
  target.val(lic);
  target.trigger("change");
};
"""

make_dd_act_menu() = """
  jQuery('.activate_menu').click(function(){
      var radiocontainer = jQuery(this).siblings('.radio-container');
      radiocontainer.show();
      var offset = jQuery(this).offset();
      radiocontainer.css({
        top: offset.top + jQuery(this).outerHeight(),
        left: offset.left
    });
  });
"""
