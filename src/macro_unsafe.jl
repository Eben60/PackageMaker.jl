module MacroUnsafe

using Blink, Blink.AtomShell
using Sockets: @ip_str

using Blink.AtomShell: port, inspector, try_connect, electron, initcbs, mainjs

"""
    @unsafe

A workaround for an upstream bug on Ubuntu 24. It disables sandboxing in Electron. 
Run this macro before calling `gogui()`.

The recommended way of using PackageMaker on Ubuntu 24 is however to use from VSCode, as 
in this case it works OK without calling `@unsafe`

# Examples
```julia-repl
julia> @unsafe;
julia> gogui()
``` 
"""
macro unsafe() # https://github.com/JuliaGizmos/Blink.jl/issues/325#issuecomment-2252670794
    return quote
        function Blink.AtomShell.init(; debug = false)
            electron() # Check path exists
            p, dp = port(), port()
            debug && inspector(dp)
            dbg = debug ? "--debug=$dp" : []
            proc = (debug ? run_rdr : run)(
                `$(electron()) --no-sandbox $dbg $mainjs port $p`; wait=false)
            conn = try_connect(ip"127.0.0.1", p)
            shell = Electron(proc, conn)
            initcbs(shell)
            return shell
        end
    end
end
export @unsafe

end