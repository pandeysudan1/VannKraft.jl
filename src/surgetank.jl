@mtkmodel Surgetank begin
    @components begin
        a = HydroPort()
        b = HydroPort()
    end
    @extend FluidData()
    @parameters begin
        H = 80.0        # elevation difference [m]
        L = 80.0        # pipe length [m]
        D = 3.5          # diameter [m]
        ϵ = 1e-4         # roughness [m]
        A = π*D^2/4      # cross-sectional area [m^2]
    end
    @variables begin
        p(t)
        mdot(t)
        h(t)              # water level
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
        p ~ a.p
        a.p ~ b.p
        mdot ~ a.mdot + b.mdot
        Dt(m) ~ mdot
        Dt(M) ~ ρ*Vdot^2/A + F
        M ~ m * v
        m    ~ ρ * A * h
        v    ~ Vdot / A
        mdot ~ ρ * Vdot 
        F  ~  Fp - Fg - Fr
        Fp ~ (p-p_a) * A
        Fg ~ m*g
        Re ~ ρ * abs(v) * D / μ
        fD ~ darcy_factor(Re, D, ϵ)
        Fr ~ (1/8) * ρ * π * D * L * v * abs(v) * fD
    end
end