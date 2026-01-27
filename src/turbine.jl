@mtkmodel Turbine begin
    @components begin
        a = HydroPort()
        b = HydroPort()
        U_V = Blocks.RealInput()
    end
    @extend FluidData()
    @parameters begin
        H_n = 460.
        Vdot_n = 23.4
        u_n = 0.95
        η_max = 0.92
        α = 3.0
        β = 0.25
        C_v = Vdot_n/(u_n*sqrt(ρ*g*H_n/p_a))
        u_v_min = 0
        u_v_max = 1
        Δp_eps = 1.0  
    end
    @variables begin
        Δp(t)
        mdot(t)
        Wdot_s(t)          
        η(t)              
        Vdot(t)              
        u_v(t)
    end

    @equations begin
        Δp ~ a.p - b.p
        0 ~ a.mdot + b.mdot
        mdot ~ a.mdot
        u_v ~ max(u_v_min, min(u_v_max, U_V.u))
        Wdot_s ~ η * Δp * Vdot 
        Δp ~ sign(Vdot)*Vdot^2/(Δp_eps+C_v^2*u_v^2)*p_a
        Vdot ~ mdot/ρ
        η ~ η_max*(1-exp(-α*(u_v-β)))  
    end
end