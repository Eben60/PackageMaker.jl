module UnusedReference
struct HtmlElem
    id::Symbol
    eltype::Symbol
    inputtype::Symbol
    parentformid::Symbol
    value::Union{String, Float64}
    checked::Union{Bool, Nothing}
end
end # module


function handleinput(win, el::HtmlElem)
    
    el.parentformid == :use_purpose_form && return handle_purpose(win, el)

    return nothing

end

function handle_purpose(win, el) 
    pgins_to_show = pgins_sets[el.value]
    for (k, v) in pgins_to_show
        @show k, v
    end
    id="Tests_inputs"
    showhide(win, id, false) 
    return nothing
end