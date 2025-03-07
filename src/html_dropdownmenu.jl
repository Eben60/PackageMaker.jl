

function make_dd_menu(parentname, fieldname, options, menutext="Show options")
    (; opt_list, show_first) = options
    labels = make_dd_label(parentname, fieldname, opt_list)
    outerdiv_id = "$(parentname)_$(fieldname)_menu"
    inputid = "$(parentname)_$(fieldname)"
    activatemenuid = "$(parentname)_activate_menu"
    menucontainerid = "$(parentname)_radio_container"
    default_opt = show_first ? (opt_list[1] |> esc_qm) : ""
    labels_str = join(labels, "\n")

    disp_span = isempty(opt_list) ? """style="display:none" """ : ""

    templ = """
    <div class="menu_container" id="$outerdiv_id">
    <input size="30" id="$(inputid)" name="$(fieldname)" class="menu_target" value="$(default_opt)" onchange="oncng(this)" type="text"> 
    <span class="activate_menu" id="$(activatemenuid)" $(disp_span)>$(menutext)</span>  <br>
    <div class="radio-container" id="$(menucontainerid)">
$(labels_str)
    </div>
  </div>
"""

    return templ
end

function make_dd_label(parentname, fieldname, opt_list)
    labels = String[]
    idtempl = parentname * "_" * fieldname

    for (i, o ) in pairs(opt_list)
        id = "$(idtempl)_$i"
        nm = id
        value = o

        label =
        """
        <label><input type="radio" name="option" value="$value" id="$id" onchange="select_license(this)">$value</label><br>"""
        push!(labels, label)
    end

    return labels
end

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