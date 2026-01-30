using VannKraft
using ModelingToolkit
using ModelingToolkit: t_nounits as t, D_nounits as Dt
using SciCompDSL
using OrdinaryDiffEq
using ModelingToolkitStandardLibrary.Blocks
using Plots

@mtkmodel Trollheim begin
    @description "Reservoir → Intake → 
    SurgeTank → Penstock → Turbine (with ramp input) → Tailrace"
    @components begin
        res  = Reservoir(H = 50.0)
        int  = VannKraft.Pipe(H = 20,   L =4500.,  D = 6)  
        st   = Surgetank(H = 80, L = 80, D = 4)                            
        pen  = VannKraft.Pipe(H = 300, L = 500, D = 4)    
        tur  = Turbine(H_n = 370, Vdot_n = 40)                               
        dis  = VannKraft.Pipe(H = 2 , L = 600.,  D = 6)
        tail = Reservoir(H = -5)                    
        ramp = Blocks.Ramp(height = 0.45, duration 
            = 5, offset = 0.5, start_time = 500)                                   
    end

    @equations begin
        connect(res.r,  int.a)
        connect(int.b,  st.a)
        connect(st.b,   pen.a)
        connect(pen.b,  tur.a)
        connect(tur.b,  dis.a)
        connect(dis.b, tail.r)
        connect(ramp.output, tur.U_V)
    end
end
;
@named trollheim = Trollheim()
sys = mtkcompile(trollheim)
prob = ODEProblem(sys, [sys.tur.Vdot => 22,
        sys.st.h => 70, sys.st.Vdot => 0.],
    (0,1000))
sol = solve(prob)
plot(sol.t,sol[sys.st.h],
    title = "Surgetank water level - m", xlim=(0,1000) )