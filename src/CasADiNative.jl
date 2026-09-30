module CasADiNative

using CasADi_jll
using CasADiSWIG_jll

function __init__()
    # casadi finds its plugins via CASADI_PLUGIN_SEARCH_PATH; prepend the JLL's lib dir.
    libdir = dirname(CasADi_jll.libcasadi_path)
    sep = Sys.iswindows() ? ';' : ':'
    ENV["CASADI_PLUGIN_SEARCH_PATH"] = haskey(ENV, "CASADI_PLUGIN_SEARCH_PATH") ?
        string(libdir, sep, ENV["CASADI_PLUGIN_SEARCH_PATH"]) : libdir
end

# Ergonomics layer, shipped as a module body beside the generated casadi.jl.
include(CasADiSWIG_jll.casadi_native_body)

end # module CasADiNative
