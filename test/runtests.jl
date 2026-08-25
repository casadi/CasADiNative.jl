using Test
import CasADiNative as ca

@testset "CasADiNative smoke test" begin
    x = ca.SX.sym("x")
    f = ca.Function("f", [x], [x^2 + 1])

    @test string(f(3.0)) == "10"
end
