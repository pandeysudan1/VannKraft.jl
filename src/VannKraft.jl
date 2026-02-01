module VannKraft

using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as Dt
using ModelingToolkitStandardLibrary
using ModelingToolkitStandardLibrary.Blocks
using DynamicQuantities

using SciCompDSL

# Submodules
include("hydraulics/Hydraulics.jl")
include("electrical/Electrical.jl")
include("control_system/ControlSystem.jl")
include("io_api/IOAPI.jl")

# Re-export main components and systems
using .Hydraulics
using .Electrical
using .ControlSystem
using .IOAPI

# Exports - Hydraulic components
export
	HydroPort,
	FluidData,
	darcy_factor,
	Pipe,
	Reservoir,
	Surgetank,
	Turbine,
	# Electrical components
	SwingGenerator,
	# Control system components
	Governor

end