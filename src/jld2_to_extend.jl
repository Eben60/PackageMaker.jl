jldcache() = joinpath(dirname(@__DIR__), "data", "valscache.jld2")

# to be used with extension JLD2Ext

function recall_fv end
# = error("You need first to manually load JLD2 to use function `recall_fv`")

function cache_fv end
# = error("You need first to manually load JLD2 to use function `recall_fv`")
