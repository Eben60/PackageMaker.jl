
function make_dd_menu(parentname, pa)
    fieldname = pa.name
    (; opt_list, show_first, menulabel) = pa.options.menuoptions
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
    <span class="activate_menu" id="$(activatemenuid)" $(disp_span)>$(menulabel)</span>  <br>
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
