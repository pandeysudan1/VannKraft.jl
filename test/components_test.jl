using VannKraft
using Test
using ModelingToolkit
using ModelingToolkitStandardLibrary
using SciCompDSL

@testset "Components: basic instantiation" begin
    @testset "Instantiation" begin
        @named res = VannKraft.Reservoir(H = 50.0)
        @test res isa VannKraft.HydroPort
        
        @named pipe = VannKraft.Pipe(H = 20.0, L = 4500.0, D = 6.0)
        @test pipe isa VannKraft.HydroPort
        
        @named st = VannKraft.Surgetank(H = 80.0, L = 80.0, D = 4.0)
        @test st isa VannKraft.HydroPort
        
        # Note: Turbine instantiation tests through trollheim_test
    end
end
