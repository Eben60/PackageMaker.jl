using Test
using PackageMaker
using PackageMaker: make_html, html_configs, initialize

initialize()
temp_dir = mktempdir(; cleanup=false)
html_test_file = joinpath(temp_dir, "test.html")
isfile(html_test_file) && rm(html_test_file)
this_file_dir = dirname(@__FILE__)
html_standard_file = joinpath(this_file_dir, "mainwin_v1_1_1.html")
make_html(html_test_file)


@testset "HTML generation" begin
    @test isfile(html_standard_file)
    @test isfile(html_test_file)
    html_standard = read(html_standard_file, String)
    html_test = read(html_test_file, String)

    start_sec = """(.*)Depending on your choice, a different set of options will be selected, which you however can override manually.</p>"""
    re_start = Regex(start_sec, "s")

    start_stand = match(re_start, html_standard)
    start_test = match(re_start, html_test)
    @test !isnothing(start_stand) && !isnothing(start_test) && start_stand.captures[1] == start_test.captures[1]
    
    
    # middle_sec = """<div  id="tmpl_section_div">(.*)<div class="plugin_form_div" id="plugin_form_div_Save_Configuration">"""
    # middle_sec = """<div  id="tmpl_section_div">(.*)<div class="plugin_form_div" id="plugin_form_div_License">"""
    # middle_sec = """<div class="plugin_form_div" id="plugin_form_div_Readme">(.*)<div class="plugin_form_div" id="plugin_form_div_License">""" #line 298-324 OK
    # middle_sec = """<div class="plugin_form_div" id="plugin_form_div_Readme">(.*)<label for="Use_Save_Configuration">Save Configuration  </label>""" #line 298-646 OK
    # middle_sec = """<div class="plugin_form_div" id="plugin_form_div_ProjectFile">(.*)<label for="Use_Save_Configuration">Save Configuration  </label>""" #line 230-646 OK
    # middle_sec = """<h2>Options and Plugins</h2>(.*)<label for="Use_Save_Configuration">Save Configuration  </label>""" #line 150-646 :(
    middle_sec = """<span class="plugin_arg_meaning" id="argmeaning_GeneralOptions_julia_min_version">(.*)<label for="Use_Save_Configuration">Save Configuration  </label>""" #line 203-646
    re_middle = Regex(middle_sec, "s")

    middle_stand = match(re_middle, html_standard)
    middle_test = match(re_middle, html_test)
    @test !isnothing(middle_stand) 
    @test !isnothing(middle_test) 
    @test !isnothing(middle_stand) && !isnothing(middle_test) && middle_stand.captures[1] == middle_test.captures[1]

    end_sec = """<span class="plugin_arg_meaning" id="argmeaning_Save_Configuration_config_name">(.*)"""
    re_end = Regex(end_sec, "s")

    end_stand = match(re_end, html_standard)
    end_test = match(re_end, html_test)
    @test !isnothing(end_stand) && !isnothing(end_test) && end_stand.captures[1] == end_test.captures[1]

    # write("tmp_processed.html", html_test)
    # write("tmp_standard.html", html_standard)

    # @test (html_standard == html_test) == true
    
    #@show html_test_file

end