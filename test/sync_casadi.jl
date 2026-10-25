# Refresh the casadi-owned files from casadi: `julia test/sync_casadi.jl [tag | local checkout]`.
# Defaults to the casadi tag pinned by the CasADi_jll compat. src/ is the package front matter
# (casadi swig/julia/package); test/casadi holds casadi's Julia tests, package tests and examples.
using TOML

# casadi dir => destination in this repo
const DIRS = [
    "swig/julia/package" => joinpath(@__DIR__, "..", "src"),
    "test/julia" => joinpath(@__DIR__, "casadi", "test", "julia"),
    "docs/examples/julia" => joinpath(@__DIR__, "casadi", "docs", "examples", "julia"),
]

src = get(ARGS, 1, lstrip(TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))["compat"]["CasADi_jll"], '='))
if isdir(src)
    root = src
    label = "local $(readchomp(`git -C $root rev-parse HEAD`))"
else
    root = mktempdir()
    run(`git -c advice.detachedHead=false clone --quiet --depth 1 --branch $src --filter=blob:none --sparse https://github.com/casadi/casadi $root`)
    run(`git -C $root sparse-checkout set $(first.(DIRS))`)
    label = "casadi/casadi $src $(readchomp(`git -C $root rev-parse HEAD`))"
end

rm(joinpath(@__DIR__, "casadi"); force = true, recursive = true)
for (d, dest) in DIRS
    rm(dest; force = true, recursive = true)
    for f in readlines(`git -C $root ls-files -- $d`)  # tracked files only
        mkpath(dirname(joinpath(dest, relpath(f, d))))
        cp(joinpath(root, f), joinpath(dest, relpath(f, d)))
    end
end
write(joinpath(@__DIR__, "casadi", "SOURCE"), label * "\n")
println("synced src and test/casadi from ", label)
