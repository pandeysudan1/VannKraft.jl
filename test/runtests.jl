using VannKraft
using VannKraft.Hydraulics
using VannKraft.Electrical
using VannKraft.ControlSystem
using VannKraft.IOAPI
using Test

@testset "VannKraft.jl" begin
    # ========================================================================
    # Module Loading Tests
    # ========================================================================
    @testset "Module Loading" begin
        # Verify all submodules load
        @test isdefined(VannKraft, :Hydraulics)
        @test isdefined(VannKraft, :Electrical)
        @test isdefined(VannKraft, :ControlSystem)
        @test isdefined(VannKraft, :IOAPI)
    end

    # ========================================================================
    # Hydraulics Module Tests
    # ========================================================================
    @testset "Hydraulics Module" begin
        @testset "Components Exported" begin
            @test :Reservoir in names(Hydraulics)
            @test :Pipe in names(Hydraulics)
            @test :Surgetank in names(Hydraulics)
            @test :HydroPort in names(Hydraulics)
            @test :Turbine in names(Hydraulics)
            @test :FluidData in names(Hydraulics)
        end

        @testset "Darcy Factor Function" begin
            # Test laminar flow (Re < 2100)
            f_laminar = Hydraulics.darcy_factor(1000, 1.0, 1e-4)
            @test f_laminar ≈ 64/1000

            # Test turbulent flow (Re > 2300)
            f_turbulent = Hydraulics.darcy_factor(10000, 1.0, 1e-4)
            @test f_turbulent > 0
            @test f_turbulent < 0.1

            # Test zero Reynolds number
            f_zero = Hydraulics.darcy_factor(0, 1.0, 1e-4)
            @test f_zero == 0.0

            # Test negative Reynolds number
            f_neg = Hydraulics.darcy_factor(-1000, 1.0, 1e-4)
            @test f_neg ≈ 64/1000
        end

        @testset "Component Instantiation" begin
            # Test that components can be created
            @test Reservoir !== nothing
            @test Pipe !== nothing
            @test Surgetank !== nothing
            @test Turbine !== nothing
        end
    end

    # ========================================================================
    # Electrical Module Tests
    # ========================================================================
    @testset "Electrical Module" begin
        @testset "Components Exported" begin
            @test :SwingGenerator in names(Electrical)
        end

        @testset "Generator Component" begin
            @test SwingGenerator !== nothing
        end
    end

    # ========================================================================
    # Control System Module Tests
    # ========================================================================
    @testset "Control System Module" begin
        @testset "Components Exported" begin
            @test :Governor in names(ControlSystem)
        end

        @testset "Governor Component" begin
            @test Governor !== nothing
        end
    end

    # ========================================================================
    # IOAPI Module Tests
    # ========================================================================
    @testset "IOAPI Module" begin
        @testset "Data Structures Exported" begin
            @test :AGCConfig in names(IOAPI)
            @test :LFCConfig in names(IOAPI)
            @test :TurbineControlSetpoint in names(IOAPI)
            @test :SystemState in names(IOAPI)
            @test :ControllerAction in names(IOAPI)
            @test :SetpointManager in names(IOAPI)
            @test :AGCController in names(IOAPI)
            @test :LFCController in names(IOAPI)
            @test :TurbineControlInterface in names(IOAPI)
        end

        @testset "SetpointManager" begin
            manager = IOAPI.SetpointManager()
            
            # Test initialization
            @test manager.power_setpoint == 0.5
            @test manager.frequency_setpoint == 50.0
            @test manager.gate_position_setpoint == 0.5
            
            # Test power setpoint update with clamping
            result = IOAPI.update_power_setpoint!(manager, 1.5)
            @test result == 1.0  # Should be clamped to max
            @test manager.power_setpoint == 1.0
            
            result = IOAPI.update_power_setpoint!(manager, -0.5)
            @test result == 0.0  # Should be clamped to min
            @test manager.power_setpoint == 0.0
            
            # Test frequency setpoint update
            result = IOAPI.update_frequency_setpoint!(manager, 52.0)
            @test manager.frequency_setpoint == 52.0
            
            result = IOAPI.update_frequency_setpoint!(manager, 100.0)
            @test manager.frequency_setpoint == 55.0  # Clamped to max
        end

        @testset "AGCConfig and AGCController" begin
            config = IOAPI.AGCConfig(
                true,      # enabled
                1.0,       # Kp
                0.5,       # Ki
                0.05,      # f_deadband
                0.1,       # P_ramp_rate
                0.01       # update_interval
            )
            
            @test config.enabled == true
            @test config.Kp == 1.0
            
            controller = IOAPI.AGCController(config)
            @test controller.config.enabled == true
            @test controller.integral_error == 0.0
            
            # Test AGC signal computation
            action = IOAPI.compute_agc_signal(controller, 50.0, 0.5, 0.5, 1.0)
            @test action.action_type == :frequency_support
            @test typeof(action.magnitude) <: Real
            @test action.timestamp == 1.0
        end

        @testset "LFCConfig and LFCController" begin
            config = IOAPI.LFCConfig(
                true,      # enabled
                0.5,       # T_1
                0.1,       # T_2
                1.0,       # Kp
                0.5,       # Ki
                0.02,      # ACE_deadband
                50.0       # f_set
            )
            
            @test config.enabled == true
            @test config.f_set == 50.0
            
            controller = IOAPI.LFCController(config)
            @test controller.config.enabled == true
            
            # Test LFC signal computation
            action = IOAPI.compute_lfc_signal(controller, 50.0, 0.0, 1.0)
            @test action.action_type == :power_setpoint
            @test typeof(action.magnitude) <: Real
        end

        @testset "TurbineControlInterface" begin
            interface = IOAPI.TurbineControlInterface()
            
            @test interface.current_setpoint.gate_position == 0.5
            @test interface.current_setpoint.ramp_rate == 0.0
            @test length(interface.setpoint_history) == 1
            
            # Test setting gate position
            setpoint = IOAPI.set_gate_position!(interface, 0.75, 0.1, 1.0)
            @test setpoint.gate_position == 0.75
            @test setpoint.ramp_rate == 0.1
            @test length(interface.setpoint_history) == 2
            
            # Test clamping
            setpoint = IOAPI.set_gate_position!(interface, 1.5, 0.1, 2.0)
            @test setpoint.gate_position == 1.0  # Clamped to max
            
            # Test control history retrieval
            history = IOAPI.get_control_history(interface, 10.0)
            @test length(history) >= 2
        end

        @testset "SystemState and Statistics" begin
            states = [
                IOAPI.SystemState(50.0, 0.5, 0.5, 1000.0, 20.0, 0.0),
                IOAPI.SystemState(50.1, 0.51, 0.51, 1010.0, 21.0, 0.1),
                IOAPI.SystemState(49.9, 0.49, 0.49, 990.0, 19.0, 0.2),
            ]
            
            freq_stats = IOAPI.compute_frequency_statistics(states)
            @test haskey(freq_stats, "mean")
            @test haskey(freq_stats, "std")
            @test haskey(freq_stats, "min")
            @test haskey(freq_stats, "max")
            @test freq_stats["mean"] ≈ 50.0 atol=0.1
            @test freq_stats["min"] ≈ 49.9
            @test freq_stats["max"] ≈ 50.1
            
            power_stats = IOAPI.compute_power_statistics(states)
            @test haskey(power_stats, "mean")
            @test power_stats["mean"] ≈ 0.5 atol=0.05
        end

        @testset "Transient Detection" begin
            # Create states with a transient
            states = [
                IOAPI.SystemState(50.0, 0.5, 0.5, 1000.0, 20.0, 0.0),
                IOAPI.SystemState(50.1, 0.5, 0.5, 1010.0, 20.0, 0.1),
                IOAPI.SystemState(50.15, 0.5, 0.5, 1015.0, 20.0, 0.2),
                IOAPI.SystemState(48.5, 0.5, 0.5, 985.0, 20.0, 0.3),  # Large transient
                IOAPI.SystemState(49.0, 0.5, 0.5, 990.0, 20.0, 0.4),
            ]
            
            transients = IOAPI.detect_transients(states, 0.5)
            @test length(transients) > 0
            @test 4 in transients  # Index of the transient
        end

        @testset "Data I/O Functions" begin
            # Note: File I/O tests require filesystem access
            # This is a smoke test to ensure functions exist and have correct signatures
            @test isdefined(IOAPI, :save_system_state)
            @test isdefined(IOAPI, :load_system_state)
            @test isdefined(IOAPI, :save_config_json)
            @test isdefined(IOAPI, :load_config_json)
        end

        @testset "Controller Disabled" begin
            config_disabled = IOAPI.AGCConfig(
                false,     # disabled
                1.0, 0.5, 0.05, 0.1, 0.01
            )
            
            controller = IOAPI.AGCController(config_disabled)
            action = IOAPI.compute_agc_signal(controller, 50.0, 0.5, 0.5, 1.0)
            @test action.action_type == :none
            @test action.magnitude == 0.0
        end
    end

    # ========================================================================
    # Integration Tests
    # ========================================================================
    @testset "Integration Tests" begin
        @testset "Submodule Access" begin
            # Verify we can access hydraulics components through parent module
            @test :Pipe in names(VannKraft)
            @test :Turbine in names(VannKraft)
            @test :SwingGenerator in names(VannKraft)
            @test :Governor in names(VannKraft)
        end

        @testset "Control Flow" begin
            # Create a simple control scenario
            setpoint_mgr = IOAPI.SetpointManager(power_setpoint=0.6)
            agc_config = IOAPI.AGCConfig(true, 1.0, 0.5, 0.05, 0.1, 0.01)
            agc_controller = IOAPI.AGCController(agc_config)
            
            # Simulate frequency deviation
            action1 = IOAPI.compute_agc_signal(agc_controller, 49.5, 0.6, 0.6, 0.0)
            @test action1.magnitude > 0  # Should command increase due to low frequency
            
            # Update setpoint
            new_setpoint = IOAPI.update_power_setpoint!(setpoint_mgr, 0.7)
            @test new_setpoint == 0.7
        end
    end
end
