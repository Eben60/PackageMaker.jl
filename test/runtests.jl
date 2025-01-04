using Test
# include("test_processvals.jl")

@testset "dropdown_menus" begin
    parentname = "parent"
    fieldname = "fieldname"
    options = ["MIT", "AGPL-3.0+", "ASL"]

    lbl = make_dd_label(parentname, fieldname, options)
    lbl2 = """<label><input type="radio" name="option" value="AGPL-3.0+" id="parent_fieldname_2" onchange="select_license(this)">AGPL-3.0+</label><br>"""

    @test lbl[2] == lbl2
    @test length(lbl) == 3

    mn = """
    <div class="menu_container" id="parent_fieldname_menu">
    <input size="30" id="parent_fieldname_menu" name="fieldname" class="menu_target" value="MIT" onchange="alert('value changed');oncng(this)" type="text"> <span class="activate_menu" id="parent_activate_menu">Show/hide licenses</span>  <br>
    <div class="radio-container" id="parent_radio_container">
<label><input type="radio" name="option" value="MIT" id="parent_fieldname_1" onchange="select_license(this)">MIT</label><br>
<label><input type="radio" name="option" value="AGPL-3.0+" id="parent_fieldname_2" onchange="select_license(this)">AGPL-3.0+</label><br>
<label><input type="radio" name="option" value="ASL" id="parent_fieldname_3" onchange="select_license(this)">ASL</label><br>
    </div>
  </div>
"""
    @test make_dd_menu(parentname, fieldname, options) == mn

end
;
