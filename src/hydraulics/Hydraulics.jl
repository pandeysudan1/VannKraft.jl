module Hydraulics

using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as Dt
using ModelingToolkitStandardLibrary
using ModelingToolkitStandardLibrary.Blocks
using DynamicQuantities

# Shared connectors and data types
include("connectors.jl")

# Hydraulic components
include("pipe.jl")
include("reservoir.jl")
include("surgetank.jl")
include("turbine.jl")

# Exports
export
	HydroPort,
	FluidData,
	darcy_factor,
	Pipe,
	Reservoir,
	Surgetank,
	Turbine

end
