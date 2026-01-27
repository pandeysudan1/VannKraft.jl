@mtkmodel Governor begin
    @components begin
        f_s = RealInput() #aggregate shaft frequency
        P_sp = RealInput() #power set point
        u_g = RealOutput() #Gate actuation signal 
    end
    @parameters begin
        S_base = 150e5
        f_base = 50.
        T_gs    = 0.2
        T_ps    = 0.04
        T_δ     = 1.75
        δ       = 0.04
        σ       = 0.1
        f_ref   = 50
        u_g_min  = 0.0
        u_g_max  = 1.0
        du_g_min = 0.2
        du_g_max = 0.05
        u_g0  = 0.72151
        x_g0  = 0.0
        x_δ0  = 0.0
        y_δ0  = 0.0
    end
    @variables begin
        x_g(t)  = x_g0
        x_δ(t)  = x_δ0
        y_δ(t)  = y_δ0
        e(t)
        u_g_ref(t)
        du_cmd(t)
    end

    @equations begin
        u_g_ref ~ 0.92*P_sp.u/S_base + 0.028
        e ~ (f_ref - f_s.u)/f_base + σ*(u_g_ref - u_g.u) - y_δ
        T_ps*Dt(x_g) + x_g ~ e
        T_δ*Dt(Dt(x_δ)) + x_δ ~ δ*u_g.u
        Dt(y_δ) ~ δ*u_g.u - x_δ
        du_cmd ~ ifelse((u_g.u <= u_g_min) & (x_g < 0),
                        0.0,
                        ifelse((u_g.u >= u_g_max) & (x_g > 0),
                               0.0,
                               ifelse(x_g <= -du_g_min,
                                      -du_g_min,
                                      ifelse(x_g >= du_g_max,
                                             du_g_max,
                                             x_g))))
        Dt(u_g.u) ~ du_cmd / T_gs
    end
end