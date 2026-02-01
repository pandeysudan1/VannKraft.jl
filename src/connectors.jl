@connector HydroPort begin
    p(t)
    mdot(t), [connect = Flow] 
end

@mtkmodel FluidData begin
    @parameters begin
        ρ = 1000.0
        g = 9.81
        p_a = 101325.0
        μ = 1e-3
    end
end

function darcy_factor(Re, D, ϵ)
    Re_l = 2100.0
    Re_t = 2300.0

    f_l(Re) = 64.0 / Re
    f_t(Re) = 1.0 / (2.0 * log10(ϵ/(3.7D) + 5.7/(Re^0.9)))^2

    if Re <= 0
        return 0.0
    elseif Re <= Re_l
        return f_l(Re)
    elseif Re < Re_t

        y1  = f_l(Re_l)
        y2  = f_t(Re_t)
        dy1 = -64.0 / (Re_l^2)

        δ   = 1e-3 * Re_t
        dy2 = (f_t(Re_t + δ) - f_t(Re_t - δ)) / (2δ)

        X = [
            Re_l^3  Re_l^2  Re_l  1.0
            Re_t^3  Re_t^2  Re_t  1.0
            3Re_l^2 2Re_l   1.0   0.0
            3Re_t^2 2Re_t   1.0   0.0
        ]
        Y = [y1, y2, dy1, dy2]

        k = X \ Y
        return k[1]*Re^3 + k[2]*Re^2 + k[3]*Re + k[4]
    else
        return f_t(Re)
    end
end

@register_symbolic darcy_factor(Re, D, ϵ)