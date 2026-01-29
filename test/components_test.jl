using VannKraft
using Test
using ModelingToolkit

@testset "Components: basic instantiation and connectivity" begin
    @testset "Instantiation" begin
        @test_nowarn Reservoir(H = 50.0)
        @test_nowarn Pipe(H = 20.0, L = 4500.0, D = 6.0)
        @test_nowarn Surgetank(H = 80.0, L = 80.0, D = 4.0)
        @test_nowarn Turbine(H_n = 370.0, Vdot_n = 40.0)
    end

    @testset "Simple connectivity/compile" begin
        @mtkmodel ComponentTest begin
            @components begin
                res  = Reservoir(H = 50.0)
                pen  = Pipe(H = 20.0, L = 100.0, D = 4.0)
            end
            @equations begin
                connect(res.r, pen.a)
            end
        end

        @test_nowarn @named ct = ComponentTest()
        sys = mtkcompile(ct)
        @test typeof(sys) <: ODESystem
    end
end
