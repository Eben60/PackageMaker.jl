# StartYourPk

GUI for [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl): "Creating new Julia packages, the easy way" - made a bit simpler.

This package allows you to create either a new package or a new project. The package is not finished: there are still some features missing, and it had only limited testing. However it appears to do what it's intended to. 

Try it out! 

Current project state (as of `v0.0.9`)
- MacOS (ARM), `Julia v1.11, v1.10` - it is where I develop it, thus somewhat more extensive (on `Julia v1.11`) testing . Currently no problems detected.
- Ubuntu (Intel "AMD64"), `Julia v1.11` - run once, no problems.
- Win10 `Julia v1.11` - the problems with windows paths (up to `v0.0.5`) now appear to be solved: The package can be now used on Windows,too.

## Installation

The package is not yet registered, therefore install it from GitHub as below. It is recommended to install this package into a separate shared environment, e.g. one named `@StartYourPk`. 

```julia
julia> ]
(@v1.11) pkg> activate @StartYourPk
  Activating new project at `~/.julia/environments/StartYourPk`

(@StartYourPk) pkg> add https://github.com/Eben60/StartYourPk.jl#master
```

Before you start, make sure that you set up global `user.name`, `user.email`, and (in case you will use GitHub plugins) `github.user` in `git`.

## Usage

```julia
julia> ]
(@v1.11) pkg> activate @StartYourPk

julia> using StartYourPk

julia> startyourpk()
```

Then fill out the GUI form and press "Submit". The project/package will be created. 

By default the function `startyourpk()` will exit Julia after it is finished. If such behavior is undesirable, call it as `startyourpk(false)`
