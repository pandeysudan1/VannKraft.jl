module ControlSystem

using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as Dt
using ModelingToolkitStandardLibrary
using ModelingToolkitStandardLibrary.Blocks
using DynamicQuantities

# Governor and control components
include("governor.jl")

# Submodules for specialized control systems
include("statistics.jl")

# Exports
export
	Governor

end
