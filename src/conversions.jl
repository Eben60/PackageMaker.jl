"specialized input types, but otherwise just String"
StrInp = Union{Type{Val{:file}}, Type{Val{:dir}}, Type{Val{:menu}}, Type{Val{:button}}, Type{Val{:text}}, } 

conv(::StrInp, s) = s |> strip

conv(::Type{Vector{S}}, val) where S <: AbstractString = split(val, "\n")

function conv(pa::PluginArg, val)
    conv2array = (pa.type ∈ (Vector{String}, :ExcludedPlugins))
    s = tidystring(val; conv2array)
    s == "nothing" && return nothing
    pa.type isa Symbol && return conv(Val{pa.type}, s)
    pa.type <: Number && return parse(pa.type, s)
    pa.type <: VersionNumber && return parse_v_string(s)
    pa.type <: AbstractString && return s
    pa.type <: Vector{S} where S <: AbstractString && return conv(pa.type, s)
    error("unsupported type $(pa.type)")
end

conv(t::Type{Val{:ExcludedPlugins}}, s::AbstractString) = conv(t, split(s, "\n") )

function conv(::Type{Val{:ExcludedPlugins}}, v::Vector{<:AbstractString})
    ks = v .|> strip
    filter!(x -> !isempty(x), ks)
    ks = Symbol.(ks)
    return NamedTuple(k => false for k in ks)
end

function parse_v_string(s)
    s1 = replace(s, "\"" => "")
    s1 = strip(s1)
    v = tryparse(VersionNumber, s1)
    isnothing(v) && error("$s doesn't look like a valid version string")
    return v
end

function tidystring(s; conv2array=true)
    re = r"(?<!\\)," # enables to escape comma if somebody need that
    conv2array && (s = replace(s, re => "\n"))

    vs = [strip(line) for line in readlines(IOBuffer(s))]
    conv2array && filter!(x -> !isempty(x), vs)
    return join(vs, "\n") |> String
end

function split_pkg_list(x)
    x = tidystring(x)
    isempty(x) && return String[]
    v = split(x, "\n") 
    jl_re = r"(?i)\.jl$"
    using_re = r"^(using)|(import)[ \t]+"
    v = replace.(v, jl_re => "", using_re => "") .|> strip .|> String
    return v
end

function type2str(x)
    t = x |>typeof |> Symbol |> String
    occursin(".", t) || return t
    re=r".*\.(.+)"
    return match(re, t)[1]
end

multiline2csv(s) = join(split(s |> tidystring, "\n"), ", ")
