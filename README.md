# StartYourPk

GUI for [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl): "Creating new Julia packages, the easy way" - made a bit simpler.

This package allows you to create either a new package or a new project. The package is not finished: there are still some features missing, and it was not properly tested yet. However it appears to do what it's intended to. 

Try it out! _(on your own risk)_

## Installation

The package is not yet registered, therefore install it from GitHub as below. It is recommended to install this package into a separate shared environment, e.g. one named `@StartYourPk`. 

```julia
julia> ]
(@v1.11) pkg> activate @StartYourPk
  Activating new project at `~/.julia/environments/StartYourPk`

(@StartYourPk) pkg> add https://github.com/Eben60/StartYourPk.jl
```

## Usage

```julia
julia> ]
(@v1.11) pkg> activate @StartYourPk

julia> using StartYourPk

julia> startyourpk()
```

Then fill out the GUI form and press "Submit". The project/package will be created. 

By default the function `startyourpk()` will exit Julia after it is finished. If such behavior is undesirable, call it like `startyourpk(false)`
