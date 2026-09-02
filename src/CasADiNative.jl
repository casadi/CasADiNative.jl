module CasADiNative

using CasADi_jll
using CasADiJulia_jll

function __init__()
    # casadi discovers its plugin shared libraries via CASADI_PLUGIN_SEARCH_PATH
    # (NOT LD_LIBRARY_PATH). Point it at the JLL's lib dir, preserving any user value.
    libdir = dirname(CasADi_jll.libcasadi_path)
    sep = Sys.iswindows() ? ';' : ':'
    ENV["CASADI_PLUGIN_SEARCH_PATH"] = haskey(ENV, "CASADI_PLUGIN_SEARCH_PATH") ?
        string(libdir, sep, ENV["CASADI_PLUGIN_SEARCH_PATH"]) : libdir
end

# The handwritten ergonomics layer, spliced in from the artifact as a body: the
# JLL ships it stripped of its own `module CasADiNative` wrapper, because nesting
# a same-named module inside this one is legal Julia that silently swallows every
# export. Its own include() then picks the generated module up from the same
# artifact directory. The layer refers to this module by name, so this module has
# to stay CasADiNative.
include(CasADiJulia_jll.casadi_native_body)

end # module CasADiNative
