# PackageMaker

GUI for [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl): "Creating new Julia packages, the easy way" - made a bit simpler.

This package allows you to create either a new package or a new project. It implements a subset of [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl) features (which hopefully cover >90% of its use cases). It also adds a couple of features of its own, e.g. ability to create Julia projects, or adding dependencies to project or packages being created, with more to come. Being a GUI app, it should be mostly self-explanatory, and external links for more information are provided from the GUI, too.



## Installation

It is recommended to install this package into a separate shared environment, e.g. one named `@PackageMaker`. The package [`ShareAdd.jl`](https://github.com/Eben60/ShareAdd.jl) can help you with using shared environments.


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

### Current issues

There may be a [problem](https://github.com/Eben60/PackageMaker.jl/issues/1) if run from Julia in terminal on Ubuntu 24, due to an upstream bug. 
If possible, in such a case run the package from VSCode, then it should work. Otherwise run the macro `@unsafe`, which would disable `Electron` 
sandboxing. To be on the safe side, make sure to terminate `Julia` after creating a package (which is actually the default behavior of `gogui()`).

```julia-repl
julia> @unsafe;
julia> gogui()
``` 

### Checking for updates

Starting with the `PackageMaker` version `v0.1.8`, on the startup of the package a check is performed whether a new version of it became avaliable. This feature is still experimental, and appears not always to work properly (possibly, if `PackageMaker` was imported throgh [`ShareAdd.jl`](https://github.com/Eben60/ShareAdd.jl)). 

You might find this function too intrusive. The public function `PackageMaker.updatecheck_settings` provides an interface to disable this feature or to change other  defaults. For details, get the function's help:

```julia-repl
help?> PackageMaker.updatecheck_settings
``` 
