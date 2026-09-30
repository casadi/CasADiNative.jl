using CasADiNative
using Test

# Smoke tests. The exhaustive suite lives in the casadi repo (test/julia/*.jl);
# port it here as the package matures. These exercise the JLL load + plugin path.
@testset "CasADiNative" begin
    @testset "symbolics + casadi-faithful constructors" begin
        x = CasADiNative.MX.sym("x", 2)         # static method-style
        @test x isa CasADiNative.MX
        @test size(x) == (2, 1)
        y = sym(SX, "y")                      # exported `sym` + type
        @test y isa SX
        @test (y + 1.0) isa SX                # operators (global Base extensions)
        @test (x .* x) isa CasADiNative.MX       # broadcasting = elementwise
    end

    @testset "Function eval" begin
        a = SX.sym("a"); b = SX.sym("b")
        # Qualified: bare `Function` is Base.Function.
        f = CasADiNative.Function("f", [a, b], [a + b, a * b], ["a", "b"], ["s", "p"])
        r = f(2.0, 3.0)
        @test Float64(r[1]) == 5.0
        @test Float64(r[2]) == 6.0
    end

    @testset "nlpsol (native sqpmethod plugin)" begin
        x = MX.sym("x"); y = MX.sym("y")
        nlp = Dict("x" => vertcat(x, y), "f" => (x - 1)^2 + (y - 2)^2, "g" => x + y)
        # qpoases (sqpmethod's default QP solver) is not in the JLL.
        solver = nlpsol("s", "sqpmethod", nlp, Dict("qpsol" => "qrqp"))
        sol = solver(x0 = [0.0, 0.0], lbg = -Inf, ubg = Inf)
        v = value  # ensure symbol is exported
        @test sol["x"] isa DM
    end

    @testset "printing" begin
        x = SX.sym("x")
        f = CasADiNative.Function("f", [x], [x^2 + 1])
        @test string(f(3.0)) == "10"
    end

    @testset "no method ambiguities" begin
        @test isempty(Test.detect_ambiguities(CasADiNative; recursive = false))
    end
end
