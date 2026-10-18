module CasADiNative

# The Windows CasADiSWIG_jll build lacks the wrapper's exports.
Sys.iswindows() && error("CasADiNative does not support Windows yet")

using CasADi_jll
using CasADiSWIG_jll
import LinearAlgebra
import OpenBLAS32_jll

function __init__()
    # Ipopt_jll needs LP64 BLAS behind libblastrampoline (same as Ipopt.jl).
    if !Base.any(lib -> lib.interface == :lp64, LinearAlgebra.BLAS.lbt_get_config().loaded_libs)
        LinearAlgebra.BLAS.lbt_forward(OpenBLAS32_jll.libopenblas_path)
    end
    # casadi finds its plugins via CASADI_PLUGIN_SEARCH_PATH; prepend the JLL's lib dir.
    libdir = dirname(CasADi_jll.libcasadi_path)
    sep = Sys.iswindows() ? ';' : ':'
    ENV["CASADI_PLUGIN_SEARCH_PATH"] = haskey(ENV, "CASADI_PLUGIN_SEARCH_PATH") ?
        string(libdir, sep, ENV["CASADI_PLUGIN_SEARCH_PATH"]) : libdir
end

# Ergonomics layer, shipped as a module body beside the generated casadi.jl.
include(CasADiSWIG_jll.casadi_native_body)

end # module CasADiNative
