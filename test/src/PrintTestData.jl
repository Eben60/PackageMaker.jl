module PrintTestData

using PackageMaker: HtmlElem

print_fv(fv) = print_fv(stdout, fv,)

function print_fv(io, fv)
    ks = keys(fv) |> collect |> sort!

    println(io, "fv = Dict{Symbol, HtmlElem}(")
    for k in ks
        v = fv[k]
        println(io, "    :$k => $v,")
    end
    println(io, "    )")
end

function print_fv(fl::AbstractString, fv)
    open(fl, "w") do io
        print_fv(io, fv)
    end
end

end # module

print_fv = PrintTestData.print_fv