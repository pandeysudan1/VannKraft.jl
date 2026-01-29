"""
    Trollheim Hydropower System Test
    
Simulates a complete hydropower plant with:
- Reservoir → Intake → SurgeTank → Penstock → Turbine → Tailrace
- Governor control via ramp input on turbine valve
"""

using VannKraft
using ModelingToolkit
using ModelingToolkitStandardLibrary
using ModelingToolkitStandardLibrary.Blocks
using OrdinaryDiffEq
using Plots

# ============================================================================
# Define the complete Trollheim system model
# ============================================================================

@mtkmodel Trollheim begin
    @description "Trollheim: Full hydropower plant with surge tank and governor ramp"
    
    @components begin
        # Water source reservoir
        res  = VannKraft.Reservoir(H = 50.0)
        
        # Intake penstock (intake tunnel)
        int  = VannKraft.Pipe(H = 20.0, L = 4500.0, D = 6.0)  
        
        # Surge tank for pressure transient damping
        st   = VannKraft.Surgetank(H = 80.0, L = 80.0, D = 4.0)                            
        
        # Main penstock (high head)
        pen  = VannKraft.Pipe(H = 300.0, L = 500.0, D = 4.0)    
        
        # Turbine with electronic governor
        tur  = VannKraft.Turbine(H_n = 370.0, Vdot_n = 40.0)                               
        
        # Discharge/tailrace penstock
        dis  = VannKraft.Pipe(H = 2.0, L = 600.0, D = 6.0)
        
        # Downstream tailrace reservoir
        tail = VannKraft.Reservoir(H = -5.0)                    
        
        # Electronic governor: ramp control of turbine guide vane
        ramp = Blocks.Ramp(height = 0.45, duration = 5.0, 
                          offset = 0.5, start_time = 500.0)
    end

    @equations begin
        # Connect hydraulic components in series
        connect(res.r,  int.a)
        connect(int.b,  st.a)
        connect(st.b,   pen.a)
        connect(pen.b,  tur.a)
        connect(tur.b,  dis.a)
        connect(dis.b, tail.r)
        
        # Connect governor output to turbine valve
        connect(ramp.output, tur.U_V)
    end
end

# ============================================================================
# Simulation Setup and Execution
# ============================================================================

function run_trollheim_simulation()
    println("=" ^ 70)
    println("Trollheim Hydropower System Simulation")
    println("=" ^ 70)
    
    # Instantiate the model
    @named trollheim = Trollheim()
    println("✓ Model instantiated: Trollheim")
    
    # Compile to ODESystem
    sys = mtkcompile(trollheim)
    println("✓ System compiled")
    
    # Initial conditions
    #   - Surge tank water level: 70 m
    #   - Turbine volumetric flow: 22 m³/s
    #   - Surge tank flow: 0 m³/s (steady initial state)
    u0 = [
        sys.tur.Vdot => 22.0,
        sys.st.h => 70.0,
        sys.st.Vdot => 0.0,
    ]
    
    # Time span: 0 to 1000 seconds
    tspan = (0.0, 1000.0)
    
    # Create ODE problem
    prob = ODEProblem(sys, u0, tspan)
    println("✓ ODE problem created")
    println("  Time span: $(tspan[1]) to $(tspan[2]) seconds")
    println("  Initial surge tank level: 70 m")
    
    # Solve using RK4 (reliable for stiff hydraulic systems)
    println("⏳ Solving ODE system...")
    sol = solve(prob, RK4(), dt = 0.1, saveat = 1.0)
    println("✓ Solution completed ($(length(sol.t)) time points)")
    
    return sys, sol
end

# ============================================================================
# Plotting Results
# ============================================================================

function plot_trollheim_results(sys, sol)
    println("\n" ^ 2)
    println("=" ^ 70)
    println("Results and Analysis")
    println("=" ^ 70)
    
    # Extract key variables
    t = sol.t
    h_st = sol[sys.st.h]           # Surge tank water level [m]
    mdot_pen = sol[sys.pen.mdot]   # Penstock flow [kg/s]
    p_tur_in = sol[sys.tur.Δp]     # Turbine pressure drop [Pa]
    η_tur = sol[sys.tur.η]         # Turbine efficiency
    
    # Create plots
    p1 = plot(t, h_st, 
        title = "Surge Tank Water Level", 
        xlabel = "Time [s]", 
        ylabel = "Height [m]",
        xlim = (0, 1000),
        linewidth = 2.5,
        legend = false)
    
    p2 = plot(t, mdot_pen ./ 1000,  # Convert kg/s to metric tonnes/s
        title = "Penstock Mass Flow Rate",
        xlabel = "Time [s]",
        ylabel = "Flow [1000 kg/s]",
        xlim = (0, 1000),
        linewidth = 2.5,
        legend = false)
    
    p3 = plot(t, p_tur_in ./ 1e5,   # Convert Pa to bar
        title = "Turbine Pressure Drop",
        xlabel = "Time [s]",
        ylabel = "Pressure [bar]",
        xlim = (0, 1000),
        linewidth = 2.5,
        legend = false)
    
    p4 = plot(t, η_tur,
        title = "Turbine Efficiency",
        xlabel = "Time [s]",
        ylabel = "Efficiency [%]",
        xlim = (0, 1000),
        ylim = (0, 1.0),
        linewidth = 2.5,
        legend = false)
    
    # Combine subplots
    p = plot(p1, p2, p3, p4, layout = (2, 2), size = (1200, 800))
    
    println("\n📊 Plot generated: 4-panel system response")
    println("   - Surge tank level (shows surge tank damping effect)")
    println("   - Penstock flow (shows governor control)")
    println("   - Turbine pressure drop (shows head variation)")
    println("   - Turbine efficiency (shows operating point)")
    
    return p
end

# ============================================================================
# Summary Statistics
# ============================================================================

function print_summary_stats(sys, sol)
    t = sol.t
    h_st = sol[sys.st.h]
    mdot_pen = sol[sys.pen.mdot]
    
    println("\n" ^ 2)
    println("=" ^ 70)
    println("Summary Statistics")
    println("=" ^ 70)
    
    # Analyze surge tank response
    h_min, h_max = minimum(h_st), maximum(h_st)
    h_var = h_max - h_min
    
    println("\n🌊 SURGE TANK DYNAMICS")
    println("   Initial level:      $(h_st[1]:.2f) m")
    println("   Minimum level:      $(h_min:.2f) m")
    println("   Maximum level:      $(h_max:.2f) m")
    println("   Level variation:    $(h_var:.2f) m (surge damping effect)")
    
    # Analyze penstock flow (steady-state vs transient)
    mdot_ss = mdot_pen[end]  # Steady state (end of simulation)
    mdot_peak_idx = argmax(abs.(mdot_pen .- mdot_ss))
    
    println("\n💧 PENSTOCK FLOW")
    println("   Steady-state flow:  $(mdot_ss / 1000:.2f) × 10³ kg/s")
    println("   Peak transient:     $(mdot_pen[mdot_peak_idx] / 1000:.2f) × 10³ kg/s")
    println("   Transient amplitude: $(abs(mdot_pen[mdot_peak_idx] - mdot_ss) / 1000:.2f) × 10³ kg/s")
    
    println("\n✅ Simulation completed successfully!")
end

# ============================================================================
# Main Execution
# ============================================================================

if abspath(PROGRAM_FILE) == @__FILE__
    try
        sys, sol = run_trollheim_simulation()
        p = plot_trollheim_results(sys, sol)
        print_summary_stats(sys, sol)
        
        # Save plot
        savefig(p, "trollheim_response.png")
        println("\n📁 Plot saved to: trollheim_response.png")
        
    catch e
        println("\n❌ Error during simulation:")
        println(e)
        rethrow(e)
    end
end
