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
# Temporary: the CasADiSWIG_jll 3.8.1+0 body shadows LinearAlgebra's dot/cross; drop them and extend.
import LinearAlgebra: dot, cross
const _OLD_BODY = !occursin("import LinearAlgebra: dot, cross", read(CasADiSWIG_jll.casadi_native_body, String))
_nodotcross(ex) = Meta.isexpr(ex, :function) && Meta.isexpr(ex.args[1], :call) && ex.args[1].args[1] == :dot ? nothing :
    ex isa Expr ? Expr(ex.head, (_nodotcross(a) for a in ex.args if a != QuoteNode(:cross))...) : ex
include(_OLD_BODY ? _nodotcross : identity, CasADiSWIG_jll.casadi_native_body)
if _OLD_BODY
    function dot(a::_Cat, b::Union{_Cat,Real})
        T = _catpromote((a, b))
        _restore(T, C.dot(_ascat(T, a), _ascat(T, b)))
    end
    dot(a::Real, b::_Cat) = dot(b, a)
    cross(a::T, b::T, dim::Integer...) where {T<:_Cat} = C.cross(a, b, dim...)
end

end # module CasADiNative
