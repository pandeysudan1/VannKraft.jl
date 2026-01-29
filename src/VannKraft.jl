module VannKraft

using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as Dt
using ModelingToolkitStandardLibrary

using SciCompDSL

# Interfaces / shared definitions
include("connectors.jl")

# Components
include("pipe.jl")
include("reservoir.jl")
include("surgetank.jl")
include("turbine.jl")
include("governor.jl")
include("generators.jl")

# Exports
export
	HydroPort,
	FluidData,
	darcy_factor,
	Pipe,
	Reservoir,
	Surgetank,
	Turbine,
	SwingGenerator
end