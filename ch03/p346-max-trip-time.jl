include("utils.jl")
using  GLMakie,DataFrames,Pipe,PrettyTables,DataFramesMeta
using  StatsBase
using  GLM,AnovaGLM

desc=Stat2Table(346,"FunnelDrop","maxmize time ",[:Funnel,:Tube,:Time ])
data=@pipe load_rda(desc.name)#|>select(_,desc.feature)

# 1. pairplot
fig=plot_cor_group(data)#;save("./ch03/imgs/p346-max-trip-time-corplot.png",fig)

# 2. lm fitting

model=lm(@formula(Time~Funnel*Tube+Funnel^2+Tube^2),data)

#= 
  Time ~ 1 + Funnel + Tube + :(Funnel ^ 2) + :(Tube ^ 2) + Funnel & Tube

    Coefficients:
    ─────────────────────────────────────────────────────────────────────────────────
                        Coef.  Std. Error      t  Pr(>|t|)     Lower 95%   Upper 95%
    ─────────────────────────────────────────────────────────────────────────────────
    (Intercept)    -26.8         9.09938    -2.95    0.0039  -44.8258      -8.7742
    Funnel           3.13797     0.901403    3.48    0.0007    1.3523       4.92365
    Tube             4.48722     1.28788     3.48    0.0007    1.93594      7.03851
    Funnel ^ 2      -0.156905    0.0345533  -4.54    <1e-04   -0.225355    -0.0884552
    Tube ^ 2        -0.235278    0.0556281  -4.23    <1e-04   -0.345477    -0.125079
    Funnel & Tube    0.0671882   0.0317875   2.11    0.0367    0.00421748   0.130159
    ─────────────────────────────────────────────────────────────────────────────────
=#

# 3. plot residuals, qqnormal
fig=plot_residuals_qq(model)#;save("./ch03/imgs/p346-max-trip-time-res-qq.png",fig)

# 4. descision surface 
function plot_response_surface()
    xs = Vector(range(extrema(data[:,1])..., length=100))
    ys=  Vector(range(extrema(data[:,2])..., length=100))
    test = mapreduce(collect, hcat, Iterators.product(xs, ys));
    df=DataFrame(Funnel=test[1,:],Tube=test[2,:])
    zhat::Vector{Float64}=predict(model,df)
    fig,ax,plt=surface(test[1,:],test[2,:],zhat)
    #save("./ch03/imgs/p346-max-trip-time-response-surface.png",fig)
end
#plot_response_surface()




