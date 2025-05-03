# from PkgSkeleton.jl

# TODO consider switching to Git.jl

username() = getgitopt("user.name", "your name (as the package author)")
githubuser() = getgitopt("github.user", "your Github username")
usermail() = getgitopt("user.email", "your e-mail (as the package author)")

function getgitopt(opt, used_for)
    c = nothing
    try
        c = LibGit2.GitConfig(LibGit2.GitRepo(pkgdir(@__MODULE__))) # get local config, if it exists. in most cases, it wouldn't, then fallback to the global one
    catch e
        if e isa LibGit2.GitError # if local repo not configured
            c = LibGit2.GitConfig()
        else
            rethrow(e)
        end
    end

    try
        LibGit2.get(AbstractString, c, opt)
    catch e
        # if e isa LibGit2.GitError # assume it is not found
        #     throw(GitOptionNotFound(opt, used_for))
        # else
        #     rethrow(e)
        # end
        warn_git_notconfigured(e)
        return ""
    end
end

function warn_git_notconfigured(e) # e::GitOptionNotFound
    get(ENV, "CI", nothing) == "true" && return nothing
    
    @warn """
Could not find option “$(e.option)” in your global git configuration.

It is necessary to set this for $(e.used_for).

You can set this in the command line with

git config --global $(e.option) "…"
""" maxlog=3
    
    return nothing
end

"""
Error type for git options not found in the global environment. Reporting with helpful error
message to the user.
"""
struct GitOptionNotFound <: Exception
    "The name for the option."
    option::String
    "What the option is used for (for the error message)."
    used_for::String
end

function Base.showerror(io::IO, e::GitOptionNotFound)
    print(io, """
    Could not find option “$(e.option)” in your global git configuration.

    It is necessary to set this for $(e.used_for).

    You can set this in the command line with

    git config --global $(e.option) "…"
    """)
end

"Checks if GitHub CLI is installed and authenticated"
function gh_installed()
    try
        isnothing(Sys.which("gh")) && return false

        stdout_buffer = IOBuffer()
        cmd = Cmd(`gh auth status`)
        rslt = run(pipeline(cmd; stdout=stdout_buffer); wait=false)
        wait(rslt)
        rslt.exitcode != 0 && return false 

        seek(stdout_buffer, 0)
        result = readlines(stdout_buffer)
        return any(x -> occursin("Active account: true", x), result)
    catch
        return false
    end
end