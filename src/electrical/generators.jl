@mtkmodel SwingGenerator begin
    @components begin
        s = MechanicalPort()
        P_ℓ = RealInput()      
        f_s = RealOutput()   
    end
    @parameters begin
        J = 2e5
        η_g = 0.99
        k_b = 1000.0
        p  = 12.
        ω_eps = 0.01
    end
    @variables begin
        K_a(t) = 0.
        W_dot_s(t)
        W_dot_f(t)
        W_dot_g(t)
    end
    @equations begin
        Dt(K_a) ~ W_dot_s - W_dot_f - W_dot_g
        K_a ~  1/2*J*s.ω^2
        W_dot_s ~ -s.τ*(s.ω+ω_eps) #consuming the generator's shaft power
        W_dot_f ~ 1/2*k_b*s.ω^2
        η_g ~ P_ℓ.u/W_dot_g
        f_s.u ~ (p/(4π))*s.ω
    end
end
