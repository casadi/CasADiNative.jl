# Refresh test/casadi from casadi: `julia test/sync_casadi.jl [tag | local checkout]`.
# Defaults to the casadi tag pinned by the CasADi_jll compat.
using TOML

const SUBDIRS = ["test/julia", "docs/examples/julia"]
const DEST = joinpath(@__DIR__, "casadi")

src = get(ARGS, 1, lstrip(TOML.parsefile(joinpath(@__DIR__, "..", "Project.toml"))["compat"]["CasADi_jll"], '='))
if isdir(src)
    root = src
    label = "local $(readchomp(`git -C $root rev-parse HEAD`))"
else
    root = mktempdir()
    run(`git -c advice.detachedHead=false clone --quiet --depth 1 --branch $src --filter=blob:none --sparse https://github.com/casadi/casadi $root`)
    run(`git -C $root sparse-checkout set $SUBDIRS`)
    label = "casadi/casadi $src $(readchomp(`git -C $root rev-parse HEAD`))"
end

rm(DEST; force = true, recursive = true)
for d in SUBDIRS
    mkpath(dirname(joinpath(DEST, d)))
    cp(joinpath(root, d), joinpath(DEST, d))
end
write(joinpath(DEST, "SOURCE"), label * "\n")
println("synced test/casadi from ", label)
