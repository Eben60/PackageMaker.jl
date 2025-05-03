@usingany Pkg, Coverage
Pkg.test("PackageMaker"; coverage=true)

srcfolder = normpath(@__DIR__, "../../src")
coverage = process_folder(srcfolder)

open("lcov.info", "w") do io
    LCOV.write(io, coverage)
end;

# clean_folder(".")