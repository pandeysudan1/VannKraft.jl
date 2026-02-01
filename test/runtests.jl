using VannKraft
using Test

@testset "VannKraft.jl" begin
    # Test 1: Package loads successfully
    @testset "Package Loads" begin
        @test true  # If we got here, package loaded successfully
    end
    
    # Test 2: Main components are exported
    @testset "Components Exported" begin
        @test :Reservoir in names(VannKraft)
        @test :Pipe in names(VannKraft)
        @test :Surgetank in names(VannKraft)
        @test :HydroPort in names(VannKraft)
        @test :Turbine in names(VannKraft)
    end
    
    # Test 3: Utility functions exist
    @testset "Utility Functions" begin
        @test isdefined(VannKraft, :darcy_factor)
    end
end
