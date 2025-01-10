module JLD2Ext

using JLD2
using PackageMaker
import PackageMaker: recall_fv, jldcache, cache_fv

"Loads saved set of values as returned by `_gogui()`. Can be used for debug and testing"
recall_fv() = load_object(jldcache())

"Saves set of values as returned by `_gogui()`. Can be used for debug and testing"
cache_fv(fv) = jldsave(jldcache(); fv)

end
