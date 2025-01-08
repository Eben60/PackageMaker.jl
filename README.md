# PackageMaker

GUI for [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl): "Creating new Julia packages, the easy way" - made a bit simpler.

This package allows you to create either a new package or a new project. It implements a subset of [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl) features (which hopefully cover >90% of its use cases) It also adds a couple of features of its own, e.g. ability to create Julia projects, or adding dependencies to project or packages being created, with more to come. Being a GUI app, it should be mostly self-explanatory, and external links for more information are provided from the GUI, too.

### Compatibility limitations

Currently may be [broken](https://github.com/Eben60/PackageMaker.jl/issues/1) if run from Julia in terminal on Ubuntu. 
**Worked however on same machine from Julia in VSCode.**

Was also broken on Win10 on Julia v1.10 both from terminal and VSCode, but **worked fine under Julia v1.11**.

No issues on Mac 🙂.

## Installation

It is recommended to install this package into a separate shared environment, e.g. one named `@PackageMaker`. The package [`ShareAdd`](https://github.com/Eben60/ShareAdd.jl) can help you with using shared environments.


```julia
julia> ]
(@v1.11) pkg> activate @PackageMaker
  Activating new project at `~/.julia/environments/PackageMaker`

(@PackageMaker) pkg> add PackageMaker
```

Before you start, make sure that you set up global `user.name`, `user.email`, as well as 
(in case you are to use GitHub-bound plugins) `github.user` in `git`.

## Usage

```julia
julia> ]
(@v1.11) pkg> activate @PackageMaker

julia> using PackageMaker

julia> gogui() 
```

Then fill out the GUI form and press "Submit". The project/package will be created. 

By default the function `gogui()` will exit Julia after a successfull finish. If such behavior is undesirable, call it as `gogui(false)`.
