module Electrical

using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as Dt
using ModelingToolkitStandardLibrary
using ModelingToolkitStandardLibrary.Blocks
using DynamicQuantities

# Electrical components
include("generators.jl")

# Exports
export
	SwingGenerator

end
