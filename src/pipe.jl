@mtkmodel Pipe begin
    @components begin
        a = HydroPort()
        b = HydroPort()
    end
    @extend FluidData()
    @parameters begin
        H = 340.0        # elevation difference [m]
        L = 500.0        # pipe length [m]
        D = 4.0          # diameter [m]
        ϵ = 1e-4         # roughness [m]
        A = π*D^2/4      # cross-sectional area [m^2]
    end

    @variables begin
        Δp(t)
        mdot(t)
        M(t)             # momentum-like state
        F(t)             # net force
        m(t)             # mass of water in pipe
        v(t)             # mean velocity
        Vdot(t)          # volumetric flow rate
        Fp(t)            # pressure force
        Fg(t)            # gravity term
        Fr(t)            # friction term
        fD(t)            # Darcy factor
        Re(t)            # Reynolds number
    end

    @equations begin
        Δp ~ a.p - b.p
        0 ~ a.mdot + b.mdot
        mdot ~ a.mdot
        Dt(M) ~ F
        M ~ m * v
        m    ~ ρ * A * L
        v    ~ Vdot / A
        mdot ~ ρ * Vdot  
        F  ~ Fp + Fg - Fr
        Fp ~ Δp * A
        Fg ~ ρ * g * H * A
        Re ~ ρ * abs(v) * D / μ
        fD ~ darcy_factor(Re, D, ϵ)
        Fr ~ (1/8) * ρ * π * D * L * v * abs(v) * fD
    end
end