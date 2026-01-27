@mtkmodel Reservoir begin
    @components begin
        r = HydroPort()
    end
    @extend FluidData()
    @parameters begin
        H = 46.5
    end
    @equations begin
        r.p ~ ρ*g*H + p_a
    end
end