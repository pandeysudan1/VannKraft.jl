using VannKraft
using Test
using ModelingToolkit
using OrdinaryDiffEq

@testset "VannKraft.jl" begin
    # Test 1: Component instantiation
    @testset "Component Instantiation" begin
        @test_nowarn Reservoir(H = 50.0)
        @test_nowarn Pipe(H = 20, L = 4500, D = 6)
        @test_nowarn Surgetank(H = 80, L = 80, D = 4)
        @test_nowarn Turbine(H_n = 370, Vdot_n = 40)
    end
    # Run the component unit tests
    include("components_test.jl")
    
    # Test 2: Trollheim system compilation
    @testset "Trollheim System" begin
        include("trollheim_test.jl")
        sys, sol = run_trollheim_simulation()
        
        # Verify solution is valid
        @test length(sol.t) > 10
        @test sol.t[1] == 0.0
        @test sol.t[end] == 1000.0
        @test all(isfinite.(sol.u))
    end
end
