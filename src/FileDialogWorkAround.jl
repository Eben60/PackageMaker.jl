module FileDialogWorkAround

using NativeFileDialog, Dates, FilePathsBase

# https://discourse.julialang.org/t/better-handling-of-pathnames/36792/33
posixpathstring(inp) = inp |> Path |> _posixpath |> string
_posixpath(path::WindowsPath) = PosixPath((path.drive, path.segments...))
_posixpath(path) = path
posixpathstring


"Returns OS version on Mac, or v0 if other OS"
function macos_version()
    Sys.isapple() || return v"0"
    osversion = read(`sw_vers --productVersion`, String)
    return VersionNumber(osversion)
end

const BUGGY_MACOS = macos_version() >= v"15"
export BUGGY_MACOS

function pick_file(path=""; filterlist="") 
    BUGGY_MACOS || return NativeFileDialog.pick_file(path; filterlist) |> posixpathstring
    return pick_workaround(path, :pickfile; filterlist) |> posixpathstring
end
export pick_file

function pick_multi_file(path=""; filterlist="") 
    BUGGY_MACOS || return NativeFileDialog.pick_multi_file(path; filterlist) |> posixpathstring
    return pick_workaround(path, :multifile; filterlist) |> posixpathstring
end
export pick_multi_file

function pick_folder(path="") 
    BUGGY_MACOS || return NativeFileDialog.pick_folder(path) |> posixpathstring
    return pick_workaround(path, :pickfolder) |> posixpathstring
end
export pick_folder

function check_if_log_noise(s, starttime)
    s == "" && return nothing
    format = DateFormat("yyyy-mm-dd HH:MM:SS.sss")

    lognoise = length(s) >= 23 && (ss = s[1:23]; true) &&
        !isnothing(tryparse(DateTime, ss, format)) &&
        starttime <= DateTime(ss, format) <= now() && 
        occursin("osascript", s) &&
        occursin("IMKClient", s)

    lognoise || @warn "OS information, possibly irrelevant: $s"

    return nothing
end


# with multiple selections allowed

function pick_workaround(path, picktype; filterlist="")
    if picktype == :pickfile
        script_trunk = """POSIX path of (choose file with prompt "Pick a file:" """
    elseif picktype == :multifile
        script_trunk = """(choose file with prompt "Pick a file:" with multiple selections allowed """
    elseif picktype == :pickfolder
        script_trunk = """POSIX path of (choose folder with prompt "Pick a folder:" """
    else
        error("Key $picktype not supported")
    end


    startswith(filterlist, ".") && (filterlist = filterlist[2:end])
    filterlist = filterlist |> lowercase

    stderr_buffer = IOBuffer()

    if isempty(filterlist)
        filterdef = filtercall = ""
    else
        startswith(filterlist, ".") && (filterlist = filterlist[2:end])
        filterlist = filterlist |> lowercase
        filterdef = """set filetype to "$filterlist"\n"""
        filtercall = "of type filetype"
    end

    if isempty(path)
        pathdef = pathcall = ""
    else
        pathdef = """set strPath to "$path"\n"""
        pathcall = "default location strPath"
    end

    script = """$(filterdef)$(pathdef)$(script_trunk) $filtercall $pathcall)"""
    cmd = `osascript -e $script`
    flpath = ""
    warn_noise = ""
    starttime = now()
    try
        flpath = readchomp(pipeline(cmd; stderr=stderr_buffer));
        warn_noise = take!(stderr_buffer) |> String;
    catch
        flpath = ""
        warn_noise = ""
    end
    check_if_log_noise(warn_noise, starttime)
    picktype == :multifile || return flpath
    return parse_multifiles(flpath)
end

function parse_multifiles(p)
    # p = "alias MacSysdiskBen:Users:elk:Downloads:2023:tmp:Abrechnung_,31.pdf, alias MacSysdiskBen:Users:elk:Downloads:2023:tmp:Abrechnung_2,574767229.pdf, alias MacSysdiskBen:Users:elk:Downloads:2023:tmp:Abrechnung_214712029800,73.pdf"
    p1 = replace(p, ", alias " => "\nalias ")
    als = split(p1, "\n")
    for (i, al) in pairs(als)
        startswith(al, "alias ") || error("cannot parse $al")
        als[i] = al[7:end]
    end
    return alias2posix.(als)
end

function alias2posix(fl)
    script = """POSIX path of "$fl" """ 
    cmd = `osascript -e $(script)`
    return readchomp(cmd)
end

end # module FileDialogWorkAround
