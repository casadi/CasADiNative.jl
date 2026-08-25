# CasADiNative.jl

Native Julia bindings for [CasADi](https://casadi.org), without a Python bridge.

```julia
import CasADiNative as ca

x = ca.SX.sym("x")
f = ca.Function("f", [x], [x^2 + 1])
f(3.0) # 10
```

`CasADiNative` is a thin package shim. Its version-matched generated Julia
module and native wrapper are provided by `CasADiJulia_jll`, which in turn
depends on `CasADi_jll` for the CasADi core library and plugins.
