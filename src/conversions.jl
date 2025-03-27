function parse_v_string(s)
    s1 = replace(s, "\"" => "")
    s1 = strip(s1)
    v = tryparse(VersionNumber, s1)
    isnothing(v) && error("$s doesn't look like a valid version string")
    return v
end

function tidystring(s; remove_empty_lines=true)
    vs = [strip(line) for line in readlines(IOBuffer(s))]
    remove_empty_lines && filter!(x -> !isempty(x), vs)
    return join(vs, "\n") |> String
end

# conv(::Symbol, s::AbstractString) 
conv(::Type{Val{:file}}, s) = strip(s) 
conv(::Type{Val{:dir}}, s) = strip(s)
conv(::Type{Val{:menu}}, s) = strip(s) 
conv(::Type{Val{:button}}, s) = strip(s) 

conv(::Type{Vector{S}}, val) where S <: AbstractString = split(val, "\n")

function conv(pa::PluginArg, val)
    s = tidystring(val)
    s == "nothing" && return nothing
    pa.type isa Symbol && return conv(Val{pa.type}, s)
    pa.type <: Number && return parse(pa.type, s)
    pa.type <: VersionNumber && return parse_v_string(s)
    pa.type <: AbstractString && return s
    pa.type <: Vector{S} where S <: AbstractString && return conv(pa.type, s)
    error("unsupported type $(pa.type)")
end

function conv(::Type{Val{:ExcludedPlugins}}, v::Vector{<:AbstractString})
    ks = v .|> strip
    filter!(x -> !isempty(x), ks)
    ks = Symbol.(ks)
    return NamedTuple(k => false for k in ks)
end

conv(t::Type{Val{:ExcludedPlugins}}, s::AbstractString) = conv(t, split(s, "\n") )

function split_pkg_list(x)
    x = tidystring(x)
    isempty(x) && return String[]
    v = split(x |> tidystring, "\n") 
    jl_re = r"(?i)\.jl$"
    v = replace.(v, jl_re => "")
    return v
end

function type2str(x)
    t = x |>typeof |> Symbol |> String
    occursin(".", t) || return t
    re=r".*\.(.+)"
    return match(re, t)[1]
end