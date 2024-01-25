module GridVisualizeTools

import Colors
import ColorSchemes

using DocStringExtensions: SIGNATURES, TYPEDEF, TYPEDSIGNATURES
using StaticArraysCore: SVector
using GeometryBasics: Point

include("colors.jl")
export region_cmap, bregion_cmap, rgbtuple

include("extraction.jl")
export extract_visible_cells3D, extract_visible_bfaces3D

include("linearsimplex.jl")
export LinearSimplex, LinearSimplexIterator
export LinearEdge, LinearTriangle, LinearTetrahedron
export testloop

include("marching.jl")
include("marching_iterators.jl")
export marching_tetrahedra, marching_triangles


include("markerpoints.jl")
export markerpoints

include("planeslevels.jl")
export makeplanes, makeisolevels

end # module GridVisualizeTools
