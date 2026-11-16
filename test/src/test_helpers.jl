using Suppressor: @suppress
using Logging: Logging, ConsoleLogger, with_logger

"""
    suppress_non_warnings(f)

Run `f()` while suppressing `stdout`, `stderr` (such as `Pkg` status output), and
`@info`/`@debug` logs, while still forwarding any `@warn` and `@error` logs to `stderr`.
"""
function suppress_non_warnings(f)
    buf = IOBuffer()
    try
        return @suppress with_logger(ConsoleLogger(buf, Logging.Warn)) do
            return f()
        end
    finally
        s = String(take!(buf))
        isempty(s) || print(stderr, s)
    end
end
