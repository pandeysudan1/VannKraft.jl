#!/usr/bin/env julia
# Quick validation script for VannKraft library

println("=" ^ 60)
println("VannKraft Library Validation")
println("=" ^ 60)

try
    # Test 1: Module Loading
    println("\n[1/5] Loading modules...")
    using VannKraft
    using VannKraft.Hydraulics
    using VannKraft.Electrical
    using VannKraft.ControlSystem
    using VannKraft.IOAPI
    println("    SUCCESS: All modules loaded")
    
    # Test 2: AGC Configuration
    println("\n[2/5] Testing AGC Controller...")
    config = IOAPI.AGCConfig(true, 1.0, 0.5, 0.05, 0.1, 0.01)
    controller = IOAPI.AGCController(config)
    action = IOAPI.compute_agc_signal(controller, 50.0, 0.5, 0.6, 1.0)
    println("    SUCCESS: AGC signal magnitude = ", action.magnitude)
    
    # Test 3: Setpoint Manager
    println("\n[3/5] Testing SetpointManager...")
    manager = IOAPI.SetpointManager()
    new_power = IOAPI.update_power_setpoint!(manager, 0.7)
    new_freq = IOAPI.update_frequency_setpoint!(manager, 51.0)
    println("    SUCCESS: Power = ", new_power, ", Frequency = ", new_freq)
    
    # Test 4: Turbine Control
    println("\n[4/5] Testing TurbineControlInterface...")
    interface = IOAPI.TurbineControlInterface()
    setpoint = IOAPI.set_gate_position!(interface, 0.75, 0.1, 1.0)
    history = IOAPI.get_control_history(interface, 10.0)
    println("    SUCCESS: Gate position = ", setpoint.gate_position, ", History entries = ", length(history))
    
    # Test 5: System Monitoring
    println("\n[5/5] Testing System Monitoring...")
    states = [
        IOAPI.SystemState(50.0, 0.5, 0.5, 1000.0, 20.0, 0.0),
        IOAPI.SystemState(50.1, 0.51, 0.51, 1010.0, 21.0, 0.1),
        IOAPI.SystemState(49.95, 0.49, 0.49, 995.0, 19.5, 0.2),
    ]
    freq_stats = IOAPI.compute_frequency_statistics(states)
    power_stats = IOAPI.compute_power_statistics(states)
    println("    SUCCESS: Freq mean = ", round(freq_stats["mean"], digits=2), 
            ", Power mean = ", round(power_stats["mean"], digits=2))
    
    println("\n" * "=" ^ 60)
    println("ALL TESTS PASSED!")
    println("=" ^ 60)
    exit(0)
    
catch e
    println("\nERROR: ", e)
    println("\nStacktrace:")
    Base.showerror(stderr, e, catch_backtrace())
    exit(1)
end
