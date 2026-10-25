include("package.jl")

# casadi's Julia tests and examples, unmodified (sync_casadi.jl); CASADI_JL is a stub importing us.
const CASADI = joinpath(@__DIR__, "casadi")
const STUB = mktempdir()
write(joinpath(STUB, "CasADiNative.jl"), "import CasADiNative\n")
ENV["CASADI_JL"] = STUB

@testset "casadi test/julia" begin
    m = Module(:CasadiTests)
    # ipqp in CasADi 3.8.1 overflows a buffer on constrained QPs (fixed upstream).
    noipqp(ex) = ex isa Expr ? Expr(ex.head, (noipqp(a) for a in ex.args if ex.head != :vect || a != "ipqp")...) : ex
    Core.eval(m, :(include(p) = Base.include(basename(p) == "conic.jl" ? $noipqp : identity, $m, p)))
    Base.include(m, joinpath(CASADI, "test", "julia", "runtests.jl"))
end

# Examples needing what the JLLs or the host lack.
has_gcc() = !Sys.iswindows() && Sys.which("gcc") !== nothing
const REQUIRES = Dict(
    "chain_qp.jl" => () -> CasADiNative.C.has_conic("qpoases"),
    "simple_lp.jl" => () -> CasADiNative.C.has_conic("qpoases"),
    "c_code_generation.jl" => has_gcc,
    "nlp_codegen.jl" => has_gcc,
)

@testset "casadi examples" begin
    dir = joinpath(CASADI, "docs", "examples", "julia")
    for f in sort(filter(endswith(".jl"), readdir(dir)))
        @testset "$f" begin
            if !get(REQUIRES, f, () -> true)()
                @test_skip f
            else
                out = IOBuffer()
                cmd = `$(Base.julia_cmd()) --startup-file=no --project=$(Base.active_project()) $(joinpath(dir, f))`
                ok = success(pipeline(Cmd(cmd; dir = mktempdir()); stdout = out, stderr = out))
                ok || print(String(take!(out)))
                @test ok
            end
        end
    end
end
