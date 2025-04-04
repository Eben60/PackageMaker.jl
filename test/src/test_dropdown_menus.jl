module TestDropdownMenus

using Test
using PackageMaker: make_dd_label, make_dd_menu

lbl2 = """<label><input type="radio" name="option" value="AGPL-3.0+" id="parent_fieldname_2" onchange="select_license(this)">AGPL-3.0+</label><br>"""
mn = "    <div class=\"menu_container\" id=\"parent_fieldname_menu\">\n    <input size=\"30\" id=\"parent_fieldname\" name=\"fieldname\" class=\"menu_target\" value=\"MIT\" onchange=\"oncng(this)\" type=\"text\"> \n    <span class=\"activate_menu\" id=\"parent_activate_menu\" >Show options</span>  <br>\n    <div class=\"radio-container\" id=\"parent_radio_container\">\n<label><input type=\"radio\" name=\"option\" value=\"MIT\" id=\"parent_fieldname_1\" onchange=\"select_license(this)\">MIT</label><br>\n<label><input type=\"radio\" name=\"option\" value=\"AGPL-3.0+\" id=\"parent_fieldname_2\" onchange=\"select_license(this)\">AGPL-3.0+</label><br>\n<label><input type=\"radio\" name=\"option\" value=\"ASL\" id=\"parent_fieldname_3\" onchange=\"select_license(this)\">ASL</label><br>\n    </div>\n  </div>\n"

@testset "dropdown_menus" begin
    parentname = "parent"
    fieldname = "fieldname"
    opt_list = ["MIT", "AGPL-3.0+", "ASL"]
    options = (; opt_list, show_first=true)
    menulabel = "Show options"
    show_first = true
    pa = (;name=fieldname, options=(; menuoptions=(; opt_list, menulabel, show_first)))

    lbl = make_dd_label(parentname, fieldname, opt_list)
 
    @test lbl[2] == lbl2
    @test length(lbl) == 3

    @test make_dd_menu(parentname, pa) == mn

end # testset
end # module