# PackageMaker

GUI for [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl): "Creating new Julia packages, the easy way" - made a bit simpler.

This package allows you to create either a new package or a new project. It implements a subset of [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl) features (which subset hopefully covers >90% of its use cases). It also adds a couple of features of its own, e.g. ability to create Julia projects, or adding dependencies to project or packages being created. Being a GUI app, it should be mostly self-explanatory, and external links for more information are provided from the GUI, too.



## Installation

It is recommended to install this package into a separate shared environment, e.g. one named `@PackageMaker`. It is not advisable to install it into the default environment.


```julia
julia> ]
(@v1.11) pkg> activate @PackageMaker
  Activating new project at `~/.julia/environments/PackageMaker`

(@PackageMaker) pkg> add PackageMaker
```

The package [`ShareAdd.jl`](https://github.com/Eben60/ShareAdd.jl) can help you with using shared environments: For both installation and usage of `PackageMaker`, type:

```julia
julia> using ShareAdd
julia> @usingany PackageMaker
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

### Multiline fields

Some [`PkgTemplates.jl`](https://github.com/JuliaCI/PkgTemplates.jl) plugin arguments are expected to be a `Vector{String}`, and `PackageMaker` implements this using `textarea` fields, enabling multiline input. Due to a [technical issue](https://discourse.julialang.org/t/issue-with-setting-multiline-text-in-textarea-blink-jl/127512), multiline text cannot be filled in from a saved configuration. As a workaround, both newlines and commas, and combinations thereof are allowed as separators (and adjacent whitespaces are ignored). On reading from a saved configuration, the elements of a vector of strings will be separated by comma/whitespace combinations, e.g. a list of Julia versions for GitHubActions plugin would look like
```
1.6, 1.10, pre
```

In multiline fields, commas can be escaped by double-backslasch: `comma\\,connected` will be parsed as `"comma,connected"`

#### Packages to be added to project

For this multiline field everything said above about separators applies (except this field is not saved on saving a config). Additionaly keywords `using` and `import` as well as the suffix `.jl` will be ignored, making it easier to paste package lists copied from e.g. another package. Thus, the input below
```
using P1, P2
import P3
P4.jl, P5.jl
P6,
P7
```
will be successfully parsed as a list `"P1"` .. `"P7"`

### Saving configurations

It is possible to save a configuration for a later reuse. The configurations are saved with the help of [Preferences.jl](https://github.com/JuliaPackaging/Preferences.jl), which by default would save them into `LocalPreferences.toml` file next to the currently-active project. You can manually edit the file to e.g. delete some config.

Not saved are: Project/Package name, package info (docstring), and packages to be added to project/package, as these are specific to each project.

A configuration is saved and applied according to the following logic: Only those parameters which were changed respective to the default values are saved/applied. That means, you can independently save several configs, dealing with different aspects, then sequentially apply them. E.g. you can save in a config `"Lab user data"` only the user name/email specific to some context, and in a config `"Public documentation"` the `Documenter` plugin settings. Then you can apply them one after another, and you will have both.

This logics however (currently) differs in respect to the selection of "activated" state of all plugins. Each config saves selection state of **all** plugins, and applies all of them. In the example above, the plugins will be selected/unselected according to the state saved in the `"Public documentation"` config, if it was applied last.

### Checking for updates

On the startup of the package a check is performed whether a new version of it became available. This feature is still experimental, and appears not always to work properly (possibly, if `PackageMaker` was imported through `@usingany PackageMaker` macro of [`ShareAdd.jl`](https://github.com/Eben60/ShareAdd.jl)). 

You might find this function too intrusive. The public function `PackageMaker.updatecheck_settings` provides an interface to disable this feature or to change other  defaults. For details, get the function's help:

```julia-repl
help?> PackageMaker.updatecheck_settings
``` 

## Current issues

There may be a [problem](https://github.com/Eben60/PackageMaker.jl/issues/1) if run from Julia in terminal on Ubuntu 24, due to an upstream bug. 
If possible, in such a case run the package from VSCode, then it should work. Otherwise run the macro `@unsafe`, which would disable `Electron` 
sandboxing. To be on the safe side, make sure to terminate `Julia` after creating a package (which is actually the default behavior of `gogui()`).

```julia-repl
julia> @unsafe;
julia> gogui()
``` 
