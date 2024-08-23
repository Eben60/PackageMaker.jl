function handleinput(win, el::HtmlElem)
    
    el.parentformid == :use_purpose_form && return handle_purpose(win, el)

    return nothing

end

function showhidepgin(win, pgin_name, show=true) 
    divid="$(pgin_name)_inputs"
    checkid = "Use_$(pgin_name)"
    checkelem(win, checkid, show)
    showhide(win, divid, show) 
end

function handle_purpose(win, el) 
    pgins_to_show = pgins_sets[el.value]
    for (pgname, v) in pgins_to_show
        showhidepgin(win, pgname, v)
    end
    return nothing
end